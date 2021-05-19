

import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/API.dart';

bool isPortrait(BuildContext context) {
  return MediaQuery.of(context).orientation == Orientation.portrait;
}

double albumGridItemHeight(BuildContext context) {
  if(isPortrait(context)) {
    return MediaQuery.of(context).size.width/3;
  }
  return MediaQuery.of(context).size.height/3;
}

double albumGridAspectRatio(BuildContext context) {
  if(isPortrait(context)) {
    return MediaQuery.of(context).size.width/albumGridItemHeight(context);
  }
  return (MediaQuery.of(context).size.width/2)/albumGridItemHeight(context);
}

int imageCrossAxisCount(BuildContext context) {
  if(isPortrait(context)) {
    return API.prefs.getDouble("portrait_image_count").ceil();
  }
  return API.prefs.getDouble("landscape_image_count").ceil();
}