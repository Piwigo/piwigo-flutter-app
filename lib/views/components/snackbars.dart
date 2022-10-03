import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';

SnackBar albumMovedSnackBar(BuildContext context) {
  return successSnackBar(context, appStrings(context).moveCategoryHUD_moved);
}
SnackBar albumAddedSnackBar(BuildContext context) {
  return successSnackBar(context, appStrings(context).createNewAlbumHUD_created);
}
SnackBar albumEditedSnackBar(BuildContext context) {
  return successSnackBar(context, appStrings(context).renameCategoryHUD_renamed);
}
SnackBar albumDeletedSnackBar(BuildContext context) {
  return successSnackBar(context, appStrings(context).deleteCategoryHUD_deleted);
}


SnackBar imagesMovedSnackBar(BuildContext context, int images) {
  return successSnackBar(context, appStrings(context).moveImageHUD_moved(images));
}
SnackBar imagesAssignedSnackBar(BuildContext context, int images) {
  return successSnackBar(context, appStrings(context).copyImageHUD_copied(images));
}
SnackBar imagesEditedSnackBar(BuildContext context, int images) {
  return successSnackBar(context, appStrings(context).renameImageHUD_renamed(images));
}

SnackBar errorSnackBar(BuildContext context, String message) {
  return SnackBar(
    backgroundColor: Theme.of(context).errorColor,
    content: Text('$message',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
  );
}
SnackBar successSnackBar(BuildContext context, String message) {
  return SnackBar(
    backgroundColor: Colors.green,
    content: Text('$message',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
  );
}
SnackBar infoSnackBar(BuildContext context, String message) {
  return SnackBar(
    backgroundColor: Colors.orange,
    content: Text('$message',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
  );
}