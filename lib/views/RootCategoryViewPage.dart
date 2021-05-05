import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'dart:async';

import 'package:poc_piwigo/api/API.dart';
import 'package:poc_piwigo/api/CategoryAPI.dart';
import 'package:poc_piwigo/services/MoveAlbumService.dart';
import 'package:poc_piwigo/ui/Dialogs.dart';
import 'package:poc_piwigo/ui/ListItems.dart';
import 'package:poc_piwigo/ui/SnackBars.dart';
import 'package:poc_piwigo/views/SettingsPage.dart';
import 'package:poc_piwigo/views/CategoryViewPage.dart';
import 'package:poc_piwigo/views/UploadGalleryViewPage.dart';

class RootCategoryViewPage extends StatefulWidget {
  final bool isAdmin;

  const RootCategoryViewPage({Key key, this.isAdmin = false}) : super(key: key);
  @override
  _RootCategoryViewPageState createState() => _RootCategoryViewPageState();
}

class _RootCategoryViewPageState extends State<RootCategoryViewPage> with SingleTickerProviderStateMixin {
  String _rootCategory;

  TextEditingController _searchTextController = new TextEditingController();
  String _filter;

  @override
  void initState() {
    super.initState();
    API.uploader = Uploader(context);
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
            expandedHeight: 100.0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              icon: Icon(Icons.settings, color: _theme.iconTheme.color),
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
                  /*
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

                   */
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
                      category["id"].toString() == _rootCategory
                  ));
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
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => CategoryViewPage(
                                      title: albums.data[index]["name"],
                                      category: albums.data[index]["id"].toString(),
                                      isAdmin: widget.isAdmin,
                                      nbImages: albums.data[index]["total_nb_images"],
                                    )),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Slidable(
                                    enabled: widget.isAdmin,
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.15,
                                    child: categoryListCard(context, albums.data[index], widget.isAdmin),
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
                                      IconSlideAction(
                                        color: Color(0xFF4B4B4B),
                                        iconWidget: Icon(Icons.reply, size: 38, color: _theme.accentIconTheme.color),
                                        onTap: () async {
                                          var result = await moveCategoryModalBottomSheet(context,
                                            albums.data[index]['id'].toString(),
                                            albums.data[index]['name']
                                          );
                                          setState(() {
                                            print('Moved album $result');
                                          });
                                        },
                                      ),
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
                                          onTap: () async {
                                            if (await confirm(
                                              context,
                                              title: Text('Confirm'),
                                              content: Text('Delete ${albums.data[index]["name"]} ?', softWrap: true, maxLines: 3),
                                              textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                                              textCancel: Text('No', style: TextStyle(color: _theme.errorColor)),
                                            )) {
                                              var result = await deleteCategory(albums.data[index]['id'].toString());
                                              ScaffoldMessenger.of(context).showSnackBar(albumDeletedSnackBar(albums.data[index]["name"]));
                                              setState(() {
                                                print('Delete album ${albums.data[index]["name"]} : $result');
                                              });
                                            }
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
                              child: Text('$nbPhotos ${nbPhotos == 1 ? 'photo' : 'photos'}', style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color, fontWeight: FontWeight.w300)),
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return createCategoryAlert(context, "0");
            }
          ).whenComplete(() {
            setState(() {
              print('refresh');
            });
          });
        },
        child: Icon(Icons.create_new_folder, color: _theme.primaryColorLight, size: 30),
      ) : Container(),
    );
  }
}