import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/components/buttons/animated_app_button.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../components/appbars/root_search_app_bar.dart';
import '../../components/cards/album_card.dart';
import '../image/image_search_view_page.dart';
import 'album_view_page.dart';

class RootAlbumViewPage extends StatefulWidget {
  const RootAlbumViewPage({
    Key? key,
    this.albumId = "0",
    this.isAdmin = false,
  }) : super(key: key);

  static const String routeName = '/';
  final String albumId;
  final bool isAdmin;

  @override
  State<RootAlbumViewPage> createState() => _RootAlbumViewPageState();
}

class _RootAlbumViewPageState extends State<RootAlbumViewPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isStarting = false;

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {});
  }

  Future<void> _onAddAlbum() async {
    showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          title: 'Create album',
          content: Column(
            children: [
              AppField(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0).copyWith(right: 0),
                onFieldSubmitted: (String value) {
                  FocusScope.of(context).unfocus();
                },
                textInputAction: TextInputAction.done,
                hint: "Album name",
                enableClearAction: true,
              ),
            ],
          ),
        );
      },
    );
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
                  setState(() {
                    _isStarting = true;
                  });
                  Navigator.of(context).pushNamed(ImageSearchViewPage.routeName).whenComplete(() async {
                    setState(() {
                      _isStarting = false;
                    });
                  });
                },
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<ApiResult<List<AlbumModel>>>(
                  future: fetchAlbums(widget.albumId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      ApiResult<List<AlbumModel>> result = snapshot.data!;
                      if (result.hasError) {
                        return const Center(
                          child: Text("error"),
                        );
                      }
                      List<AlbumModel> albums = result.data!;
                      return AnimatedSlide(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        offset: _isStarting ? const Offset(0, 1) : Offset.zero,
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8.0,
                          ).copyWith(bottom: kToolbarHeight),
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
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _onAddAlbum,
              child: Icon(Icons.create_new_folder, color: Theme.of(context).primaryColorLight),
            )
          : null,
    );
  }
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    Key? key,
    this.title = '',
    this.content,
    this.width,
    this.height,
    this.action,
  }) : super(key: key);

  final String title;
  final Widget? content;
  final double? width;
  final double? height;
  final Widget? action;
  static final RoundedLoadingButtonController _controller = RoundedLoadingButtonController();

  double _getWidth(context) {
    var screen = MediaQuery.of(context);
    if (screen.orientation == Orientation.portrait) {
      return screen.size.width * 0.8;
    }
    return screen.size.height * 0.8;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24.0),
      elevation: 5,
      backgroundColor: Colors.transparent,
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: height,
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: content,
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Center(child: Text("Cancel")),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: AnimatedAppButton(
                          controller: _controller,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {},
                          child: const Text('Confirm'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
