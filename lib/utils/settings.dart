class Settings {
  /// Key: ALBUM_THUMBNAIL_SIZE
  static const String defaultAlbumThumbnailSize = 'medium';

  /// Key: IMAGE_THUMBNAIL_SIZE
  static const String defaultImageThumbnailSize = 'medium';

  /// Key: IMAGE_FULL_SCREEN_SIZE
  static const String defaultImageFullScreenSize = 'medium';

  /// Key: REMOVE_METADATA
  static const bool defaultRemoveMetadata = false;

  /// Key: SHOW_THUMBNAIL_TITLE
  static const bool defaultShowThumbnailTitle = false;

  /// Key: PORTRAIT_IMAGE_COUNT
  static const int defaultPortraitImageCount = 4;

  /// Key: SORT
  static const int defaultSort = 0;

  static getDerivativeRatio(String derivative) {
    switch (derivative) {
      case 'square' '':
        return '60x60';
      case 'thumb':
        return '72x72';
      case '2small':
        return '120x120';
      case 'xsmall':
        return '216x162';
      case 'small':
        return '288x216';
      case 'medium':
        return '396x297';
      case 'large':
        return '504x378';
      case 'xlarge':
        return '612x459';
      case 'xxlarge':
        return '828x621';
      case 'full':
        return '';
      default:
        return '';
    }
  }
}
