
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'WeirdBorder.dart';

String albumSubCount(dynamic album) {
  String displayString = '${album["total_nb_images"]} ${album["total_nb_images"] == 1 ? 'photo' : 'photos'}';
  if(album["nb_categories"] > 0) {
    displayString += ', ${album["nb_categories"]} ${album["nb_categories"] == 1 ? 'sub-album' : 'sub-albums'}';
  }
  return displayString;
}

Widget categoryListCard(BuildContext context, dynamic album, bool isAdmin) {
  ThemeData _theme = Theme.of(context);
  return Row(
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
        child: album["tn_url"] == null ?
        Icon(Icons.image_not_supported_outlined, size: 50)
            :
        ClipRRect(
          borderRadius: BorderRadius.circular(7.0),
          child: Image.network(
            album["tn_url"],
            fit: BoxFit.fill,
          ),
        ),
      ),
      Container(
        decoration: ShapeDecoration(
          shape: WeirdBorder(radius: 7),
          color: _theme.backgroundColor,
        ),
        width: 14,
        height: 130.0,
      ),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0, color: _theme.backgroundColor),
            color: _theme.backgroundColor,
          ),
          padding: EdgeInsets.all(5),
          height: 130.0,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${album["name"]}',
                  style: _theme.textTheme.headline6,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1
                ),
                Column(
                  children: [
                    Text('${album["comment"] == "" ?
                    "(no description)" :
                    album["comment"]
                    }',
                      style: _theme.textTheme.subtitle1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      maxLines: 2
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Text(albumSubCount(album),
                        style: Theme.of(context).textTheme.bodyText2,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
              ]
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
        child: isAdmin? Center(
          child: Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Color(0xFF4B4B4B)), //TODO: Change color to adapt the first IconSlideAction
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              color: Color(0xFF4B4B4B), //TODO: Change color to adapt the first IconSlideAction
            ),
          ),
        ) : Container(width: 8),
      ),
    ],
  );
}