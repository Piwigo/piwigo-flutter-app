import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/app_image_display.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/resources.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    Key? key,
    this.onPressed,
    this.selected,
    required this.image,
    this.onLongPress,
  }) : super(key: key);

  final Function()? onPressed;
  final Function()? onLongPress;
  final bool? selected;
  final ImageModel image;

  final Duration selectDuration = const Duration(milliseconds: 200);
  final Curve selectCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumbnail(context),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (image.isVideo)
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.local_movies,
                            color: Color(0xFFFFFFFF),
                            size: 12,
                            shadows: AppShadows.icon,
                          ),
                        ),
                      if (image.favorite)
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.favorite,
                            color: Color(0xFFFFFFFF),
                            size: 12,
                            shadows: AppShadows.icon,
                          ),
                        ),
                    ],
                  ),
                  if (Preferences.getShowThumbnailTitle)
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.black,
                              Colors.black.withOpacity(0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter),
                      ),
                      child: AutoSizeText(
                        image.name,
                        maxLines: 1,
                        maxFontSize: 14,
                        minFontSize: 8,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
            ..._buildSelectOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(context) {
    final String? imageUrl =
        image.getDerivativeFromString(Preferences.getImageThumbnailSize)?.url;
    return ImageNetworkDisplay(
      imageUrl: imageUrl,
    );
  }

  List<Widget> _buildSelectOverlay(context) {
    return [
      AnimatedOpacity(
        duration: selectDuration,
        curve: selectCurve,
        opacity: selected == true ? 0.5 : 0.0,
        child: Container(
          color: Colors.black,
          child: const Center(),
        ),
      ),
      Positioned(
        top: 4,
        right: 4,
        child: Stack(
          children: [
            AnimatedScale(
              duration: selectDuration,
              curve: selectCurve,
              scale: selected == false ? 1 : 0,
              child: AnimatedOpacity(
                duration: selectDuration,
                curve: selectCurve,
                opacity: selected == false ? 1 : 0,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor),
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            AnimatedScale(
              duration: selectDuration,
              curve: selectCurve,
              scale: selected == true ? 1 : 0,
              child: AnimatedOpacity(
                duration: selectDuration,
                curve: selectCurve,
                opacity: selected == true ? 1 : 0,
                child: Icon(Icons.check_circle, size: 20),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
