import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/data/datasources/local/preferences_datasource.dart';
import 'package:piwigo_ng/core/extensions/album_preferences_extension.dart';
import 'package:piwigo_ng/core/presentation/widgets/images/custom_network_image.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_entity.dart';
import 'package:piwigo_ng/utils/resources.dart';

class ImageCardWidget extends StatelessWidget with AppPreferencesMixin {
  const ImageCardWidget({
    super.key,
    this.onPressed,
    this.selected,
    required this.image,
    this.onLongPress,
  });

  final Function()? onPressed;
  final Function()? onLongPress;
  final bool? selected;
  final ImageEntity image;

  static const Duration _selectDuration = Duration(milliseconds: 200);
  static const Curve _selectCurve = Curves.easeInOut;
  static const double _overlayOpacity = 0.5;
  static const double _selectIconSize = 20.0;

  String? get _imageUrl => image.getDerivative(prefs.getImageThumbnailSize).url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomNetworkImage(
              imageUrl: _imageUrl,
            ),
            _buildInfoOverlay(context),
            ..._buildSelectOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoOverlay(BuildContext context) => Positioned(
        bottom: 0.0,
        right: 0.0,
        left: 0.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (image.isVideo)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.local_movies,
                      color: AppColors.white,
                      size: 12,
                      shadows: AppShadows.icon,
                    ),
                  ),
                if (image.favorite)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.white,
                      size: 12,
                      shadows: AppShadows.icon,
                    ),
                  ),
              ],
            ),
            if (prefs.getShowThumbnailTitle)
              Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.black,
                      Colors.black.withOpacity(0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: AutoSizeText(
                  image.name,
                  maxLines: 1,
                  maxFontSize: 14,
                  minFontSize: 8,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                ),
              ),
          ],
        ),
      );

  List<Widget> _buildSelectOverlay(BuildContext context) => <Widget>[
        AnimatedOpacity(
          duration: _selectDuration,
          curve: _selectCurve,
          opacity: selected == true ? _overlayOpacity : 0.0,
          child: const Material(
            color: Colors.black,
            child: Center(),
          ),
        ),
        Positioned(
          top: UIConstants.paddingTiny,
          right: UIConstants.paddingTiny,
          child: Stack(
            children: <Widget>[
              AnimatedScale(
                duration: _selectDuration,
                curve: _selectCurve,
                scale: selected == false ? 1 : 0,
                child: AnimatedOpacity(
                  duration: _selectDuration,
                  curve: _selectCurve,
                  opacity: selected == false ? 1 : 0,
                  child: Container(
                    height: _selectIconSize,
                    width: _selectIconSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).primaryColor),
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              AnimatedScale(
                duration: _selectDuration,
                curve: _selectCurve,
                scale: selected == true ? 1 : 0,
                child: AnimatedOpacity(
                  duration: _selectDuration,
                  curve: _selectCurve,
                  opacity: selected == true ? 1 : 0,
                  child: const Icon(Icons.check_circle, size: _selectIconSize),
                ),
              ),
            ],
          ),
        ),
      ];
}
