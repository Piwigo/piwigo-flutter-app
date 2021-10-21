import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';

SnackBar albumMovedSnackBar(BuildContext context) {
  return SnackBar(
    content: Text(appStrings(context).moveCategoryHUD_moved, style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar albumAddedSnackBar(BuildContext context) {
  return SnackBar(
    content: Text(appStrings(context).createNewAlbumHUD_created, style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar albumEditedSnackBar(BuildContext context) {
  return SnackBar(
    content: Text(appStrings(context).renameCategoryHUD_renamed, style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar albumDeletedSnackBar(BuildContext context) {
  return SnackBar(
    content: Text(appStrings(context).deleteCategoryHUD_deleted, style: TextStyle(color: Color(0xff479900))),
  );
}


SnackBar imagesMovedSnackBar(BuildContext context, int images) {
  return SnackBar(
    content: Text(appStrings(context).moveImageHUD_moved(images), style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar imagesAssignedSnackBar(BuildContext context, int images) {
  return SnackBar(
    content: Text(appStrings(context).copyImageHUD_copied(images), style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar imagesEditedSnackBar(BuildContext context, int images) {
  return SnackBar(
    content: Text(appStrings(context).renameImageHUD_renamed(images), style: TextStyle(color: Color(0xff479900))),
  );
}

SnackBar errorSnackBar(BuildContext context, String message) {
  return SnackBar(
    content: Text('$message', style: TextStyle(color: Theme.of(context).errorColor)),
  );
}