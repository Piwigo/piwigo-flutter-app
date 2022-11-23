import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/images.dart';
import 'package:piwigo_ng/components/popup_list_item.dart';
import 'package:piwigo_ng/components/scroll_widgets/image_grid_view.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/page_routes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../components/fields/app_field.dart';

class ImageSearchViewPage extends StatefulWidget {
  const ImageSearchViewPage({Key? key}) : super(key: key);

  static const String routeName = '/images/search';

  @override
  State<ImageSearchViewPage> createState() => _ImageSearchViewPageState();
}

class _ImageSearchViewPageState extends State<ImageSearchViewPage> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late final Future<ApiResult<Map>> _imageFuture;
  List<ImageModel>? _searchList = [];
  List<ImageModel> _selectedList = [];

  String _searchText = '';
  int _nbImages = 0;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _imageFuture = searchImages(_searchText);
    SchedulerBinding.instance.addPostFrameCallback((duration) {
      Future.delayed(SlideUpPageRoute.duration).then(
        (value) => FocusScope.of(context).requestFocus(_focusNode),
      );
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
    final String oldSearch = _searchText;
    final ApiResult<Map> result = await searchImages(_searchText);
    if (!result.hasData) {
      _refreshController.refreshFailed();
      await Future.delayed(const Duration(milliseconds: 500));
      return _refreshController.refreshCompleted();
    }
    if (_searchText == oldSearch) {
      final int? total = result.data!["total_count"];
      setState(() {
        _page = 0;
        if (total != null) {
          _nbImages = total;
        }
        _searchList = result.data!["images"].cast<ImageModel>() ?? [];
        _selectedList.clear();
      });
    }
    return _refreshController.refreshCompleted();
  }

  Future<void> _loadMoreImages() async {
    if (_searchList == null && _nbImages <= _searchList!.length) return;
    ApiResult<Map> result = await searchImages(_searchText, _page + 1);
    if (result.hasError || !result.hasData) {
      _refreshController.loadFailed();
      await Future.delayed(const Duration(milliseconds: 500));
      return _refreshController.loadComplete();
    }
    final int? total = result.data!["total_count"];
    setState(() {
      if (total != null) {
        _nbImages = total;
      }
      _searchList!.addAll(result.data!["images"].cast<ImageModel>() ?? []);
    });
    _refreshController.loadComplete();
  }

  void _onEdit() {}
  void _onMove() {}
  void _onDelete() {}
  void _onDownload() {}
  void _onShare() {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SmartRefresher(
            controller: _refreshController,
            scrollController: _scrollController,
            enablePullUp: _searchList != null && _searchList!.isNotEmpty && _nbImages > _searchList!.length,
            onLoading: _loadMoreImages,
            onRefresh: _onRefresh,
            header: MaterialClassicHeader(
              backgroundColor: Theme.of(context).cardColor,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _searchAppBar,
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

  Widget get _searchAppBar {
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      titleSpacing: 0.0,
      leading: IconButton(
        onPressed: () {
          _focusNode.unfocus();
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
      title: Hero(
        tag: 'search-bar',
        child: Material(
          color: Colors.transparent,
          child: AppField(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            controller: _searchController,
            focusNode: _focusNode,
            prefix: const Icon(Icons.search),
            hint: "Search...",
            onChanged: (value) => setState(() {
              _searchText = value;
              _onRefresh();
            }),
            onFieldSubmitted: (value) {
              if (value.isEmpty) Navigator.of(context).pop();
            },
          ),
        ),
      ),
      actions: [
        if (_selectedList.isNotEmpty)
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
                  onTap: _onShare,
                  child: PopupListItem(
                    icon: Icons.share,
                    text: appStrings.imageOptions_share,
                  ),
                ),
              if (_selectedList.isNotEmpty)
                PopupMenuItem(
                  onTap: _onDownload,
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
          if (_searchList == null) {
            final ApiResult<Map> result = snapshot.data!;
            if (!snapshot.data!.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(appStrings.categoryImageList_noDataError),
                ),
              );
            }
            _nbImages = result.data!["total_count"];
            _searchList = result.data!["images"].cast<ImageModel>() ?? [];
          }
          if (_searchList!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(appStrings.noImages),
              ),
            );
          }
          return ImageGridView(
            imageList: _searchList ?? [],
            selectedList: _selectedList,
            onSelectImage: (image) => setState(() {
              _selectedList.add(image);
            }),
            onDeselectImage: (image) => setState(() {
              _selectedList.remove(image);
            }),
          );
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
          children: [
            Expanded(
              child: IconButton(
                onPressed: _onEdit,
                icon: Icon(Icons.edit),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _onMove,
                icon: Icon(Icons.drive_file_move),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _onDelete,
                icon: Icon(Icons.delete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
