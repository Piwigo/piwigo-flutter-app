import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageDatasource {
  const SecureStorageDatasource();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  FlutterSecureStorage get instance => _secureStorage;
}
