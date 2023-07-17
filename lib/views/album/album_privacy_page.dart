import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/components/cards/piwigo_chip.dart';
import 'package:piwigo_ng/components/modals/select_groups_modal.dart';
import 'package:piwigo_ng/components/sections/form_section.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/group_model.dart';
import 'package:piwigo_ng/models/user_model.dart';
import 'package:piwigo_ng/network/api_error.dart';
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
  late final Future<ApiResponse> _adminsFuture;
  late AlbumStatus _selectedMode;

  List<UserModel>? _admins;
  List<GroupModel> _groups = [];

  @override
  void initState() {
    _selectedMode = widget.album.status;
    _adminsFuture = _getAdmins();
    // todo: is private, get album groups
    super.initState();
  }

  Future<ApiResponse> _getAdmins() async {
    ApiResponse response = await getAllAdmins();
    if (response.hasError) {
      _admins = null;
      return response;
    }
    _admins = response.data;
    return response;
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
      body: ListView(
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
                  subtitle: Text(appStrings.categoryPrivacyMode_publicMessage),
                  onChanged: _onChangeMode,
                ),
                RadioListTile(
                  value: AlbumStatus.private,
                  groupValue: _selectedMode,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  title: Text(appStrings.categoryPrivacyMode_private),
                  subtitle: Text(appStrings.categoryPrivacyMode_privateMessage),
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
          PiwigoButton(
            margin: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            text: appStrings.alertConfirmButton,
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
            child: Wrap(
              spacing: 8.0,
              runSpacing: .0,
              children: List.generate(_groups.length, (index) {
                GroupModel group = _groups[index];
                return PiwigoChip(
                  onRemove: () => _onRemoveGroup(index),
                  label: group.name,
                );
              }),
            ),
          ),
          FormSection(
            title: appStrings.categoryPrivacyUsers,
            child: FutureBuilder<ApiResponse>(
                future: _adminsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (_admins == null) {
                      return Text(appStrings.none);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appStrings
                            .categoryPrivacyUsers_message(_admins!.length)),
                        Builder(builder: (context) {
                          if (_admins!.length > 5) {
                            String admins = _admins!
                                .sublist(0, 5)
                                .map((e) => e.name)
                                .join(', ');
                            Text("$admins, ...");
                          }
                          String admins =
                              _admins!.map((e) => e.name).join(', ');
                          return Text("$admins.");
                        }),
                      ],
                    );
                  }
                  return LinearProgressIndicator();
                }),
          ),
        ],
      ),
    );
  }
}
