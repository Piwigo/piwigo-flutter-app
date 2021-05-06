import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:piwigo_ng/api/SessionAPI.dart';

import '../services/upload/chunked_uploader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:piwigo_ng/api/API.dart';

class Uploader {
  BuildContext context;
  SnackBar endSnackBar;
  SnackBar snackBar;

  Uploader(this.context) {
    snackBar = SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Uploading"),
          CircularProgressIndicator(),
        ],
      ),
      duration: Duration(seconds: 5),
    );
    endSnackBar = SnackBar(
      content: Text('All photos are uploaded'),
      duration: Duration(seconds: 10),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
  }

  Future<void> _showUploadNotification(Map<String, dynamic> downloadStatus) async {
    final android = AndroidNotificationDetails(
        'channel id',
        'channel name',
        'channel description',
        priority: Priority.high,
        importance: Importance.max
    );
    final platform = NotificationDetails(android: android);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await API.localNotification.show(
        1,
        isSuccess ? 'Success' : 'Failure',
        isSuccess ? 'All files has been uploaded successfully!' : 'There was an error while downloading the file.',
        platform,
        payload: json
    );
  }

  void uploadPhotos(List<Asset> photos, String category) async {
    Map<String, dynamic> result = {
      'isSuccess': true,
      'filePath': null,
      'error': null,
    };

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    for(var element in photos) {
      Response response = await uploadChunk(element, category);
      API.dio.clear();
      print("Request: ${response.data}");

      if(json.decode(response.data)["stat"] == "ok") {} else {
        print("Request failed: ${response.statusCode}");

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.data}'),
        ));
      }
    }
    saveStatus((await sessionStatus())['result']);

    await _showUploadNotification(result);

    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // ScaffoldMessenger.of(context).showSnackBar(endSnackBar);
  }

  void upload(Asset photo, String category) async {
    Map<String, String> queries = {"format":"json", "method": "pwg.images.upload"};

    ByteData byteData = await photo.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();

    FormData formData =  FormData.fromMap({
      "category": category,
      "pwg_token": API.prefs.getString("pwg_token"),
      "file": MultipartFile.fromBytes(
        imageData,
        filename: photo.name,
      ),
      "name": photo.name,
    });

    Response response = await API.dio.post("ws.php",
      data: formData,
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      print('Upload ${response.data}');
      if(json.decode(response.data)["stat"] == "ok") {}
    } else {
      print("Request failed: ${response.statusCode}");
    }
  }
  Future<Response> uploadChunk(Asset photo, String category) async {
    Map<String, String> queries = {
      "format":"json",
      "method": "pwg.images.uploadAsync"
    };
    Map<String, String> fields = {
      'username': API.prefs.getString("username"),
      'password': API.prefs.getString("password"),
      'filename': photo.name,
      'category': category,
    };
    ChunkedUploader chunkedUploader = ChunkedUploader(API.dio);

    try {
      Future<Response> response = chunkedUploader.upload(
        context: context,
        path: "/ws.php",
        filePath: await FlutterAbsolutePath.getAbsolutePath(photo.identifier),
        maxChunkSize: API.prefs.getInt("upload_form_chunk_size")*1000,
        params: queries,
        method: 'POST',
        data: fields,
        contentType: Headers.formUrlEncodedContentType,
        onUploadProgress: (progress) {
          print('${photo.name} ${(progress*100).ceil()/100}');
        });
      return response;
    } on DioError catch (e) {
      print('Dio upload chunk error $e');
      return Future.value(null);
    }
  }
}


class FlutterAbsolutePath {
  static const MethodChannel _channel =
  const MethodChannel('flutter_absolute_path');

  /// Gets absolute path of the file from android URI or iOS PHAsset identifier
  /// The return of this method can be used directly with flutter [File] class
  static Future<String> getAbsolutePath(String uri) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'uri': uri,
    };
    final String path = await _channel.invokeMethod('getAbsolutePath', params);
    return path;
  }
}

class UploadGalleryViewPage extends StatefulWidget {
  final List<Asset> imageData;
  final String category;

  UploadGalleryViewPage({Key key, this.imageData, this.category}) : super(key: key);

  @override
  _UploadGalleryViewPage createState() => _UploadGalleryViewPage();
}

class _UploadGalleryViewPage extends State<UploadGalleryViewPage> {

  bool _showImages = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int getGridColumns(int nbElements) {
    if(nbElements < 4) return nbElements;
    if(nbElements < 10) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: _theme.iconTheme,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        centerTitle: true,
        title: Text("Upload Photos"),
        actions: [
          IconButton(
            onPressed: () {
              API.uploader.uploadPhotos(widget.imageData, widget.category);
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.upload_file),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("${widget.imageData.length} ${widget.imageData.length == 1 ? 'photo' : 'photos'}", style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color)),
                ),
              ),
              Text('Show photos'),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showImages = !_showImages;
                  });
                },
                icon: Icon(Icons.more_horiz),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: _showImages ? GridView.builder( // Put images on a grid
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: getGridColumns(widget.imageData.length),
                  ),
                  itemCount: widget.imageData.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Card(
                        elevation: 5,
                        semanticContainer: true,
                        child: GridTile(
                          child: Container(
                            child: AssetThumb(
                              asset: widget.imageData[index],
                              width: 300,
                              height: 300,
                              spinner: Text(""),
                              quality: 50,
                            ),
                          ),
                        ),
                      ),
                    );
                    /*
                    return FutureBuilder(
                      future: FlutterAbsolutePath.getAbsolutePath(widget.imageData[index].identifier),
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          return createCardImage(context, snapshot.data);
                        } else {
                          return CircularProgressIndicator();
                        }
                      }
                    ); // Custom grid cells
                    */
                  }
                ) : Text(""),
              ),

              Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    API.uploader.uploadPhotos(widget.imageData, widget.category);
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xffff7700)),
                  ),
                  child: Text("Upload",
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*
  Widget createCardImage(BuildContext context, String imagePath) {
    return Container(
      child: Card(
        elevation: 5,
        semanticContainer: true,
        child: GridTile(
          child: Container(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
  */
}