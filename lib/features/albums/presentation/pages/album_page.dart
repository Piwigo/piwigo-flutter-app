import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';
import 'package:piwigo_ng/core/utils/listeners/immersive_scroll_listener.dart';
import 'package:piwigo_ng/features/albums/domain/entities/album_entity.dart';
import 'package:piwigo_ng/features/albums/presentation/blocs/album_content/album_content_bloc.dart';
import 'package:piwigo_ng/features/albums/presentation/widgets/album_content_widget.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/session_status/session_status_bloc.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key, required this.album});

  final AlbumEntity album;

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> with UserStatusMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() => ImmersiveScrollListener.function(_scrollController));
  }

  @override
  void dispose() {
    _scrollController.removeListener(() => ImmersiveScrollListener.function(_scrollController));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AlbumContentBloc>(
      create: (BuildContext context) => AlbumContentBloc()..add(AlbumContentEvent.getAlbum(albumId: widget.album.id)),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(widget.album.name),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: UIConstants.paddingMedium),
                child: AlbumContentWidget(),
              ),
            ),
          ],
        ),
        floatingActionButton: isAdmin(context)
            ? FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () {},
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
