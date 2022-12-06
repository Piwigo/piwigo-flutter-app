import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class DeleteImagesModal extends StatelessWidget {
  const DeleteImagesModal({
    Key? key,
    required this.imageList,
    required this.album,
  }) : super(key: key);

  final List<ImageModel> imageList;
  final AlbumModel album;

  bool get _safeDelete {
    for (ImageModel image in imageList) {
      if (image.categories.length > 1) {
        return true;
      }
    }
    return false;
  }

  bool get _canMakeOrphans {
    for (ImageModel image in imageList) {
      List<int> albums = image.categories.map<int>((a) => a['id']).toList();
      albums.removeWhere((a) => a == album.id);
      if (albums.isEmpty) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoModal(
      title: appStrings.deleteImage_delete,
      subtitle: appStrings.deleteImage_message(imageList.length),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              minLeadingWidth: 24,
              leading: Icon(Icons.delete, color: Theme.of(context).errorColor),
              title: Text(appStrings.deleteImageCount_title(imageList.length)),
              subtitle: _canMakeOrphans && _safeDelete ? Text(appStrings.deleteCategory_allImages_subtitle) : null,
              onTap: () => Navigator.of(context).pop(DeleteAlbumModes.forceDelete),
            ),
            if (_safeDelete)
              Builder(
                builder: (context) {
                  if (_canMakeOrphans) {
                    return ListTile(
                      minLeadingWidth: 24,
                      leading: Icon(Icons.remove_circle, color: Theme.of(context).primaryColor),
                      title: Text(appStrings.deleteCategory_orphanedImages),
                      subtitle: Text(appStrings.deleteCategory_orphanedImages_subtitle),
                      onTap: () => Navigator.of(context).pop(DeleteAlbumModes.noDelete),
                    );
                  }
                  return ListTile(
                    minLeadingWidth: 24,
                    leading: Icon(Icons.remove_circle, color: Theme.of(context).primaryColor),
                    title: Text(_canMakeOrphans ? appStrings.deleteCategory_orphanedImages : appStrings.removeSingleImage_title),
                    subtitle: Text(_canMakeOrphans
                        ? appStrings.deleteCategory_orphanedImages_subtitle
                        : appStrings.deleteCategory_noImages_subtitle),
                    onTap: () => Navigator.of(context).pop(DeleteAlbumModes.noDelete),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
