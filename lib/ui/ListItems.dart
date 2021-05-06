
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:piwigo_ng/views/CategoryViewPage.dart';
import 'package:piwigo_ng/services/MoveAlbumService.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';

import 'Dialogs.dart';
import 'SnackBars.dart';
import 'WeirdBorder.dart';

String albumSubCount(dynamic album) {
  String displayString = '${album["total_nb_images"]} ${album["total_nb_images"] == 1 ? 'photo' : 'photos'}';
  if(album["nb_categories"] > 0) {
    displayString += ', ${album["nb_categories"]} ${album["nb_categories"] == 1 ? 'sub-album' : 'sub-albums'}';
  }
  return displayString;
}

Widget albumListItem(BuildContext context, dynamic album, bool isAdmin, Function(String) onRefresh) {
  ThemeData _theme = Theme.of(context);

  return InkWell(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CategoryViewPage(
          title: album["name"],
          category: album["id"].toString(),
          isAdmin: isAdmin,
        )),
      );
    },
    child: Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
      ),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.15,
        child: categoryListCard(context, album, isAdmin),
        secondaryActions: <Widget>[
          IconSlideAction(
            color: _theme.iconTheme.color,
            iconWidget: Icon(Icons.edit, size: 38, color: _theme.accentIconTheme.color),
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return EditCategoryDialog(
                    catId: album['id'],
                    catName: album['name'],
                    catDesc: album['comment'],
                    privacy: album['status'] == 'private' ? true : false
                  );
                }
              ).whenComplete(() {
                onRefresh('Edited ${album['name']}');
              });
            },
          ),
          IconSlideAction(
            color: Color(0xFF4B4B4B),
            iconWidget: Icon(Icons.reply, size: 38, color: _theme.accentIconTheme.color),
            onTap: () async {
              var result = await moveCategoryModalBottomSheet(context,
                album['id'].toString(),
                album['name'],
                false,
                (item) async {
                  if (await confirm(
                    context,
                    title: Text('Confirm'),
                    content: Text('Move ${album['name']} to ${item.name} ?', softWrap: true, maxLines: 3),
                    textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                    textCancel: Text('No', style: TextStyle(color: Theme.of(context).errorColor)),
                  )) {
                    print('Move ${album['id']} to ${item.id}');
                    var result = await moveCategory(album['id'], item.id);
                    print(result);
                    ScaffoldMessenger.of(context).showSnackBar(albumMovedSnackBar(album['name'], item.name));
                    Navigator.of(context).pop();
                  }
                },
              );
              onRefresh('Moved ${album['name']} : $result');
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
                  content: Text('Delete ${album["name"]} ?', softWrap: true, maxLines: 3),
                  textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                  textCancel: Text('No', style: TextStyle(color: _theme.errorColor)),
                )) {
                  var result = await deleteCategory(album['id'].toString());
                  ScaffoldMessenger.of(context).showSnackBar(albumDeletedSnackBar(album["name"]));
                  onRefresh('Deleted ${album['name']} : $result');
                }
              },
              closeOnTap: true,
            ),
          ),
        ],
      ),
    ),
  );
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
            fit: BoxFit.cover,
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
            width: 10,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: _theme.iconTheme.color),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              color: _theme.iconTheme.color,
            ),
          ),
        ) : Container(width: 8),
      ),
    ],
  );
}