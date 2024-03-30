import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/network/tags.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/image/image_tags_page.dart';

class OpenTagModal extends StatefulWidget {
  const OpenTagModal({super.key});

  @override
  _OpenTagModalState createState() => _OpenTagModalState();
}

class _OpenTagModalState extends State<OpenTagModal> {
  final ScrollController _scrollController = ScrollController();
  late final Future _tagsFuture;

  String _searchQuery = '';
  List<TagModel>? _tagList;

  @override
  void initState() {
    super.initState();
    _tagsFuture = _onRefresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      final ApiResponse<List<TagModel>> result = await getTags();
      if (!result.hasData) return;
      setState(() {
        _tagList = result.data!.where((tag) => tag.counter > 0).toList()..sort((a, b) => a.name.compareTo(b.name));
      });
    } catch (e) {
      setState(() {
        _tagList = null;
      });
    }
  }

  void _onSelectTag(TagModel tag) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(
      ImageTagsPage.routeName,
      arguments: {
        'tag': tag,
      },
    );
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
      ),
      body: ListView(
        controller: ModalScrollController.of(context),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: AppField(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              prefix: Icon(Icons.search),
              onChanged: (query) => setState(() {
                _searchQuery = query;
              }),
            ),
          ),
          FutureBuilder(
            future: _tagsFuture,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return _buildTagList();
                default:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTagList() {
    if (_tagList == null) {
      return Center(
        child: Text(appStrings.coreDataFetch_TagError),
      );
    }

    List<TagModel> tags =
        _tagList!.where((tag) => tag.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    if (tags.isEmpty) {
      return Center(
        child: Text(appStrings.none),
      );
    }

    return Column(
      children: tags.map((tag) => _buildItem(tag)).toList(),
    );
  }

  Widget _buildItem(TagModel tag) => ListTile(
        visualDensity: VisualDensity.compact,
        shape: Border(
          bottom: BorderSide(color: Theme.of(context).scaffoldBackgroundColor),
        ),
        title: Text(tag.name),
        trailing: Text(appStrings.imageCount(tag.counter)),
        onTap: () => _onSelectTag(tag),
      );
}

Future<int?> showOpenTagModal(BuildContext context) async {
  return showMaterialModalBottomSheet<int>(
    context: context,
    enableDrag: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) => OpenTagModal(),
  );
}
