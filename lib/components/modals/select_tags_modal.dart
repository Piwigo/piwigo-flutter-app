import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/components/lists/select_model_list.dart';
import 'package:piwigo_ng/components/modals/create_tag_modal.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/network/tags.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class SelectTagsModal extends StatefulWidget {
  const SelectTagsModal({
    Key? key,
    this.selectedTags,
  }) : super(key: key);

  final List<TagModel>? selectedTags;

  @override
  _SelectTagsModalState createState() => _SelectTagsModalState();
}

class _SelectTagsModalState extends State<SelectTagsModal> {
  final ScrollController _scrollController = ScrollController();
  late final Future _tagsFuture;

  List<TagModel> _selectedTagList = [];
  List<TagModel>? _tagList = [];

  @override
  void initState() {
    _selectedTagList = List.from(widget.selectedTags ?? []);
    super.initState();
    _tagsFuture = _onRefresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<TagModel> get _unselectedTagList =>
      _tagList!.where((t) => !_selectedTagList.contains(t)).toList();

  Future<void> _onRefresh() async {
    final ApiResponse<List<TagModel>> result = await getTags();
    if (!result.hasData) return;
    setState(() {
      _tagList = result.data!;
      _sortLists();
    });
  }

  Future<void> _onAddTag() async {
    TagModel? addedTag = await showPiwigoModal<TagModel?>(
      context: context,
      builder: (context) => CreateTagModal(),
    );
    if (addedTag == null) return;
    await _onRefresh();
    if (_tagList == null) return;
    try {
      setState(() {
        _selectedTagList.add(
          _tagList!.where((tag) => tag.id == addedTag.id).first,
        );
        _sortLists();
      });
    } on StateError catch (_) {
      debugPrint('Can\'t fetch new tag');
    }
  }

  int _onSelectTag(TagModel tag) {
    setState(() {
      _selectedTagList.add(tag);
      _sortLists();
    });
    return _selectedTagList.indexOf(tag);
  }

  int _onDeselectTag(TagModel tag) {
    setState(() {
      _selectedTagList.remove(tag);
      _sortLists();
    });
    return _unselectedTagList.indexOf(tag);
  }

  void _sortLists() {
    _selectedTagList.sort((a, b) => a.name.compareTo(b.name));
    _tagList?.sort((a, b) => a.name.compareTo(b.name));
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
            child: FutureBuilder(
              future: _tagsFuture,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return _tagLists;
                  default:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
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
    if (_tagList == null) {
      return Center(
        child: Text(appStrings.errorHUD_label),
      );
    }
    return ListView(
      controller: ModalScrollController.of(context),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SelectModelList<TagModel>(
          selected: _selectedTagList,
          unselected: _unselectedTagList,
          itemBuilder: (group) => Text(group.name),
          onSelect: _onSelectTag,
          onDeselect: _onDeselectTag,
        ),
      ],
    );
  }
}

Future<List<TagModel>?> showSelectTagsModal(
  BuildContext context, [
  List<TagModel>? selectedTags,
]) async {
  return showMaterialModalBottomSheet<List<TagModel>>(
    context: context,
    enableDrag: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) => SelectTagsModal(
      selectedTags: selectedTags,
    ),
  );
}
