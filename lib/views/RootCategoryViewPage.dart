import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';
import 'dart:convert';
import 'package:poc_piwigo/api/API.dart';
import 'package:poc_piwigo/views/SettingsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/WeirdBorder.dart';
import 'CategoryViewPage.dart';



class RootCategoryViewPage extends StatefulWidget {
  final bool isAdmin;

  const RootCategoryViewPage({Key key, this.isAdmin = false}) : super(key: key);
  @override
  _RootCategoryViewPageState createState() => _RootCategoryViewPageState();
}

class _RootCategoryViewPageState extends State<RootCategoryViewPage> with SingleTickerProviderStateMixin {
  Map<int, bool> _swipedItems = Map();
  String _rootCategory;

  TextEditingController _searchTextController = new TextEditingController();
  String _filter;

  @override
  void initState() {
    super.initState();

    _rootCategory = "0";
    _filter = "";
  }
  @override
  void dispose() {
    super.dispose();
  }



  bool _filterSearch(String name) {
    if(_filter != null) {
      if(!name.toLowerCase().contains(_filter.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

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

  void addCategory(String catName, String catDesc) async {
    Map<String, String> queries = {
      "format": "json",
      "method": "pwg.categories.add",
      "name": catName,
      "comment": catDesc,
      "parent": "0"
    };

    Response response = await API.dio.post('ws.php', queryParameters: queries);

    if(response.statusCode == 200) {
      print(response.data);
      setState(() {
        print("refresh");
      });
    }
  }

  void deleteCategory(String catId) async {
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
        print(response.data);
        setState(() {
          print("refresh");
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String albumSubCount(dynamic album) {
    String displayString = '${album["total_nb_images"]} ${album["total_nb_images"] == 1 ? 'photo' : 'photos'}';
    if(album["nb_categories"] > 0) {
      displayString += ', ${album["nb_categories"]} ${album["nb_categories"] == 1 ? 'sub-album' : 'sub-albums'}';
    }
    return displayString;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 180.0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              icon: Icon(Icons.settings, color: _theme.iconTheme.color),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Consumer<ThemeNotifier>(
                //   builder: (context, notifier, child) => Switch(
                //     onChanged:(value){
                //       notifier.toggleTheme();
                //     },
                //     value: notifier.darkTheme,
                //   ),
                // ),
              ],
            ),
            /*
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: implement exploration menu | favorites
                },
                icon: Icon(Icons.menu, color: _theme.iconTheme.color),
              ),
            ],
             */
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text("Albums", style: _theme.textTheme.headline1),
                  ),
                  // TODO: implement all image search
                  Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _theme.inputDecorationTheme.fillColor
                    ),
                    child: TextField(
                      controller: _searchTextController,
                      onChanged: (str) {
                        setState(() {
                          _filter = str;
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: _theme.inputDecorationTheme.prefixStyle.color),
                        hintText: "Search album",
                        hintStyle: _theme.inputDecorationTheme.hintStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: FutureBuilder<List<dynamic>>(
              future: fetchAlbums(_rootCategory), // Albums of the list
              builder: (BuildContext context, AsyncSnapshot albums) {
                if(albums.hasData){
                  int nbPhotos = 0;
                  albums.data.forEach((cat) => nbPhotos+=cat["total_nb_images"]);
                  albums.data.removeWhere((category) => (
                      category["id"].toString() == _rootCategory || _filterSearch(category["name"].toString()))
                  );
                  return RefreshIndicator(
                    displacement: 20,
                    onRefresh: () {
                      setState(() {
                        print("refresh");
                      });

                      return Future.delayed(Duration(milliseconds: 1000));
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            itemCount: albums.data.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              if(_swipedItems.isEmpty) {
                                albums.data.forEach((item) {
                                  _swipedItems[index] = false;
                                });
                              }
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => CategoryViewPage(
                                      title: albums.data[index]["name"],
                                      category: albums.data[index]["id"].toString(),
                                      isAdmin: widget.isAdmin,
                                    )),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Slidable(
                                    enabled: widget.isAdmin,
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.15,
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 0, color: _theme.backgroundColor),
                                            color: _theme.backgroundColor,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                          ),
                                          padding: EdgeInsets.all(5),
                                          height: 130.0,
                                          width: 130.0,
                                          child: albums.data[index]["tn_url"] == null ?
                                          Icon(Icons.image_not_supported_outlined, size: 50)
                                              :
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(7.0),
                                            child: Image.network(
                                              albums.data[index]["tn_url"],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: ShapeDecoration(
                                            shape: WeirdBorder(radius: 7),
                                            color: Theme.of(context).backgroundColor,
                                          ),
                                          width: 14,
                                          height: 130.0,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(width: 0, color: Theme.of(context).backgroundColor),
                                              color: Theme.of(context).backgroundColor,
                                            ),
                                            padding: EdgeInsets.all(5),
                                            height: 130.0,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('${albums.data[index]["name"]}', style: _theme.textTheme.headline6, textAlign: TextAlign.center,),
                                                Column(
                                                  children: [
                                                    Text('${albums.data[index]["comment"] == "" ?
                                                        "(no description)" :
                                                        albums.data[index]["comment"]
                                                      }',
                                                      style: _theme.textTheme.subtitle1,
                                                      textAlign: TextAlign.center
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.all(5),
                                                      child: Text(albumSubCount(albums.data[index]),
                                                          style: Theme.of(context).textTheme.bodyText2
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 130.0,
                                          decoration: BoxDecoration(
                                            color: _theme.backgroundColor,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: widget.isAdmin? Center(
                                            child: Container(
                                              width: 8,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                border: Border.all(width: 1, color: _theme.errorColor), //TODO: Change color to adapt the first IconSlideAction
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft: Radius.circular(10),
                                                ),
                                                color: _theme.errorColor, //TODO: Change color to adapt the first IconSlideAction
                                              ),
                                            ),
                                          ) : Container(width: 8),
                                        ),
                                      ],
                                    ),
                                    secondaryActions: <Widget>[
                                      /*
                                      IconSlideAction(
                                        color: _theme.iconTheme.color,
                                        iconWidget: Icon(Icons.edit, size: 38, color: _theme.accentIconTheme.color),
                                        onTap: () {
                                          // TODO: Add edit album view
                                          print('Edit');
                                        },
                                      ),
                                       */
                                      /*
                                      IconSlideAction(
                                        color: Color(0xFF4B4B4B),
                                        iconWidget: Icon(Icons.reply, size: 38, color: _theme.accentIconTheme.color),
                                        onTap: () {
                                          // TODO: Add album tree structure for moving albums
                                          print('Move');
                                        },
                                      ),

                                       */
                                      Container(
                                        height: 130,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                          color: _theme.errorColor,
                                        ),
                                        child: IconSlideAction(
                                          color: Colors.transparent,
                                          iconWidget: Icon(Icons.delete, size: 38, color: _theme.accentIconTheme.color),
                                          onTap: () {
                                            print("delete ${albums.data[index]["name"]}");
                                            deleteCategory(albums.data[index]['id'].toString());
                                          },
                                          closeOnTap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text("$nbPhotos photos", style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color, fontWeight: FontWeight.w300)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }
          ),
        ),
      ),
      floatingActionButton: widget.isAdmin? FloatingActionButton(
        onPressed: () {
          final _formKey = GlobalKey<FormState>();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return createCategoryAlert(context);
            }
          );
        },
        child: Icon(Icons.create_new_folder, color: _theme.primaryColorLight, size: 30),
      ) : Container(),
    );
  }

  Widget createCategoryAlert(context) {
    ThemeData _theme = Theme.of(context);
    final _formKey = GlobalKey<FormState>();
    final _addAlbumNameController = TextEditingController();
    final _addAlbumDescController = TextEditingController();


    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      actions: [
        InkResponse(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: CircleAvatar(
            child: Icon(Icons.close, color: _theme.errorColor),
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
      title: Text("Album creation"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 250,
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _theme.inputDecorationTheme.fillColor
                      ),
                      child: TextFormField(
                        maxLines: 1,
                        controller: _addAlbumNameController,
                        style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: 'album name',
                          hintStyle: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: _theme.disabledColor),
                        ),
                        validator: (value) {
                          if(value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _theme.inputDecorationTheme.fillColor
                      ),
                      child: TextFormField(
                        minLines: 1,
                        maxLines: 3,
                        controller: _addAlbumDescController,
                        style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: 'description (optional)',
                          hintStyle: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: _theme.disabledColor),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(_theme.accentColor),
                        ),
                        child: Text('Create album', style: TextStyle(fontSize: 16, color: Colors.white)),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            addCategory(_addAlbumNameController.text, _addAlbumDescController.text);
                            _addAlbumNameController.text = "";
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}