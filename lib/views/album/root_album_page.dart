import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/scroll_widgets/album_grid_view.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/network/albums.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/utils/album_actions.dart';
import 'package:piwigo_ng/utils/localizations.dart';

import '../../components/appbars/root_search_app_bar.dart';
import '../image/image_search_page.dart';

class RootAlbumPage extends StatefulWidget {
  const RootAlbumPage({
    Key? key,
    this.albumId = 0,
    this.isAdmin = false,
  }) : super(key: key);

  static const String routeName = '/';
  final int albumId;
  final bool isAdmin;

  @override
  State<RootAlbumPage> createState() => _RootAlbumPageState();
}

class _RootAlbumPageState extends State<RootAlbumPage> {
  final ScrollController _scrollController = ScrollController();

  late final Future<ApiResponse<List<AlbumModel>>> _albumsFuture;
  List<AlbumModel> _albumList = [];

  @override
  void initState() {
    super.initState();
    _albumsFuture = fetchAlbums(widget.albumId);
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final ApiResponse<List<AlbumModel>> result =
        await fetchAlbums(widget.albumId);
    if (!result.hasData) {
      return;
    }

    setState(() {
      _albumList = result.data!;
    });
  }

  void _onAddAlbum() =>
      onAddAlbum(context, widget.albumId).whenComplete(() => _onRefresh());
  void _onTapAlbum(AlbumModel album) =>
      onOpenAlbum(context, album).whenComplete(() => _onRefresh());
  void _onEditAlbum(AlbumModel album) =>
      onEditAlbum(context, album).whenComplete(() => _onRefresh());
  void _onMoveAlbum(AlbumModel album) =>
      onMoveAlbum(context, album).whenComplete(() => _onRefresh());
  void _onDeleteAlbum(AlbumModel album) =>
      onDeleteAlbum(context, album).then((success) {
        if (success) _onRefresh();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        backgroundColor: Theme.of(context).cardColor,
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              RootSearchAppBar(
                scrollController: _scrollController,
                onSearch: () {
                  Navigator.of(context).pushNamed(ImageSearchPage.routeName);
                },
              ),
              SliverToBoxAdapter(
                child: _albumGrid,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _speedDial,
    );
  }

  Widget get _albumGrid {
    return FutureBuilder<ApiResponse<List<AlbumModel>>>(
      future: _albumsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ApiResponse<List<AlbumModel>> result = snapshot.data!;
          if (!result.hasData) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                appStrings.categoryImageList_noDataError,
                textAlign: TextAlign.center,
              ),
            );
          }
          if (_albumList.isEmpty) {
            if (result.data!.isEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  appStrings.categoryMainEmpty,
                  textAlign: TextAlign.center,
                ),
              );
            }
            _albumList = result.data!;
          }
          return Padding(
            padding: widget.isAdmin
                ? const EdgeInsets.only(bottom: 72.0)
                : EdgeInsets.zero,
            child: AlbumGridView(
              isAdmin: widget.isAdmin,
              albumList: _albumList,
              onTap: _onTapAlbum,
              onDelete: _onDeleteAlbum,
              onEdit: _onEditAlbum,
              onMove: _onMoveAlbum,
            ),
          );
        }
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget? get _speedDial {
    if (!widget.isAdmin) return null;
    return FloatingActionButton(
      onPressed: _onAddAlbum,
      child: Icon(Icons.create_new_folder,
          color: Theme.of(context).primaryColorLight),
    );
  }
}
