import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/buttons/animated_piwigo_button.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/network/albums.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class EditAlbumModal extends StatefulWidget {
  const EditAlbumModal({Key? key, required this.album}) : super(key: key);

  final AlbumModel album;

  @override
  State<EditAlbumModal> createState() => _EditAlbumModalState();
}

class _EditAlbumModalState extends State<EditAlbumModal> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late String _name;

  @override
  initState() {
    _name = widget.album.name;
    _nameController = TextEditingController(text: _name);
    _descriptionController = TextEditingController(text: widget.album.comment);
    super.initState();
  }

  Future<void> _onEditAlbum() async {
    if (_name.isEmpty) return;
    if (_name == widget.album.name &&
        _descriptionController.text == widget.album.comment) {
      Navigator.of(context).pop();
    }
    _btnController.start();
    ApiResponse result = await editAlbum(
      albumId: widget.album.id,
      name: _name,
      description: _descriptionController.text,
    );
    if (result.hasError) {
      _btnController.error();
      ScaffoldMessenger.of(context).showSnackBar(
        errorSnackBar(
          message: appStrings.renameCategoryError_title,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        successSnackBar(
          message: appStrings.renameCategoryHUD_renamed,
          icon: Icons.build_circle,
        ),
      );
      _btnController.success();
      Navigator.of(context).pop();
    }
    await Future.delayed(const Duration(seconds: 1));
    _btnController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoModal(
      title: appStrings.renameCategory_title,
      subtitle: appStrings.renameCategory_message,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: AppField(
                controller: _nameController,
                onChanged: (value) => setState(() {
                  _name = value;
                }),
                hint: appStrings.createNewAlbum_placeholder,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: AppField(
                controller: _descriptionController,
                hint: appStrings.createNewAlbumDescription_placeholder,
                minLines: 5,
                maxLines: 10,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: AnimatedPiwigoButton(
                controller: _btnController,
                disabled: _name.isEmpty,
                color: Theme.of(context).primaryColor,
                onPressed: _onEditAlbum,
                child: Text(
                  appStrings.categoryCellOption_rename,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
