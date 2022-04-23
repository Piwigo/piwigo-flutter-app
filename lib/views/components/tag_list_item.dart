import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/model/PageArguments.dart';
import 'package:piwigo_ng/routes/RoutePaths.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/CategoryViewPage.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/views/TagViewPage.dart';

import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';
import 'package:piwigo_ng/views/components/dialogs/tags_dialogs.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';
import 'package:piwigo_ng/views/components/custom_shapes.dart';


// String albumSubCount(dynamic album, context) {
//   String displayString = appStrings(context).imageCount(album["total_nb_images"]);
//   if(album["nb_categories"] > 0) {
//     displayString += ', ${appStrings(context).subAlbumCount(album["nb_categories"])}';
//   }
//   return displayString;
// }

class TagListItem extends StatefulWidget {
  const TagListItem(this.tag, {Key key,
    this.isAdmin = false, this.onClose, this.onOpen
  }) : super(key: key);

  final dynamic tag;
  final bool isAdmin;
  final Function() onClose;
  final Function() onOpen;

  @override
  _TagListItemState createState() => _TagListItemState();
}
class _TagListItemState extends State<TagListItem> {

  void _onRenameTag() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return EditTagDialog(
              tagId: widget.tag['id'],
              tagName: widget.tag['name']
          );
        }
    ).whenComplete(() {
      widget.onClose();
    });
  }
  void _onMoveAlbum() async {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return MoveOrCopyDialog(
    //       title: appStrings(context).moveCategory,
    //       subtitle: appStrings(context).moveCategory_select(widget.album['name']),
    //       catId: widget.tag['id'].toString(),
    //       catName: widget.tag['name'],
    //       isImage: false,
    //       onSelected: (item) async {
    //         if (await confirmMoveDialog(context,
    //           content: appStrings(context).moveCategory_message(widget.album['name'], item.name),
    //         )) {
    //           var result = await moveCategory(widget.album['id'], item.id);
    //           if(result['stat'] == 'fail') {
    //             ScaffoldMessenger.of(context).showSnackBar(
    //                 errorSnackBar(context, result['result'])
    //             );
    //           } else {
    //             ScaffoldMessenger.of(context).showSnackBar(
    //                 albumMovedSnackBar(context)
    //             );
    //           }
    //           Navigator.of(context).pop();
    //         }
    //       },
    //     );
    //   }
    // ).whenComplete(() {
    //   widget.onClose();
    // });
    // widget.onClose();
  }
  void _onDeleteTag() async {
    // if(widget.album["total_nb_images"] > 0) {
    //   int choice = await confirmDeleteAlbumWithImagesDialog(context,
    //     content: appStrings(context).deleteCategory_message(widget.album["total_nb_images"], widget.album["name"]),
    //     count: widget.album["total_nb_images"],
    //   );
    //   var result;
    //   switch(choice) {
    //     case 0: result = await deleteCategory(widget.album['id'].toString(),
    //         deletionMode: 'no_delete');
    //       break;
    //     case 1: result = await deleteCategory(widget.album['id'].toString(),
    //         deletionMode: 'delete_orphans');
    //       break;
    //     case 2: result = await deleteCategory(widget.album['id'].toString(),
    //         deletionMode: 'force_delete');
    //       break;
    //     default: break;
    //   }
    //   widget.onClose();
    // }
    // else {
    //   if (await confirmDeleteDialog(context,
    //     content: appStrings(context).deleteCategory_message(widget.album["total_nb_images"], widget.album["name"]),
    //   )) {
    //     var result = await deleteCategory(widget.album['id'].toString());
    //     if(result['stat'] == 'fail') {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           errorSnackBar(context, result['result'])
    //       );
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           albumDeletedSnackBar(context)
    //       );
    //       widget.onClose();
    //     }
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if(widget.onOpen != null) widget.onOpen();

        Navigator.of(context).pushNamed(RoutePaths.TagContent,
          arguments: PageArguments(
            tag: widget.tag['id'].toString(),
            title: widget.tag['name'],
            isAdmin: widget.isAdmin,
          )
        );

        // Navigator.of(context).push(
        //   MaterialPageRoute(builder: (context) => TagViewPage(
        //     title: widget.tag["name"],
        //     tag: widget.tag["id"].toString(),
        //     isAdmin: widget.isAdmin,
        //     // nbImages: widget.tag["nb_images"],
        //   )),
        // ).whenComplete(() {
        //   widget.onClose();
        // });



      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Slidable(
          enabled: widget.isAdmin,
          child: TagListCard(widget.tag, isAdmin: widget.isAdmin),
          endActionPane: ActionPane(
            motion: DrawerMotion(),
            children: [
              CustomSlidableAction(
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: (_) {
                  _onRenameTag();
                },
                child: Center(
                  child: Icon(Icons.edit, size: 38, color: Colors.white),
                ),
              ),
              CustomSlidableAction(
                backgroundColor: Color(0xFF4B4B4B),
                child: Center(
                  child: Icon(Icons.reply, size: 38, color: Colors.white),
                ),
                onPressed: (_) {
                  _onMoveAlbum();
                },
              ),
              CustomSlidableAction(
                backgroundColor: Colors.red,
                child: Center(
                  child: Icon(Icons.delete, size: 38, color: Colors.white),
                ),
                autoClose: true,
                onPressed: (_) {
                  _onDeleteTag();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TagListCard extends StatelessWidget {
  const TagListCard(this.tag, {Key key, this.isAdmin = false}) : super(key: key);

  final dynamic tag;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // albumThumbnail(context, tag),
        // albumItemSeparator(context),
        tagInfo(context, tag),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: isAdmin? Center(
            child: Container(
              width: 10,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Theme.of(context).iconTheme.color),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ) : Container(width: 8),
        ),
      ],
    );
  }

  Widget tagInfo(BuildContext context, tag) {

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0, color: Theme.of(context).backgroundColor),
          color: Theme.of(context).backgroundColor,
        ),
        padding: EdgeInsets.all(5),
        height: 80,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${tag["name"]}',
                  style: Theme.of(context).textTheme.headline4,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1
              ),
              Column(
                children: [
                  // Text('${album["comment"]}',
                  //     style: Theme.of(context).textTheme.subtitle1,
                  //     textAlign: TextAlign.center,
                  //     overflow: TextOverflow.fade,
                  //     softWrap: true,
                  //     maxLines: 2
                  // ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Text(appStrings(context).imageCount(tag["counter"]),
                      style: Theme.of(context).textTheme.bodyText2,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ]
        ),
      ),
    );
  }
  // Widget albumThumbnail(BuildContext context, album) {
  //   return LayoutBuilder(builder: (context, layout) {
  //     return Container(
  //       decoration: BoxDecoration(
  //         border: Border.all(width: 0, color: Theme.of(context).backgroundColor),
  //         color: Theme.of(context).backgroundColor,
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(10),
  //           bottomLeft: Radius.circular(10),
  //         ),
  //       ),
  //       padding: EdgeInsets.all(5),
  //       height: layout.maxHeight,// albumGridItemHeight(context),
  //       width: layout.maxHeight,// albumGridItemHeight(context),
  //       child: album["tn_url"] == null ?
  //       Icon(Icons.image_not_supported_outlined, size: 50)
  //           :
  //       ClipRRect(
  //         borderRadius: BorderRadius.circular(7.0),
  //         child: Image.network(
  //           album["tn_url"],
  //           fit: BoxFit.cover,
  //         ),
  //       ),
  //     );
  //   });
  // }
  // Widget albumItemSeparator(BuildContext context) {
  //   return Container(
  //     decoration: ShapeDecoration(
  //       shape: AlbumCardSeparatorShape(radius: 7),
  //       color: Theme.of(context).backgroundColor,
  //     ),
  //     width: 14,
  //     height: 80,
  //   );
  // }
}

