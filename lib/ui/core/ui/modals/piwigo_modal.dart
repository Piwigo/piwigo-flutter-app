import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:piwigo_ng/utils/settings.dart';

class PiwigoModal extends StatelessWidget {
  const PiwigoModal({
    Key? key,
    this.title,
    this.subtitle,
    this.content,
  }) : super(key: key);

  final String? title;
  final String? subtitle;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Settings.modalMaxWidth,
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        controller: ModalScrollController.of(context),
        shrinkWrap: true,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            primary: false,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close),
            ),
            title: Text(
              title ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                subtitle!,
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          if (content != null) content!,
        ],
      ),
    );
  }
}

Future<T?> showPiwigoModal<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) {
  return showMaterialModalBottomSheet<T>(
    context: context,
    // isScrollControlled: true,
    // useSafeArea: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    // constraints: BoxConstraints(
    //   maxWidth: Settings.modalMaxWidth,
    // ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(15.0),
      ),
    ),
    builder: (context) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: builder.call(context),
      );
    },
  );
}
