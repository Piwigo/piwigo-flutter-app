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
SnackBar albumDeletedSnackBar(String deletedCategory) {
  return SnackBar(
    content: Text("Deleted album $deletedCategory", style: TextStyle(color: Color(0xff479900))),
  );
}