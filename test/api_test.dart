import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:piwigo_ng/data/services/api_client.dart';

void main() {
  test('API HTTPS getVersion - ok',() async {
    final apiClient =
      ApiClient('static-testing.la-taniere-solidaire.gay');
    expect(await apiClient.getVersion(), "15.6.0");
  });
  test('API HTTPS getVersion - 404',() async { // Does not work yet
    final apiClient = ApiClient('piwigo.exemple.com');
    expect(await apiClient.getVersion(), throwsA(
      predicate((e) => e is HttpException && e.message == "Invalid response : 404")
    ));
  });
}