import 'package:piwigo_ng/app.dart';

import '../l10n/app_localizations.dart';

AppLocalizations get appStrings =>
    AppLocalizations.of(App.scaffoldMessengerKey.currentContext!)!;

enum PrivacyLevel {
  unchanged,
  everybody,
  contacts,
  friends,
  family,
  admins,
}

extension PrivacyLevelExtension on PrivacyLevel {
  String get localization {
    switch (this) {
      case PrivacyLevel.unchanged:
        return appStrings.privacyLevel_unchanged;
      case PrivacyLevel.everybody:
        return appStrings.privacyLevel_everybody;
      case PrivacyLevel.contacts:
        return appStrings.privacyLevel_adminsFamilyFriendsContacts;
      case PrivacyLevel.friends:
        return appStrings.privacyLevel_adminsFamilyFriends;
      case PrivacyLevel.family:
        return appStrings.privacyLevel_adminFamily;
      case PrivacyLevel.admins:
        return appStrings.privacyLevel_admin;
    }
  }

  int? get value {
    switch (this) {
      case PrivacyLevel.unchanged:
        return null;
      case PrivacyLevel.everybody:
        return 0;
      case PrivacyLevel.contacts:
        return 1;
      case PrivacyLevel.friends:
        return 2;
      case PrivacyLevel.family:
        return 4;
      case PrivacyLevel.admins:
        return 8;
    }
  }
}

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
    case 'lt':
      return 'Lietuvių kalba';
    case 'sk':
      return 'Slovenčina';
    case 'zh':
      return '中文';
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
