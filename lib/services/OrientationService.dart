

import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';

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


int getImageCrossAxisCount(BuildContext context) {
  if(isPortrait(context)) {
    return API.prefs.getDouble("portrait_image_count").ceil();
  }
  return API.prefs.getDouble("landscape_image_count").ceil();
}
void setImageCrossAxisCount(BuildContext context, double value) {
  if(isPortrait(context) && value <= Constants.portraitImageCountMax && value >= Constants.portraitImageCountMin) {
    API.prefs.setDouble("portrait_image_count", value);
    print('Set Portrait image count ${API.prefs.getDouble("portrait_image_count")}');
  } else if (value <= Constants.landscapeImageCountMax && value >= Constants.landscapeImageCountMin) {
    API.prefs.setDouble("landscape_image_count", value);
    print('Set Landscape image count ${API.prefs.getDouble("landscape_image_count")}');
  }
}
void incrementImageCrossAxisCount(BuildContext context) {
  if(isPortrait(context) && API.prefs.getDouble("portrait_image_count") < Constants.portraitImageCountMax) {
    int value = API.prefs.getDouble("portrait_image_count").ceil()+1;
    API.prefs.setDouble("portrait_image_count", value.toDouble());
    print('increment: ${API.prefs.getDouble("portrait_image_count")}');
  } else if (API.prefs.getDouble("landscape_image_count") < Constants.landscapeImageCountMax) {
    int value = API.prefs.getDouble("landscape_image_count").ceil()+1;
    API.prefs.setDouble("landscape_image_count", value.toDouble());
    print('increment: ${API.prefs.getDouble("landscape_image_count")}');
  }
}
void decrementImageCrossAxisCount(BuildContext context) {
  if(isPortrait(context) && API.prefs.getDouble("portrait_image_count") > Constants.portraitImageCountMin) {
    int value = API.prefs.getDouble("portrait_image_count").ceil()-1;
    API.prefs.setDouble("portrait_image_count", value.toDouble());
    print('decrement: ${API.prefs.getDouble("portrait_image_count")}');
  } else if (API.prefs.getDouble("landscape_image_count") > Constants.landscapeImageCountMin) {
    int value = API.prefs.getDouble("landscape_image_count").ceil()-1;
    API.prefs.setDouble("landscape_image_count", value.toDouble());
    print('decrement: ${API.prefs.getDouble("landscape_image_count")}');
  }
}
