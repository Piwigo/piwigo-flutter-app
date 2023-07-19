import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/components/cards/piwigo_chip.dart';
import 'package:piwigo_ng/components/modals/select_groups_modal.dart';
import 'package:piwigo_ng/components/sections/form_section.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/album_permission_model.dart';
import 'package:piwigo_ng/models/group_model.dart';
import 'package:piwigo_ng/models/user_model.dart';
import 'package:piwigo_ng/network/albums.dart';
import 'package:piwigo_ng/network/api_error.dart';
import 'package:piwigo_ng/network/groups.dart';
import 'package:piwigo_ng/network/permissions.dart';
import 'package:piwigo_ng/network/users.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class AlbumPrivacyPage extends StatefulWidget {
  const AlbumPrivacyPage({Key? key, required this.album}) : super(key: key);

  static const String routeName = '/album/privacy';

  final AlbumModel album;

  @override
  State<AlbumPrivacyPage> createState() => _AlbumPrivacyPageState();
}

class _AlbumPrivacyPageState extends State<AlbumPrivacyPage> {
  late final Future<void> _adminsFuture;
  late final Future<void> _permissionsFuture;
  late AlbumStatus _selectedMode;

  List<GroupModel> _allowedGroups = [];
  List<UserModel>? _admins;
  List<GroupModel> _groups = [];

  @override
  void initState() {
    _selectedMode = widget.album.status;
    _adminsFuture = _getAdmins();
    _permissionsFuture = _getPermissions();
    super.initState();
  }

  Future<void> _getAdmins() async {
    ApiResponse response = await getAllAdmins();
    if (response.hasError) {
      _admins = null;
      return;
    }
    _admins = response.data;
  }

  Future<void> _getPermissions() async {
    AlbumPermissionModel? permissions = await getAlbumPermissions(
      widget.album.id,
    );
    if (permissions == null) {
      _allowedGroups = [];
      return;
    }

    List<GroupModel>? groups = await getAllGroups(
      groups: permissions.groups,
    );
    if (groups == null) {
      _allowedGroups = [];
      return;
    }

    _allowedGroups = groups;
    _groups = [..._groups, ..._allowedGroups].toSet().toList();
  }

  Future<void> _onConfirmPermissions() async {
    ApiResponse editResult = await editAlbum(
      albumId: widget.album.id,
      status: _selectedMode,
    );
    if (!editResult.hasData || !editResult.data) return;

    if (_selectedMode == AlbumStatus.private) {
      List<GroupModel> newGroups =
          _groups.where((e) => !_allowedGroups.contains(e)).toList();
      List<GroupModel> removedGroups =
          _allowedGroups.where((e) => !_groups.contains(e)).toList();

      bool addSuccess = await addPermission(
        albumId: widget.album.id,
        groups: newGroups.map((group) => group.id).toList(),
      );

      bool removeSuccess = await removePermission(
        albumId: widget.album.id,
        groups: removedGroups.map((group) => group.id).toList(),
      );
    }

    Navigator.of(context).pop();
  }

  void _onChangeMode(AlbumStatus? mode) {
    if (mode == null) return;
    setState(() {
      _selectedMode = mode;
    });
  }

  void _onRemoveGroup(int index) {
    setState(() {
      _groups.removeAt(index);
    });
  }

  Future<void> _onSelectGroups() async {
    List<GroupModel>? selectedGroups = await showSelectGroupModal(
      context,
      _groups,
    );
    if (selectedGroups == null) return;
    setState(() {
      _groups = selectedGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appStrings.categoryPrivacy),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
              ),
              children: [
                Text(
                  appStrings.categoryPrivacy_subtitle(widget.album.name),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                  child: Column(
                    children: [
                      RadioListTile<AlbumStatus>(
                        value: AlbumStatus.public,
                        groupValue: _selectedMode,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        title: Text(appStrings.categoryPrivacyMode_public),
                        subtitle:
                            Text(appStrings.categoryPrivacyMode_publicMessage),
                        onChanged: _onChangeMode,
                      ),
                      RadioListTile(
                        value: AlbumStatus.private,
                        groupValue: _selectedMode,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        title: Text(appStrings.categoryPrivacyMode_private),
                        subtitle:
                            Text(appStrings.categoryPrivacyMode_privateMessage),
                        onChanged: _onChangeMode,
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 150),
                  curve: Curves.ease,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: _selectedMode == AlbumStatus.public ? .0 : null,
                    child: _privateSection,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: PiwigoButton(
              onPressed: _onConfirmPermissions,
              text: appStrings.alertConfirmButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _privateSection {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSection(
            title: appStrings.categoryPrivacyGroups,
            actions: [
              IconButton(
                tooltip: appStrings.categoryPrivacyGroups_add,
                onPressed: _onSelectGroups,
                icon: Icon(Icons.add_circle),
              ),
            ],
            child: FutureBuilder(
              future: _permissionsFuture,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return _buildGroupPermissions;
                  default:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                }
              },
            ),
          ),
          FormSection(
            title: appStrings.categoryPrivacyUsers,
            child: FutureBuilder(
              future: _adminsFuture,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return _buildUserPermissions;
                  default:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget get _buildGroupPermissions {
    return Wrap(
      spacing: 8.0,
      runSpacing: .0,
      children: List.generate(_groups.length, (index) {
        GroupModel group = _groups[index];
        return PiwigoChip(
          onRemove: () => _onRemoveGroup(index),
          label: group.name,
        );
      }),
    );
  }

  Widget get _buildUserPermissions {
    if (_admins == null) {
      return Text(appStrings.none);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appStrings.categoryPrivacyUsers_message(_admins!.length)),
        Builder(builder: (context) {
          if (_admins!.length > 5) {
            String admins =
                _admins!.sublist(0, 5).map((e) => e.name).join(', ');
            Text("$admins, ...");
          }
          String admins = _admins!.map((e) => e.name).join(', ');
          return Text("$admins.");
        }),
      ],
    );
  }
}
