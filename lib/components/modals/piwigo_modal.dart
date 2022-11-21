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
  }) : super(key: key);

  final String? title;
  final String? subtitle;
  final Widget? content;
  final bool canCancel;

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
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            if (content != null) content!,
            if (canCancel) ...[
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
            ]
          ],
        ),
      ),
    );
  }
}
