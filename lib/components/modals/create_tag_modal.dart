import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/tags.dart';
import 'package:piwigo_ng/components/buttons/animated_piwigo_button.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/components/snackbars.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class CreateTagModal extends StatefulWidget {
  const CreateTagModal({Key? key}) : super(key: key);

  @override
  State<CreateTagModal> createState() => _CreateTagModalState();
}

class _CreateTagModalState extends State<CreateTagModal> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  String _name = '';

  Future<void> _onCreateTag() async {
    if (_name.isEmpty) return;
    _btnController.start();
    ApiResult result = await createTag(_name);
    if (result.hasError) {
      _btnController.error();
      ScaffoldMessenger.of(context).showSnackBar(
        errorSnackBar(
          message: appStrings.tagsAddError_message,
        ),
      );
    } else {
      _btnController.success();
      ScaffoldMessenger.of(context).showSnackBar(
        successSnackBar(
          message: appStrings.tagsAddHUD_created,
          icon: Icons.add_circle_outlined,
        ),
      );
      Navigator.of(context).pop(result.data);
    }
    await Future.delayed(const Duration(seconds: 1));
    _btnController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoModal(
      title: appStrings.tagsAdd_title,
      subtitle: appStrings.tagsAdd_message,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: AppField(
                onChanged: (value) => setState(() {
                  _name = value;
                }),
                hint: appStrings.tagsAdd_placeholder,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: AnimatedPiwigoButton(
                controller: _btnController,
                disabled: _name.isEmpty,
                color: Theme.of(context).primaryColor,
                onPressed: _onCreateTag,
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
