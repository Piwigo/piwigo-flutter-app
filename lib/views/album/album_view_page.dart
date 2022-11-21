import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/components/modals/choose_camera_picker_modal.dart';
import 'package:piwigo_ng/components/modals/create_album_modal.dart';
import 'package:piwigo_ng/components/modals/delete_album_mode_modal.dart';
import 'package:piwigo_ng/components/modals/edit_album_modal.dart';
import 'package:piwigo_ng/components/popup_list_item.dart';
import 'package:piwigo_ng/components/scroll_widgets/album_grid_view.dart';
import 'package:piwigo_ng/components/scroll_widgets/image_grid_view.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/image/image_view_page.dart';
import 'package:piwigo_ng/views/upload/upload_view_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../api/images.dart';

class AlbumViewPage extends StatefulWidget {
  const AlbumViewPage({
    Key? key,
    this.isAdmin = false,
    required this.album,
  }) : super(key: key);

  static const String routeName = '/album';
  final AlbumModel album;
  final bool isAdmin;

  @override
  State<AlbumViewPage> createState() => _AlbumViewPageState();
}

class _AlbumViewPageState extends State<AlbumViewPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  late AlbumModel _currentAlbum;

  late final Future<List<ApiResult>> _data;
  List<ImageModel> _imageList = [];
  List<AlbumModel> _albumList = [];
  List<ImageModel> _selectedList = [];

  int _page = 0;

  @override
  initState() {
    _currentAlbum = widget.album;
    _data = Future.wait([fetchAlbums(widget.album.id), fetchImages(widget.album.id, 0)]);
    super.initState();
  }

  List<AlbumModel> _parseAlbums(List<AlbumModel> albums) {
    albums.removeWhere((album) {
      if (album.id == widget.album.id) {
        _currentAlbum = album;
        return true;
      }
      return false;
    });
    return albums;
  }

  Future<void> _loadMoreImages() async {
    if (_currentAlbum.nbImages <= _imageList.length) return;
    ApiResult<List<ImageModel>> result = await fetchImages(widget.album.id, _page + 1);
    if (result.hasError || !result.hasData) {
      _refreshController.loadFailed();
      await Future.delayed(const Duration(milliseconds: 500));
      return _refreshController.loadComplete();
    }
    setState(() {
      _imageList.addAll(result.data!);
    });
    _refreshController.loadComplete();
  }

  Future<void> _onRefresh() async {
    final result = await Future.wait([fetchAlbums(widget.album.id), fetchImages(widget.album.id, 0)]);
    final ApiResult<List<AlbumModel>> albumsResult = result.first as ApiResult<List<AlbumModel>>;
    final ApiResult<List<ImageModel>> imagesResult = result.last as ApiResult<List<ImageModel>>;
    if (!albumsResult.hasData || !imagesResult.hasData) {
      _refreshController.refreshFailed();
      await Future.delayed(const Duration(milliseconds: 500));
      return _refreshController.refreshCompleted();
    }
    setState(() {
      _page = 0;
      _albumList = _parseAlbums(albumsResult.data!);
      _imageList = imagesResult.data!;
    });
    _refreshController.refreshCompleted();
  }

  void _onTapAlbum(AlbumModel album) {
    Navigator.of(context).pushNamed(AlbumViewPage.routeName, arguments: {
      'isAdmin': widget.isAdmin, // todo: use preferences
      'album': album,
    }).then((value) => _onRefresh());
  }

  Future<void> _onAddAlbum() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).padding,
        child: CreateAlbumModal(albumId: widget.album.id),
      ),
    ).whenComplete(() => _onRefresh());
  }

  Future<bool> _onDeleteAlbum(AlbumModel album) async {
    DeleteAlbumModes mode = DeleteAlbumModes.deleteOrphans;
    if (album.nbTotalImages != 0) {
      final int? choice = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) => DeleteAlbumModeModal(
          albumModel: album,
        ),
      );
      if (choice == null) return false;
      switch (choice) {
        case 0:
          mode = DeleteAlbumModes.noDelete;
          break;
        case 1:
          mode = DeleteAlbumModes.deleteOrphans;
          break;
        case 2:
          mode = DeleteAlbumModes.forceDelete;
          break;
      }
    }
    final ApiResult result = await deleteAlbum(
      album.id,
      deletionMode: mode,
    );
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        errorSnackBar(message: appStrings.deleteCategoryError_title),
      );
      return false;
    }
    _onRefresh();
    return true;
  }

  Future<void> _onEditAlbum(AlbumModel album) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).padding,
        child: EditAlbumModal(album: album),
      ),
    ).whenComplete(() => _onRefresh());
  }

  Future<void> _onEditPhotos() async {}
  Future<void> _onMovePhotos() async {}
  Future<void> _onDeletePhotos() async {}

  Future<void> _onPickImages() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.media,
      );
      if (result == null) return;
      final List<XFile> images = result.files.map<XFile>((e) {
        return XFile(e.path!, name: e.name, bytes: e.bytes);
      }).toList();
      if (images.isNotEmpty) {
        Navigator.of(context).pushNamed(UploadViewPage.routeName, arguments: {
          'images': images,
          'category': widget.album.id,
        }).then((value) => _refreshController.requestRefresh());
      }
    } catch (e) {
      debugPrint('${e.toString()}');
    }
  }

  Future<void> _onTakePhoto() async {
    final int? choice = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => ChooseCameraPickerModal(),
    );
    if (choice == null) return;
    try {
      final ImagePicker picker = ImagePicker();
      XFile? image;
      switch (choice) {
        case 0:
          image = await picker.pickImage(source: ImageSource.camera);
          break;
        case 1:
          image = await picker.pickVideo(source: ImageSource.camera);
          break;
      }

      if (image != null) {
        Navigator.of(context).pushNamed(UploadViewPage.routeName, arguments: {
          'images': [image],
          'category': widget.album.id,
        }).then((value) => _refreshController.requestRefresh());
      }
    } catch (e) {
      debugPrint('${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          scrollController: _scrollController,
          enablePullUp: _imageList.isNotEmpty && _currentAlbum.nbImages > _imageList.length,
          onLoading: _loadMoreImages,
          onRefresh: _onRefresh,
          header: MaterialClassicHeader(
            backgroundColor: Theme.of(context).cardColor,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _appBar,
              SliverToBoxAdapter(
                child: FutureBuilder<List<ApiResult>>(
                  future: _data,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _albumGrid(snapshot),
                          _imageGrid(snapshot),
                          SizedBox(
                            height: 72,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                appStrings.imageCount(widget.album.nbImages),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset: _selectedList.isEmpty ? Offset(0, 1) : Offset.zero,
        child: _bottomBar,
      ),
      floatingActionButton: _adminActionsSpeedDial,
    );
  }

  Widget get _appBar {
    return SliverAppBar(
      pinned: true,
      titleSpacing: 0,
      title: Text(
        widget.album.name,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      actions: [
        PopupMenuButton(
          position: PopupMenuPosition.under,
          itemBuilder: (context) => [
            if (_selectedList.isNotEmpty)
              PopupMenuItem(
                onTap: () => setState(() {
                  _selectedList.clear();
                }),
                child: PopupListItem(
                  icon: Icons.cancel,
                  text: appStrings.categoryImageList_deselectButton,
                ),
              ),
            if (_selectedList.isNotEmpty)
              PopupMenuItem(
                child: PopupListItem(
                  icon: Icons.share,
                  text: appStrings.imageOptions_share,
                ),
              ),
            if (_selectedList.isNotEmpty)
              PopupMenuItem(
                child: PopupListItem(
                  icon: Icons.download,
                  text: appStrings.downloadImage_title(_selectedList.length),
                ),
              ),
            PopupMenuItem(
              onTap: () => _onEditAlbum(widget.album),
              child: PopupListItem(
                icon: Icons.drive_file_rename_outline_sharp,
                text: appStrings.renameCategory_title,
              ),
            ),
            PopupMenuItem(
              onTap: () async {
                if (await _onDeleteAlbum(widget.album)) {
                  Navigator.of(context).pop();
                }
              },
              child: PopupListItem(
                color: Theme.of(context).errorColor,
                icon: Icons.delete,
                text: appStrings.deleteCategory_title,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget? get _adminActionsSpeedDial {
    if (!widget.isAdmin) return null;
    final Color childBackgroundColor = Theme.of(context).primaryColorLight;
    final Color childIconColor = Theme.of(context).primaryColor;
    return SpeedDial(
      spacing: 5,
      overlayOpacity: 0.3,
      overlayColor: Colors.black,
      animatedIcon: AnimatedIcons.menu_close,
      activeBackgroundColor: Colors.red,
      children: [
        SpeedDialChild(
          backgroundColor: childBackgroundColor,
          foregroundColor: childIconColor,
          onTap: _onAddAlbum,
          child: Icon(Icons.create_new_folder),
        ),
        SpeedDialChild(
          backgroundColor: childBackgroundColor,
          foregroundColor: childIconColor,
          onTap: _onPickImages,
          child: Icon(Icons.add_photo_alternate),
        ),
        SpeedDialChild(
          backgroundColor: childBackgroundColor,
          foregroundColor: childIconColor,
          onTap: _onTakePhoto,
          child: Icon(Icons.add_a_photo),
        ),
      ],
    );
  }

  Widget _albumGrid(AsyncSnapshot snapshot) {
    if (_albumList.isEmpty) {
      final ApiResult<List<AlbumModel>> result = snapshot.data!.first as ApiResult<List<AlbumModel>>;
      _albumList = _parseAlbums(result.data!);
    }
    if (_albumList.isEmpty) return const SizedBox();
    return AlbumGridView(
      albumList: _albumList,
      onTap: _onTapAlbum,
      onEdit: _onEditAlbum,
      onDelete: _onDeleteAlbum,
    );
  }

  Widget _imageGrid(AsyncSnapshot snapshot) {
    if (_imageList.isEmpty && _page == 0) {
      final ApiResult<List<ImageModel>> result = snapshot.data!.last as ApiResult<List<ImageModel>>;
      if (result.hasError || !result.hasData) {
        return Center(
          child: Text(appStrings.noImages),
        );
      }
      _imageList = result.data!;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
    }
    if (_imageList.isEmpty) {
      return Center(
        child: Text(appStrings.noImages),
      );
    }
    return ImageGridView(
      imageList: _imageList,
      selectedList: _selectedList,
      onTapImage: (image) => Navigator.of(context).pushNamed(
        ImageViewPage.routeName,
        arguments: {
          'images': _imageList,
          'startId': image.id,
          'album': _currentAlbum,
        },
      ),
      onSelectImage: (image) => setState(() {
        _selectedList.add(image);
      }),
      onDeselectImage: (image) => setState(() {
        _selectedList.remove(image);
      }),
    );
  }

  Widget get _bottomBar {
    return BottomAppBar(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _selectedList.isEmpty ? 0 : 56.0,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: _onEditPhotos,
                icon: Icon(Icons.edit),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _onMovePhotos,
                icon: Icon(Icons.drive_file_move),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _onDeletePhotos,
                icon: Icon(Icons.delete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
