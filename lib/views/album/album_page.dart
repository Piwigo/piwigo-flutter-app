import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/components/lists/album_grid_view.dart';
import 'package:piwigo_ng/components/lists/image_grid_view.dart';
import 'package:piwigo_ng/components/popup_list_item.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/network/albums.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/network/images.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/services/upload_notifier.dart';
import 'package:piwigo_ng/utils/album_actions.dart';
import 'package:piwigo_ng/utils/image_actions.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:piwigo_ng/views/image/image_page.dart';
import 'package:piwigo_ng/views/upload/upload_page.dart';
import 'package:piwigo_ng/views/upload/upload_status_page.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({
    Key? key,
    this.isAdmin = false,
    required this.album,
  }) : super(key: key);

  static const String routeName = '/album';
  final AlbumModel album;
  final bool isAdmin;

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  late AlbumModel _currentAlbum;

  late final Future<List<ApiResponse>> _data;
  List<ImageModel>? _imageList;
  List<AlbumModel>? _albumList;
  List<ImageModel> _selectedList = [];

  int _page = 0;

  @override
  initState() {
    _currentAlbum = widget.album;
    _data = Future.wait([
      fetchAlbums(widget.album.id),
      fetchImages(widget.album.id, 0),
    ]);
    super.initState();
  }

  bool get _hasNonFavorites => _selectedList.where((image) => !image.favorite).isNotEmpty;

  bool get _enableLoad {
    if (_imageList == null || _imageList!.isEmpty) return false;
    return _currentAlbum.nbImages > _imageList!.length;
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
    if (_imageList == null) return;
    if (_currentAlbum.nbImages <= _imageList!.length) return;
    ApiResponse<List<ImageModel>> result = await fetchImages(widget.album.id, _page + 1);
    if (result.hasError || !result.hasData) {
      _refreshController.loadFailed();
      await Future.delayed(const Duration(milliseconds: 500));
      return _refreshController.loadComplete();
    }
    setState(() {
      _page += 1;
      _imageList!.addAll(result.data!);
    });
    _refreshController.loadComplete();
  }

  Future<void> _onRefresh() async {
    final result = await Future.wait([fetchAlbums(widget.album.id), fetchImages(widget.album.id, 0)]);
    final ApiResponse<List<AlbumModel>> albumsResult = result.first as ApiResponse<List<AlbumModel>>;
    final ApiResponse<List<ImageModel>> imagesResult = result.last as ApiResponse<List<ImageModel>>;
    if (!albumsResult.hasData || !imagesResult.hasData) {
      _refreshController.refreshFailed();
      await Future.delayed(const Duration(milliseconds: 500));
      return _refreshController.refreshCompleted();
    }
    setState(() {
      _page = 0;
      _albumList = _parseAlbums(albumsResult.data!);
      _imageList = imagesResult.data!;
      _selectedList.removeWhere((image) => !(_imageList ?? []).contains(image));
    });
    _refreshController.refreshCompleted();
  }

  void _onAddAlbum() => onAddAlbum(context, widget.album.id).whenComplete(() => _onRefresh());

  void _onTapAlbum(AlbumModel album) => onOpenAlbum(context, album).whenComplete(() => _onRefresh());

  void _onEditAlbum(AlbumModel album) => onEditAlbum(context, album).whenComplete(() => _onRefresh());

  void _onMoveAlbum(AlbumModel album) => onMoveAlbum(context, album).whenComplete(() => _onRefresh());

  Future<bool> _onDeleteAlbum(AlbumModel album) async {
    return onDeleteAlbum(context, album).then((success) {
      if (success) _onRefresh();
      return success;
    });
  }

  void _onAlbumPrivacy(AlbumModel album) => onEditAlbumPrivacy(context, album).whenComplete(() => _onRefresh());

  void _onTapPhoto(ImageModel image) {
    Navigator.of(context).pushNamed(
      ImagePage.routeName,
      arguments: {
        'images': _imageList,
        'startId': image.id,
        'album': _currentAlbum,
      },
    ).then((images) {
      if (images == null || images is! List<ImageModel>) return;
      setState(() {
        _imageList = images;
        _page = ((images.length - 1) / Settings.defaultElementPerPage).floor();
      });
    });
  }

  void _onEditPhotos() {
    onEditPhotos(context, _selectedList).then((success) {
      if (success == true) {
        _selectedList.clear();
        _onRefresh();
      }
    });
  }

  Future<void> _onMovePhotos() async {
    onMovePhotos(context, _selectedList, _currentAlbum).whenComplete(() => _onRefresh());
  }

  void _onLikePhotos() {
    onLikePhotos(_selectedList, _hasNonFavorites).whenComplete(() => _onRefresh());
  }

  void _onDeletePhotos() {
    onDeletePhotos(context, _selectedList, _currentAlbum).then((success) {
      if (success) _onRefresh();
    });
  }

  Future<void> _onPickImages() async {
    EasyLoading.show(
      status: appStrings.loadingHUD_label,
      indicator: CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: true,
    );
    List<XFile>? images = await onPickImages();
    if (!EasyLoading.isShow) return;
    EasyLoading.dismiss();
    if (images == null || images.isEmpty) return;
    Navigator.of(context).pushNamed(UploadPage.routeName, arguments: {
      'images': images,
      'category': widget.album.id,
    }).then((value) => _refreshController.requestRefresh());
  }

  Future<void> _onTakePhoto() async {
    XFile? image = await onTakePhoto(context);
    if (image == null) return;
    Navigator.of(context).pushNamed(UploadPage.routeName, arguments: {
      'images': [image],
      'category': widget.album.id,
    }).then((value) => _refreshController.requestRefresh());
  }

  void _onWillPop(bool pop) {
    if (pop) return;
    if (_selectedList.isNotEmpty) {
      setState(() {
        _selectedList.clear();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SmartRefresher(
            controller: _refreshController,
            scrollController: _scrollController,
            enablePullUp: _enableLoad,
            onLoading: _loadMoreImages,
            onRefresh: _onRefresh,
            header: MaterialClassicHeader(
              backgroundColor: Theme.of(context).cardColor,
              color: Theme.of(context).colorScheme.secondary,
            ),
            footer: ClassicFooter(
              loadingText: appStrings.loadingHUD_label,
              noDataText: appStrings.categoryImageList_noDataError,
              failedText: appStrings.errorHUD_label,
              idleText: '',
              canLoadingText: appStrings.loadMoreHUD_label,
            ),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _appBar,
                SliverToBoxAdapter(
                  child: FutureBuilder<List<ApiResponse>>(
                    future: _data,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.first.hasError && snapshot.data!.last.hasError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              appStrings.categoryImageList_noDataError,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _albumGrid(snapshot),
                            _imageGrid(snapshot),
                            SizedBox(
                              height: 72.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  appStrings.imageCount(_currentAlbum.nbTotalImages),
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
      ),
    );
  }

  Widget get _appBar {
    Orientation orientation = MediaQuery.of(context).orientation;
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      pinned: true,
      titleSpacing: 0,
      centerTitle: _selectedList.isNotEmpty,
      title: Text(
        _selectedList.isEmpty ? _currentAlbum.name : _selectedList.length.toString(),
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      actions: [
        if (_selectedList.isNotEmpty)
          IconButton(
            onPressed: () => setState(() {
              _selectedList.clear();
            }),
            tooltip: appStrings.categoryImageList_deselectButton,
            icon: Icon(Icons.cancel),
          ),
        if (orientation == Orientation.landscape && _selectedList.isNotEmpty) ..._imageActions,
        if (widget.isAdmin || _currentAlbum.canUpload)
          PopupMenuButton(
            tooltip: appStrings.imageOptions_title,
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              if (_selectedList.isNotEmpty)
                PopupMenuItem(
                  onTap: () => Future.delayed(
                    const Duration(seconds: 0),
                    () => share(_selectedList),
                  ),
                  child: PopupListItem(
                    icon: Icons.share,
                    text: appStrings.imageOptions_share,
                  ),
                ),
              if (_selectedList.isNotEmpty && Preferences.getUserStatus != 'guest')
                PopupMenuItem(
                  onTap: () => Future.delayed(
                    const Duration(seconds: 0),
                    _onLikePhotos,
                  ),
                  child: PopupListItem(
                    icon: _hasNonFavorites ? Icons.favorite_border : Icons.favorite,
                    text: _hasNonFavorites
                        ? appStrings.imageOptions_addFavorites
                        : appStrings.imageOptions_removeFavorites,
                  ),
                ),
              if (_selectedList.isNotEmpty)
                PopupMenuItem(
                  onTap: () => Future.delayed(
                    const Duration(seconds: 0),
                    () => downloadImages(_selectedList),
                  ),
                  child: PopupListItem(
                    icon: Icons.download,
                    text: appStrings.downloadImage_title(_selectedList.length),
                  ),
                ),
              PopupMenuItem(
                onTap: () => Future.delayed(
                  const Duration(seconds: 0),
                  () => _onEditAlbum(_currentAlbum),
                ),
                child: PopupListItem(
                  icon: Icons.drive_file_rename_outline_sharp,
                  text: appStrings.renameCategory_title,
                ),
              ),
              PopupMenuItem(
                onTap: () => Future.delayed(
                  const Duration(seconds: 0),
                  () => _onAlbumPrivacy(_currentAlbum),
                ),
                child: PopupListItem(
                  icon: Icons.lock,
                  text: appStrings.categoryPrivacy,
                ),
              ),
              PopupMenuItem(
                onTap: () => Future.delayed(
                  const Duration(seconds: 0),
                  () async {
                    if (await _onDeleteAlbum(_currentAlbum)) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                child: PopupListItem(
                  color: Theme.of(context).colorScheme.error,
                  icon: Icons.delete,
                  text: appStrings.deleteCategory_title,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _albumGrid(AsyncSnapshot snapshot) {
    // initialize album list
    if (_albumList == null) {
      final ApiResponse<List<AlbumModel>> result = snapshot.data!.first as ApiResponse<List<AlbumModel>>;
      // if only albums has error
      if (!result.hasData) {
        return Center(
          child: Text(appStrings.categoryImageList_noDataError),
        );
      }
      _albumList = _parseAlbums(result.data!);
    }
    if (_albumList!.isEmpty) return const SizedBox();
    return AlbumGridView(
      isAdmin: widget.isAdmin,
      albumList: _albumList!,
      onTap: _onTapAlbum,
      onEdit: _onEditAlbum,
      onDelete: _onDeleteAlbum,
      onMove: _onMoveAlbum,
    );
  }

  Widget _imageGrid(AsyncSnapshot snapshot) {
    // Initialize image list
    if (_imageList == null) {
      final ApiResponse<List<ImageModel>> result = snapshot.data!.last as ApiResponse<List<ImageModel>>;
      // if only images has error
      if (!result.hasData) {
        return Center(
          child: Text(appStrings.categoryImageList_noDataError),
        );
      }
      _imageList = result.data!;
      // Refresh after build (for _enableLoad)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
    }
    if (_imageList!.isEmpty) return const SizedBox();
    // rebuild current selection with new images
    _selectedList = _imageList!.where((image) => _selectedList.contains(image)).toList();
    return ImageGridView(
      album: _currentAlbum,
      imageList: _imageList!,
      selectedList: _selectedList,
      onTapImage: _onTapPhoto,
      onSelectImage: (image) => setState(() {
        _selectedList.add(image);
      }),
      onDeselectImage: (image) => setState(() {
        _selectedList.remove(image);
      }),
    );
  }

  Widget? get _adminActionsSpeedDial {
    final Color childBackgroundColor = Theme.of(context).cardColor;
    final Color childIconColor = Theme.of(context).primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Consumer<UploadNotifier>(
          builder: (context, uploadNotifier, child) {
            bool uploading = uploadNotifier.uploadList.isNotEmpty;
            return FloatingActionButton(
              tooltip: uploading ? appStrings.uploadList_title : appStrings.categorySelection_root,
              shape: uploading ? CircleBorder() : null,
              backgroundColor: Theme.of(context).disabledColor.withOpacity(0.7),
              onPressed: () {
                if (uploading) {
                  Navigator.of(context).pushNamed(UploadStatusPage.routeName);
                } else {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: Builder(builder: (context) {
                if (uploading) {
                  UploadItem item = uploadNotifier.uploadList.first;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: StreamBuilder<double>(
                          stream: item.progress.stream,
                          initialData: 0.0,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return CircularProgressIndicator(
                                strokeWidth: 5.0,
                                value: min(snapshot.data!, 1.0),
                              );
                            }
                            return CircularProgressIndicator(strokeWidth: 5.0);
                          },
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${uploadNotifier.uploadList.length}",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  );
                }
                return child!;
              }),
            );
          },
          child: Icon(Icons.home, color: Colors.white),
        ),
        if (widget.isAdmin || widget.album.canUpload) ...[
          SizedBox(width: 16.0),
          SpeedDial(
            heroTag: '<default FloatingActionButton tag>',
            spacing: 5,
            overlayOpacity: 0.3,
            overlayColor: Colors.black,
            animatedIcon: AnimatedIcons.menu_close,
            children: [
              SpeedDialChild(
                shape: CircleBorder(),
                backgroundColor: childBackgroundColor,
                foregroundColor: childIconColor,
                labelBackgroundColor: childBackgroundColor,
                label: appStrings.createNewAlbum_title,
                onTap: _onAddAlbum,
                child: Icon(Icons.create_new_folder),
              ),
              SpeedDialChild(
                shape: CircleBorder(),
                backgroundColor: childBackgroundColor,
                foregroundColor: childIconColor,
                labelBackgroundColor: childBackgroundColor,
                label: appStrings.categoryUpload_images,
                onTap: _onPickImages,
                child: Icon(Icons.add_photo_alternate),
              ),
              SpeedDialChild(
                shape: CircleBorder(),
                backgroundColor: childBackgroundColor,
                foregroundColor: childIconColor,
                labelBackgroundColor: childBackgroundColor,
                label: appStrings.categoryUpload_takePhoto,
                onTap: _onTakePhoto,
                child: Icon(Icons.add_a_photo),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget get _bottomBar {
    return OrientationBuilder(builder: (context, orientation) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _selectedList.isEmpty || orientation == Orientation.landscape ? 0 : 56.0,
        child: BottomAppBar(
          height: 56.0,
          child: Row(
            children: _imageActions.map((action) => Expanded(child: action)).toList(),
          ),
        ),
      );
    });
  }

  List<Widget> get _imageActions {
    List<Widget> adminActions = [
      IconButton(
        onPressed: _onEditPhotos,
        tooltip: appStrings.imageOptions_edit,
        icon: Icon(Icons.edit),
      ),
      IconButton(
        onPressed: _onMovePhotos,
        tooltip: appStrings.moveImage_title,
        icon: Icon(Icons.drive_file_move),
      ),
      IconButton(
        onPressed: _onDeletePhotos,
        tooltip: appStrings.deleteImage_delete,
        icon: Icon(Icons.delete),
      ),
    ];
    List<Widget> userActions = [
      IconButton(
        onPressed: () => share(_selectedList),
        tooltip: appStrings.imageOptions_share,
        icon: Icon(Icons.share),
      ),
      if (Preferences.getUserStatus != 'guest') // Todo: enum roles
        IconButton(
          onPressed: _onLikePhotos,
          tooltip: _hasNonFavorites ? appStrings.imageOptions_addFavorites : appStrings.imageOptions_removeFavorites,
          isSelected: !_hasNonFavorites,
          selectedIcon: Icon(Icons.favorite),
          icon: Icon(Icons.favorite_border),
        ),
      IconButton(
        onPressed: () => downloadImages(_selectedList),
        tooltip: appStrings.imageOptions_download,
        icon: Icon(Icons.download),
      ),
    ];

    return widget.isAdmin || _currentAlbum.canUpload ? adminActions : userActions;
  }
}
