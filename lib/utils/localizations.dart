import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:piwigo_ng/app.dart';

AppLocalizations appStrings = AppLocalizations.of(App.appKey.currentContext!)!;

Map<int, String> privacyLevels(context) => {
      -1: appStrings.privacyLevel_unchanged,
      0: appStrings.privacyLevel_everybody,
      1: appStrings.privacyLevel_adminsFamilyFriendsContacts,
      2: appStrings.privacyLevel_adminsFamilyFriends,
      4: appStrings.privacyLevel_adminFamily,
      8: appStrings.privacyLevel_admin,
    };

String getLanguageFromCode(String code) {
  switch (code) {
    case 'de':
      return 'Deutsch';
      break;
    case 'en':
      return 'English';
      break;
    case 'es':
      return 'Español';
      break;
    case 'fr':
      return 'Français';
      break;
    case 'zh':
      return '中国人';
      break;
    default:
      return code;
      break;
  }
}

Map<int, String> albumSort(context) => {
      0: appStrings.categorySort_nameAscending,
      1: appStrings.categorySort_nameDescending,
      2: appStrings.categorySort_fileNameAscending,
      3: appStrings.categorySort_fileNameDescending,
      4: appStrings.categorySort_dateCreatedDescending,
      5: appStrings.categorySort_dateCreatedAscending,
      6: appStrings.categorySort_datePostedDescending,
      7: appStrings.categorySort_datePostedAscending,
      8: appStrings.categorySort_ratingScoreDescending,
      9: appStrings.categorySort_ratingScoreAscending,
      10: appStrings.categorySort_visitsDescending,
      11: appStrings.categorySort_visitsAscending,
      12: appStrings.categorySort_manual,
      13: appStrings.categorySort_random,
    };

String thumbnailSize(context, String size) {
  String sizeName = "";

  switch (size) {
    case "square":
      sizeName = appStrings.thumbnailSizeSquare;
      break;
    case "thumb":
      sizeName = appStrings.thumbnailSizeThumbnail;
      break;
    case "2small":
      sizeName = appStrings.thumbnailSizeXXSmall;
      break;
    case "xsmall":
      sizeName = appStrings.thumbnailSizeXSmall;
      break;
    case "small":
      sizeName = appStrings.thumbnailSizeSmall;
      break;
    case "medium":
      sizeName = appStrings.thumbnailSizeMedium;
      break;
    case "large":
      sizeName = appStrings.thumbnailSizeLarge;
      break;
    case "xlarge":
      sizeName = appStrings.thumbnailSizeXLarge;
      break;
    case "xxlarge":
      sizeName = appStrings.thumbnailSizeXXLarge;
      break;
    case "full":
      sizeName = appStrings.thumbnailSizexFullRes;
      break;
    default:
      sizeName = "null";
      break;
  }

  return sizeName;
}

String photoSize(context, String size) {
  String sizeName = "";

  switch (size) {
    case "square":
      sizeName = appStrings.imageSizeSquare;
      break;
    case "thumb":
      sizeName = appStrings.imageSizeThumbnail;
      break;
    case "2small":
      sizeName = appStrings.imageSizeXXSmall;
      break;
    case "xsmall":
      sizeName = appStrings.imageSizeXSmall;
      break;
    case "small":
      sizeName = appStrings.imageSizeSmall;
      break;
    case "medium":
      sizeName = appStrings.imageSizeMedium;
      break;
    case "large":
      sizeName = appStrings.imageSizeLarge;
      break;
    case "xlarge":
      sizeName = appStrings.imageSizeXLarge;
      break;
    case "xxlarge":
      sizeName = appStrings.imageSizeXXLarge;
      break;
    case "full":
      sizeName = appStrings.imageSizexFullRes;
      break;
    default:
      sizeName = "null";
      break;
  }

  return sizeName;
}
