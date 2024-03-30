import 'dart:convert';

import 'package:piwigo_ng/core/data/datasources/local/preferences_datasource.dart';
import 'package:piwigo_ng/core/utils/constants/api_constants.dart';
import 'package:piwigo_ng/core/utils/constants/local_key_constants.dart';

extension ApiPreferencesExtension on PreferencesDatasource {
  String? get apiBaseUrl => instance.getString(LocalKeyConstants.serverUrlKey);

  bool get isBasicAuthEnabled => instance.getBool(LocalKeyConstants.enableBasicAuthKey) ?? false;

  String? get apiBasicHeader {
    if (!isBasicAuthEnabled) return null;
    String username = instance.getString(LocalKeyConstants.basicUsernameKey) ?? '';
    String password = instance.getString(LocalKeyConstants.basicPasswordKey) ?? '';
    return '${ApiConstants.basicPrefix} ${base64.encode(utf8.encode('$username:$password'))}';
  }
}
