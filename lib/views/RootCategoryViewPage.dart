import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';
import 'dart:convert';
import 'package:poc_piwigo/api/API.dart';
import 'package:poc_piwigo/views/SettingsPage.dart';

import '../ui/WeirdBorder.dart';
import 'CategoryViewPage.dart';



class RootCategoryViewPage extends StatefulWidget {
  @override
  _RootCategoryViewPageState createState() => _RootCategoryViewPageState();
}

class _RootCategoryViewPageState extends State<RootCategoryViewPage> with SingleTickerProviderStateMixin {
  final _addAlbumController = TextEditingController();
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

  void addCategory(String catName) async {
    Map<String, String> queries = {
      "format": "json",
      "method": "pwg.categories.add",
      "name": catName,
      "parent": _rootCategory
    };

    Response response = await API.dio.post('ws.php', queryParameters: queries);

    if(response.statusCode == 200) {
      print(response.data);
      setState(() {
        print("refresh");
      });
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
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: FutureBuilder<List<dynamic>>(
              future: fetchAlbums(_rootCategory), // Albums of the list
              builder: (BuildContext context, AsyncSnapshot albums) {
                if(albums.hasData){
                  albums.data.removeWhere((category) => (
                      category["id"].toString() == _rootCategory || _filterSearch(category["name"].toString()))
                  );
                  return CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        pinned: true,
                        snap: false,
                        floating: false,
                        expandedHeight: 180.0,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => SettingsPage()),
                                );
                              },
                              icon: Icon(Icons.settings, color: _theme.iconTheme.color),
                            ),

                            // Consumer<ThemeNotifier>(
                            //   builder: (context, notifier, child) => Switch(
                            //     onChanged:(value){
                            //       notifier.toggleTheme();
                            //     },
                            //     value: notifier.darkTheme,
                            //   ),
                            // ),
                            Icon(Icons.menu, color: _theme.iconTheme.color),
                          ],
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Text("Albums", style: _theme.textTheme.headline1),
                              ),
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
                                    hintText: "Search",
                                    hintStyle: _theme.inputDecorationTheme.hintStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.all(5),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
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
                                    )),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.15,
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 0, color: Theme.of(context).backgroundColor),
                                            color: Theme.of(context).backgroundColor,
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
                                                Text('${albums.data[index]["name"]}', style: _theme.textTheme.headline6),
                                                Column(
                                                  children: [
                                                    Text('${albums.data[index]["description"] == null ?
                                                    "(no description)" :
                                                    albums.data[index]["description"]
                                                    }',
                                                        style: _theme.textTheme.subtitle1),
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
                                          child: Center(
                                            child: Container(
                                              width: 8,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                border: Border.all(width: 1, color: _theme.accentColor),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft: Radius.circular(10),
                                                ),
                                                color: _theme.accentColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    secondaryActions: <Widget>[
                                      IconSlideAction(
                                        color: _theme.iconTheme.color,
                                        iconWidget: Icon(Icons.edit, size: 38, color: _theme.accentIconTheme.color),
                                        onTap: () {
                                          print('Edit');
                                        },
                                      ),
                                      IconSlideAction(
                                        color: Color(0xFF4B4B4B),
                                        iconWidget: Icon(Icons.reply, size: 38, color: _theme.accentIconTheme.color),
                                        onTap: () {
                                          print('More');
                                        },
                                      ),
                                      Container(
                                        height: 130,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          color: _theme.errorColor,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            print("delete");
                                          },
                                          icon: Icon(Icons.delete, size: 38, color: _theme.accentIconTheme.color),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: albums.data.length,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final _formKey = GlobalKey<FormState>();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return createCategoryAlert(_formKey, context);
            }
          );
        },
        child: Icon(Icons.create_new_folder, color: _theme.primaryColorLight, size: 30),
      ),
    );
  }

  Widget createCategoryAlert(_formKey, context) {
    ThemeData _theme = Theme.of(context);
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children:[
              InkResponse(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  child: Icon(Icons.close),
                  backgroundColor: _theme.errorColor,
                ),
              ),
            ]
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextFormField(
                    controller: _addAlbumController,
                    decoration: InputDecoration(
                        hintText: "Album name"
                    ),
                    validator: (value) {
                      if(value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    child: Text("Create album"),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        addCategory(_addAlbumController.text);
                        _addAlbumController.text = "";
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}