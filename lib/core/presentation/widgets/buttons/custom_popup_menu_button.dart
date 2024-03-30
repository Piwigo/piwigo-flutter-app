import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';

class CustomPopupMenuButton extends StatelessWidget {
  const CustomPopupMenuButton({
    super.key,
    required this.items,
  });

  final List<CustomPopupMenuItem> items;

  bool get _hasNotification => items.where((CustomPopupMenuItem item) => item.notification).isNotEmpty;

  @override
  Widget build(BuildContext context) => PopupMenuButton<void>(
        position: PopupMenuPosition.under,
        icon: Badge(
          isLabelVisible: _hasNotification,
          child: const Icon(Icons.more_vert),
        ),
        itemBuilder: (BuildContext context) => items
            .where((CustomPopupMenuItem items) => items.available)
            .map<PopupMenuItem<void>>(
              (CustomPopupMenuItem item) => PopupMenuItem<void>(
                onTap: item.onTap,
                child: Row(
                  children: <Widget>[
                    Badge(
                      isLabelVisible: item.notification,
                      child: Icon(item.icon),
                    ),
                    const SizedBox(width: UIConstants.paddingSmall),
                    Text(
                      item.label,
                      style: context.theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
}

class CustomPopupMenuItem {
  const CustomPopupMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.available = true,
    this.notification = false,
  });

  final Function()? onTap;
  final String label;
  final IconData? icon;
  final bool available;
  final bool notification; // todo: notification
}
