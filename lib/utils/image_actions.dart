import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/images.dart';
import 'package:piwigo_ng/api/upload.dart';
import 'package:piwigo_ng/api/users.dart';
import 'package:piwigo_ng/components/dialogs/confirm_dialog.dart';
import 'package:piwigo_ng/components/modals/choose_camera_picker_modal.dart';
import 'package:piwigo_ng/components/modals/choose_move_option_modal.dart';
import 'package:piwigo_ng/components/modals/delete_images_modal.dart';
import 'package:piwigo_ng/components/modals/move_or_copy_modal.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/image/edit_image_page.dart';

final ImagePicker _picker = ImagePicker();

Future<List<XFile>?> onPickImages() async {
  try {
    if (!await askMediaPermission()) return null;
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );
    if (result == null) return null;
    return result.files
        .map<XFile>((e) => XFile(e.path!, name: e.name, bytes: e.bytes))
        .toList();
  } catch (e) {
    debugPrint('${e.toString()}');
  }
  return null;
}

Future<XFile?> onTakePhoto(BuildContext context) async {
  final int? choice = await showModalBottomSheet<int>(
    context: context,
    builder: (context) => ChooseCameraPickerModal(),
  );
  if (choice == null) return null;
  try {
    XFile? image;
    switch (choice) {
      case 0:
        image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: (Preferences.getUploadQuality * 100).round(),
          requestFullMetadata: Preferences.getRemoveMetadata,
        );
        break;
      case 1:
        image = await _picker.pickVideo(source: ImageSource.camera);
        break;
    }
    return image;
  } catch (e) {
    debugPrint('${e.toString()}');
  }
  return null;
}

Future<bool?> onEditPhotos(
    BuildContext context, List<ImageModel> images) async {
  return await Navigator.of(context)
      .pushNamed(EditImagePage.routeName, arguments: {
    'images': images,
  });
}

Future<dynamic> onMovePhotos(BuildContext context, List<ImageModel> images,
    [AlbumModel? album]) async {
  late AlbumModel origin;
  if (album == null || images.length == 1) {
    origin = AlbumModel(
      id: images.first.categories.first['id'],
      name: '',
    );
  } else {
    origin = album;
  }
  return showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: MediaQuery.of(context).padding,
      child: MoveOrCopyModal(
        title: appStrings.moveImage_title,
        subtitle:
            appStrings.moveImage_selectAlbum(images.length, images.first.name),
        isImage: true,
        album: origin,
        onSelected: (selectedAlbum) async {
          final int? choice = await showModalBottomSheet<int>(
            context: context,
            builder: (context) => ChooseMoveOptionModal(),
          );
          if (choice == null ||
              !await showConfirmDialog(
                context,
                title: appStrings.moveImage_title,
                message: appStrings.moveImage_message(
                    images.length, images.first, selectedAlbum.name),
              )) return false;
          int results = 0;
          switch (choice) {
            case 0:
              results = await moveImages(images, origin.id, selectedAlbum.id);
              break;
            case 1:
              results = await assignImages(images, selectedAlbum.id);
              break;
          }
          if (results > 0) {
            return true;
          }
          return false;
        },
      ),
    ),
  );
}

Future<bool> onDeletePhotos(BuildContext context, List<ImageModel> images,
    [AlbumModel? album]) async {
  final DeleteAlbumModes? mode = await showModalBottomSheet<DeleteAlbumModes>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (context) => DeleteImagesModal(
      imageList: images,
      album: album,
    ),
  );
  if (mode == null) return false;
  if (!await showConfirmDialog(
    context,
    message: appStrings.deleteImage_message(
      images.length,
    ),
  )) {
    return false;
  }
  final int result = await deleteImages(
    images,
    album,
    mode,
  );
  if (result > 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      successSnackBar(message: appStrings.deleteImageSuccess_message(result)),
    );
    return true;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      errorSnackBar(message: appStrings.deleteImageFail_message),
    );
  }
  return false;
}

Future<bool?> onLikePhotos(
    List<ImageModel> images, bool hasNonFavorites) async {
  if (hasNonFavorites) {
    int success =
        await addFavorites(images.where((image) => !image.favorite).toList());
    if (success > 0) {
      return true;
    }
  } else {
    int success = await removeFavorites(images);
    if (success > 0) {
      return false;
    }
  }
  return null;
}
