import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:piwigo_ng/api/SessionAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/components/SnackBars.dart';

import '../services/upload/chunked_uploader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:piwigo_ng/api/API.dart';

class Uploader {
  BuildContext context;
  SnackBar snackBar;

  Uploader(this.context) {
    snackBar = SnackBar(
      content: Text(appStrings(context).imageUploadTableCell_uploading),
      duration: Duration(seconds: 2),
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
    final isSuccess = downloadStatus['isSuccess'];

    await API.localNotification.show(
      1,
      isSuccess ? 'Success' : 'Failure',
      isSuccess ? appStrings(context).imageUploadCompleted_message : appStrings(context).uploadError_message,
      platform,
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
      if(json.decode(response.data)["stat"] == "fail") {
        print("Request failed: ${response.statusCode}");

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(context, response.data));
      }
    }

    print('new status');
    createDio();

    await _showUploadNotification(result);
  }

  void createDio() async {
    API.dio = Dio();
    API.cookieJar = CookieJar();
    API.dio.interceptors.add(CookieManager(API.cookieJar));
    if(API.prefs.getBool("is_logged") != null && API.prefs.getBool("is_logged")) {
      API.dio.options.baseUrl = API.prefs.getString("base_url");
      if(API.prefs.getBool("is_guest") != null && !API.prefs.getBool("is_guest")) {
        await loginUser(API.prefs.getString("base_url"), API.prefs.getString("username"), API.prefs.getString("password"));
      } else {
        await loginGuest(API.prefs.getString("base_url"));
      }
    }
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
    print(await FlutterAbsolutePath.getAbsolutePath(photo.identifier));
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
        onUploadProgress: (value) {
          // print('${photo.name} $progress');
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
        title: Text(appStrings(context).categoryUpload_images),
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
                  child: Text(appStrings(context).imageCount(widget.imageData.length), style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color)),
                ),
              ),
              Text(appStrings(context).showPhotos),
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
                  child: Text(appStrings(context).imageUploadDetailsButton_title,
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