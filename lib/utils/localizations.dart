import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations appStrings(BuildContext context) => AppLocalizations.of(context)!;

Map<int, String> privacyLevels(BuildContext context) => {
      -1: appStrings(context).privacyLevel_unchanged,
      0: appStrings(context).privacyLevel_everybody,
      1: appStrings(context).privacyLevel_adminsFamilyFriendsContacts,
      2: appStrings(context).privacyLevel_adminsFamilyFriends,
      4: appStrings(context).privacyLevel_adminFamily,
      8: appStrings(context).privacyLevel_admin,
    };

String getLanguageFromCode(String code) {
  switch (code) {
    case 'de':
      return 'Deutsch';
    case 'en':
      return 'English';
    case 'es':
      return 'Español';
    case 'fr':
      return 'Français';
    case 'zh':
      return '中国人';
    default:
      return code;
  }
}

Map<int, String> albumSort(BuildContext context) => {
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

String thumbnailSize(BuildContext context, String size) {
  String sizeName = "";

  switch (size) {
    case "square":
      sizeName = appStrings(context).thumbnailSizeSquare;
      break;
    case "thumb":
      sizeName = appStrings(context).thumbnailSizeThumbnail;
      break;
    case "2small":
      sizeName = appStrings(context).thumbnailSizeXXSmall;
      break;
    case "xsmall":
      sizeName = appStrings(context).thumbnailSizeXSmall;
      break;
    case "small":
      sizeName = appStrings(context).thumbnailSizeSmall;
      break;
    case "medium":
      sizeName = appStrings(context).thumbnailSizeMedium;
      break;
    case "large":
      sizeName = appStrings(context).thumbnailSizeLarge;
      break;
    case "xlarge":
      sizeName = appStrings(context).thumbnailSizeXLarge;
      break;
    case "xxlarge":
      sizeName = appStrings(context).thumbnailSizeXXLarge;
      break;
    case "full":
      sizeName = appStrings(context).thumbnailSizexFullRes;
      break;
    default:
      sizeName = "null";
      break;
  }

  return sizeName;
}

String photoSize(BuildContext context, String size) {
  String sizeName = "";

  switch (size) {
    case "square":
      sizeName = appStrings(context).imageSizeSquare;
      break;
    case "thumb":
      sizeName = appStrings(context).imageSizeThumbnail;
      break;
    case "2small":
      sizeName = appStrings(context).imageSizeXXSmall;
      break;
    case "xsmall":
      sizeName = appStrings(context).imageSizeXSmall;
      break;
    case "small":
      sizeName = appStrings(context).imageSizeSmall;
      break;
    case "medium":
      sizeName = appStrings(context).imageSizeMedium;
      break;
    case "large":
      sizeName = appStrings(context).imageSizeLarge;
      break;
    case "xlarge":
      sizeName = appStrings(context).imageSizeXLarge;
      break;
    case "xxlarge":
      sizeName = appStrings(context).imageSizeXXLarge;
      break;
    case "full":
      sizeName = appStrings(context).imageSizexFullRes;
      break;
    default:
      sizeName = "null";
      break;
  }

  return sizeName;
}
