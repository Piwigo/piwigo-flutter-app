import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:piwigo_ng/components/app_image_display.dart';
import 'package:piwigo_ng/components/clippers/album_card_clipper.dart';
import 'package:piwigo_ng/components/clippers/clip_shadow_path.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';

import 'album_card_action.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    Key? key,
    required this.album,
    this.onTap,
    this.showActions = true,
    this.onDelete,
    this.onEdit,
    this.onMove,
  }) : super(key: key);

  final AlbumModel album;
  final Function()? onTap;
  final Function()? onDelete;
  final Function()? onEdit;
  final Function()? onMove;
  final bool showActions;

  static const double ALBUM_ANCHOR_RADIUS = 8.0;
  static const double ALBUM_OUTER_RADIUS = 16.0;
  static const double ALBUM_RATIO = 3.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ALBUM_OUTER_RADIUS),
        child: Slidable(
          enabled: showActions,
          endActionPane: _actionPane(context),
          child: Builder(builder: (context) {
            return GestureDetector(
              onLongPress: () => Slidable.of(context)?.openEndActionPane(),
              child: Builder(builder: (context) {
                if (!showActions) {
                  return _userContent;
                }
                return _adminContent;
              }),
            );
          }),
        ),
      ),
    );
  }

  ActionPane? _actionPane(BuildContext context) {
    return ActionPane(
      motion: const DrawerMotion(),
      children: [
        AlbumCardAction(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          autoClose: true,
          onPressed: onEdit,
          icon: Icons.edit,
        ),
        AlbumCardAction(
          backgroundColor:
              const Color(0xFF4B4B4B), // Todo: Theme grey action color
          foregroundColor: Colors.white,
          autoClose: true,
          onPressed: onMove,
          icon: Icons.drive_file_move,
        ),
        AlbumCardAction(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Colors.white,
          autoClose: true,
          onPressed: onDelete,
          icon: Icons.delete,
        ),
      ],
    );
  }

  Widget get _adminContent {
    return Builder(builder: (context) {
      return Stack(
        children: [
          Positioned(
            right: 0.0,
            top: 1.0,
            bottom: 1.0,
            width: ALBUM_ANCHOR_RADIUS * 2.0,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: ALBUM_ANCHOR_RADIUS * 2.0 + 1.0,
              child: Container(
                width: ALBUM_ANCHOR_RADIUS * 2.0 + 1.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 1.0),
                ),
              ),
            ),
          ),
          ClipShadowPath(
            clipper: const AlbumCardClipper(
              anchorRadius: ALBUM_ANCHOR_RADIUS,
              outerRadius: ALBUM_OUTER_RADIUS,
              isAdmin: true,
            ),
            shadow: Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 3.0,
              offset: const Offset(1.0, 0.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(8.0).copyWith(right: 0.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border:
                    Border.all(color: Theme.of(context).cardColor, width: 1.0),
              ),
              child: AlbumCardContent(
                album: album,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget get _userContent {
    return Builder(builder: (context) {
      return ClipPath(
        clipper: const AlbumCardClipper(
          anchorRadius: ALBUM_ANCHOR_RADIUS,
          outerRadius: ALBUM_OUTER_RADIUS,
          isAdmin: false,
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).cardColor, width: 1.0),
          ),
          child: AlbumCardContent(
            album: album,
          ),
        ),
      );
    });
  }
}

class AlbumCardContent extends StatelessWidget {
  const AlbumCardContent({
    Key? key,
    required this.album,
  }) : super(key: key);

  final AlbumModel album;

  bool isCommentValid(String? input) {
    if (input == null) return false;

    // Define a regular expression pattern to match common CSS attributes and selectors
    final RegExp cssPattern = RegExp(
      r"(^|\s)(color|font-size|margin|padding|background|border|position|display|opacity|animation|@media|@keyframes)(:|\s)",
      caseSensitive: false,
    );

    // Check if the input string contains the CSS pattern
    if (cssPattern.hasMatch(input)) return true;

    // Define a regular expression pattern to match common HTML tags and attributes
    final RegExp htmlPattern = RegExp(
      r"(^|<\s*)(div|span|p|a|h1|h2|h3|h4|h5|h6|img|ul|ol|li|br|strong|em|blockquote)(\s|>)",
      caseSensitive: false,
    );

    // Check if the input string contains the HTML pattern
    return htmlPattern.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          _thumbnail,
          const SizedBox(width: AlbumCard.ALBUM_ANCHOR_RADIUS * 2 + 16.0),
          Expanded(
            child: _content,
          ),
        ],
      );
    });
  }

  Widget get _thumbnail => AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Builder(builder: (context) {
            return ImageNetworkDisplay(
              imageUrl: album.urlRepresentative,
            );
          }),
        ),
      );

  Widget get _content => Builder(
      builder: (context) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  album.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  maxFontSize:
                      Theme.of(context).textTheme.titleLarge!.fontSize!,
                  minFontSize: 10.0,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Builder(builder: (context) {
                        return AutoSizeText(
                          album.comment ?? '',
                          maxFontSize:
                              Theme.of(context).textTheme.bodySmall!.fontSize!,
                          minFontSize: 10.0,
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      }),
                    ),
                  ),
                ),
                AutoSizeText(
                  appStrings.imageCount(album.nbTotalImages),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  maxFontSize:
                      Theme.of(context).textTheme.labelSmall!.fontSize!,
                  minFontSize: 8.0,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ));
}
