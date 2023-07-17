import 'package:flutter/material.dart';
import 'package:piwigo_ng/utils/resources.dart';

class SelectChip extends StatelessWidget {
  const SelectChip({
    Key? key,
    required this.label,
    this.onTap,
    this.icon,
    this.selected = false,
  }) : super(key: key);

  final Widget? icon;
  final bool selected;
  final String label;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      elevation: .0,
      side: BorderSide.none,
      labelStyle: TextStyle(
        fontSize: 14,
        color: selected
            ? AppColors.white
            : Theme.of(context).textTheme.bodyMedium!.color,
      ),
      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
      checkmarkColor: AppColors.white,
      selected: selected,
      onSelected: (_) => onTap?.call(),
      label: Text(label),
    );
  }
}

class PiwigoChip extends StatelessWidget {
  const PiwigoChip({
    Key? key,
    required this.label,
    this.onRemove,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  final String label;
  final Function()? onRemove;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      elevation: .0,
      side: BorderSide.none,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      deleteIconColor: AppColors.white,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 14,
        color: AppColors.white,
      ),
      onDeleted: () => onRemove?.call(),
    );
  }
}
