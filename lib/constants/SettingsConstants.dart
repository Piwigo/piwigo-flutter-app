import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:piwigo_ng/api/API.dart';

class Constants {

  Constants(this.context);

  final BuildContext context;

  static Map<int, String> albumSort = {
    0: "Photo Title, A → Z",
    1: "Photo Title, Z > A",
    2: "Creation Date, New > Old",
    3: "Creation Date, Old > New",
    4: "Addition Date, New > Old",
    5: "Addition Date, Old > New",
    6: "File Name, A > Z",
    7: "File Name, Z > A",
    8: "Rate, High > Low",
    9: "Rate, Low > High",
    10: "Views, High > Low",
    11: "Views, Low > High",
    12: "Manual Sort",
    13: "Random Sort"
  };
  static Map<int, String> privacyLevels = {
    0: 'Everyone',
    1: 'Admins, Family, Friends, Contacts',
    2: 'Admins, Family, Friends',
    4: 'Admins, Family',
    8: 'Admins',
  };

  static double PORTRAIT_IMAGE_COUNT_MIN = 1;
  static double PORTRAIT_IMAGE_COUNT_MAX = 6;
  static double LANDSCAPE_IMAGE_COUNT_MIN = 4.0;
  static double LANDSCAPE_IMAGE_COUNT_MAX = 10.0;

}

AppLocalizations appStrings(context) {
  return AppLocalizations.of(context);
}

Map<int, String> albumSort(context) {
  return {
    0: appStrings(context).categorySort_nameAscending,
    1: appStrings(context).categorySort_nameDescending,
    2: appStrings(context).categorySort_fileNameAscending,
    3: appStrings(context).categorySort_fileNameDescending,
    4: appStrings(context).categorySort_dateCreatedDescending,
    5: appStrings(context).categorySort_dateCreatedAscending,
    6: appStrings(context).categorySort_datePostedDescending,
    7: appStrings(context).categorySort_datePostedAscending,
    8: appStrings(context).categorySort_ratingScoreDescending,
    9: appStrings(context).categorySort_ratingScoreAscending,
    10: appStrings(context).categorySort_visitsDescending,
    11: appStrings(context).categorySort_visitsAscending,
    12: appStrings(context).categorySort_manual,
    13: appStrings(context).categorySort_random,
  };
}

Map<int, String> privacyLevels(context) {
  return {
    -1: appStrings(context).privacyLevel_unchanged,
    0: appStrings(context).privacyLevel_everybody,
    1: appStrings(context).privacyLevel_adminsFamilyFriendsContacts,
    2: appStrings(context).privacyLevel_adminsFamilyFriends,
    4: appStrings(context).privacyLevel_adminFamily,
    8: appStrings(context).privacyLevel_admin,
  };
}

String thumbnailSize(context, String size) {
  String sizeName = "";

  switch(size) {
    case "square": sizeName = appStrings(context).thumbnailSizeSquare;
      break;
    case "thumb": sizeName = appStrings(context).thumbnailSizeThumbnail;
      break;
    case "2small": sizeName = appStrings(context).thumbnailSizeXXSmall;
      break;
    case "xsmall": sizeName = appStrings(context).thumbnailSizeXSmall;
      break;
    case "small": sizeName = appStrings(context).thumbnailSizeSmall;
      break;
    case "medium": sizeName = appStrings(context).thumbnailSizeMedium;
      break;
    case "large": sizeName = appStrings(context).thumbnailSizeLarge;
      break;
    case "xlarge": sizeName = appStrings(context).thumbnailSizeXLarge;
      break;
    case "xxlarge": sizeName = appStrings(context).thumbnailSizeXXLarge;
      break;
    case "full": sizeName = appStrings(context).thumbnailSizexFullRes;
      break;
    default: sizeName = "null";
      break;
  }

  return sizeName;
}

String photoSize(context, String size) {
  String sizeName = "";

  switch(size) {
    case "square": sizeName = appStrings(context).imageSizeSquare;
      break;
    case "thumb": sizeName = appStrings(context).imageSizeThumbnail;
      break;
    case "2small": sizeName = appStrings(context).imageSizeXXSmall;
      break;
    case "xsmall": sizeName = appStrings(context).imageSizeXSmall;
      break;
    case "small": sizeName = appStrings(context).imageSizeSmall;
      break;
    case "medium": sizeName = appStrings(context).imageSizeMedium;
      break;
    case "large": sizeName = appStrings(context).imageSizeLarge;
      break;
    case "xlarge": sizeName = appStrings(context).imageSizeXLarge;
      break;
    case "xxlarge": sizeName = appStrings(context).imageSizeXXLarge;
      break;
    case "full": sizeName = appStrings(context).imageSizexFullRes;
      break;
    default: sizeName = "null";
      break;
  }

  return sizeName;
}

