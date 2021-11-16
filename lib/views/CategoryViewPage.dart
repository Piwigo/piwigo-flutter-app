import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:images_picker/images_picker.dart';
import 'dart:async';

import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/components/list_item.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';

import 'package:piwigo_ng/views/ImageViewPage.dart';
import 'package:piwigo_ng/views/UploadGalleryViewPage.dart';
import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';


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

  // TODO: zoom in/out grid
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

  Future<void> _onRefresh() {
    setState(() {
      _page = 0;
    });
    return Future.delayed(Duration(milliseconds: 500));
  }

  void _onEditSelection() async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EditImagesPage(
          catId: int.parse(widget.category),
          images: _selectedItems.values.toList(),
        ))
    );
  }
  void _onDownloadSelection() async {
    if (await confirmDownloadDialog(context,
      content: appStrings(context)
          .downloadImage_title(_selectedItems.length),
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
  void _onMoveCopySelection() async {
    int choice = await chooseMoveCopyImage(context,
      content: appStrings(context).moveOrCopyImage_title(_selectedItems.length)
    );

    switch(choice) {
      case 0: showDialog(context: context,
          builder: (context) {
            return MoveOrCopyDialog(
              title: appStrings(context).moveImage_title,
              subtitle: appStrings(context).moveImage_selectAlbum(_selectedItems.length, ''),
              catId: widget.category,
              catName: widget.title,
              isImage: true,
              onSelected: (item) async {
                if( await confirmMoveDialog(context,
                  content: appStrings(context).moveImage_message(_selectedItems.length, "", item.name),
                )) {
                  int nbMoved = await moveImages(context,
                      _selectedItems.values.toList(),
                      int.parse(item.id)
                  );
                  ScaffoldMessenger.of(context).showSnackBar(imagesMovedSnackBar(context, nbMoved));
                  Navigator.of(context).pop();
                }
              },
            );
          }
        ).whenComplete(() {
          setState(() {
            _selectedItems.clear();
            _isEditMode = false;
          });
        });
        break;
      case 1: showDialog(context: context,
          builder: (context) {
            return MoveOrCopyDialog(
              title: appStrings(context).copyImage_title,
              subtitle: appStrings(context).copyImage_selectAlbum(_selectedItems.length, ''),
              catId: widget.category,
              catName: widget.title,
              isImage: true,
              onSelected: (item) async {
                if( await confirmAssignDialog(context,
                  content: appStrings(context).copyImage_message(_selectedItems.length, "", item.name),
                )) {
                  int nbCopied = await assignImages(context,
                      _selectedItems.values.toList(),
                      int.parse(item.id)
                  );
                  ScaffoldMessenger.of(context).showSnackBar(imagesAssignedSnackBar(context, nbCopied));
                  Navigator.of(context).pop();
                }
              },
            );
          }
        ).whenComplete(() {
          setState(() {
            _selectedItems.clear();
            _isEditMode = false;
          });
        });
        break;
      default: break;
    }
  }
  void _onDeleteSelection() async {
    int choice = await confirmRemoveImagesFromAlbumDialog(context,
      content: appStrings(context).deleteImage_message(_selectedItems.length),
      count: _selectedItems.length,
    );
    if(choice != -1) {
      List<int> selection = [];
      selection.addAll(_selectedItems.keys.toList());

      setState(() {
        _isEditMode = false;
        _selectedItems.clear();
      });

      int nbSuccess = 0;
      switch(choice) {
        case 0: nbSuccess = await deleteImages(context, selection);
        break;
        case 1: nbSuccess = await removeImages(context, selection, widget.category);
        break;
        default: break;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(appStrings(context).deleteImageSuccess_message(nbSuccess)),
      ));

      setState(() {});
    }
  }

  void _onSelectAll() {
    setState(() {
      if(_selectedItems.length == imageList.length) {
        _selectedItems.clear();
      } else {
        imageList.forEach((image) {
          _selectedItems.putIfAbsent(image['id'], () => image);
        });
      }
    });
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
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
        color: _theme.iconTheme.color,
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
          onPressed: _onSelectAll,
          icon: _selectedItems.length == imageList.length ?
            Icon(Icons.check_circle) : Icon(Icons.circle_outlined),
        ) : SizedBox(),
        _isEditMode ? IconButton(
          onPressed: closeEditMode,
          icon: Icon(Icons.cancel),
        ) : widget.isAdmin? IconButton(
          onPressed: openEditMode,
          icon: Icon(Icons.touch_app_rounded),
        ) : SizedBox(),
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
                print('refresh');
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
              List<Media> mediaList = await ImagesPicker.pick(
                count: 100,
                pickType: PickType.all,
                quality: 1.0,
              );
              print(mediaList[0].path);
              if(mediaList.isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => UploadGalleryViewPage(imageData: mediaList, category: widget.category)
                )).whenComplete(() {
                  setState(() {
                    // API.uploader.createDio();
                    print('After upload'); // refresh
                  });
                });
              }
            } catch (e) {
              print('Dio error ${e.toString()}');
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
                List<Media> mediaList = await ImagesPicker.openCamera(
                  pickType: PickType.image,
                  quality: 1.0,
                );
                print(mediaList[0].path);
                if(mediaList.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UploadGalleryViewPage(imageData: mediaList, category: widget.category)
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

  Widget createPageContent(dynamic albums, int nbImages) {
    ThemeData _theme = Theme.of(context);

    int albumCrossAxisCount = MediaQuery.of(context).size.width <= Constants.ALBUM_MIN_WIDTH ? 1
        : (MediaQuery.of(context).size.width/Constants.ALBUM_MIN_WIDTH).floor();

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
                    setState(() {});
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
        if(_selectedItems.length > 0) {
          switch (index) {
            case 0:
              _onEditSelection();
              break;
            case 1:
              _onDownloadSelection();
              break;
            case 2:
              _onMoveCopySelection();
              break;
            case 3:
              _onDeleteSelection();
              break;
            default:
              break;
          }
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
                backgroundColor: Color(0xff868686),
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