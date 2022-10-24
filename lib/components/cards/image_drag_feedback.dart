import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/cards/image_card.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/utils/resources.dart';

class ImageDragFeedback extends StatelessWidget {
  const ImageDragFeedback({
    Key? key,
    required this.image,
    this.stackedImages = const [],
    this.action,
  }) : super(key: key);

  final List<ImageModel> stackedImages;
  final ImageModel image;
  final Widget? action;

  static final double feedbackSize = 96.0;

  final Duration selectDuration = const Duration(milliseconds: 200);
  final Curve selectCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: feedbackSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: selectDuration,
            curve: selectCurve,
            top: action != null ? -40 : 40,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppShadows.dragStack,
                color: Theme.of(context).cardColor,
              ),
              child: action ?? const SizedBox.square(dimension: 24),
            ),
          ),
          ...List.generate(stackedImages.length + 1, (index) {
            ImageModel stackImage;
            if (index < stackedImages.length) {
              stackImage = stackedImages[index];
            } else {
              stackImage = image;
            }
            return Positioned(
              top: 8.0 * index,
              left: 8.0 * index,
              child: Container(
                height: feedbackSize - 16,
                width: feedbackSize - 16,
                decoration: BoxDecoration(boxShadow: AppShadows.dragStack),
                child: ImageCard(image: stackImage),
              ),
            );
          }),
        ],
      ),
    );
  }
}
