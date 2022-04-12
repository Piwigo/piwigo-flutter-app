import 'dart:async';

import 'package:flutter/material.dart';

import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/services/upload/Uploader.dart';
import 'package:piwigo_ng/views/components/list_item.dart';
import 'package:piwigo_ng/views/SettingsViewPage.dart';

import 'package:piwigo_ng/views/components/appbars.dart';
import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';
import 'package:piwigo_ng/views/components/sidedrawer.dart';

class RootCategoryViewPage extends StatefulWidget {
  static const String routeName = '/categories';
  final bool isAdmin;

  const RootCategoryViewPage({Key key, this.isAdmin = false}) : super(key: key);
  @override
  _RootCategoryViewPageState createState() => _RootCategoryViewPageState();
}
class _RootCategoryViewPageState extends State<RootCategoryViewPage> with SingleTickerProviderStateMixin {
  String _rootCategory;
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

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
      drawer: SideDrawer(view: 'album'),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxScrolled) => [
          AppBarExpandable(
            scrollController: _scrollController,
            actions: [IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              icon: Icon(Icons.settings, color: _theme.iconTheme.color),
            )],
            title: appStrings(context).tabBar_albums,
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
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Text(albumSnapshot.data['result']),
                    ); //appStrings(context).categoryMainEmtpy
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
                          _albumGrid(albums),
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

  Widget _albumGrid(dynamic albums) {
    int albumCrossAxisCount = MediaQuery.of(context).size.width <= Constants.albumMinWidth ? 1
        : (MediaQuery.of(context).size.width/Constants.albumMinWidth).floor();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: albumCrossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: albumGridAspectRatio(context),
      ),
      padding: EdgeInsets.all(10),
      itemCount: albums.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        var album = albums[index];
        return AlbumListItem(album, isAdmin: widget.isAdmin, onClose: () {
          setState(() {});
        });
      },
    );
  }
}