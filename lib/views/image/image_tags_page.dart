import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/lists/image_grid_view.dart';
import 'package:piwigo_ng/components/popup_list_item.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/network/images.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/image_actions.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:piwigo_ng/views/image/image_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ImageTagsPage extends StatefulWidget {
  const ImageTagsPage({
    Key? key,
    required this.tag,
    this.isAdmin = false
  }) : super(key: key);

  static const String routeName = '/images/tags';

  final TagModel tag;
  final bool isAdmin;

  @override
  State<ImageTagsPage> createState() => _ImageTagsPageState();
}

class _ImageTagsPageState extends State<ImageTagsPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  late final Future<ApiResponse<Map>> _imageFuture;
  List<ImageModel>? _imageList;
  List<ImageModel> _selectedList = [];

  int _nbImages = 0;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _imageFuture = fetchTagImages(widget.tag.id).then((response) {
      if (response.hasData) {
        setState(() {
          final int? total = response.data!['total_count'];
          if (total != null) {
            _nbImages = total;
          }
          _imageList = response.data!['images'].cast<ImageModel>() ?? [];
        });
      }
      return response;
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _hasNonFavorites =>
      _selectedList.where((image) => !image.favorite).isNotEmpty;

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
    final ApiResponse<Map> result = await fetchTagImages(widget.tag.id);
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
    ApiResponse<Map> result = await fetchTagImages(widget.tag.id, _page + 1);
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
        ImagePage.routeName,
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
      ).then((images) {
        if (images == null || images is! List<ImageModel>) return;
        setState(() {
          _imageList = images;
          _page =
              ((images.length - 1) / Settings.defaultElementPerPage).floor();
        });
      });
  void _onEditPhotos() => onEditPhotos(context, _selectedList).then((success) {
        if (success == true) {
          _selectedList.clear();
          _onRefresh();
        }
      });
  void _onLikePhotos() =>
      onLikePhotos(_selectedList, false).whenComplete(() => _onRefresh());
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
                  child: _taggedImageGrid,
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
    Orientation orientation = MediaQuery.of(context).orientation;
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      titleSpacing: 0.0,
      leading: BackButton(
        onPressed: () => Navigator.of(context).pop(),
      ),
      // title: Text(appStrings.categoryDiscoverFavorites_title),
      title: Text(widget.tag.name),
      actions: [
        if (_selectedList.isNotEmpty)
          IconButton(
            onPressed: () => setState(() {
              _selectedList.clear();
            }),
            tooltip: appStrings.categoryImageList_deselectButton,
            icon: Icon(Icons.cancel),
          ),
        if (orientation == Orientation.landscape) ..._actions,
        if (widget.isAdmin)
          PopupMenuButton(
            tooltip: appStrings.imageOptions_title,
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

  Widget get _taggedImageGrid {
    return FutureBuilder<ApiResponse<Map>>(
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

  Widget _buildImageGrid(AsyncSnapshot snapshot) {
    final ApiResponse<Map> result = snapshot.data!;
    if (_imageList == null) {
      _nbImages = result.data!['total_count'];
      _imageList = result.data!['images'].cast<ImageModel>() ?? [];
    }

    _selectedList =
        _imageList!.where((image) => _selectedList.contains(image)).toList();

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

  Widget get _bottomBar {
    return OrientationBuilder(builder: (context, orientation) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _selectedList.isEmpty || orientation == Orientation.landscape
            ? 0
            : 56.0,
        child: BottomAppBar(
          height: 56.0,
          child: Row(
            children:
                _actions.map((action) => Expanded(child: action)).toList(),
          ),
        ),
      );
    });
  }

  List<Widget> get _actions {
    List<Widget> adminActions = [
      IconButton(
        onPressed: _onEditPhotos,
        tooltip: appStrings.imageOptions_edit,
        icon: Icon(Icons.edit),
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
          tooltip: _hasNonFavorites
              ? appStrings.imageOptions_addFavorites
              : appStrings.imageOptions_removeFavorites,
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

    return widget.isAdmin ? adminActions : userActions;
  }
}
