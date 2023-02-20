import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
    this.example = false,
    this.onDelete,
    this.onEdit,
    this.onMove,
  }) : super(key: key);

  final bool example;
  final AlbumModel album;
  final Function()? onTap;
  final Function()? onDelete;
  final Function()? onEdit;
  final Function()? onMove;
  final bool showActions;

  static const double kAlbumAnchorRadius = 8.0;
  static const double kAlbumOuterRadius = 16.0;
  static const double kAlbumRatio = 3;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kAlbumOuterRadius),
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
          backgroundColor: const Color(0xFF4B4B4B), // Todo: Theme grey action color
          foregroundColor: Colors.white,
          autoClose: true,
          onPressed: onMove,
          icon: Icons.drive_file_move,
        ),
        AlbumCardAction(
          backgroundColor: Theme.of(context).errorColor,
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
            width: kAlbumAnchorRadius * 2.0,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: kAlbumAnchorRadius * 2.0 + 1.0,
              child: Container(
                width: kAlbumAnchorRadius * 2.0 + 1.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                ),
              ),
            ),
          ),
          ClipShadowPath(
            clipper: const AlbumCardClipper(
              anchorRadius: kAlbumAnchorRadius,
              outerRadius: kAlbumOuterRadius,
              isAdmin: true,
            ),
            shadow: Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3.0,
              offset: const Offset(1.0, 0.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(8.0).copyWith(right: 0.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).cardColor, width: 1.0),
              ),
              child: AlbumCardContent(
                album: album,
                example: example,
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
          anchorRadius: kAlbumAnchorRadius,
          outerRadius: kAlbumOuterRadius,
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
            example: example,
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
    this.example = false,
  }) : super(key: key);

  final AlbumModel album;
  final bool example;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          _thumbnail,
          const SizedBox(width: AlbumCard.kAlbumAnchorRadius * 2 + 16),
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
            if (album.urlRepresentative == null) {
              return FittedBox(
                fit: BoxFit.cover,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              );
            }
            if (example) {
              return Image.asset(
                album.urlRepresentative!,
                fit: BoxFit.cover,
                errorBuilder: (context, o, s) {
                  debugPrint("$o");
                  return Center(child: Icon(Icons.image_not_supported));
                },
              );
            }
            return CachedNetworkImage(
              imageUrl: album.urlRepresentative!,
              imageBuilder: (context, provider) => Image(
                image: provider,
                fit: BoxFit.cover,
              ),
              progressIndicatorBuilder: (context, url, download) => Center(
                child: CircularProgressIndicator(
                  value: download.progress,
                ),
              ),
              errorWidget: (context, url, error) {
                debugPrint("[$url] $error");
                return FittedBox(
                  fit: BoxFit.cover,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                );
              },
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
                Text(
                  album.name,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        album.comment ?? '',
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    appStrings.imageCount(album.nbTotalImages),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ));
}
