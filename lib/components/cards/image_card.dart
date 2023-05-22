import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    Key? key,
    this.onPressed,
    this.selected = false,
  }) : super(key: key);

  final Function()? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            "https://png.pngtree.com/background/20210711/original/pngtree-round-gold-frame-picture-image_1155839.jpg",
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
