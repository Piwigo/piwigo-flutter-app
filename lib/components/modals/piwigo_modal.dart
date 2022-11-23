import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class PiwigoModal extends StatelessWidget {
  const PiwigoModal({
    Key? key,
    this.title,
    this.subtitle,
    this.content,
    this.canCancel = false,
    this.fullscreen = false,
  }) : super(key: key);

  final String? title;
  final String? subtitle;
  final Widget? content;
  final bool canCancel;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      backgroundColor: Theme.of(context).backgroundColor,
      enableDrag: false,
      onClosing: () {},
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Builder(builder: (context) {
          Widget? titleWidget;
          Widget? subtitleWidget;
          List<Widget>? cancelWidget;
          if (title != null) {
            titleWidget = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }
          if (subtitle != null) {
            subtitleWidget = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
          if (canCancel) {
            cancelWidget = [
              Divider(
                indent: 16.0,
                endIndent: 16.0,
                height: 8.0,
              ),
              PiwigoButton(
                color: Colors.transparent,
                style: Theme.of(context).textTheme.titleSmall,
                onPressed: () => Navigator.of(context).pop(null),
                text: appStrings.alertCancelButton,
              ),
            ];
          }
          if (fullscreen) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (titleWidget != null) titleWidget,
                  if (subtitleWidget != null) subtitleWidget,
                  if (content != null)
                    Expanded(
                      child: content!,
                    ),
                  if (cancelWidget != null) ...cancelWidget,
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            children: [
              if (titleWidget != null) titleWidget,
              if (subtitleWidget != null) subtitleWidget,
              if (content != null) content!,
              if (cancelWidget != null) ...cancelWidget,
            ],
          );
        }),
      ),
    );
  }
}
