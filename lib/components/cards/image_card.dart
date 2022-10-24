import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/image_model.dart';

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
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            image.derivatives.medium.url,
            fit: BoxFit.cover,
            errorBuilder: (context, o, s) => Center(child: Icon(Icons.image_not_supported)),
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
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
        ],
      ),
    );
  }
}
