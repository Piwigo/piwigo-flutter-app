import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/components/cards/piwigo_chip.dart';
import 'package:piwigo_ng/models/group_model.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/network/groups.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late final Future<ApiResponse> _groupsFuture;

  PagingModel _paging = PagingModel();

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

  Future<ApiResponse> _getData() async {
    ApiResponse response = await getGroups();
    if (response.hasError) {
      _groupList = null;
      return response;
    }
    if (response.paging != null) {
      _paging = response.paging!;
    }
    _groupList = response.data;
    _sortList();
    return response;
  }

  Future<void> _loadMoreGroups() async {
    if (_groupList == null) return;
    ApiResponse response = await getGroups(_paging.page + 1);
    if (response.hasError) {
      _refreshController.loadFailed();
      await Future.delayed(const Duration(milliseconds: 500));
      return _refreshController.loadComplete();
    }
    setState(() {
      if (response.paging != null) {
        _paging = response.paging!;
      }
      _groupList!.addAll(response.data);
      _sortList();
    });
    _refreshController.loadComplete();
  }

  void _onSelectGroup(GroupModel group) {
    if (_selectedGroupList.contains(group)) {
      _onDeselectGroup(group);
    } else {
      setState(() {
        _selectedGroupList.add(group);
        _sortList();
      });
    }
  }

  void _onDeselectGroup(GroupModel group) {
    setState(() {
      _selectedGroupList.remove(group);
      _sortList();
    });
  }

  void _sortList() {
    _groupList?.sort((a, b) {
      bool selectedA = _selectedGroupList.contains(a);
      bool selectedB = _selectedGroupList.contains(b);
      if (selectedA && !selectedB) return -1;
      if (!selectedA && selectedB) return 1;
      return a.compareTo(b);
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
        title: Text(appStrings.groupsTitle_selectOne),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<ApiResponse>(
              future: _groupsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _groupLists;
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
              onPressed: () => Navigator.of(context).pop(_selectedGroupList),
              text: appStrings.alertConfirmButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _groupLists {
    // List<GroupModel> unselectedGroups =
    //     _groupList.where((group) => !_selectedGroupList.contains(group)).toList();
    if (_groupList == null) {
      return Center(
        child: Text(appStrings.errorHUD_label),
      );
    }
    return SmartRefresher(
      controller: _refreshController,
      scrollController: ModalScrollController.of(context),
      enablePullDown: false,
      enablePullUp: _paging.nbTotal == _paging.nbPerPage,
      onLoading: _loadMoreGroups,
      footer: ClassicFooter(
        loadingText: appStrings.loadingHUD_label,
        noDataText: appStrings.categoryImageList_noDataError,
        failedText: appStrings.errorHUD_label,
        idleText: '',
        canLoadingText: appStrings.loadMoreHUD_label,
      ),
      child: ListView(
        controller: ModalScrollController.of(context),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: .0,
            children: List.generate(_groupList!.length, (index) {
              GroupModel group = _groupList![index];
              return SelectChip(
                selected: _selectedGroupList.contains(group),
                onTap: () => _onSelectGroup(group),
                label: group.name,
              );
            }),
          ),
        ],
      ),
    );
  }
}

Future<List<GroupModel>?> showSelectGroupModal(
  BuildContext context, [
  List<GroupModel>? selectedGroups,
]) async {
  return showMaterialModalBottomSheet<List<GroupModel>>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) => SelectGroupsModal(
      selectedGroups: selectedGroups,
    ),
  );
}
