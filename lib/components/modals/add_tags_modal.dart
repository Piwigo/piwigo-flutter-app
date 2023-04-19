import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/tags.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/components/cards/tag_chip.dart';
import 'package:piwigo_ng/components/modals/create_tag_modal.dart';
import 'package:piwigo_ng/components/sections/form_section.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/resources.dart';

class AddTagsModal extends StatefulWidget {
  const AddTagsModal({
    Key? key,
    this.selectedTags,
  }) : super(key: key);

  final List<TagModel>? selectedTags;

  @override
  _AddTagsModalState createState() => _AddTagsModalState();
}

class _AddTagsModalState extends State<AddTagsModal> {
  final ScrollController _scrollController = ScrollController();
  late final Future<ApiResult<List<TagModel>>> _tagsFuture;

  List<TagModel> _selectedTagList = [];
  List<TagModel> _tagList = [];

  @override
  void initState() {
    _selectedTagList = widget.selectedTags ?? [];
    super.initState();
    _tagsFuture = getTags();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final ApiResult<List<TagModel>> result = await getTags();
    if (!result.hasData) return;
    setState(() {
      _tagList = result.data!;
    });
  }

  Future<void> _onAddTag() async {
    TagModel? addedTag = await showCreateTagModal(context);
    if (addedTag == null) return;
    await _onRefresh();
    try {
      setState(() {
        _selectedTagList
            .add(_tagList.where((tag) => tag.id == addedTag.id).first);
      });
    } on StateError catch (_) {
      debugPrint('Can\'t fetch new tag');
    }
  }

  void _onSelectTag(TagModel tag) {
    setState(() {
      _selectedTagList.add(tag);
    });
  }

  void _onDeselectTag(TagModel tag) {
    setState(() {
      _selectedTagList.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      backgroundColor: Theme.of(context).colorScheme.background,
      enableDrag: false,
      onClosing: () {},
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
      ),
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15.0),
            ),
          ),
          elevation: 0.0,
          scrolledUnderElevation: 5.0,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(appStrings.tags),
          actions: [
            IconButton(
              tooltip: appStrings.tagsAdd_placeholder,
              onPressed: _onAddTag,
              icon: Icon(Icons.add),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<ApiResult<List<TagModel>>>(
                  future: _tagsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (!snapshot.data!.hasData) {
                        return Center(
                          child: Text(appStrings.errorHUD_label),
                        );
                      }
                      if (_tagList.isEmpty) {
                        _tagList = snapshot.data!.data ?? [];
                      }
                      return _tagLists;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: PiwigoButton(
                color: Theme.of(context).primaryColor,
                onPressed: () => Navigator.of(context).pop(),
                text: appStrings.alertConfirmButton,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _tagLists {
    List<TagModel> unselectedTags =
        _tagList.where((tag) => !_selectedTagList.contains(tag)).toList();
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            crossAxisMargin: 8.0,
            mainAxisMargin: 8.0,
            radius: Radius.circular(10.0),
            thumbColor: MaterialStateColor.resolveWith(
              (states) => Theme.of(context).disabledColor,
            ),
          ),
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              FormSection(
                title: appStrings.tagsHeader_selected,
                child: TagWrap(
                  tags: _selectedTagList,
                  onTap: _onDeselectTag,
                ),
              ),
              FormSection(
                title: appStrings.tagsHeader_notSelected,
                child: TagWrap(
                  tags: unselectedTags,
                  removeAction: false,
                  onTap: _onSelectTag,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TagWrap extends StatelessWidget {
  const TagWrap(
      {Key? key, this.tags = const [], this.removeAction = true, this.onTap})
      : super(key: key);

  final List<TagModel> tags;
  final bool removeAction;
  final Function(TagModel)? onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(tags.length, (index) {
        TagModel tag = tags[index];
        return TagChip(
          tag: tag,
          onTap: () => onTap?.call(tag),
          icon: removeAction
              ? Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.error,
                )
              : Icon(
                  Icons.add_circle_outline,
                  color: AppColors.success,
                ),
        );
      }),
    );
  }
}
