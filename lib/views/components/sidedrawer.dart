import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/model/PageArguments.dart';
import 'package:piwigo_ng/routes/RoutePaths.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({
    Key key, this.leading, this.title = '', this.scrollController,
    this.view, this.isAdmin, this.isLoggedIn
  }) : super(key: key);

  final ScrollController scrollController;
  final Widget leading;
  final String title;
  final String view;
  final bool isAdmin;
  final bool isLoggedIn;

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {


  @override
  initState() {
    // widget.scrollController.addListener(() => refresh());
    super.initState();
  }

  void refresh() {
    setState(() {

    });
  }
  //
  // double get _horizontalTitlePadding {
  //   const kBasePadding = 15.0;
  //   const kMultiplier = 0.7;
  //   const kExpandedHeight = 120;
  //
  //   if (widget.scrollController.hasClients) {
  //
  //     if (widget.scrollController.offset > (kExpandedHeight - kToolbarHeight)) {
  //       return (kExpandedHeight - kToolbarHeight) * kMultiplier +
  //           kBasePadding;
  //     }
  //
  //     return (widget.scrollController.offset) * kMultiplier + kBasePadding;
  //   }
  //
  //   return kBasePadding;
  // }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Column(
        // Important: Remove any padding from the ListView.
        // padding: EdgeInsets.zero,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // DrawerHeader(
          //   decoration: BoxDecoration(
          //     color: Colors.blue,
          //   ),
          //   child: Text(widget.view),
          // ),
          Padding(
            padding: EdgeInsets.fromLTRB(50, 50, 50, 10),
            child: Image.asset('assets/logo/piwigo_logo.png'),
          ),
          ListTile(
            title: Text(appStrings(context).tabBar_albums),
            leading: Icon(Icons.photo_album, color: _theme.iconTheme.color),
            selected: widget.view == 'album',
            onTap: () {
              Navigator.of(context).pushReplacementNamed(RoutePaths.Categories,
                arguments: PageArguments(
                  isAdmin: widget.isAdmin,
                ),
              );
            },
          ),
          ListTile(
            title: Text(appStrings(context).tabBar_tags),
            leading: Icon(Icons.collections_bookmark, color: _theme.iconTheme.color),
            selected: widget.view == 'tag',
            onTap: () {
              Navigator.of(context).pushReplacementNamed(RoutePaths.Tags,
                arguments: PageArguments(
                  isAdmin: widget.isAdmin,
                ),
              );
            },
          ),
          (widget.isLoggedIn != null && widget.isLoggedIn) ? ListTile(
            title: Text(appStrings(context).categoryDiscoverFavorites_title),
            leading: Icon(Icons.favorite , color: _theme.iconTheme.color),
            selected: widget.view == 'favorite',
            onTap: () {
              Navigator.of(context).pushReplacementNamed(RoutePaths.Favorites,
                arguments: PageArguments(
                  isAdmin: widget.isAdmin,
                ),
              );
            },
          ) : Container(),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(appStrings(context).settingsHeader_server(API.prefs.getString('version')),
                  style: Theme.of(context).textTheme.caption.merge(TextStyle(fontStyle: FontStyle.italic)),
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.left,
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
