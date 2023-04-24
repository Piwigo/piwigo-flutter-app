import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/components/dialogs/confirm_dialog.dart';
import 'package:piwigo_ng/components/modals/create_album_modal.dart';
import 'package:piwigo_ng/components/modals/delete_album_mode_modal.dart';
import 'package:piwigo_ng/components/modals/edit_album_modal.dart';
import 'package:piwigo_ng/components/modals/move_or_copy_modal.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/album/album_view_page.dart';

Future<void> onOpenAlbum(BuildContext context, AlbumModel album) async {
  Navigator.of(context).pushNamed(
    AlbumViewPage.routeName,
    arguments: {
      'album': album,
    },
  );
}

Future<void> onAddAlbum(BuildContext context, int parentId) async {
  await showCreateAlbumModal(
    context,
    parentId,
  );
}

Future<void> onEditAlbum(BuildContext context, AlbumModel album) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => EditAlbumModal(album: album),
  );
}

Future<void> onMoveAlbum(BuildContext context, AlbumModel album) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => MoveOrCopyModal(
      title: appStrings.moveCategory,
      subtitle: appStrings.moveCategory_select(album.name),
      album: album,
      onSelected: (selectedAlbum) async {
        if (!await showConfirmDialog(
          context,
          title: appStrings.moveCategory,
          message: appStrings.moveCategory_message(
            album.name,
            selectedAlbum.name,
          ),
        )) return false;
        ApiResult<bool> result = await moveAlbum(
          album.id,
          selectedAlbum.id,
        );

        return result.hasData && result.data == true;
      },
    ),
  );
}

Future<bool> onDeleteAlbum(BuildContext context, AlbumModel album) async {
  DeleteAlbumModes? mode = DeleteAlbumModes.deleteOrphans;
  if (album.nbTotalImages != 0) {
    mode = await showModalBottomSheet<DeleteAlbumModes>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) => DeleteAlbumModeModal(
        albumModel: album,
      ),
    );
    if (mode == null) return false;
  }
  if (!await showConfirmDialog(
    context,
    title: appStrings.deleteCategoryConfirm_title,
    message: appStrings.deleteCategory_message(album.nbTotalImages, album.name),
    confirm: appStrings.deleteCategoryConfirm_deleteButton,
    confirmColor: Theme.of(context).colorScheme.error,
  )) return false;
  final ApiResult result = await deleteAlbum(
    album.id,
    deletionMode: mode,
  );
  if (result.hasData && result.data == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      successSnackBar(message: appStrings.deleteCategoryHUD_deleted),
    );
    return true;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    errorSnackBar(message: appStrings.deleteCategoryError_title),
  );
  return false;
}
