import 'dart:convert';

import 'package:flutter/services.dart';

import '../services/upload/chunked_uploader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:poc_piwigo/api/API.dart';
import 'package:shared_preferences/shared_preferences.dart';



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

  @override
  void dispose() {
    super.dispose();
  }

  void uploadPhotos(List<Asset> photos) async {
    photos.forEach((element) async {
      uploadChunk(element);
    });
  }

  void upload(Asset photo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> queries = {"format":"json", "method": "pwg.images.upload"};

    ByteData byteData = await photo.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();

    FormData formData =  FormData.fromMap({
      "category": widget.category,
      "pwg_token": prefs.getString("pwg_token"),
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
      print(response.data);
      if(json.decode(response.data)["stat"] == "ok") {
        SnackBar snackBar = SnackBar(
          content: Text("Successfully uploaded ${photo.name}"),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      print("Request failed: ${response.statusCode}");
    }
  }
  void uploadChunk(Asset photo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> queries = {
      "format":"json",
      "method": "pwg.images.uploadAsync"
    };
    Map<String, String> fields = {
      'username': "remiflutter",
      'password': "remimi",
      'filename': photo.name,
      'category': widget.category,
    };
    ChunkedUploader chunkedUploader = ChunkedUploader(API.dio);

    try {
      Response response = await chunkedUploader.upload(
        path: "/ws.php",
        filePath: await FlutterAbsolutePath.getAbsolutePath(photo.identifier),
        maxChunkSize: prefs.getInt("upload_form_chunk_size")*1000,
        params: queries,
        method: 'POST',
        data: fields,
        contentType: Headers.formUrlEncodedContentType,
        onUploadProgress: (progress) {
          print(progress);
        });
      print(response);
      if(json.decode(response.data)["stat"] == "ok") {
        SnackBar snackBar = SnackBar(
          content: Text("Successfully uploaded ${photo.name}"),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        print("Request failed: ${response.statusCode}");
      }
    } on DioError catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Photos"),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: GridView.builder( // Put images on a grid
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3
                  ),
                  itemCount: widget.imageData.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return createCardImage(context, widget.imageData[index]); // Custom grid cells
                  }
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    uploadPhotos(widget.imageData);
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


  Widget createCardImage(BuildContext context, Asset image) {
    return Container(
      child: Card(
        elevation: 5,
        semanticContainer: true,
        child: GridTile(
          child: Container(
            child: AssetThumb(
              asset: image,
              width: 300,
              height: 300,
            ),
          ),
        ),
      ),
    );
  }
}