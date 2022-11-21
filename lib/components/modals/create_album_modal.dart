import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/components/buttons/animated_piwigo_button.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class CreateAlbumModal extends StatefulWidget {
  const CreateAlbumModal({Key? key, required this.albumId}) : super(key: key);

  final int albumId;

  @override
  State<CreateAlbumModal> createState() => _CreateAlbumModalState();
}

class _CreateAlbumModalState extends State<CreateAlbumModal> {
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  String _name = '';
  String _description = '';

  Future<void> _onCreateAlbum() async {
    if (_name.isEmpty) return;
    _btnController.start();
    ApiResult result = await addAlbum(
      parentId: widget.albumId,
      name: _name,
      description: _description,
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: 400.0,
              ),
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              child: Column(
                children: [
                  AppField(
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => setState(() {
                      _name = value;
                    }),
                    hint: appStrings.createNewAlbum_placeholder,
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.3,
                    color: Theme.of(context).disabledColor,
                  ),
                  AppField(
                    textInputAction: TextInputAction.done,
                    onChanged: (value) => setState(() {
                      _description = value;
                    }),
                    onFieldSubmitted: (value) => _onCreateAlbum(),
                    hint: appStrings.createNewAlbumDescription_placeholder,
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                children: [
                  AnimatedPiwigoButton(
                    controller: _btnController,
                    disabled: _name.isEmpty,
                    color: Theme.of(context).primaryColor,
                    onPressed: _onCreateAlbum,
                    child: Text(
                      appStrings.alertAddButton,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  PiwigoButton(
                    color: Colors.transparent,
                    style: Theme.of(context).textTheme.titleSmall,
                    onPressed: () => Navigator.of(context).pop(),
                    text: appStrings.alertCancelButton,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
