import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/FavoritesViewPage.dart';
import 'package:piwigo_ng/views/components/RootTagViewPage.dart';

enum ViewPopupMenuOptions { favorites, tags, top_viewed, top_rated }

class ViewPopupMenuButton extends StatelessWidget {
  const ViewPopupMenuButton({Key key, this.isAdmin = false}) : super(key: key);

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        _onMenuItemSelected(value as int, context);
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      // padding: EdgeInsets.zero,
      // offset: Offset(0, 50),
      itemBuilder: (ctx) => [
         isAdmin ? _buildPopupMenuItem(
          appStrings(context).categoryDiscoverFavorites_title, ViewPopupMenuOptions.favorites.index,
          iconData: Icons.favorite_border
        ) : null,
        _buildPopupMenuItem(
          appStrings(context).tags, ViewPopupMenuOptions.tags.index,
          iconData: Icons.local_offer_outlined
        ),
        _buildPopupMenuItem(
          appStrings(context).categoryDiscoverVisits_title, ViewPopupMenuOptions.top_viewed.index,
        ),
        _buildPopupMenuItem(
          appStrings(context).categoryDiscoverBest_title, ViewPopupMenuOptions.top_rated.index,
        ),
        _buildPopupMenuItem(
          appStrings(context).categoryDiscoverRecent_title, ViewPopupMenuOptions.top_rated.index,
            iconData: Icons.access_time_rounded
        ),
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(
      String title, int position, {IconData iconData}) {
    return PopupMenuItem(
      value: position,
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Spacer(),
          if (iconData != null) Icon(iconData, color: Colors.black),
        ],
      ),
    );
  }

  _onMenuItemSelected(int value, BuildContext context) {
    MaterialPageRoute route;

    if (value == ViewPopupMenuOptions.favorites.index) {
      route = MaterialPageRoute(builder: (context) => FavoritesViewPage(
        isAdmin: isAdmin,
      ));
    } else if (value == ViewPopupMenuOptions.tags.index) {
      route = MaterialPageRoute(builder: (context) => RootTagViewPage(
        isAdmin: isAdmin,
      ));
    }
    if (route != null) Navigator.of(context).push(route);
  }
}

