import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/images.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    Key? key,
    this.onPressed,
    this.selected = false,
    required this.image,
  }) : super(key: key);

  final Function()? onPressed;
  final bool selected;
  final ImageModel image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            image.derivatives['medium']['url'],
            fit: BoxFit.cover,
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            curve: Curves.ease,
            opacity: selected ? 0.5 : 0.0,
            child: Container(
              color: Colors.black,
              child: const Center(),
            ),
          ),
        ],
      ),
    );
  }
}
