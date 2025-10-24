import 'dart:convert' as convert;
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient(this.host, {this.useHTTPS = true});
  final String host;
  final bool useHTTPS;

  Future<String> getVersion() async {
    var url = useHTTPS?
    Uri.https(host,"ws.php?format=json&method=pwg.getVersion") :
    Uri.http("$host/ws.php?format=json&method=pwg.getVersion");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
      convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse['result'] as String;
    } else {
      throw HttpException("Invalid response : ${response.statusCode}",uri: url);
    }
  }
}