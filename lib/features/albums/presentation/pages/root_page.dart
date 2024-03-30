import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/presentation/widgets/app_bars/expanded_app_bar.dart';
import 'package:piwigo_ng/core/presentation/widgets/buttons/custom_popup_menu_button.dart';
import 'package:piwigo_ng/core/router/app_routes.dart';
import 'package:piwigo_ng/core/utils/constants/hero_tags.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';
import 'package:piwigo_ng/core/utils/listeners/immersive_scroll_listener.dart';
import 'package:piwigo_ng/features/albums/presentation/blocs/album_content/album_content_bloc.dart';
import 'package:piwigo_ng/features/albums/presentation/widgets/album_content_widget.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/session_status/session_status_bloc.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with UserStatusMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final int rootId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(
      () => ImmersiveScrollListener.function(
        _scrollController,
        <SystemUiOverlay>[SystemUiOverlay.top],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(
      () => ImmersiveScrollListener.function(
        _scrollController,
        <SystemUiOverlay>[SystemUiOverlay.top],
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AlbumContentBloc>(
      create: (BuildContext context) => AlbumContentBloc()..add(AlbumContentEvent.getAlbum(albumId: rootId)),
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            ExpandedAppBar(
              scrollController: _scrollController,
              leading: IconButton(
                onPressed: () => context.navigator.pushNamed(AppRoutes.settings),
                icon: const Icon(Icons.settings),
              ),
              title: context.localizations.tabBar_albums,
              actions: <Widget>[
                _buildPopupMenu(context),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingMedium,
                  vertical: UIConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: context.theme.appBarTheme.backgroundColor,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.navigator.pushNamed(AppRoutes.searchImages),
                  child: IgnorePointer(
                    child: Hero(
                      tag: HeroTags.imageSearchField,
                      child: Material(
                        color: Colors.transparent,
                        child: AppField(
                          controller: _searchController,
                          padding: const EdgeInsets.symmetric(
                            vertical: UIConstants.paddingXSmall,
                            horizontal: UIConstants.paddingSmall,
                          ),
                          prefix: const Icon(Icons.search),
                          hint: "Search...",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: AlbumContentWidget(),
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

  Widget _buildPopupMenu(BuildContext context) {
    return CustomPopupMenuButton(
      items: <CustomPopupMenuItem>[
        CustomPopupMenuItem(
          onTap: () {}, // todo: go to upload queue
          label: context.localizations.uploadSection_queue,
          icon: Icons.upload,
        ),
        if (!isGuest(context))
          CustomPopupMenuItem(
            onTap: () {}, // todo: go to favorites
            label: context.localizations.categoryDiscoverFavorites_title,
            icon: Icons.favorite,
          ),
      ],
    );
  }
}
