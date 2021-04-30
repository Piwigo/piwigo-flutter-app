import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:poc_piwigo/model/Category.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'API.dart';

Future<List<dynamic>> fetchAlbums(String albumID) async {

  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.getList",
    "cat_id": albumID
  };
  Response response = await API.dio.get('ws.php', queryParameters: queries);

  if (response.statusCode == 200) {
    return json.decode(response.data)["result"]["categories"];
  } else {
    throw Exception("bad request: "+response.statusCode.toString());
  }
}
Future<Category> getAlbumList() async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.getAdminList",
  };

  Response response = await API.dio.get('ws.php', queryParameters: queries);

  if (response.statusCode == 200) {
    Category root = Category("0", "root", fullname: "root");
    json.decode(response.data)['result']['categories'].forEach((cat) {
      List<int> rank = cat['global_rank'].split('.').map(int.parse).toList().cast<int>();
      Category newCat = Category(cat['id'], cat['name'], comment: cat['comment'], nbImages: cat['nb_images'].toString(), fullname: cat['fullname'], status: cat['status']);
      if(rank.length > 1) {
        Category nextInputCat = root.children.elementAt(rank.first-1);
        rank.removeAt(0);
        addCatRecursive(rank, newCat, nextInputCat);
      } else {
        root.children.add(newCat);
      }
    });
    return root;
  } else {
    throw Exception("bad request: "+response.statusCode.toString());
  }
}
void addCatRecursive(List<int> rank, Category cat, Category inputCat) {
  if(rank.length > 1) {
    Category nextInputCat = inputCat.children.elementAt(rank.first-1);
    rank.removeAt(0);
    addCatRecursive(rank, cat, nextInputCat);
  } else {
    inputCat.children.add(cat);
  }
}

Future<dynamic> addCategory(String catName, String catDesc, String parent) async {
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.add",
    "name": catName,
    "comment": catDesc,
    "parent": parent
  };

  try {
    Response response = await API.dio.post('ws.php', queryParameters: queries);

    if (response.statusCode == 200) {
      return json.decode(response.data);
    }
  } catch(e) {
    print('Dio add category error $e');
    return e;
  }
}
Future<dynamic> deleteCategory(String catId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.delete",
  };
  FormData formData =  FormData.fromMap({
    "category_id": catId,
    "pwg_token": prefs.getString("pwg_token"),
  });
  try {
    Response response = await API.dio.post(
        'ws.php',
        data: formData,
        queryParameters: queries
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    }
  } catch (e) {
    print('Dio delete category error $e');
    return e;
  }
}
Future<dynamic> moveCategory(String catId, String parentCatId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, String> queries = {
    "format": "json",
    "method": "pwg.categories.move",
  };
  FormData formData = FormData.fromMap({
    "category_id": catId,
    "parent": parentCatId,
    "pwg_token": prefs.getString("pwg_token"),
  });
  try {
    Response response = await API.dio.post(
        'ws.php',
        data: formData,
        queryParameters: queries
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    }
  } catch (e) {
    print('Dio move category error $e');
    return e;
  }
}