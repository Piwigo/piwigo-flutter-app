
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/CategoryViewPage.dart';
import 'package:piwigo_ng/services/MoveAlbumService.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';

import 'Dialogs.dart';
import 'SnackBars.dart';
import 'CustomShapes.dart';


String albumSubCount(dynamic album, context) {
  String displayString = appStrings(context).imageCount(album["total_nb_images"]);
  if(album["nb_categories"] > 0) {
    displayString += ', ${appStrings(context).subAlbumCount(album["nb_categories"])}';
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
          nbImages: album["nb_images"],
        )),
      ).whenComplete(() {
        onRefresh('Closed children category');
      });
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Slidable(
        enabled: isAdmin,
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
                    if (await confirmMoveDialog(context,
                      content: appStrings(context).moveCategory_message(album['name'],item.name),
                    )) {
                      var result = await moveCategory(album['id'], item.id);
                      print(result);
                      if(result['stat'] == 'fail') {
                        ScaffoldMessenger.of(context).showSnackBar(
                            errorSnackBar(context, result['result'])
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            albumMovedSnackBar(context)
                        );
                      }
                      Navigator.of(context).pop();
                    }
                  },
                );
                onRefresh('Moved ${album['name']} : $result');
              },
            ),
          IconSlideAction(
            color: _theme.errorColor,
            iconWidget: Icon(Icons.delete, size: 38, color: _theme.accentIconTheme.color),
            onTap: () async {
              if (await confirmDeleteDialog(context,
                content: appStrings(context).deleteCategory_message(album["total_nb_images"], album["name"]),
              )) {
                var result = await deleteCategory(album['id'].toString());
                if(result['stat'] == 'fail') {
                  ScaffoldMessenger.of(context).showSnackBar(
                      errorSnackBar(context, result['result'])
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      albumDeletedSnackBar(context)
                  );
                  onRefresh('Deleted ${album['name']} : $result');
                }
              }
            },
            closeOnTap: true,
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
      albumThumbnail(context, album, borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        bottomLeft: Radius.circular(10),
      )),
      albumItemSeparator(context),
      albumInfo(context, album),
      Container(
        height: albumGridItemHeight(context),
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



Widget albumListItemRight(BuildContext context, dynamic album, bool isAdmin, Function(String) onRefresh) {
  ThemeData _theme = Theme.of(context);

  return InkWell(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CategoryViewPage(
          title: album["name"],
          category: album["id"].toString(),
          isAdmin: isAdmin,
          nbImages: album["nb_images"],
        )),
      ).whenComplete(() {
        onRefresh('Closed children category');
      });
    },
    child: Container(
      // padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Slidable(
        enabled: isAdmin,
        actionPane: SlidableBehindActionPane(),
        actionExtentRatio: 0.15,
        child: categoryListCardRight(context, album, isAdmin),
        actions: <Widget>[
          Container(
            height: albumGridItemHeight(context),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              color: _theme.errorColor,
            ),
            child: IconSlideAction(
              color: Colors.transparent,
              iconWidget: Icon(Icons.delete, size: 38, color: _theme.accentIconTheme.color),
              onTap: () async {
                if (await confirmDeleteDialog(context,
                  content: appStrings(context).deleteCategory_message(album["total_nb_images"], album['name']),
                )) {
                  var result = await deleteCategory(album['id'].toString());
                  if(result['stat'] == 'fail') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        errorSnackBar(context, result['result'])
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        albumDeletedSnackBar(context)
                    );
                    onRefresh('Deleted ${album['name']} : $result');
                  }
                }
              },
              closeOnTap: true,
            ),
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
                  if (await confirmMoveDialog(context,
                    content: appStrings(context).moveCategory_message(album['name'],item.name),
                  )) {
                    print('Move ${album['id']} to ${item.id}');
                    var result = await moveCategory(album['id'], item.id);
                    if(result['stat'] == 'fail') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          errorSnackBar(context, result['result'])
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          albumMovedSnackBar(context)
                      );
                    }
                    Navigator.of(context).pop();
                  }
                },
              );
              onRefresh('Moved ${album['name']} : $result');
            },
          ),
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
        ],
      ),
    ),
  );
}
Widget categoryListCardRight(BuildContext context, dynamic album, bool isAdmin) {
  ThemeData _theme = Theme.of(context);
  return Row(
    children: [
      Container(
        height: albumGridItemHeight(context),
        decoration: BoxDecoration(
          color: _theme.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
        ),
        child: isAdmin? Center(
          child: Container(
            width: 10,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: _theme.iconTheme.color),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              color: _theme.iconTheme.color,
            ),
          ),
        ) : Container(width: 8),
      ),
      albumInfo(context, album),
      albumItemSeparator(context),
      albumThumbnail(context, album, borderRadius: BorderRadius.only(
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
      )),
    ],
  );
}



Widget albumInfo(BuildContext context, album) {

  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(width: 0, color: Theme.of(context).backgroundColor),
        color: Theme.of(context).backgroundColor,
      ),
      padding: EdgeInsets.all(5),
      height: albumGridItemHeight(context),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${album["name"]}',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1
            ),
            Column(
              children: [
                Text('${album["comment"]}',
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  maxLines: 2
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: Text(albumSubCount(album, context),
                    style: Theme.of(context).textTheme.bodyText2,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ]
      ),
    ),
  );
}
Widget albumThumbnail(BuildContext context, album, {BorderRadius borderRadius = BorderRadius.zero}) {
  return LayoutBuilder(builder: (context, layout) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 0, color: Theme.of(context).backgroundColor),
        color: Theme.of(context).backgroundColor,
        borderRadius: borderRadius,
      ),
      padding: EdgeInsets.all(5),
      height: layout.maxHeight,// albumGridItemHeight(context),
      width: layout.maxHeight,// albumGridItemHeight(context),
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
    );
  });
}
Widget albumItemSeparator(BuildContext context) {
  return Container(
    decoration: ShapeDecoration(
      shape: AlbumCardSeparatorShape(radius: 7),
      color: Theme.of(context).backgroundColor,
    ),
    width: 14,
    height: albumGridItemHeight(context),
  );
}