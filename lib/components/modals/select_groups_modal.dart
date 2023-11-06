import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/components/lists/select_model_list.dart';
import 'package:piwigo_ng/models/group_model.dart';
import 'package:piwigo_ng/network/groups.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class SelectGroupsModal extends StatefulWidget {
  const SelectGroupsModal({
    Key? key,
    this.selectedGroups,
  }) : super(key: key);

  final List<GroupModel>? selectedGroups;

  @override
  _SelectGroupsModalState createState() => _SelectGroupsModalState();
}

class _SelectGroupsModalState extends State<SelectGroupsModal> {
  final ScrollController _scrollController = ScrollController();
  late final Future _groupsFuture;

  List<GroupModel> _selectedGroupList = [];
  List<GroupModel>? _groupList = [];

  @override
  void initState() {
    _selectedGroupList = widget.selectedGroups ?? [];
    super.initState();
    _groupsFuture = _getData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<GroupModel> get _unselectedGroupList =>
      _groupList!.where((g) => !_selectedGroupList.contains(g)).toList();

  Future _getData() async {
    List<GroupModel>? data = await getAllGroups();
    _groupList = data;
  }

  int _onSelectGroup(GroupModel group) {
    setState(() {
      _selectedGroupList.add(group);
      _sortLists();
    });
    return _selectedGroupList.indexOf(group);
  }

  int _onDeselectGroup(GroupModel group) {
    setState(() {
      _selectedGroupList.remove(group);
      _sortLists();
    });
    return _unselectedGroupList.indexOf(group);
  }

  void _sortLists() {
    _selectedGroupList.sort((a, b) => a.name.compareTo(b.name));
    _groupList?.sort((a, b) => a.name.compareTo(b.name));
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
        title: Text(appStrings.groups),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _groupsFuture,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return _groupLists;
                  default:
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
              onPressed: () => Navigator.of(context).pop(_selectedGroupList),
              text: appStrings.alertConfirmButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _groupLists {
    if (_groupList == null) {
      return Center(
        child: Text(appStrings.errorHUD_label),
      );
    }
    return ListView(
      controller: ModalScrollController.of(context),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SelectModelList<GroupModel>(
          selected: _selectedGroupList,
          unselected: _unselectedGroupList,
          itemBuilder: (group) => Text(group.name),
          onSelect: _onSelectGroup,
          onDeselect: _onDeselectGroup,
        ),
      ],
    );
  }
}

Future<List<GroupModel>?> showSelectGroupModal(
  BuildContext context, [
  List<GroupModel>? selectedGroups,
]) async {
  return showMaterialModalBottomSheet<List<GroupModel>>(
    context: context,
    enableDrag: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) => SelectGroupsModal(
      selectedGroups: selectedGroups,
    ),
  );
}
