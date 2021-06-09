import 'package:flutter/material.dart';

SnackBar albumMovedSnackBar(String movedCategory, String parentCategory) {
  return SnackBar(
    content: Text("Moved album $movedCategory to $parentCategory", style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar albumAddedSnackBar(String addedCategory) {
  return SnackBar(
    content: Text("Created album $addedCategory", style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar albumEditedSnackBar(String editedCategory) {
  return SnackBar(
    content: Text("Edited album $editedCategory", style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar albumDeletedSnackBar(String deletedCategory) {
  return SnackBar(
    content: Text("Deleted album $deletedCategory", style: TextStyle(color: Color(0xff479900))),
  );
}


SnackBar imageMovedSnackBar(String image, String parentCategory) {
  return SnackBar(
    content: Text("Moved image $image to $parentCategory", style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar imagesMovedSnackBar(int images, String parentCategory) {
  return SnackBar(
    content: Text("Moved $images images to $parentCategory", style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar imageAssignedSnackBar(String image, String parentCategory) {
  return SnackBar(
    content: Text("Assigned image $image to $parentCategory", style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar imagesAssignedSnackBar(int images, String parentCategory) {
  return SnackBar(
    content: Text("Assigned $images images to $parentCategory", style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar imageEditedSnackBar(String image) {
  return SnackBar(
    content: Text("Edited $image", style: TextStyle(color: Color(0xff479900))),
  );
}
SnackBar imagesEditedSnackBar(int images) {
  return SnackBar(
    content: Text("Edited $images images", style: TextStyle(color: Color(0xff479900))),
  );
}

SnackBar errorSnackBar(BuildContext context, String message) {
  return SnackBar(
    content: Text('$message', style: TextStyle(color: Theme.of(context).errorColor)),
  );
}