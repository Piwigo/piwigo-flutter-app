import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/model/PageArguments.dart';
import 'package:piwigo_ng/routes/RoutePaths.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({
    Key key, this.leading, this.title = '', this.scrollController,
    this.view, this.isAdmin
  }) : super(key: key);

  final ScrollController scrollController;
  final Widget leading;
  final String title;
  final String view;
  final bool isAdmin;

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
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(widget.view),
          ),
          ListTile(
            title: Text(appStrings(context).sidebar_albums),
            leading: Icon(Icons.photo_album, color: _theme.iconTheme.color),
            selected: widget.view == 'album',
            onTap: () {
              Navigator.of(context).pushReplacementNamed(RoutePaths.Categories,
                arguments: PageArguments(
                  isAdmin: widget.isAdmin,
                ),
              );
              // Navigator.of(context).pushReplacement(
              //     MaterialPageRoute(builder: (context) => RootCategoryViewPage())
              // );
            },
          ),
          ListTile(
            title: Text(appStrings(context).sidebar_tags),
            leading: Icon(Icons.collections_bookmark, color: _theme.iconTheme.color),
            selected: widget.view == 'tag',
            onTap: () {
              Navigator.of(context).pushReplacementNamed(RoutePaths.Tags,
                arguments: PageArguments(
                  isAdmin: widget.isAdmin,
                ),
              );
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(builder: (context) => RootTagViewPage())
              // );
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: Text(appStrings(context).sidebar_favorites),
            leading: Icon(Icons.favorite , color: _theme.iconTheme.color),
            selected: widget.view == 'favorite',
            onTap: () {
              Navigator.of(context).pushReplacementNamed(RoutePaths.Favorites,
                arguments: PageArguments(
                  isAdmin: widget.isAdmin,
                ),
              );
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
