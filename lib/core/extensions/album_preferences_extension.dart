import 'package:piwigo_ng/core/data/datasources/local/preferences_datasource.dart';
import 'package:piwigo_ng/core/injector/injector.dart';
import 'package:piwigo_ng/core/utils/constants/local_key_constants.dart';
import 'package:piwigo_ng/core/utils/constants/settings_constants.dart';
import 'package:piwigo_ng/features/images/data/enums/image_size_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension AlbumPreferencesExtension on PreferencesDatasource {
  SharedPreferences get _prefs => serviceLocator();

  ImageSizeEnum get getAlbumThumbnailSize => ImageSizeEnum.fromJson(
        _prefs.getString(LocalKeyConstants.albumThumbnailSizeKey) ?? SettingsConstants.defaultAlbumThumbnailSize.value,
      );

  ImageSizeEnum get getImageThumbnailSize => ImageSizeEnum.fromJson(
        _prefs.getString(LocalKeyConstants.imageThumbnailSizeKey) ?? SettingsConstants.defaultImageThumbnailSize.value,
      );

  bool get getShowThumbnailTitle {
    return _prefs.getBool(LocalKeyConstants.showThumbnailTitleKey) ?? SettingsConstants.defaultShowThumbnailTitle;
  }
}
