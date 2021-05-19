import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:async';

import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/ui/Dialogs.dart';
import 'package:piwigo_ng/ui/ListItems.dart';
import 'package:piwigo_ng/views/SettingsPage.dart';
import 'package:piwigo_ng/views/UploadGalleryViewPage.dart';

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
                          /*
                          ListView.builder(
                            itemCount: albums.data.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return albumListItem(context, albums.data[index], widget.isAdmin, (message) {
                                setState(() {
                                  print('$message');
                                });
                              });
                            },
                          ),

                           */
                          GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isPortrait(context)? 1 : 2,
                              mainAxisSpacing: 3,
                              crossAxisSpacing: 5,
                              childAspectRatio: albumGridAspectRatio(context),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            itemCount: albums.data.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              var album = albums.data[index];
                              if (isPortrait(context) || index%2 == 0) {
                                return albumListItem(context, album, widget.isAdmin, (message) {
                                  setState(() {
                                    print('$message');
                                  });
                                });
                              }
                              return albumListItemRight(context, album, widget.isAdmin, (message) {
                                setState(() {
                                  print('$message');
                                });
                              });
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