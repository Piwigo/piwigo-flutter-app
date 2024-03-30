import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/extensions/string_extension.dart';
import 'package:piwigo_ng/core/presentation/widgets/images/custom_network_image.dart';
import 'package:piwigo_ng/core/utils/app_colors.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';
import 'package:piwigo_ng/features/albums/domain/entities/album_entity.dart';
import 'package:piwigo_ng/features/albums/presentation/painters/album_card_painter.dart';

class AlbumCardWidget extends StatelessWidget {
  const AlbumCardWidget({
    super.key,
    required this.album,
    this.onTap,
    this.showActions = false,
  });

  final AlbumEntity album;
  final bool showActions;
  final Function()? onTap;

  static const double maxWidth = 448.0;
  static const double sizeRatio = 3.0;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
        child: Slidable(
          enabled: showActions,
          endActionPane: _actionPane(context),
          child: GestureDetector(
            onTap: onTap,
            child: CustomPaint(
              painter: AlbumCardPainter(context: context, showActions: showActions),
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingXSmall),
                child: _buildCardContent(context),
              ),
            ),
          ),
        ),
      );

  Widget _buildCardContent(BuildContext context) => Row(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
              child: CustomNetworkImage(
                imageUrl: album.urlRepresentative,
              ),
            ),
          ),
          const SizedBox(width: UIConstants.paddingXLarge),
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  album.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingTiny),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        album.comment?.isNotEmpty == true
                            ? album.comment!
                            : context.localizations.createNewAlbumDescription_noDescription.capitalize(),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
                Text(
                  context.localizations.imageCount(album.nbTotalImages),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      );

  ActionPane? _actionPane(BuildContext context) {
    return ActionPane(
      motion: const DrawerMotion(),
      children: <Widget>[
        CustomSlidableAction(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.zero,
          onPressed: (BuildContext context) {},
          // todo: edit album
          child: const Icon(Icons.edit, size: 32.0),
        ),
        CustomSlidableAction(
          backgroundColor: AppColors.grey,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.zero,
          onPressed: (BuildContext context) {},
          // todo: move album
          child: const Icon(Icons.drive_file_move, size: 32.0),
        ),
        CustomSlidableAction(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.zero,
          onPressed: (BuildContext context) {},
          // todo: delete album
          child: const Icon(Icons.delete, size: 32.0),
        ),
      ],
    );
  }
}
