import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/components/popup_list_item.dart';
import 'package:piwigo_ng/components/scroll_widgets/album_grid_view.dart';
import 'package:piwigo_ng/components/scroll_widgets/image_grid_view.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/services/upload_notifier.dart';
import 'package:piwigo_ng/utils/album_actions.dart';
import 'package:piwigo_ng/utils/image_actions.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/image/image_view_page.dart';
import 'package:piwigo_ng/views/upload/upload_status_page.dart';
import 'package:piwigo_ng/views/upload/upload_view_page.dart';
import 'package:provider/provider.dart';
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
    _data = Future.wait([
      fetchAlbums(widget.album.id),
      fetchImages(widget.album.id, 0),
    ]);
    super.initState();
  }

  bool get _hasNonFavorites => _selectedList.where((image) => !image.favorite).isNotEmpty;

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
      _page += 1;
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
      _selectedList.removeWhere((image) => !_imageList.contains(image));
    });
    _refreshController.refreshCompleted();
  }

  void _onAddAlbum() => onAddAlbum(context, widget.album.id).whenComplete(() => _onRefresh());
  void _onTapAlbum(AlbumModel album) => onOpenAlbum(context, album).whenComplete(() => _onRefresh());
  void _onEditAlbum(AlbumModel album) => onEditAlbum(context, album).whenComplete(() => _onRefresh());
  void _onMoveAlbum(AlbumModel album) => onMoveAlbum(context, album).whenComplete(() => _onRefresh());
  Future<bool> _onDeleteAlbum(AlbumModel album) => onDeleteAlbum(context, album).then((success) {
        if (success) _onRefresh();
        return success;
      });

  void _onTapPhoto(ImageModel image) => Navigator.of(context).pushNamed(
        ImageViewPage.routeName,
        arguments: {
          'images': _imageList,
          'startId': image.id,
          'album': _currentAlbum,
        },
      ).whenComplete(() => _onRefresh());
  void _onEditPhotos() => onEditPhotos(context, _selectedList).then((success) {
        if (success == true) {
          _selectedList.clear();
          _onRefresh();
        }
      });
  Future<void> _onMovePhotos() async => onMovePhotos(context, _selectedList, _currentAlbum).whenComplete(() => _onRefresh());
  void _onLikePhotos() => onLikePhotos(_selectedList, _hasNonFavorites).whenComplete(() => _onRefresh());
  _onDeletePhotos() => onDeletePhotos(context, _selectedList, _currentAlbum).then((success) {
        if (success) _onRefresh();
      });

  Future<void> _onPickImages() async {
    List<XFile>? images = await onPickImages();
    if (images == null || images.isEmpty) return;
    Navigator.of(context).pushNamed(UploadViewPage.routeName, arguments: {
      'images': images,
      'category': widget.album.id,
    }).then((value) => _refreshController.requestRefresh());
  }

  Future<void> _onTakePhoto() async {
    XFile? image = await onTakePhoto(context);
    if (image == null) return;
    Navigator.of(context).pushNamed(UploadViewPage.routeName, arguments: {
      'images': [image],
      'category': widget.album.id,
    }).then((value) => _refreshController.requestRefresh());
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
            color: Theme.of(context).colorScheme.secondary,
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
                            height: 72,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
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
    );
  }

  Widget get _appBar {
    return SliverAppBar(
      pinned: true,
      titleSpacing: 0,
      centerTitle: _selectedList.isNotEmpty,
      title: Text(
        _selectedList.isEmpty ? _currentAlbum.name : _selectedList.length.toString(),
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      actions: [
        AnimatedScale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          scale: _selectedList.isEmpty ? 0 : 1,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            opacity: _selectedList.isEmpty ? 0 : 1,
            child: IconButton(
              onPressed: () => setState(() {
                _selectedList.clear();
              }),
              icon: Icon(Icons.cancel),
            ),
          ),
        ),
        if (widget.isAdmin)
          PopupMenuButton(
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
                    text: _hasNonFavorites ? appStrings.imageOptions_addFavorites : appStrings.imageOptions_removeFavorites,
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
                  () async {
                    if (await _onDeleteAlbum(_currentAlbum)) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
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
    final Color childBackgroundColor = Theme.of(context).primaryColorLight;
    final Color childIconColor = Theme.of(context).primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Consumer<UploadNotifier>(
          builder: (context, uploadNotifier, child) {
            return FloatingActionButton(
              backgroundColor: Colors.grey.withOpacity(0.8),
              onPressed: () {
                print(uploadNotifier.uploadList.isNotEmpty);
                if (uploadNotifier.uploadList.isNotEmpty) {
                  Navigator.of(context).pushNamed(UploadStatusPage.routeName);
                } else {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: Builder(builder: (context) {
                if (uploadNotifier.uploadList.isNotEmpty) {
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
          ),
        ],
      ],
    );
  }

  Widget _albumGrid(AsyncSnapshot snapshot) {
    if (_albumList.isEmpty) {
      final ApiResult<List<AlbumModel>> result = snapshot.data!.first as ApiResult<List<AlbumModel>>;
      List<AlbumModel> albums = _parseAlbums(result.data!);
      if (albums.isEmpty) return const SizedBox();
      _albumList = _parseAlbums(result.data!);
    }
    return AlbumGridView(
      isAdmin: widget.isAdmin,
      albumList: _albumList,
      onTap: _onTapAlbum,
      onEdit: _onEditAlbum,
      onDelete: _onDeleteAlbum,
      onMove: _onMoveAlbum,
    );
  }

  Widget _imageGrid(AsyncSnapshot snapshot) {
    if (_imageList.isEmpty && _page == 0) {
      final ApiResult<List<ImageModel>> result = snapshot.data!.last as ApiResult<List<ImageModel>>;
      _imageList = result.data!;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
    }
    _selectedList = _imageList.where((image) => _selectedList.contains(image)).toList();
    return ImageGridView(
      imageList: _imageList,
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

  Widget get _bottomBar {
    return BottomAppBar(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _selectedList.isEmpty ? 0 : 56.0,
        child: Row(
          children: widget.isAdmin
              ? [
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
                ]
              : [
                  Expanded(
                    child: IconButton(
                      onPressed: () => share(_selectedList),
                      icon: Icon(Icons.share),
                    ),
                  ),
                  if (Preferences.getUserStatus != 'guest') // Todo: enum roles
                    Expanded(
                      child: IconButton(
                        onPressed: _onLikePhotos,
                        icon: Builder(
                          builder: (context) {
                            if (_hasNonFavorites) {
                              return Icon(Icons.favorite_border);
                            }
                            return Icon(Icons.favorite);
                          },
                        ),
                      ),
                    ),
                  Expanded(
                    child: IconButton(
                      onPressed: () => downloadImages(_selectedList),
                      icon: Icon(Icons.download),
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
