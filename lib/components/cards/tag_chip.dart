import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/tag_model.dart';

class SelectTagChip extends StatelessWidget {
  const SelectTagChip({
    Key? key,
    required this.tag,
    this.onTap,
    this.icon,
    this.selected = false,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  final Widget? icon;
  final bool selected;
  final TagModel tag;
  final Function()? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      visualDensity: VisualDensity.compact,
      elevation: 0.0,
      label: Text(tag.name),
      labelStyle: TextStyle(
        fontSize: 14,
        color: foregroundColor ??
            (selected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium!.color),
      ),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.transparent, width: 0.0),
      ),
      backgroundColor:
          backgroundColor ?? Theme.of(context).chipTheme.backgroundColor,
      checkmarkColor: Colors.white,
      selected: selected,
      onSelected: (_) => onTap?.call(),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({
    Key? key,
    required this.tag,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  final Widget? icon;
  final TagModel tag;
  final Function()? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return RawChip(
      visualDensity: VisualDensity.compact,
      elevation: 0.0,
      avatar: icon,
      label: Text(tag.name),
      labelStyle: TextStyle(
        fontSize: 14,
        color: foregroundColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      ),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.red, width: 5.0),
      ),
      backgroundColor:
          backgroundColor ?? Theme.of(context).chipTheme.backgroundColor,
      checkmarkColor: Colors.white,
      onSelected: (_) => onTap?.call(),
    );
  }
}
