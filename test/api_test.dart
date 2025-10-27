import 'package:flutter_test/flutter_test.dart';
import 'package:piwigo_ng/data/services/api_client.dart';

void main() {
  test('API getVersion HTTPS ',() async {
    final apiClient =
      ApiClient.fromURL('https://demo1.piwigo.com/');
    expect(await apiClient.getVersion(), "15.7.0");
  });
}