import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:async';

import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/components/Dialogs.dart';
import 'package:piwigo_ng/views/components/ListItems.dart';
import 'package:piwigo_ng/views/SettingsViewPage.dart';
import 'package:piwigo_ng/views/UploadGalleryViewPage.dart';

class RootCategoryViewPage extends StatefulWidget {
  final bool isAdmin;

  const RootCategoryViewPage({Key key, this.isAdmin = false}) : super(key: key);
  @override
  _RootCategoryViewPageState createState() => _RootCategoryViewPageState();
}

class _RootCategoryViewPageState extends State<RootCategoryViewPage> with SingleTickerProviderStateMixin {
  String _rootCategory;

  @override
  void initState() {
    super.initState();
    _rootCategory = "0";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      API.uploader = Uploader(context);
    });
  }
  @override
  void dispose() {
    super.dispose();
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
            expandedHeight: 130.0,
            centerTitle: true,
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
              title: Text(appStrings(context).tabBar_albums, style: _theme.textTheme.headline1),
              /*
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        hintText: appStrings(context)(context).search,
                        hintStyle: _theme.inputDecorationTheme.hintStyle,
                      ),
                    ),
                  ),
                ],
              ),
               */
            ),
          ),
        ],
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: FutureBuilder<Map<String,dynamic>>(
              future: fetchAlbums(_rootCategory), // Albums of the list
              builder: (BuildContext context, AsyncSnapshot albumSnapshot) {
                if(albumSnapshot.hasData){
                  if(albumSnapshot.data['stat'] == 'fail') {
                    return Center(child: Text(appStrings(context).categoryMainEmtpy));
                  }
                  var albums = albumSnapshot.data['result']['categories'];
                  int nbPhotos = 0;
                  albums.forEach((cat) => nbPhotos+=cat["total_nb_images"]);
                  albums.removeWhere((category) => (
                      category["id"].toString() == _rootCategory
                  ));
                  return RefreshIndicator(
                    displacement: 20,
                    notificationPredicate: (notification) {
                      return notification.metrics.atEdge;
                    },
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
                            itemCount: albums.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return albumListItem(context, albums[index], widget.isAdmin, (message) {
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
                            itemCount: albums.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              var album = albums[index];
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
                              child: Text(appStrings(context).imageCount(nbPhotos), style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color, fontWeight: FontWeight.w300)),
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
              return CreateCategoryDialog(catId: "0");
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