import 'package:flutter/material.dart';
import 'package:piwigo_ng/data/services/api_client.dart';
import 'package:piwigo_ng/ui/authentification/widgets/login_screen.dart';

class InstanceScreen extends StatefulWidget {
  const InstanceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _InstanceScreenState();
}

class _InstanceScreenState extends State<InstanceScreen> {
  final instanceURLTextController = TextEditingController();
  String? _piwigoVersion;

  @override
  void initState() {
    super.initState();
    instanceURLTextController.addListener(checkURL);
  }

  @override
  void dispose() {
    instanceURLTextController.dispose();
    super.dispose();
  }

  Future<void> checkURL() async {
    var uri = Uri.parse(instanceURLTextController.text);
    if (uri.isAbsolute) {
      var apiClient = ApiClient(uri.authority, uri.path, uri.scheme != 'http');
      try {
        setState(() async {
          _piwigoVersion = await apiClient.getVersion();
        });
      } catch (e) {
        print(e);
      }
    } else {
      setState(() {
        _piwigoVersion = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16.0,
          children: [
            Image(image: AssetImage('assets/piwigo_logo.png')),
            TextFormField(
              controller: instanceURLTextController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Server URL",
              ),
            ),
            Visibility(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _piwigoVersion != null ? Icons.check : Icons.close,
                    color: _piwigoVersion != null ? Colors.green : Colors.red,
                  ),
                  Text(_piwigoVersion ?? 'Invalid URL'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _piwigoVersion == null
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    )
                  : null,
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
