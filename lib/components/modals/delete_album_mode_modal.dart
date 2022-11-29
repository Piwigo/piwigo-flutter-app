import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class DeleteAlbumModeModal extends StatelessWidget {
  const DeleteAlbumModeModal({
    Key? key,
    required this.albumModel,
  }) : super(key: key);

  final AlbumModel albumModel;

  @override
  Widget build(BuildContext context) {
    return PiwigoModal(
      title: appStrings.deleteCategory_title,
      subtitle: appStrings.deleteCategory_message(albumModel.nbTotalImages, albumModel.name),
      canCancel: true,
      content: Column(
        children: [
          ListTile(
            minLeadingWidth: 24,
            leading: Icon(Icons.photo_library, color: Theme.of(context).primaryColor),
            title: Text(appStrings.deleteCategory_noImages),
            subtitle: Text(appStrings.deleteCategory_noImages_subtitle),
            onTap: () => Navigator.of(context).pop(DeleteAlbumModes.noDelete),
          ),
          ListTile(
            minLeadingWidth: 24,
            leading: Icon(Icons.delete, color: Theme.of(context).errorColor),
            title: Text(appStrings.deleteCategory_orphanedImages),
            subtitle: Text(appStrings.deleteCategory_orphanedImages_subtitle),
            onTap: () => Navigator.of(context).pop(DeleteAlbumModes.deleteOrphans),
          ),
          ListTile(
            minLeadingWidth: 24,
            leading: SizedBox.fromSize(
              size: Size.square(24),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.photo_library,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Stack(
                      children: [
                        Icon(
                          Icons.delete,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          size: 20,
                        ),
                        Icon(
                          Icons.delete,
                          color: Theme.of(context).errorColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            title: Text(appStrings.deleteCategory_allImages(albumModel.nbTotalImages)),
            subtitle: Text(appStrings.deleteCategory_allImages_subtitle),
            onTap: () => Navigator.of(context).pop(DeleteAlbumModes.forceDelete),
          ),
        ],
      ),
    );
  }
}
