import 'package:flutter/material.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';

enum SortMethods {
  nameAsc,
  nameDesc,
  fileAsc,
  fileDesc,
  dateCreatedAsc,
  dateCreatedDesc,
  dateAvailableAsc,
  dateAvailableDesc,
  rateAsc,
  rateDesc,
  hitAsc,
  hitDesc,
  random,
}

extension SortMethodsExtension on SortMethods {
  String get label {
    switch (this) {
      case SortMethods.nameAsc:
        return appStrings.categorySort_nameAscending;
      case SortMethods.nameDesc:
        return appStrings.categorySort_nameDescending;
      case SortMethods.fileAsc:
        return appStrings.categorySort_fileNameAscending;
      case SortMethods.fileDesc:
        return appStrings.categorySort_fileNameDescending;
      case SortMethods.dateCreatedAsc:
        return appStrings.categorySort_dateCreatedAscending;
      case SortMethods.dateCreatedDesc:
        return appStrings.categorySort_dateCreatedDescending;
      case SortMethods.dateAvailableAsc:
        return appStrings.categorySort_datePostedAscending;
      case SortMethods.dateAvailableDesc:
        return appStrings.categorySort_datePostedDescending;
      case SortMethods.rateAsc:
        return appStrings.categorySort_ratingScoreAscending;
      case SortMethods.rateDesc:
        return appStrings.categorySort_ratingScoreDescending;
      case SortMethods.hitAsc:
        return appStrings.categorySort_visitsAscending;
      case SortMethods.hitDesc:
        return appStrings.categorySort_visitsDescending;
      case SortMethods.random:
        return appStrings.categorySort_random;
    }
  }

  String get value {
    switch (this) {
      case SortMethods.nameAsc:
        return 'name ASC';
      case SortMethods.nameDesc:
        return 'name DESC';
      case SortMethods.fileAsc:
        return 'file ASC';
      case SortMethods.fileDesc:
        return 'file DESC';
      case SortMethods.dateCreatedAsc:
        return 'date_creation ASC';
      case SortMethods.dateCreatedDesc:
        return 'date_creation DESC';
      case SortMethods.dateAvailableAsc:
        return 'date_available ASC';
      case SortMethods.dateAvailableDesc:
        return 'date_available DESC';
      case SortMethods.rateAsc:
        return 'rating_score ASC';
      case SortMethods.rateDesc:
        return 'rating_score DESC';
      case SortMethods.hitAsc:
        return 'hit ASC';
      case SortMethods.hitDesc:
        return 'hit DESC';
      case SortMethods.random:
        return 'random';
    }
  }
}

class Settings {
  static const String privacyPolicyUrl =
      'https://piwigo.org/mobile-apps-privacy-policy&webview';
  static const String twitterUrl = 'https://twitter.com/piwigo';
  static const String forumUrl = 'https://piwigo.org/forum';
  static const String playStorePrefixUrl = 'market://details?id=';
  static const String crowdinUrl = 'https://crowdin.com/project/piwigo-ng';

  static const String defaultAlbumThumbnailSize = 'medium';
  static const String defaultImageThumbnailSize = 'medium';
  static const String defaultImageFullScreenSize = 'medium';
  static const SortMethods defaultImageSort = SortMethods.nameAsc;
  static const bool defaultRemoveMetadata = false;
  static const bool defaultCompress = false;
  static const bool defaultDeleteAfterUpload = false;
  static const bool defaultWifiUpload = true;
  static const bool defaultShowThumbnailTitle = false;
  static const int defaultImageRowCount = 4;
  static const int minImageRowCount = 1; // Settings slider min range
  static const int maxImageRowCount = 6; // Settings slider max range
  static const int defaultElementPerPage = 100; // API requests
  static const double defaultAlbumGridSize = 448.0;
  static const double defaultUploadQuality = 1.0;
  static const double modalMaxWidth = 600.0;
  static const int uploadNotificationId = 1;
  static const int autoUploadNotificationId = 2;
  static const List<Duration> autoUploadFrequencies = [
    Duration(hours: 1),
    Duration(hours: 6),
    Duration(hours: 12),
    Duration(days: 1),
    Duration(days: 7),
  ];

  /// Default autoUploadInterval in hours
  static const int defaultAutoUploadFrequency = 1;

  /// Get image row count based on device orientation
  static int getImageCrossAxisCount(BuildContext context, [int? nbImageRow]) {
    final Size size = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final int portraitImageRowCount =
        nbImageRow ?? Preferences.getImageRowCount;
    if (orientation == Orientation.portrait) return portraitImageRowCount;
    return (portraitImageRowCount * size.width / size.height).round();
    // final double crossAxisExtent = ((orientation == Orientation.portrait ? size.width : size.height)) / nbPortraitImageRow;
    // return (size.width / crossAxisExtent).round();
  }

  /// Key: SORT
  static const int defaultSort = 0;

  static String getDerivativeRatio(String derivative) {
    switch (derivative) {
      case 'square':
        return '(60x60)';
      case 'thumb':
        return '(72x72)';
      case '2small':
        return '(120x120)';
      case 'xsmall':
        return '(216x162)';
      case 'small':
        return '(288x216)';
      case 'medium':
        return '(396x297)';
      case 'large':
        return '(504x378)';
      case 'xlarge':
        return '(612x459)';
      case 'xxlarge':
        return '(828x621)';
      case 'full':
        return '';
      default:
        return '';
    }
  }

  static SortMethods sortFromValue(value) {
    switch (value) {
      case 'name ASC':
        return SortMethods.nameAsc;
      case 'name DESC':
        return SortMethods.nameDesc;
      case 'file ASC':
        return SortMethods.fileAsc;
      case 'file DESC':
        return SortMethods.fileDesc;
      case 'date_creation ASC':
        return SortMethods.dateCreatedAsc;
      case 'date_creation DESC':
        return SortMethods.dateCreatedDesc;
      case 'date_available ASC':
        return SortMethods.dateAvailableAsc;
      case 'date_available DESC':
        return SortMethods.dateAvailableDesc;
      case 'rating_score ASC':
        return SortMethods.rateAsc;
      case 'rating_score DESC':
        return SortMethods.rateDesc;
      case 'hit ASC':
        return SortMethods.hitAsc;
      case 'hit DESC':
        return SortMethods.hitDesc;
      default:
        return SortMethods.random;
    }
  }
}
