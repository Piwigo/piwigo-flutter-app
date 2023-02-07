import 'package:flutter/material.dart';

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
          shrinkWrap: true,
          children: [
            AppBar(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15.0),
                ),
              ),
              elevation: 0.0,
              scrolledUnderElevation: 5.0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(title ?? ''),
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
      ),
    );
  }
}
