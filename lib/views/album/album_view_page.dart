import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/components/cards/image_card.dart';
import 'package:piwigo_ng/modals/choose_camera_picker_modal.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/upload/upload_view_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../api/images.dart';
import '../../components/cards/album_card.dart';

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

  late final Future<List<ApiResult>> _data;
  List<ImageModel> _imageList = [];
  List<AlbumModel> _albumList = [];

  int _nbImages = 0;
  int _page = 0;

  @override
  initState() {
    _nbImages = widget.album.nbImages;
    super.initState();
    _getData();
  }

  void _getData() {
    setState(() {
      _data = Future.wait([fetchAlbums(widget.album.id), fetchImages(widget.album.id, 0)]);
    });
  }

  List<AlbumModel> _parseAlbums(List<AlbumModel> albums) {
    albums.removeWhere((album) => album.id == widget.album.id);
    return albums;
  }

  Future<void> _loadMoreImages() async {
    if (_nbImages <= _imageList.length) return;
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
      _albumList = _parseAlbums(albumsResult.data!);
      _imageList = imagesResult.data!;
    });
    _refreshController.refreshCompleted();
  }

  Future<void> _onAddAlbum() async {
    Navigator.of(context).pushNamed(UploadViewPage.routeName, arguments: {
      "images": <XFile>[],
      "category": widget.album.id,
    });
  }

  Future<void> _onPickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? images = await picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        Navigator.of(context).pushNamed(UploadViewPage.routeName, arguments: {
          'images': images,
          'category': widget.album.id,
        }).whenComplete(() {
          setState(() {});
        });
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
        }).whenComplete(() {
          setState(() {});
        });
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
          enablePullUp: _imageList.isNotEmpty && widget.album.nbImages > _imageList.length,
          onLoading: _loadMoreImages,
          onRefresh: _onRefresh,
          header: MaterialClassicHeader(
            backgroundColor: Theme.of(context).cardColor,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                titleSpacing: 0,
                title: Text(
                  widget.album.name,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                pinned: true,
              ),
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
      floatingActionButton: widget.isAdmin ? _adminActionsSpeedDial : null,
    );
  }

  Widget get _adminActionsSpeedDial {
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
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400.0,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: AlbumCard.kAlbumRatio,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _albumList.length,
      itemBuilder: (context, index) {
        AlbumModel album = _albumList[index];
        return AlbumCard(
          album: album,
          onTap: () {
            Navigator.of(context).pushNamed(AlbumViewPage.routeName, arguments: {
              'isAdmin': widget.isAdmin,
              'album': album,
            });
          },
        );
      },
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
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _imageList.length,
      itemBuilder: (context, index) {
        var image = _imageList[index];
        return ImageCard(
          image: image,
        );
      },
    );
  }
}
