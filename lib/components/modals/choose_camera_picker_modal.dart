import 'package:flutter/material.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class ChooseCameraPickerModal extends StatelessWidget {
  const ChooseCameraPickerModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      backgroundColor: Theme.of(context).backgroundColor,
      enableDrag: false,
      onClosing: () {},
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        children: [
          ListTile(
            leading: Icon(Icons.photo_camera, color: Theme.of(context).primaryColor),
            title: Text(appStrings.categoryUpload_takePhoto),
            onTap: () => Navigator.of(context).pop(0),
          ),
          ListTile(
            leading: Icon(Icons.video_camera_back, color: Theme.of(context).primaryColor),
            title: Text(appStrings.categoryUpload_takeVideo),
            onTap: () => Navigator.of(context).pop(1),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.close),
            title: Text(appStrings.alertCancelButton),
            onTap: () => Navigator.of(context).pop(null),
          ),
        ],
      ),
    );
  }
}
