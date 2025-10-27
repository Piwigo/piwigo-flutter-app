import 'package:flutter_test/flutter_test.dart';
import 'package:piwigo_ng/data/services/api_client.dart';

void main() {

  var piwigoUrl = {
    'default':'https://demo1.piwigo.com/',
    'subpath':'http://192.168.122.24/piwigo/'
  };

  test('API getVersion HTTPS ',() async {
    final apiClient =
      ApiClient.fromURL(piwigoUrl['default']!);
    expect(await apiClient.getVersion(), "15.7.0");
  });
  test('API getVersion HTTPS (subpath)',() async {
    final apiClient =
    ApiClient.fromURL(piwigoUrl['subpath']!);
    expect(await apiClient.getVersion(), "15.6.0");
  });
}