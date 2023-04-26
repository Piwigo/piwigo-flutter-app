import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class ChooseMoveOptionModal extends StatelessWidget {
  const ChooseMoveOptionModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PiwigoModal(
      title: appStrings.moveImage_title,
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              minLeadingWidth: 24,
              leading: Icon(Icons.drive_file_move,
                  color: Theme.of(context).primaryColor),
              title: Text(appStrings.moveImage_title),
              onTap: () => Navigator.of(context).pop(0),
            ),
            ListTile(
              minLeadingWidth: 24,
              leading: Icon(Icons.copy, color: Theme.of(context).primaryColor),
              title: Text(appStrings.copyImage_title),
              onTap: () => Navigator.of(context).pop(1),
            ),
          ],
        ),
      ),
    );
  }
}
