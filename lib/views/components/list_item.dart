import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/CategoryViewPage.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';

import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';
import 'package:piwigo_ng/views/components/custom_shapes.dart';


String albumSubCount(dynamic album, context) {
  String displayString = appStrings(context).imageCount(album["total_nb_images"]);
  if(album["nb_categories"] > 0) {
    displayString += ', ${appStrings(context).subAlbumCount(album["nb_categories"])}';
  }
  return displayString;
}

class AlbumListItem extends StatefulWidget {
  const AlbumListItem(this.album, {Key key, this.isAdmin = false, this.onClose, this.onOpen, this.canUpload = false}) : super(key: key);

  final dynamic album;
  final bool isAdmin;
  final bool canUpload;
  final Function() onClose;
  final Function() onOpen;

  @override
  _AlbumListItemState createState() => _AlbumListItemState();
}
class _AlbumListItemState extends State<AlbumListItem> {

  void _onEditAlbum() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCategoryDialog(
            catId: widget.album['id'],
            catName: widget.album['name'],
            catDesc: widget.album['comment'],
            privacy: widget.album['status'] == 'private' ? true : false
        );
      },
    );
    widget.onClose();
  }
  void _onMoveAlbum() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MoveOrCopyDialog(
          title: appStrings(context).moveCategory,
          subtitle: appStrings(context).moveCategory_select(widget.album['name']),
          catId: widget.album['id'].toString(),
          catName: widget.album['name'],
          isImage: false,
          onSelected: (item) async {
            if (await confirmMoveDialog(context,
              content: appStrings(context).moveCategory_message(widget.album['name'], item.name),
            )) {
              var result = await moveCategory(widget.album['id'], item.id);
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
      }
    );
    widget.onClose();
  }
  void _onDeleteAlbum() async {
    if(widget.album["total_nb_images"] > 0) {
      int choice = await confirmDeleteAlbumWithImagesDialog(context,
        content: appStrings(context).deleteCategory_message(widget.album["total_nb_images"], widget.album["name"]),
        count: widget.album["total_nb_images"],
      );
      var result;
      switch(choice) {
        case 0: result = await deleteCategory(widget.album['id'].toString(),
            deletionMode: 'no_delete');
          break;
        case 1: result = await deleteCategory(widget.album['id'].toString(),
            deletionMode: 'delete_orphans');
          break;
        case 2: result = await deleteCategory(widget.album['id'].toString(),
            deletionMode: 'force_delete');
          break;
        default: break;
      }
      widget.onClose();
    }
    else {
      if (await confirmDeleteDialog(context,
        content: appStrings(context).deleteCategory_message(widget.album["total_nb_images"], widget.album["name"]),
      )) {
        var result = await deleteCategory(widget.album['id'].toString());
        if(result['stat'] == 'fail') {
          ScaffoldMessenger.of(context).showSnackBar(
              errorSnackBar(context, result['result'])
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              albumDeletedSnackBar(context)
          );
          widget.onClose();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if(widget.onOpen != null) widget.onOpen();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CategoryViewPage(
            title: widget.album["name"],
            category: widget.album["id"].toString(),
            isAdmin: widget.isAdmin,
            nbImages: widget.album["nb_images"],
          )),
        ).whenComplete(() {
          widget.onClose();
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Slidable(
          enabled: widget.isAdmin,
          child: AlbumListCard(widget.album, isAdmin: widget.isAdmin, canUpload: widget.canUpload,),
          endActionPane: ActionPane(
            motion: DrawerMotion(),
            children: [
              CustomSlidableAction(
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: (_) => _onEditAlbum(),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ),
              CustomSlidableAction(
                backgroundColor: Color(0xFF4B4B4B),
                onPressed: (_) => _onMoveAlbum(),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(Icons.reply, color: Colors.white),
                  ),
                ),
              ),
              CustomSlidableAction(
                backgroundColor: Colors.red,
                autoClose: true,
                onPressed: (_) => _onDeleteAlbum(),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlbumListCard extends StatelessWidget {
  const AlbumListCard(this.album, {Key key, this.isAdmin = false, this.canUpload = false,}) : super(key: key);

  final dynamic album;
  final bool isAdmin;
  final bool canUpload;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        albumThumbnail(context, album),
        albumItemSeparator(context),
        albumInfo(context, album),
        Container(
          height: albumGridItemHeight(context),
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
              height: 60,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text('${album["name"]}',
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ),
                  if(canUpload) Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Icon(Icons.upload, size: 18,),
                  ),
                ],
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
  Widget albumThumbnail(BuildContext context, album) {
    return LayoutBuilder(builder: (context, layout) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0, color: Theme.of(context).backgroundColor),
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
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
}

