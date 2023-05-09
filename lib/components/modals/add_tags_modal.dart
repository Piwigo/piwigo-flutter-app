import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/tags.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/components/cards/tag_chip.dart';
import 'package:piwigo_ng/components/modals/create_tag_modal.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';

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
    TagModel? addedTag = await showPiwigoModal<TagModel?>(
      context: context,
      builder: (context) => CreateTagModal(),
    );
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
    if (_selectedTagList.contains(tag)) {
      _onDeselectTag(tag);
    } else {
      setState(() {
        _selectedTagList.add(tag);
      });
    }
  }

  void _onDeselectTag(TagModel tag) {
    setState(() {
      _selectedTagList.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.new_label),
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
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: PiwigoButton(
              color: Theme.of(context).primaryColor,
              onPressed: () => Navigator.of(context).pop(_selectedTagList),
              text: appStrings.alertConfirmButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _tagLists {
    // List<TagModel> unselectedTags =
    //     _tagList.where((tag) => !_selectedTagList.contains(tag)).toList();
    return ListView(
      controller: ModalScrollController.of(context),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        TagWrap(
          tags: _tagList,
          onTap: _onSelectTag,
          isSelected: (tag) => _selectedTagList.contains(tag),
        ),
      ],
    );
  }
}

class TagWrap extends StatelessWidget {
  const TagWrap({
    Key? key,
    this.tags = const [],
    this.onTap,
    this.isSelected,
  }) : super(key: key);

  final List<TagModel> tags;
  final Function(TagModel)? onTap;
  final bool Function(TagModel)? isSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(tags.length, (index) {
        TagModel tag = tags[index];
        return SelectTagChip(
          tag: tag,
          selected: isSelected?.call(tag) ?? false,
          onTap: () => onTap?.call(tag),
        );
      }),
    );
  }
}
