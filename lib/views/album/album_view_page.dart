import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/views/upload/upload_view_page.dart';

import '../../api/images.dart';
import '../../components/cards/album_card.dart';
import '../../services/shared_preferences_service.dart';

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
  int _nbImages = 0;
  int _page = 0;

  final List<ImageModel> _imageList = [];

  @override
  initState() {
    _nbImages = widget.album.nbImages;
    super.initState();
  }

  Future<void> _loadMoreImages() async {
    if (_nbImages <= _imageList.length) return;
    ApiResult<List<ImageModel>> result = await fetchImages(widget.album.id, _page + 1);
    if (result.hasError || !result.hasData) return;
    _imageList.addAll(result.data!);
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {});
  }

  Future<void> _onAddAlbum() async {
    Navigator.of(context).pushNamed(UploadViewPage.routeName, arguments: {
      "images": <XFile>[],
      "category": widget.album.id,
    });
  }

  Future<void> _onPickImages() async {
    try {
      // final List<XFile> images = ((await FilePicker.platform.pickFiles(
      //   type: FileType.media,
      //   allowMultiple: true,
      // )) ?.files ?? [])
      //     .map<XFile>((e) => XFile(e.path, name: e.name, bytes: e.bytes)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        backgroundColor: Theme.of(context).cardColor,
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          child: CustomScrollView(
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
                child: Column(
                  children: [
                    FutureBuilder<ApiResult<List<AlbumModel>>>(
                      future: fetchAlbums(widget.album.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          ApiResult<List<AlbumModel>> result = snapshot.data!;
                          if (result.hasError || !result.hasData) {
                            return const Center(
                              child: Text("error"),
                            );
                          }
                          List<AlbumModel> albums = result.data!;
                          albums.removeWhere((album) => album.id == widget.album.id);
                          if (albums.isEmpty) return const SizedBox();
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400.0,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                              childAspectRatio: AlbumCard.kAlbumRatio,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: albums.length,
                            itemBuilder: (context, index) {
                              AlbumModel album = albums[index];
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
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8.0),
                    FutureBuilder<ApiResult<List<ImageModel>>>(
                      future: fetchImages(widget.album.id, _page),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          ApiResult<List<ImageModel>> result = snapshot.data!;
                          if (result.hasError || !result.hasData) {
                            return const Center(
                              child: Text("error"),
                            );
                          }
                          List<ImageModel> images = result.data!;
                          if (images.isEmpty) return const SizedBox();
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 4.0,
                              crossAxisSpacing: 4.0,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              var image = images[index];
                              return Image.network(
                                image.derivatives[appPreferences.getString('THUMBNAIL_SIZE')]['url'] ?? '',
                                fit: BoxFit.cover,
                              );
                            },
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
                  ],
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
          child: Icon(Icons.add_a_photo),
        ),
      ],
    );
  }
}
