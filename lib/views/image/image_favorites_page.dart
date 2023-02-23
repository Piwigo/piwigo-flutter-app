import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/images.dart';
import 'package:piwigo_ng/components/popup_list_item.dart';
import 'package:piwigo_ng/components/scroll_widgets/image_grid_view.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/image_actions.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/image/image_view_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ImageFavoritesPage extends StatefulWidget {
  const ImageFavoritesPage({Key? key, this.isAdmin = false}) : super(key: key);

  static const String routeName = '/images/favorites';

  final bool isAdmin;

  @override
  State<ImageFavoritesPage> createState() => _ImageFavoritesPageState();
}

class _ImageFavoritesPageState extends State<ImageFavoritesPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  late final Future<ApiResult<Map>> _imageFuture;
  List<ImageModel>? _imageList;
  List<ImageModel> _selectedList = [];

  int _nbImages = 0;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _imageFuture = fetchFavorites();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _hasNonFavorites => _selectedList.where((image) => !image.favorite).isNotEmpty;

  Future<bool> _onWillPop() async {
    if (_selectedList.isNotEmpty) {
      setState(() {
        _selectedList.clear();
      });
      return false;
    }
    return true;
  }

  Future<void> _onRefresh() async {
    final ApiResult<Map> result = await fetchFavorites();
    if (!result.hasData) {
      _refreshController.refreshFailed();
      await Future.delayed(const Duration(milliseconds: 500));
      return _refreshController.refreshCompleted();
    }
    final int? total = result.data!['total_count'];
    setState(() {
      _page = 0;
      if (total != null) {
        _nbImages = total;
      }
      _imageList = result.data!['images'].cast<ImageModel>() ?? [];
      _selectedList.clear();
    });
    return _refreshController.refreshCompleted();
  }

  Future<void> _loadMoreImages() async {
    if (_imageList == null || _nbImages <= _imageList!.length) return;
    ApiResult<Map> result = await fetchFavorites(_page + 1);
    if (result.hasError || !result.hasData) {
      _refreshController.loadFailed();
      await Future.delayed(const Duration(milliseconds: 500));
      return _refreshController.loadComplete();
    }
    final int? total = result.data!['total_count'];
    setState(() {
      if (total != null) {
        _nbImages = total;
      }
      _imageList!.addAll(result.data!['images'].cast<ImageModel>() ?? []);
    });
    _refreshController.loadComplete();
  }

  void _onTapPhoto(ImageModel image) => Navigator.of(context).pushNamed(
        ImageViewPage.routeName,
        arguments: {
          'images': _imageList,
          'startId': image.id,
          'album': AlbumModel(
            id: -1,
            name: '',
            nbImages: _nbImages,
            nbTotalImages: _nbImages,
          ),
        },
      ).whenComplete(() => _onRefresh());
  void _onEditPhotos() => onEditPhotos(context, _selectedList).then((success) {
        if (success == true) {
          _selectedList.clear();
          _onRefresh();
        }
      });
  void _onLikePhotos() => onLikePhotos(_selectedList, false).whenComplete(() => _onRefresh());
  _onDeletePhotos() => onDeletePhotos(context, _selectedList).then((success) {
        if (success) _onRefresh();
      });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SmartRefresher(
            controller: _refreshController,
            scrollController: _scrollController,
            enablePullUp: _imageList != null && _nbImages > _imageList!.length,
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
                  child: _searchGrid,
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
      ),
    );
  }

  Widget get _appBar {
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      titleSpacing: 0.0,
      leading: BackButton(
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(appStrings.categoryDiscoverFavorites_title),
      actions: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          child: SizedBox(
            width: _selectedList.isEmpty ? (widget.isAdmin ? 0.0 : 16.0) : null,
            child: AnimatedScale(
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
          ),
        ),
        if (widget.isAdmin)
          PopupMenuButton(
            padding: EdgeInsets.zero,
            enabled: _selectedList.isNotEmpty,
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
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
              if (Preferences.getUserStatus != 'guest')
                PopupMenuItem(
                  onTap: () => Future.delayed(
                    const Duration(seconds: 0),
                    _onLikePhotos,
                  ),
                  child: PopupListItem(
                    icon: Icons.remove_circle,
                    text: appStrings.imageOptions_removeFavorites,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
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
            ],
          ),
      ],
    );
  }

  Widget get _searchGrid {
    return FutureBuilder<ApiResult<Map>>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (!snapshot.data!.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(appStrings.categoryImageList_noDataError),
              ),
            );
          }
          return _buildImageGrid(snapshot);
        }
        return Center(child: CircularProgressIndicator());
      },
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

  Widget _buildImageGrid(AsyncSnapshot snapshot) {
    final ApiResult<Map> result = snapshot.data!;
    if (_imageList == null) {
      _nbImages = result.data!['total_count'];
      _imageList = result.data!['images'].cast<ImageModel>() ?? [];
    }

    _selectedList = _imageList!.where((image) => _selectedList.contains(image)).toList();

    if (_imageList!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(appStrings.noImages),
        ),
      );
    }
    return ImageGridView(
      imageList: _imageList!,
      selectedList: _selectedList,
      onSelectImage: (image) => setState(() {
        _selectedList.add(image);
      }),
      onDeselectImage: (image) => setState(() {
        _selectedList.remove(image);
      }),
      onTapImage: _onTapPhoto,
    );
  }
}
