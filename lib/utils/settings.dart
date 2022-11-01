import 'package:flutter/material.dart';
import 'package:piwigo_ng/services/preferences_service.dart';

class Settings {
  static const String defaultAlbumThumbnailSize = 'medium';
  static const String defaultImageThumbnailSize = 'medium';
  static const String defaultImageFullScreenSize = 'medium';
  static const bool defaultRemoveMetadata = false;
  static const bool defaultCompress = false;
  static const bool defaultDeleteAfterUpload = false;
  static const bool defaultWifiUpload = true;
  static const bool defaultShowThumbnailTitle = false;
  static const int defaultImageRowCount = 4;
  static const int minImageRowCount = 1; // Settings slider min range
  static const int maxImageRowCount = 6; // Settings slider max range
  static const double defaultAlbumGridSize = 448.0;
  static const double defaultUploadQuality = 1.0;

  /// Get image row count based on device orientation
  static int getImageCrossAxisCount(BuildContext context, [int? nbImageRow]) {
    final Size size = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final int portraitImageRowCount = nbImageRow ?? Preferences.getImageRowCount;
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
}
