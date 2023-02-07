import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piwigo_ng/api/images.dart';
import 'package:piwigo_ng/models/status_model.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single instance of SharedPreferences for local storage
late final SharedPreferences appPreferences;

/// Handles local storage keys
class Preferences {
  // ------------ Account ------------

  static const String serverUrlKey = 'SERVER_URL';
  static const String usernameKey = 'SERVER_USERNAME';
  static const String passwordKey = 'SERVER_PASSWORD';

  // ------------ Server ------------

  static const String accountUsernameKey = 'ACCOUNT_USERNAME';
  static const String userStatusKey = 'USER_STATUS';
  static String get getUserStatus {
    return appPreferences.getString(userStatusKey) ?? 'guest';
  }

  static const String communityStatusKey = 'COMMUNITY_STATUS';
  static const String tokenKey = 'PWG_TOKEN';
  static const String versionKey = 'VERSION';
  static const String availableSizesKey = 'AVAILABLE_SIZES';
  static List<String> get getAvailableSizes {
    return appPreferences.getStringList(availableSizesKey) ?? [];
  }

  static const String isAdminKey = 'IS_USER_ADMIN';
  static const String uploadChunkSizeKey = 'UPLOAD_FORM_CHUNK_SIZE';
  static const String fileTypesKey = 'FILE_TYPES';

  // ------------ Settings ------------

  static const String imageRowCountKey = 'IMAGE_ROW_COUNT';
  static int get getImageRowCount {
    return appPreferences.getInt(imageRowCountKey) ?? Settings.defaultImageRowCount;
  }

  static const String showThumbnailTitleKey = 'SHOW_THUMBNAIL_TITLE';
  static bool get getShowThumbnailTitle {
    return appPreferences.getBool(showThumbnailTitleKey) ?? Settings.defaultShowThumbnailTitle;
  }

  static const String removeMetadataKey = 'REMOVE_METADATA';
  static bool get getRemoveMetadata {
    return appPreferences.getBool(removeMetadataKey) ?? Settings.defaultRemoveMetadata;
  }

  static const String imageFullScreenSizeKey = 'IMAGE_FULL_SCREEN_SIZE';
  static String get getImageFullScreenSize {
    return appPreferences.getString(imageFullScreenSizeKey) ?? Settings.defaultImageFullScreenSize;
  }

  static const String imageThumbnailSizeKey = 'IMAGE_THUMBNAIL_SIZE';
  static String get getImageThumbnailSize {
    return appPreferences.getString(imageThumbnailSizeKey) ?? Settings.defaultImageThumbnailSize;
  }

  static const String imageSortKey = 'IMAGE_SORT';
  static SortMethods get getImageSort {
    String? sortValue = appPreferences.getString(imageSortKey);
    if (sortValue == null) {
      return Settings.defaultImageSort;
    }
    return Settings.sortFromValue(sortValue);
  }

  static const String albumThumbnailSizeKey = 'ALBUM_THUMBNAIL_SIZE';
  static String get getAlbumThumbnailSize {
    return appPreferences.getString(albumThumbnailSizeKey) ?? Settings.defaultAlbumThumbnailSize;
  }

  static const String uploadAuthorKey = 'UPLOAD_AUTHOR_NAME';
  static String? get getUploadAuthor {
    String? authorName = appPreferences.getString(uploadAuthorKey);
    if (authorName == null || authorName.isEmpty) return null;
    return appPreferences.getString(uploadAuthorKey);
  }

  static const String compressUploadKey = 'COMPRESS_BEFORE_UPLOAD';
  static bool get getCompressUpload {
    return appPreferences.getBool(compressUploadKey) ?? Settings.defaultCompress;
  }

  static const String deleteAfterUploadKey = 'DELETE_AFTER_UPLOAD';
  static bool get getDeleteAfterUpload {
    return appPreferences.getBool(deleteAfterUploadKey) ?? Settings.defaultDeleteAfterUpload;
  }

  static const String wifiUploadKey = 'UPLOAD_WIFI_ONLY';
  static bool get getWifiUpload {
    return appPreferences.getBool(wifiUploadKey) ?? Settings.defaultWifiUpload;
  }

  static const String uploadQualityKey = 'UPLOAD_QUALITY';
  static double get getUploadQuality {
    return appPreferences.getDouble(uploadQualityKey) ?? Settings.defaultUploadQuality;
  }

  static const String downloadDestinationKey = 'DOWNLOAD_DESTINATION';
  static Future<String?> get getDownloadDestination async {
    return appPreferences.getString(downloadDestinationKey) ?? await pickDirectoryPath();
  }

  static const String downloadNotificationKey = 'DOWNLOAD_NOTIFICATION';
  static bool get getDownloadNotification {
    return appPreferences.getBool(downloadNotificationKey) ?? true;
  }

  static const String uploadNotificationKey = 'UPLOAD_NOTIFICATION';
  static bool get getUploadNotification {
    return appPreferences.getBool(uploadNotificationKey) ?? true;
  }

  // ------------ Set preferences ------------

  /// Save account login (username and password)
  /// Then call saveStatus if status is not null
  static void saveId(StatusModel? status, {String? username, String? password}) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    storage.write(key: usernameKey, value: username);
    storage.write(key: passwordKey, value: password);

    if (status != null) {
      saveStatus(status);
    }
  }

  /// Saves server info retrieved from pwg.session.getStatus API call
  static void saveStatus(StatusModel status) async {
    appPreferences.setString(accountUsernameKey, status.username);
    appPreferences.setString(tokenKey, status.pwgToken);
    appPreferences.setString(versionKey, status.version);
    appPreferences.setStringList(availableSizesKey, status.availableSizes);
    if (status.realStatus != null) {
      appPreferences.setString(communityStatusKey, status.status);
      status.status = status.realStatus!;
    }
    if (['admin', 'webmaster'].contains(status.status)) {
      appPreferences.setBool(isAdminKey, true);
      appPreferences.setInt(uploadChunkSizeKey, status.uploadFormChunkSize ?? 0);
      appPreferences.setString(fileTypesKey, status.uploadFileTypes ?? '');
    } else {
      appPreferences.setBool(isAdminKey, false);
    }
    appPreferences.setString(userStatusKey, status.status);
  }
}
