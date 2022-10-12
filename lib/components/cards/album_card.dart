import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/components/clippers/album_card_clipper.dart';
import 'package:piwigo_ng/components/clippers/clip_shadow_path.dart';

import 'album_card_action.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    Key? key,
    required this.album,
    this.onTap,
  }) : super(key: key);

  final AlbumModel album;
  final Function()? onTap;

  static const double kAlbumAnchorRadius = 8.0;
  static const double kAlbumOuterRadius = 16.0;
  static const double kAlbumRatio = 2.5;

  Future<void> _onEdit() async {}

  Future<void> _onMove() async {}

  Future<void> _onDelete() async {}

  void _onPressedAlbum() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kAlbumOuterRadius),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              AlbumCardAction(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white, // Todo: Theme icon light color
                onPressed: _onEdit,
                icon: Icons.edit,
              ),
              AlbumCardAction(
                backgroundColor: const Color(0xFF4B4B4B), // Todo: Theme grey action color
                onPressed: _onMove,
                icon: Icons.drive_file_move,
              ),
              AlbumCardAction(
                backgroundColor: Theme.of(context).errorColor,
                autoClose: true,
                onPressed: _onDelete,
                icon: Icons.delete,
              ),
            ],
          ),
          child: Builder(builder: (context) {
            return GestureDetector(
              onLongPress: () => Slidable.of(context)?.openEndActionPane(),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 1,
                    bottom: 1,
                    child: Container(
                      width: kAlbumAnchorRadius * 2,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                      ),
                    ),
                  ),
                  ClipShadowPath(
                    clipper: const AlbumCardClipper(
                      anchorRadius: kAlbumAnchorRadius,
                      outerRadius: kAlbumOuterRadius,
                    ),
                    shadow: Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 3.0,
                      offset: const Offset(1.0, 0.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        left: 8.0,
                        bottom: 8.0,
                        right: 0.0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                          color: Theme.of(context).cardColor,
                          width: 1,
                        ),
                      ),
                      child: AlbumCardContent(
                        album: album,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class AlbumCardContent extends StatelessWidget {
  const AlbumCardContent({
    Key? key,
    required this.album,
  }) : super(key: key);

  final AlbumModel album;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          SizedBox.square(
            dimension: constraints.maxHeight,
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
                return CachedNetworkImage(
                  imageUrl: album.urlRepresentative!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => FittedBox(
                    fit: BoxFit.cover,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: AlbumCard.kAlbumAnchorRadius * 2 + 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      album.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      album.comment ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    "${album.nbTotalImages} photos", // Todo: use variable
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
