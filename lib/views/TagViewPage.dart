import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/ImageViewPage.dart';
import 'package:piwigo_ng/views/components/content_grid.dart';

import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';


class TagViewPage extends StatefulWidget {
  TagViewPage({Key key, this.title, this.tag, this.isAdmin, this.nbImages}) : super(key: key);
  final bool isAdmin;
  final String title;
  final String tag;
  final int nbImages;

  @override
  _TagViewPageState createState() => _TagViewPageState();
}
class _TagViewPageState extends State<TagViewPage> with SingleTickerProviderStateMixin {
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
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EditImagesPage(
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
              print('Loading page $page of tag ${widget.tag}');
              return fetchTagImages(widget.tag, page);
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
                  tag: widget.tag,
                )),
              ).whenComplete(() {
                _getData();
              });
            },
          ),
        ),
      ),
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
      Text(widget.title),
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
}