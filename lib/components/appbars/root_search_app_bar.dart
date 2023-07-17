import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/notification_dot.dart';
import 'package:piwigo_ng/components/popup_list_item.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/services/upload_notifier.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/image/image_favorites_page.dart';
import 'package:piwigo_ng/views/upload/upload_status_page.dart';
import 'package:provider/provider.dart';

import '../../views/settings/settings_page.dart';
import '../fields/app_field.dart';

class RootSearchAppBar extends StatefulWidget {
  const RootSearchAppBar({
    Key? key,
    required this.scrollController,
    required this.onSearch,
  }) : super(key: key);

  final ScrollController scrollController;
  final Function() onSearch;

  @override
  State<RootSearchAppBar> createState() => _RootSearchAppBarState();
}

class _RootSearchAppBarState extends State<RootSearchAppBar> {
  final _expandedHeight = kToolbarHeight * 2;
  final _opacityScale = 0.3;

  @override
  initState() {
    widget.scrollController.addListener(() => setState(() {}));
    super.initState();
  }

  double get _titleOpacity {
    if (widget.scrollController.hasClients) {
      if (widget.scrollController.offset > _expandedHeight * _opacityScale) {
        return 0.0;
      }
      return (_expandedHeight * _opacityScale -
              widget.scrollController.offset) /
          (_expandedHeight * _opacityScale);
    }
    return 1.0;
  }

  double get _horizontalTitlePadding {
    const basePadding = 16.0;
    const delta = (kToolbarHeight - basePadding) / basePadding;

    if (widget.scrollController.hasClients) {
      if (widget.scrollController.offset > (_expandedHeight - kToolbarHeight)) {
        // In case 0% of the expanded height is viewed
        return basePadding * delta + basePadding;
      }

      // In case 0%-100% of the expanded height is viewed
      double scrollDelta =
          (_expandedHeight - widget.scrollController.offset) / _expandedHeight;
      double scrollPercent = (scrollDelta * 2 - 1);
      return (1 - scrollPercent) * delta * basePadding + basePadding;
    }

    return basePadding;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(SettingsPage.routeName),
        icon: const Icon(Icons.settings),
      ),
      pinned: true,
      centerTitle: true,
      titleSpacing: 0,
      title: Opacity(
        opacity: _titleOpacity,
        child: GestureDetector(
          onTap: widget.onSearch,
          child: const Hero(
            tag: '<search-bar>',
            child: Material(
              color: Colors.transparent,
              child: IgnorePointer(
                child: AppField(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  prefix: Icon(Icons.search),
                  hint: "Search...",
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        _popupMenu,
      ],
      expandedHeight: _expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(
          horizontal: _horizontalTitlePadding,
          vertical: 16,
        ),
        title: Text(
          appStrings.tabBar_albums,
          textScaleFactor: 1,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }

  Widget get _popupMenu {
    return Stack(
      alignment: Alignment.center,
      children: [
        PopupMenuButton(
          position: PopupMenuPosition.under,
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => Future.delayed(
                const Duration(seconds: 0),
                () =>
                    Navigator.of(context).pushNamed(UploadStatusPage.routeName),
              ),
              child: Stack(
                children: [
                  PopupListItem(
                    icon: Icons.upload,
                    text: appStrings.uploadSection_queue,
                  ),
                  Positioned(
                    top: 14.0,
                    left: 0.0,
                    child: Consumer<UploadNotifier>(
                        builder: (context, uploadNotifier, child) {
                      return NotificationDot(
                        isShown: uploadNotifier.uploadList.isNotEmpty,
                      );
                    }),
                  ),
                ],
              ),
            ),
            if (Preferences.getUserStatus != 'guest')
              PopupMenuItem(
                onTap: () => Future.delayed(
                  const Duration(seconds: 0),
                  () => Navigator.of(context)
                      .pushNamed(ImageFavoritesPage.routeName),
                ),
                child: PopupListItem(
                  icon: Icons.favorite,
                  text: appStrings.categoryDiscoverFavorites_title,
                ),
              ),
          ],
        ),
        Positioned(
          top: 12.0,
          left: 12.0,
          child: Consumer<UploadNotifier>(
              builder: (context, uploadNotifier, child) {
            return NotificationDot(
              isShown: uploadNotifier.uploadList.isNotEmpty,
            );
          }),
        ),
      ],
    );
  }
}
