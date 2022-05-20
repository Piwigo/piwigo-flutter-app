import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';

import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/UploadStatusProvider.dart';
import 'package:piwigo_ng/views/ImageViewPage.dart';
import 'package:piwigo_ng/views/components/content_grid.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';

import 'package:piwigo_ng/views/UploadGalleryViewPage.dart';
import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';
import 'package:provider/provider.dart';


class FavoritesViewPage extends StatefulWidget {
  FavoritesViewPage({Key key, this.isAdmin, this.nbImages}) : super(key: key);
  final bool isAdmin;
  final int nbImages;

  @override
  _FavoritesViewPageState createState() => _FavoritesViewPageState();
}
class _FavoritesViewPageState extends State<FavoritesViewPage> with SingleTickerProviderStateMixin {
  GlobalKey _key = GlobalKey();

  bool _isEditMode;
  Map<int, dynamic> _selectedItems = Map();
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _isEditMode = false;
  }

  void _getData() {
    final ContentGridState contentGridState = _key.currentState;
    contentGridState.reloadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _selectedPhotos() {
    return _selectedItems.length;
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

  void _onEditSelection() async {
    // Navigator.of(context).push(
    //     MaterialPageRoute(builder: (_) => EditImagesPage(
    //       catId: int.parse(widget.category),
    //       images: _selectedItems.values.toList(),
    //     ))
    // );
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
              catName: appStrings(context).categoryDiscoverFavorites_title,
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
        _getData();
      });
      break;
      case 1: showDialog(context: context,
          builder: (context) {
            return MoveOrCopyDialog(
              title: appStrings(context).copyImage_title,
              subtitle: appStrings(context).copyImage_selectAlbum(_selectedItems.length, ''),
              // catName: widget.title,
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
        _getData();
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
        case 1: nbSuccess = await removeImages(context, selection, '0'); //TODO: update this
        break;
        default: break;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(appStrings(context).deleteImageSuccess_message(nbSuccess)),
      ));

      _getData();
    }
  }

  void _onSelectAll() {
    final ContentGridState contentGridState = _key.currentState;
    setState(() {
      if(_selectedItems.length == contentGridState.imageList.length) {
        _selectedItems.clear();
      } else {
        contentGridState.imageList.forEach((image) {
          _selectedItems.putIfAbsent(image['id'], () => image);
        });
      }
    });
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
          body: ContentGrid(
              key: _key,
              // category: widget.category,
              isAdmin: widget.isAdmin,
              nbImages: widget.nbImages,
              isEditMode: _isEditMode || false,
              selectedItems: _selectedItems,
              loadMoreImages: (int page) {
                print('Loading page $page of favorite images');
                return fetchFavoriteImages(page);
              },
              setEditMode: (bool isEditMode, {image}) => {
                setState(() {
                  _isEditMode = isEditMode;
                  if (!_isEditMode) {
                    _selectedItems.clear();
                  } else if (image != null) {
                    _selectedItems.putIfAbsent(image['id'], () => image);
                  }
                })
              },
              deselectItem: (dynamic image) {
                setState(() {
                  _selectedItems.remove(image['id']);
                });
              },
              selectItem: (dynamic image) {
                setState(() {
                  _selectedItems.putIfAbsent(image['id'], () => image);
                });
              },
              onImageTap: (List<dynamic> images, int index) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ImageViewPage(
                    images: images,
                    index: index,
                    isAdmin: widget.isAdmin,
                    favorites: true,
                  )),
                ).whenComplete(() {
                  _getData();
                });
              },
          ),
        ),
      ),
      // floatingActionButton: _isEditMode ?
      // Center() : createFloatingActionButton(),
      bottomNavigationBar: _isEditMode ?
      createBottomBar() : Container(height: 0),
    );
  }

  Widget createAppBar() {
    ThemeData _theme = Theme.of(context);
    final ContentGridState contentGridState = _key.currentState;
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
      Text(appStrings(context).categoryDiscoverFavorites_title),
      actions: [
        _isEditMode ? IconButton(
          onPressed: _onSelectAll,
          icon: _selectedItems.length == contentGridState.imageList.length ?
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
      child: child,
    );
  }

  // Widget createUploadActionButton() {
  //   ThemeData _theme = Theme.of(context);
  //   return SpeedDial(
  //     spaceBetweenChildren: 10,
  //     childMargin: EdgeInsets.only(bottom: 17, right: 10),
  //     animatedIcon: AnimatedIcons.menu_close,
  //     animatedIconTheme: IconThemeData(size: 22.0),
  //     closeManually: false,
  //     curve: Curves.bounceIn,
  //     backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
  //     foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
  //     overlayColor: Colors.black,
  //     elevation: 5.0,
  //     overlayOpacity: 0.5,
  //     shape: CircleBorder(),
  //     children: [
  //       SpeedDialChild(
  //         elevation: 5,
  //         labelWidget: Text(appStrings(context).createNewAlbum_title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
  //         child: Icon(Icons.create_new_folder),
  //         backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
  //         foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
  //         onTap: () async {
  //           showDialog(
  //               context: context,
  //               builder: (BuildContext context) {
  //                 return CreateCategoryDialog(catId: widget.category);
  //               }
  //           ).whenComplete(() {
  //             _getData();
  //           });
  //         },
  //       ),
  //       SpeedDialChild(
  //           elevation: 5,
  //           labelWidget: Text(appStrings(context).categoryUpload_images, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
  //           child: Icon(Icons.add_to_photos),
  //           backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
  //           foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
  //           onTap: () async {
  //             try {
  //               ScaffoldMessenger.of(context).removeCurrentSnackBar();
  //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                 content: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text(appStrings(context).loadingHUD_label),
  //                     CircularProgressIndicator(),
  //                   ],
  //                 ),
  //                 duration: Duration(days: 365),
  //               ));
  //               final List<XFile> images = ((await FilePicker.platform.pickFiles(
  //                 type: FileType.media,
  //                 allowMultiple: true,
  //               )) ?.files ?? []).map<XFile>((e) => XFile(e.path, name: e.name, bytes: e.bytes)).toList();
  //               ScaffoldMessenger.of(context).removeCurrentSnackBar();
  //               if(images.isNotEmpty) {
  //                 Navigator.push(context, MaterialPageRoute(
  //                     builder: (context) => UploadGalleryViewPage(imageData: images, category: widget.category)
  //                 )).whenComplete(() {
  //                   setState(() {
  //                     print('After upload'); // refresh
  //                   });
  //                 });
  //               }
  //             } catch (e) {
  //               print('${e.toString()}');
  //             }
  //           }
  //       ),
  //       SpeedDialChild(
  //           elevation: 5,
  //           labelWidget: Text(appStrings(context).categoryUpload_take, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
  //           child: Icon(Icons.photo_camera_rounded),
  //           backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
  //           foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
  //           onTap: () async {
  //             try {
  //               ScaffoldMessenger.of(context).removeCurrentSnackBar();
  //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                 content: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text(appStrings(context).loadingHUD_label),
  //                     CircularProgressIndicator(),
  //                   ],
  //                 ),
  //                 duration: Duration(days: 365),
  //               ));
  //               final XFile image = await ImagePicker().pickImage(source: ImageSource.camera);
  //               ScaffoldMessenger.of(context).removeCurrentSnackBar();
  //               if(image != null) {
  //                 Navigator.push(context, MaterialPageRoute(
  //                     builder: (context) => UploadGalleryViewPage(imageData: [image], category: widget.category)
  //                 )).whenComplete(() {
  //                   setState(() {
  //                     print('After upload'); // refresh
  //                   });
  //                 });
  //               }
  //             } catch (e) {
  //               print('Dio error ${e.toString()}');
  //             }
  //           }
  //       ),
  //     ],
  //   );
  // }

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

  // Widget createFloatingActionButton() {
  //   final uploadStatusProvider = Provider.of<UploadStatusNotifier>(context);
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Stack(
  //       children: <Widget>[
  //         Align(
  //           alignment: Alignment.bottomRight,
  //           child: Container(
  //             margin: EdgeInsets.only(bottom: 0, right: widget.isAdmin? 70 : 0),
  //             child: FloatingActionButton(
  //               backgroundColor: Color(0xff868686),
  //               onPressed: () {
  //                 Navigator.of(context).popUntil((route) => route.isFirst);
  //               },
  //               child: uploadStatusProvider.status ?
  //               Stack(
  //                 alignment: Alignment.center,
  //                 children: [
  //                   SizedBox(
  //                     height: 55,
  //                     width: 55,
  //                     child: CircularProgressIndicator(
  //                       strokeWidth: 5,
  //                       value: uploadStatusProvider.progress,
  //                     ),
  //                   ),
  //                   Text("${uploadStatusProvider.getRemaining()}",
  //                     style: TextStyle(fontSize: 16),
  //                   ),
  //                 ],
  //               ) :
  //               Icon(Icons.home, color: Colors.grey.shade200, size: 30),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}