import 'dart:math';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/images.dart';
import 'package:piwigo_ng/components/buttons/animated_piwigo_button.dart';
import 'package:piwigo_ng/components/cards/image_details_card.dart';
import 'package:piwigo_ng/components/cards/tag_chip.dart';
import 'package:piwigo_ng/components/dialogs/confirm_dialog.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/components/modals/add_tags_modal.dart';
import 'package:piwigo_ng/components/sections/form_section.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class EditImagePage extends StatefulWidget {
  const EditImagePage({
    Key? key,
    this.images = const [],
  }) : super(key: key);

  final List<ImageModel> images;

  static const String routeName = '/images/edit';

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  static const double maxCarouselElementWidth = 300.0;
  static const double carouselHeight = 128.0;
  late final TextEditingController _authorController;
  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _descriptionController =
      TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  final List<DropdownMenuItem<int?>> _levelItems = [];
  List<TagModel> _tags = [];
  int? _privacyLevel;
  List<ImageModel> _imageList = [];

  @override
  void initState() {
    _imageList = widget.images;
    _authorController =
        TextEditingController(text: Preferences.getUploadAuthor);
    if (_imageList.length == 1) {
      _titleController.text = _imageList.first.name;
      _descriptionController.text = _imageList.first.comment ?? '';
      _tags = _imageList.first.tags;
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PrivacyLevel.values.forEach((privacy) {
        _levelItems.add(DropdownMenuItem<int?>(
          value: privacy.value,
          child: Tooltip(
            message: privacy.localization,
            child: Text(privacy.localization, overflow: TextOverflow.fade),
          ),
        ));
      });
      if (_imageList.length == 1) {
        ApiResult<ImageModel>? result = await getImage(_imageList.first.id);
        if (result.hasData) {
          setState(() {
            _imageList[0] = result.data!;
            _tags = result.data!.tags;
          });
        }
      }
      setState(() {});
    });
  }

  Future<void> _onRemoveImage(ImageModel image) async {
    if (!await showConfirmDialog(
      context,
      title: appStrings.removeSelectedImage_title,
      message: appStrings.removeSelectedImage_message,
      confirm: appStrings.alertRemoveButton,
      confirmColor: Theme.of(context).colorScheme.error,
    )) return;
    setState(() {
      _imageList.remove(image);
      if (_imageList.isEmpty) {
        Navigator.of(context).pop();
      }
    });
  }

  void _onDeselectTag(TagModel tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _onEdit() async {
    _btnController.start();
    Iterable<int> tagIds = _tags.map<int>((tag) => tag.id);
    int result = await editImages(_imageList, {
      'title': _titleController.text.isEmpty ? null : _titleController.text,
      'author': _authorController.text.isEmpty ? null : _authorController.text,
      'description': _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      'level': _privacyLevel,
      'tags': tagIds.isEmpty ? null : tagIds.join(','),
    });
    if (!mounted) return;
    if (result <= 0) {
      _btnController.error();
      await Future.delayed(const Duration(milliseconds: 300));
      _btnController.reset();
    } else {
      _btnController.success();
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 5.0,
        title: Text(appStrings.imageOptions_edit),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _carousel,
          FormSection(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: appStrings.editImageDetails_title,
            child: AppField(
              controller: _titleController,
              hint: appStrings.editImageDetails_titlePlaceholder,
            ),
          ), // title
          FormSection(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: appStrings.editImageDetails_author,
            child: AppField(
              controller: _authorController,
              hint: appStrings.settings_defaultAuthorPlaceholder,
            ),
          ), // author
          FormSection(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: appStrings.editImageDetails_description,
            child: AppField(
              controller: _descriptionController,
              hint: appStrings.editImageDetails_descriptionPlaceholder,
              minLines: 5,
              maxLines: 10,
            ),
          ), // description
          FormSection(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: appStrings.editImageDetails_privacyLevel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              child: DropdownButton<int?>(
                onTap: () {
                  final FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                isExpanded: true,
                underline: const SizedBox(),
                value: _privacyLevel,
                onChanged: (level) {
                  setState(() {
                    _privacyLevel = level;
                  });
                },
                style: Theme.of(context).textTheme.bodyMedium,
                items: _levelItems,
              ),
            ),
          ), // privacy
          FormSection(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: appStrings.tagsAdd_title,
            onTapTitle: () {
              showMaterialModalBottomSheet<List<TagModel>>(
                context: context,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                builder: (context) => AddTagsModal(
                  selectedTags: _tags,
                ),
              ).then((value) {
                if (value is! List<TagModel>) return;
                setState(() {
                  _tags = value;
                });
              });
            },
            actions: [
              const Icon(Icons.add_circle),
            ],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(_tags.length, (index) {
                  TagModel tag = _tags[index];
                  return TagChip(
                    tag: tag,
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onTap: () => _onDeselectTag(tag),
                  );
                }),
              ),
            ),
          ), // tags
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: AnimatedPiwigoButton(
              controller: _btnController,
              color: Theme.of(context).primaryColor,
              onPressed: _onEdit,
              child: Text(
                appStrings.alertConfirmButton,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _carousel {
    return SizedBox(
      height: carouselHeight,
      child: OrientationBuilder(builder: (context, orientation) {
        return PageView.builder(
          controller: PageController(
            viewportFraction: min(
              maxCarouselElementWidth / MediaQuery.of(context).size.width,
              0.9,
            ),
          ),
          padEnds: false,
          itemCount: _imageList.length,
          itemBuilder: (context, index) {
            ImageModel image = _imageList[index];
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 8.0 : 0.0,
                right: index == _imageList.length - 1 ? 8.0 : 0.0,
              ),
              child: ImageDetailsCard(
                image: image,
                onRemove: () => _onRemoveImage(image),
              ),
            );
          },
        );
      }),
    );
  }
}
