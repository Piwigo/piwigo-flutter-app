import 'dart:convert' as convert;
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient(this.host, this.subpath, this.useHTTPS);
  final String host;
  final String subpath;
  final bool useHTTPS;

  factory ApiClient.fromURL(String url) {
    var uri = Uri.parse(url);
    return ApiClient(uri.host, uri.path, uri.scheme == 'https');
  }

  Future<Map<String, dynamic>> _getRequest(String method) async {
    var url = useHTTPS
        ? Uri.https(host, '$subpath/ws.php', {
            'format': 'json',
            'method': method,
          })
        : Uri.http(host, '$subpath/ws.php', {
            'format': 'json',
            'method': method,
          });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return convert.jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw HttpException(
        "Invalid response : ${response.statusCode}",
        uri: url,
      );
    }
  }

  // API calls

  Future<String> getVersion() async {
    return (await _getRequest('pwg.getVersion'))['result'] as String;
  }
}
