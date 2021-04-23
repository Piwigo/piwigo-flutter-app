import 'package:flutter/material.dart';

SnackBar albumMovedSnackBar(String movedCategory, String parentCategory) {
  return SnackBar(
    content: Text("Moved $movedCategory to $parentCategory"),
  );
}