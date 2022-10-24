import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piwigo_ng/models/status_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences appPreferences;

void savePreferences(StatusModel status, {String? username, String? password}) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  storage.write(key: 'SERVER_USERNAME', value: username);
  storage.write(key: 'SERVER_PASSWORD', value: password);

  saveStatus(status);
}

void saveStatus(StatusModel status) async {
  appPreferences.setString('ACCOUNT_USERNAME', status.username);
  appPreferences.setString('USER_STATUS', status.status);
  appPreferences.setString('PWG_TOKEN', status.pwgToken);
  appPreferences.setString('VERSION', status.version);
  appPreferences.setStringList("AVAILABLE_SIZES", status.availableSizes);
  if (["admin", "webmaster"].contains(status.status)) {
    appPreferences.setBool("IS_USER_ADMIN", true);
    appPreferences.setInt('UPLOAD_FORM_CHUNK_SIZE', status.uploadFormChunkSize ?? 0);
    appPreferences.setString("FILE_TYPES", status.uploadFileTypes ?? '');
  } else {
    appPreferences.setBool("IS_USER_ADMIN", false);
  }
}
