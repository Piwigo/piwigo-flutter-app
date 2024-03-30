import 'package:piwigo_ng/core/enum/sort_method_enum.dart';
import 'package:piwigo_ng/features/images/data/enums/image_size_enum.dart';

class SettingsConstants {
  //region Albums
  static const ImageSizeEnum defaultAlbumThumbnailSize = ImageSizeEnum.thumb;

  //endregion

  //region Images
  static const ImageSizeEnum defaultImageThumbnailSize = ImageSizeEnum.thumb;

  static const SortMethodEnum defaultImageSort = SortMethodEnum.custom;

  static const bool defaultShowThumbnailTitle = false;

  //endregion

  static const int defaultElementPerPage = 100;
}
