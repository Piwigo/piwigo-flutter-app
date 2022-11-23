import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/components/modals/create_album_modal.dart';
import 'package:piwigo_ng/components/modals/delete_album_mode_modal.dart';
import 'package:piwigo_ng/components/modals/edit_album_modal.dart';
import 'package:piwigo_ng/components/modals/move_or_copy_modal.dart';
import 'package:piwigo_ng/components/scroll_widgets/album_grid_view.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';

import '../../components/appbars/root_search_app_bar.dart';
import '../image/image_search_view_page.dart';
import 'album_view_page.dart';

class RootAlbumViewPage extends StatefulWidget {
  const RootAlbumViewPage({
    Key? key,
    this.albumId = 0,
    this.isAdmin = false,
  }) : super(key: key);

  static const String routeName = '/';
  final int albumId;
  final bool isAdmin;

  @override
  State<RootAlbumViewPage> createState() => _RootAlbumViewPageState();
}

class _RootAlbumViewPageState extends State<RootAlbumViewPage> {
  final ScrollController _scrollController = ScrollController();

  late final Future<ApiResult<List<AlbumModel>>> _albumsFuture;
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
    final ApiResult<List<AlbumModel>> result = await fetchAlbums(widget.albumId);
    if (!result.hasData) {
      return;
    }

    setState(() {
      _albumList = result.data!;
    });
  }

  Future<void> _onAddAlbum() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).padding,
        child: CreateAlbumModal(albumId: widget.albumId),
      ),
    ).whenComplete(() => _onRefresh());
  }

  void _onTapAlbum(AlbumModel album) {
    Navigator.of(context).pushNamed(
      AlbumViewPage.routeName,
      arguments: {
        'album': album,
      },
    ).then((value) => _onRefresh());
  }

  Future<void> _onDeleteAlbum(AlbumModel album) async {
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
      if (choice == null) return;
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
      return;
    }
    _onRefresh();
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

  Future<void> _onMoveAlbum(AlbumModel album) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).padding,
        child: MoveOrCopyModal(
          title: appStrings.moveCategory,
          subtitle: appStrings.moveCategory_select(album.name),
          album: album,
        ),
      ),
    ).whenComplete(() => _onRefresh());
  }

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
            slivers: [
              RootSearchAppBar(
                scrollController: _scrollController,
                onSearch: () {
                  Navigator.of(context).pushNamed(ImageSearchViewPage.routeName);
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
    return FutureBuilder<ApiResult<List<AlbumModel>>>(
      future: _albumsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ApiResult<List<AlbumModel>> result = snapshot.data!;
          if (!result.hasData) {
            return Center(
              child: Text(appStrings.categoryImageList_noDataError),
            );
          }
          if (_albumList.isEmpty) {
            if (result.data!.isEmpty) {
              return Center(
                child: Text(appStrings.categoryMainEmpty),
              );
            }
            _albumList = result.data!;
          }
          return AlbumGridView(
            albumList: _albumList,
            onTap: _onTapAlbum,
            onDelete: _onDeleteAlbum,
            onEdit: _onEditAlbum,
            onMove: _onMoveAlbum,
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
      child: Icon(Icons.create_new_folder, color: Theme.of(context).primaryColorLight),
    );
  }
}
