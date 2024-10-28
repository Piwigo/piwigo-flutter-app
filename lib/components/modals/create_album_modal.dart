import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/buttons/animated_piwigo_button.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/network/albums.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class CreateAlbumModal extends StatefulWidget {
  const CreateAlbumModal({Key? key, required this.albumId}) : super(key: key);

  final int albumId;

  @override
  State<CreateAlbumModal> createState() => _CreateAlbumModalState();
}

class _CreateAlbumModalState extends State<CreateAlbumModal> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _descriptionController = TextEditingController();

  String _name = '';

  Future<void> _onCreateAlbum() async {
    if (_name.isEmpty) return;
    _btnController.start();
    ApiResponse result = await addAlbum(
      parentId: widget.albumId,
      name: _name,
      description: _descriptionController.text,
    );
    if (result.hasError) {
      _btnController.error();
      ScaffoldMessenger.of(context).showSnackBar(
        errorSnackBar(
          message: appStrings.createAlbumError_title,
        ),
      );
    } else {
      _btnController.success();
      ScaffoldMessenger.of(context).showSnackBar(
        successSnackBar(
          message: appStrings.createNewAlbumHUD_created,
          icon: Icons.add_circle_outlined,
        ),
      );
      Navigator.of(context).pop();
    }
    await Future.delayed(const Duration(seconds: 1));
    _btnController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoModal(
      title: appStrings.createNewAlbum_title,
      subtitle: appStrings.createNewAlbum_message,
      content: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: AppField(
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
                onPressed: _onCreateAlbum,
                child: Text(
                  appStrings.alertAddButton,
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

Future<void> showCreateAlbumModal(BuildContext context, int parentId) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => CreateAlbumModal(albumId: parentId),
  );
}
