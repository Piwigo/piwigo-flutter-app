import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:images_picker/images_picker.dart';
import 'dart:async';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/MoveAlbumService.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/components/Dialogs.dart';
import 'package:piwigo_ng/views/components/ListItems.dart';
import 'package:piwigo_ng/views/components/SnackBars.dart';

import 'ImageViewPage.dart';
import 'UploadGalleryViewPage.dart';


class CategoryViewPage extends StatefulWidget {
  CategoryViewPage({Key key, this.title, this.category, this.isAdmin, this.nbImages}) : super(key: key);
  final bool isAdmin;
  final String title;
  final String category;
  final int nbImages;

  @override
  _CategoryViewPageState createState() => _CategoryViewPageState();
}

class _CategoryViewPageState extends State<CategoryViewPage> with SingleTickerProviderStateMixin {
  bool _isEditMode;
  int _page;
  int _nbImages;
  Map<int, dynamic> _selectedItems = Map();
  ScrollController _controller = ScrollController();
  List<dynamic> imageList = [];

  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _page = 0;
    _nbImages = widget.nbImages;
    _isEditMode = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isSelected(int id) {
    return _selectedItems.keys.contains(id);
  }
  int _selectedPhotos() {
    return _selectedItems.length;
  }

  showMore() async {
    _page++;
    var response = await fetchImages(widget.category, _page);
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
    });
  }
  openEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }
  closeEditMode() {
    setState(() {
      _isEditMode = false;
    });
    _selectedItems.clear();
  }


  Future<void> onRefresh() {
    setState(() {
      _page = 0;
    });
    return Future.delayed(Duration(milliseconds: 500));
  }

  handleAlbumSnapshot(AsyncSnapshot albumSnapshot, int nbImages) {
    if(albumSnapshot.data['stat'] == 'fail') {
      return Center(child: Text(appStrings(context).categoryMainEmtpy));
    }
    var albums = albumSnapshot.data['result']['categories'];
    int nbImages = _nbImages;
    if(albums.length > 0 && albums[0]["id"].toString() == widget.category) {
      nbImages = albums[0]["total_nb_images"];
      _nbImages = nbImages;
    }
    albums.removeWhere((category) =>
    (category["id"].toString() == widget.category)
    );
    return albums;
  }
  handleImagesSnapshot(AsyncSnapshot imagesSnapshot) {
    imageList.clear();
    imageList.addAll(imagesSnapshot.data['result']['images']);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: createListeners(
        NestedScrollView(
          controller: _controller,
          headerSliverBuilder: (context, innerBoxScrolled) => [
            createAppBar(),
          ],
          body: createFutureBuilders(),
        ),
      ),
      floatingActionButton: _isEditMode ?
        Center() : createFloatingActionButton(),
      bottomNavigationBar: _isEditMode ?
        createBottomBar() : Container(height: 0),
    );
  }

  Widget createAppBar() {
    ThemeData _theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      snap: false,
      floating: false,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: _theme.iconTheme.color,//change your color here
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.chevron_left),
      ),
      title: _isEditMode ?
      Text("${_selectedPhotos()}", overflow: TextOverflow.fade, softWrap: true) :
      Text(widget.title),
      actions: [
        _isEditMode ? IconButton(
          onPressed: closeEditMode,
          icon: Icon(Icons.cancel),
        ) : widget.isAdmin? IconButton(
          onPressed: openEditMode,
          icon: Icon(Icons.touch_app),
        ) : Container(),
      ],
    );
  }

  Widget createListeners(Widget child) {
    return WillPopScope(
      onWillPop: () async {
        if(_isEditMode) {
          closeEditMode();
          return false;
        }
        return true;
      },
      child: GestureDetector(
        /*
        onScaleStart: (details) {
          _scaleFactor = getImageCrossAxisCount(context).toDouble();
          _baseScaleFactor = _scaleFactor;
        },
        onScaleUpdate: (details) {
          setState(() {
            _scaleFactor = _baseScaleFactor / details.scale;
            setImageCrossAxisCount(context, _scaleFactor.ceil().toDouble());
          });
        },
        */
        child: child,
      ),
    );
  }

  Widget createFutureBuilders() {
    return FutureBuilder<Map<String,dynamic>>(
        future: fetchAlbums(widget.category), // Albums of the list
        builder: (BuildContext context, AsyncSnapshot albumSnapshot) {
          if (albumSnapshot.hasData) {
            int nbImages = _nbImages;
            var albums = handleAlbumSnapshot(albumSnapshot, nbImages);
            // print(albums);
            return FutureBuilder<Map<String,dynamic>>(
                future: fetchImages(widget.category, 0), // Images of the list
                builder: (BuildContext context, AsyncSnapshot imagesSnapshot) {
                  if (imagesSnapshot.hasData) {
                    if (imageList.isEmpty || _page == 0) {
                      if(imagesSnapshot.data['stat'] == 'fail') {
                        return Center(child: Text(appStrings(context).categoryImageList_noDataError));
                      }
                      handleImagesSnapshot(imagesSnapshot);
                    }
                    return createPageContent(albums, nbImages);
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
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
      childMargin: EdgeInsets.only(bottom: 17, right: 10),
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      closeManually: false,
      curve: Curves.bounceIn,
      backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
      foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
      elevation: 8.0,
      overlayOpacity: 0.1,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          labelWidget: Text(appStrings(context).createNewAlbum_title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _theme.buttonColor)),
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
                print('refresh');
              });
            });
          },
        ),
        SpeedDialChild(
            labelWidget: Text(appStrings(context).categoryUpload_images, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _theme.buttonColor)),
            child: Icon(Icons.add_a_photo),
            backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
            foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
            onTap: () async {
              try {
                List<Asset> imageList = await MultiImagePicker.pickImages(
                  maxImages: 100,
                  enableCamera: true,
                  cupertinoOptions: CupertinoOptions(takePhotoIcon: 'chat'),
                  materialOptions: MaterialOptions(
                    actionBarTitle: 'Piwigo',
                    allViewTitle: appStrings(context).all_Photos,
                    actionBarColor: '#ffff7700',
                    actionBarTitleColor: '#ffeeeeee',
                    lightStatusBar: false,
                    statusBarColor: '#ffab40',
                    startInAllView: false,
                    selectCircleStrokeColor: '#ffffff',
                    selectionLimitReachedText: appStrings(context).selectLimit,
                  ),
                );
                if(imageList.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UploadGalleryViewPage(imageData: imageList, category: widget.category)
                  ));
                }
              } catch (e) {
                print('Dio error ${e.toString()}');
              }
            }
        ),
        SpeedDialChild(
            labelWidget: Text(appStrings(context).categoryUpload_videos, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _theme.buttonColor)),
            child: Icon(Icons.video_collection_rounded),
            backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
            foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
            onTap: () async {
              try {
                List<Media> res = await ImagesPicker.pick(
                  count: 100,
                  pickType: PickType.video,
                  quality: 0.8,
                );
                print(res[0].path);
                List<Asset> imageList = res.map((media) => Asset(media.path, media.path.split('/').last, media.size.ceil(), media.size.ceil())).toList();
                if(imageList.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UploadGalleryViewPage(imageData: imageList, category: widget.category)
                  ));
                }
              } catch (e) {
                print('Dio error ${e.toString()}');
              }
            }
        ),
      ],
    );
  }

  Widget createPageContent(dynamic albums, int nbImages) {
    ThemeData _theme = Theme.of(context);
    return RefreshIndicator(
      displacement: 20,
      notificationPredicate: (notification) {
        return notification.metrics.atEdge;
      },
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            albums.length > 0 ?
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isPortrait(context)? 1 : 2,
                mainAxisSpacing: 3,
                crossAxisSpacing: 5,
                childAspectRatio: albumGridAspectRatio(context),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5),
              itemCount: albums.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var album = albums[index];
                if (isPortrait(context) || index%2 == 0) {
                  return albumListItem(context, album, widget.isAdmin, (message) {
                    setState(() {
                      print('$message');
                    });
                  });
                }
                return albumListItemRight(context, album, widget.isAdmin, (message) {
                  setState(() {
                    print('$message');
                  });
                });
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
                  onLongPress: _isEditMode ? () {
                    setState(() {
                      _isSelected(image['id']) ?
                      _selectedItems.remove(image['id']) :
                      _selectedItems.putIfAbsent(image['id'], () => image);
                    });
                  } : widget.isAdmin ? () {
                    setState(() {
                      _isEditMode = true;
                      _selectedItems.putIfAbsent(image['id'], () => image);
                    });
                  } : () {},
                  onTap: () {
                    _isEditMode ?
                    setState(() {
                      _isSelected(image['id']) ?
                      _selectedItems.remove(image['id']) :
                      _selectedItems.putIfAbsent(image['id'], () => image);
                    }) :
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ImageViewPage(
                        images: imageList,
                        index: index,
                        isAdmin: widget.isAdmin,
                        category: widget.category,
                      )),
                    ).whenComplete(() {
                      setState(() {});
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: _isSelected(image['id']) ?
                      Border.all(width: 5, color: _theme.accentColor) :
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
                        _isEditMode? Align(
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
            nbImages > (_page+1)*100 ? GestureDetector(
              onTap: () {
                showMore();
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(appStrings(context).showMore(nbImages-((_page+1)*100)), style: TextStyle(fontSize: 14, color: _theme.disabledColor)),
                  ],
                ),
              ),
            ) : Center(),
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text(appStrings(context).imageCount(nbImages), style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color, fontWeight: FontWeight.w300)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget createBottomBar() {
    ThemeData _theme = Theme.of(context);
    return BottomNavigationBar(
      onTap: (index) async {
        switch (index) {
          case 0:
            if(_selectedItems.length > 0) {
              print('Edit: ${_selectedItems.keys}');
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EditImageSelectionDialog(
                      catId: int.parse(widget.category),
                      images: _selectedItems.values.toList(),
                    );
                  }
              ).whenComplete(() {
                print('Edited ${_selectedItems.length} images');
                setState(() {
                  _selectedItems.clear();
                  _isEditMode = false;
                });
              });
            }
            break;
          case 1:
            if(_selectedItems.length > 0) {
              if(await confirmDownloadDialog(context,
                content: appStrings(context).downloadImage_title(_selectedItems.length),
              )) {
                print('Download ${_selectedItems.keys.toList()}');

                List<dynamic> selection = [];
                selection.addAll(_selectedItems.values.toList());

                setState(() {
                  _isEditMode = false;
                  _selectedItems.clear();
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appStrings(context).downloadingImages(selection.length)),
                      CircularProgressIndicator(),
                    ],
                  ),
                ));

                await downloadImages(selection);
              }
            }
            break;
          case 2:
            if(_selectedItems.length > 0) {
              print('Move ${_selectedItems.keys}');
              await moveCategoryModalBottomSheet(context,
                widget.category,
                widget.title,
                true,
                (item) async {
                  int result = await confirmMoveAssignImage(context,
                    content: appStrings(context).moveImage_message(_selectedItems.length, "", item.name),
                  );
                  print(result);
                  if (result == 0) {
                    print('Move selection to ${item.id}');
                    int nbMoved = await moveImages(context,
                      _selectedItems.values.toList(),
                      int.parse(item.id)
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      imagesMovedSnackBar(context, nbMoved)
                    );
                    Navigator.of(context).pop();
                  } else if (result == 1) {
                    print('Assign selection to ${item.id}');
                    int nbAssigned = await assignImages(context,
                      _selectedItems.values.toList(),
                      int.parse(item.id)
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      imagesAssignedSnackBar(context, nbAssigned)
                    );
                    Navigator.of(context).pop();
                  }
                },
              );
              setState(() {
                _isEditMode = false;
                _selectedItems.clear();
              });
            }
            break;
          case 3:
            if(_selectedItems.length > 0) {
              if(await confirmDeleteDialog(context,
                content: appStrings(context).deleteImageCount_title(_selectedItems.length),
              )) {
                print('Delete ${_selectedItems.keys}');

                List<int> selection = [];
                selection.addAll(_selectedItems.keys.toList());

                setState(() {
                  _isEditMode = false;
                  _selectedItems.clear();
                });

                int nbSuccess = await deleteImages(context, selection);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(appStrings(context).deleteImageSuccess_message(nbSuccess)),
                ));
                setState(() {});
              }
            }
            break;
          default:
            break;
        }
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.edit, color: _theme.iconTheme.color),
          label: appStrings(context).imageOptions_edit,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download_rounded, color: _theme.iconTheme.color),
          label: appStrings(context).imageOptions_download,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.reply_outlined, color: _theme.iconTheme.color),
          label: appStrings(context).moveImage_title,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.delete_outline, color: _theme.errorColor),
          label: appStrings(context).deleteImage_delete,
        ),
      ],
      backgroundColor: _theme.scaffoldBackgroundColor,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 14,
      unselectedFontSize: 14,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: 0,
    );
  }

  Widget createFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          widget.isAdmin? Align(
            alignment: Alignment.bottomRight,
            child: createUploadActionButton(),
          ) : Container(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(bottom: 0, right: widget.isAdmin? 70 : 0),
              child: FloatingActionButton(
                backgroundColor: Color(0xaa868686),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Icon(Icons.home, color: Colors.grey.shade200, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}