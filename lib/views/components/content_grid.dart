import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/components/list_item.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';

import 'package:piwigo_ng/views/UploadGalleryViewPage.dart';
import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';


class ContentGrid extends StatefulWidget {
  ContentGrid({Key key,
    this.title, this.category, this.isAdmin, this.nbImages, this.isEditMode,
    @required this.selectedItems, @required this.setEditMode, @required this.loadMoreImages,
    @required this.selectItem, @required this.deselectItem, @required this.onImageTap,
  }) : super(key: key);
  final bool isAdmin;
  final String title;
  final String category;
  final int nbImages;
  final Function(int) loadMoreImages;
  final Function(bool, {dynamic image}) setEditMode;
  final Function(dynamic) selectItem;
  final Function(dynamic) deselectItem;
  final Function(List<dynamic>, int) onImageTap;
  final bool isEditMode;
  final Map<int, dynamic> selectedItems;

  @override
  ContentGridState createState() => ContentGridState();
}
class ContentGridState extends State<ContentGrid> with SingleTickerProviderStateMixin {
  Future<Map<String,dynamic>> _albumsFuture;
  Future<Map<String,dynamic>> _imagesFuture;

  int _page;
  int _nbImages;
  List<dynamic> imageList = [];

  @override
  void initState() {
    _getData();
    super.initState();
    _page = 0;
    _nbImages = widget.nbImages ?? 0;
  }

  void _getData() {
    if (widget.category != null && widget.category.isNotEmpty) {
      _albumsFuture = fetchAlbums(widget.category);
    } else {
      _albumsFuture = Future<Map<String,dynamic>>.value({
        'stat': 'success',
        'result': {'categories': []}
      });
    }
    _imagesFuture = widget.loadMoreImages(0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isSelected(int id) {
    return widget.selectedItems.keys.contains(id);
  }
  // int _selectedPhotos() {
  //   return widget.selectedItems.length;
  // }

  showMore() async {
    _page++;
    var response = await widget.loadMoreImages(_page);
    if(response['stat'] == 'fail') {
      ScaffoldMessenger.of(context).showSnackBar(
          errorSnackBar(context, response['result'])
      );
    } else {
      var newListPage = response['result']['images'];
      imageList.addAll(newListPage);
    }
    setState(() {
      print('Fetch images of page $_page');
      // _getData();
    });
  }

  reloadData() async {
    imageList.clear();
    setState(() {
      _page = 0;
      _getData();
    });
  }

  openEditMode(dynamic image) {
    widget.setEditMode(true, image: image);
  }

  closeEditMode() {
    widget.setEditMode(false);
  }

  Future<void> _onRefresh() {
    setState(() {
      _page = 0;
      _getData();
    });
    return Future.delayed(Duration(milliseconds: 500));
  }

  handleAlbumSnapshot(AsyncSnapshot albumSnapshot) {
    var albums = albumSnapshot.data['result']['categories'];
    // int nbImages = _nbImages;
    if(albums.length > 0 && albums[0]["id"].toString() == widget.category) {
      // nbImages = albums[0]["total_nb_images"];
      // _nbImages = nbImages;
      _nbImages = albums[0]["total_nb_images"];
    }
    albums.removeWhere((category) =>
      (category["id"].toString() == widget.category)
    );
    return albums;
  }
  handleImagesSnapshot(AsyncSnapshot imagesSnapshot) {
    imageList.clear();
    imageList.addAll(imagesSnapshot.data['result']['images']);
    if (_nbImages == 0 && imagesSnapshot.data['result'].containsKey('paging')) {
      if (imagesSnapshot.data['result']['paging'].containsKey('total_count')) {
        if (imagesSnapshot.data['result']['paging']['total_count'] is String) {
          _nbImages = int.parse(imagesSnapshot.data['result']['paging']['total_count']);
        } else {
          _nbImages = imagesSnapshot.data['result']['paging']['total_count'];
        }
      } else {
        _nbImages = imagesSnapshot.data['result']['paging']['count'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return createFutureBuilders();
  }

  Widget createFutureBuilders() {
    return FutureBuilder<Map<String,dynamic>>(
        future: _albumsFuture, // Albums of the list
        builder: (BuildContext context, AsyncSnapshot albumSnapshot) {
          if (albumSnapshot.hasData) {
            if(albumSnapshot.data['stat'] == 'fail') {
              return Center(
                child: Text(appStrings(context).categoryImageList_noDataError),
              );
            }
            var albums = handleAlbumSnapshot(albumSnapshot);
            return FutureBuilder<Map<String,dynamic>>(
              future: _imagesFuture,
              builder: (BuildContext context, AsyncSnapshot imagesSnapshot) {
                if (imagesSnapshot.hasData) {
                  if (imageList.isEmpty || _page == 0) {
                    if(imagesSnapshot.data['stat'] == 'fail') {
                      return Center(child: Text(appStrings(context).categoryImageList_noDataError));
                    }
                    handleImagesSnapshot(imagesSnapshot);
                  }
                  return createPageContent(albums);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }

  Widget createUploadActionButton() {
    ThemeData _theme = Theme.of(context);
    return SpeedDial(
      spaceBetweenChildren: 10,
      childMargin: EdgeInsets.only(bottom: 17, right: 10),
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      closeManually: false,
      curve: Curves.bounceIn,
      backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
      foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
      overlayColor: Colors.black,
      elevation: 5.0,
      overlayOpacity: 0.5,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          elevation: 5,
          labelWidget: Text(appStrings(context).createNewAlbum_title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          child: Icon(Icons.create_new_folder),
          backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
          foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
          onTap: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CreateCategoryDialog(catId: widget.category);
                }
            ).whenComplete(() {
              setState(() {
                _getData();
              });
            });
          },
        ),
        SpeedDialChild(
            elevation: 5,
            labelWidget: Text(appStrings(context).categoryUpload_images, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            child: Icon(Icons.add_to_photos),
            backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
            foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
            onTap: () async {
              try {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(appStrings(context).loadingHUD_label),
                      CircularProgressIndicator(),
                    ],
                  ),
                  duration: Duration(days: 365),
                ));
                final List<XFile> images = ((await FilePicker.platform.pickFiles(
                  type: FileType.media,
                  allowMultiple: true,
                )) ?.files ?? []).map<XFile>((e) => XFile(e.path, name: e.name, bytes: e.bytes)).toList();
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                if(images.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UploadGalleryViewPage(imageData: images, category: widget.category)
                  )).whenComplete(() {
                    setState(() {
                      print('After upload'); // refresh
                    });
                  });
                }
              } catch (e) {
                print('${e.toString()}');
              }
            }
        ),
        SpeedDialChild(
            elevation: 5,
            labelWidget: Text(appStrings(context).categoryUpload_take, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            child: Icon(Icons.photo_camera_rounded),
            backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
            foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
            onTap: () async {
              try {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(appStrings(context).loadingHUD_label),
                      CircularProgressIndicator(),
                    ],
                  ),
                  duration: Duration(days: 365),
                ));
                final XFile image = await ImagePicker().pickImage(source: ImageSource.camera);
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                if(image != null) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UploadGalleryViewPage(imageData: [image], category: widget.category)
                  )).whenComplete(() {
                    setState(() {
                      print('After upload'); // refresh
                    });
                  });
                }
              } catch (e) {
                print('Dio error ${e.toString()}');
              }
            }
        ),
      ],
    );
  }

  Widget createPageContent(dynamic albums) {
    ThemeData _theme = Theme.of(context);

    int albumCrossAxisCount = MediaQuery.of(context).size.width <= Constants.albumMinWidth ? 1
        : (MediaQuery.of(context).size.width/Constants.albumMinWidth).round();

    return RefreshIndicator(
      displacement: 20,
      notificationPredicate: (notification) {
        return notification.metrics.atEdge;
      },
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            albums.length > 0 ?
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: albumCrossAxisCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: albumGridAspectRatio(context),
              ),
              padding: EdgeInsets.all(10),
              itemCount: albums.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var album = albums[index];
                return AlbumListItem(album,
                  isAdmin: widget.isAdmin,
                  onClose: () {
                    setState(() {
                      _getData();
                    });
                  },
                  onOpen: closeEditMode,
                );
              },
            ) : Center(),
            imageList.length > 0 ?
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: getImageCrossAxisCount(context),
                mainAxisSpacing: 3.0,
                crossAxisSpacing: 3.0,
              ),
              padding: EdgeInsets.symmetric(horizontal: 5),
              itemCount: imageList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var image = imageList[index];
                return InkWell(
                  onLongPress: widget.isEditMode ? () {
                    setState(() {
                      _isSelected(image['id']) ?
                      widget.deselectItem(image) :
                      widget.selectItem(image);
                    });
                  } : widget.isAdmin ? () {
                    openEditMode(image);
                  } : () {},
                  onTap: () {
                    widget.isEditMode ?
                      _isSelected(image['id']) ?
                      widget.deselectItem(image) :
                      widget.selectItem(image) :
                      widget.onImageTap(imageList, index);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: _isSelected(image['id']) ?
                      Border.all(width: 5, color: _theme.colorScheme.primary) :
                      Border.all(width: 0, color: Colors.white),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.network(imageList[index]["derivatives"][API.prefs.getString('thumbnail_size')]["url"],
                            fit: BoxFit.cover,
                          ),
                        ),
                        _isSelected(image['id']) ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Color(0x80000000),
                        ) : Center(),
                        /*
                        widget.isEditMode? Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: _isSelected(image['id']) ?
                              Icon(Icons.check_circle, color: _theme.floatingActionButtonTheme.backgroundColor) :
                              Icon(Icons.check_circle_outline, color: _theme.disabledColor),
                          ),
                        ) : Center(),

                         */
                        API.prefs.getBool('show_thumbnail_title')? Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            color: Color(0x80ffffff),
                            child: AutoSizeText('${image['name']}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 12),
                              maxFontSize: 14, minFontSize: 7,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ) : Center(),
                      ],
                    ),
                  ),
                );
              },
            ) : Center(),
            _nbImages > (_page+1)*100 ? GestureDetector(
              onTap: () {
                showMore();
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(appStrings(context).showMore(_nbImages-((_page+1)*100)), style: TextStyle(fontSize: 14, color: _theme.disabledColor)),
                  ],
                ),
              ),
            ) : Center(),
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text(appStrings(context).imageCount(_nbImages), style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color, fontWeight: FontWeight.w300)),
              ),
            )
          ],
        ),
      ),
    );
  }
}