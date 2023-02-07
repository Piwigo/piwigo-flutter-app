import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/tag_model.dart';

class TagChip extends StatelessWidget {
  const TagChip({Key? key, required this.tag, this.onTap, this.icon}) : super(key: key);

  final Widget? icon;
  final TagModel tag;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: ShapeDecoration(
          shape: StadiumBorder(),
          color: Theme.of(context).chipTheme.backgroundColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                tag.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (icon != null) icon!,
          ],
        ),
      ),
    );
  }
}
