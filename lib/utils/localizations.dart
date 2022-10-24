import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:piwigo_ng/app.dart';

AppLocalizations get appStrings => AppLocalizations.of(App.scaffoldMessengerKey.currentContext!)!;

Map<int, String> get privacyLevels => {
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

Map<int, String> get albumSort => {
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

String thumbnailSize(String size) {
  switch (size) {
    case 'square':
      return appStrings.thumbnailSizeSquare;
    case 'thumb':
      return appStrings.thumbnailSizeThumbnail;
    case '2small':
      return appStrings.thumbnailSizeXXSmall;
    case 'xsmall':
      return appStrings.thumbnailSizeXSmall;
    case 'small':
      return appStrings.thumbnailSizeSmall;
    case 'medium':
      return appStrings.thumbnailSizeMedium;
    case 'large':
      return appStrings.thumbnailSizeLarge;
    case 'xlarge':
      return appStrings.thumbnailSizeXLarge;
    case 'xxlarge':
      return appStrings.thumbnailSizeXXLarge;
    case 'full':
      return appStrings.thumbnailSizexFullRes;
    default:
      return 'null';
  }
}

String photoSize(String size) {
  switch (size) {
    case 'square':
      return appStrings.imageSizeSquare;
    case 'thumb':
      return appStrings.imageSizeThumbnail;
    case '2small':
      return appStrings.imageSizeXXSmall;
    case 'xsmall':
      return appStrings.imageSizeXSmall;
    case 'small':
      return appStrings.imageSizeSmall;
    case 'medium':
      return appStrings.imageSizeMedium;
    case 'large':
      return appStrings.imageSizeLarge;
    case 'xlarge':
      return appStrings.imageSizeXLarge;
    case 'xxlarge':
      return appStrings.imageSizeXXLarge;
    case 'full':
      return appStrings.imageSizexFullRes;
    default:
      return 'null';
  }
}
