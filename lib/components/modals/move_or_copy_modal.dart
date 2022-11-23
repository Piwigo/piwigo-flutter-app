import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/components/dialogs/confirm_dialog.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class MoveOrCopyModal extends StatefulWidget {
  const MoveOrCopyModal({
    Key? key,
    required this.album,
    this.isImage = false,
    this.onSelected,
    this.title,
    this.subtitle,
  }) : super(key: key);

  final AlbumModel album;
  final bool isImage;
  final String? title;
  final String? subtitle;
  final Function(int)? onSelected;

  @override
  _MoveOrCopyModalState createState() => _MoveOrCopyModalState();
}

class _MoveOrCopyModalState extends State<MoveOrCopyModal> {
  late final Future<ApiResult<List<AlbumModel>>> _albumFuture;
  late final List<int> _disabledAlbums;

  List<AlbumModel> _albums = [];

  @override
  void initState() {
    _albumFuture = getAlbumTree();
    List<String> parentAlbums = widget.album.upperCategories.split(',');
    _disabledAlbums = [
      widget.album.id,
      if (parentAlbums.length == 1) 0,
      if (parentAlbums.length > 1) int.parse(parentAlbums[parentAlbums.length - 2]),
    ];

    super.initState();
  }

  Future<void> _onTapAlbum(AlbumModel album) async {
    print(album.name);
    if (await showConfirmDialog(
      context,
      message: appStrings.moveCategory_message(
        widget.album.name,
        album.name,
      ),
    )) {
      ApiResult<bool> result = await moveAlbum(
        widget.album.id,
        album.id,
      );

      if (result.hasData && result.data == true) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoModal(
      title: widget.title,
      subtitle: widget.subtitle,
      fullscreen: true,
      content: Column(
        children: [
          _albumTreeList,
          PiwigoButton(
            color: Colors.transparent,
            style: Theme.of(context).textTheme.titleSmall,
            onPressed: () => Navigator.of(context).pop(null),
            text: appStrings.alertCancelButton,
          ),
        ],
      ),
    );
  }

  Widget get _albumTreeList => Expanded(
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
            thumbVisibility: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: SingleChildScrollView(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: _rootAlbum,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget get _rootAlbum => FutureBuilder<ApiResult<List<AlbumModel>>>(
        future: _albumFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (!snapshot.data!.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(appStrings.errorHUD_label),
                  ),
                ],
              );
            }
            if (_albums.isEmpty) {
              _albums = snapshot.data!.data ?? [];
            }
            return ExpansionAlbumTile(
              album: AlbumModel(
                id: 0,
                name: appStrings.categorySelection_root,
                children: _albums,
              ),
              disabledAlbums: _disabledAlbums,
              onTap: _onTapAlbum,
              isRoot: true,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
}

class ExpansionAlbumTile extends StatefulWidget {
  const ExpansionAlbumTile({
    Key? key,
    required this.album,
    this.disabledAlbums = const [],
    this.isRoot = false,
    this.index = 0,
    this.onTap,
  }) : super(key: key);

  final AlbumModel album;
  final List<int> disabledAlbums;
  final bool isRoot;
  final int index;
  final Function(AlbumModel)? onTap;

  @override
  State<ExpansionAlbumTile> createState() => _ExpansionAlbumTileState();
}

class _ExpansionAlbumTileState extends State<ExpansionAlbumTile> {
  bool _expanded = false;

  @override
  void initState() {
    if (widget.isRoot) {
      _expanded = true;
    }
    super.initState();
  }

  bool get _disabled => widget.disabledAlbums.contains(widget.album.id);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tileTitle,
        if (widget.album.children.isNotEmpty && _expanded) _divider,
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _expandedList,
        ),
      ],
    );
  }

  Widget get _tileTitle => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_disabled) return;
          widget.onTap?.call(widget.album);
        },
        child: SizedBox(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${List.generate(widget.index, (index) => ' ').join()}${widget.album.name}",
                      overflow: TextOverflow.ellipsis,
                      style: _disabled ? Theme.of(context).textTheme.bodySmall : Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              if (widget.album.children.isNotEmpty && !widget.isRoot)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() {
                    _expanded = !_expanded;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            appStrings.albumCount(widget.album.nbCategories),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: _expanded ? -0.25 : 0.25,
                          child: Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget get _divider => Divider(
        height: 1,
        thickness: 1,
        indent: 16.0,
        endIndent: 0.0,
      );

  Widget get _expandedList {
    if (_expanded) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.album.children.length,
        itemBuilder: (context, index) {
          return ExpansionAlbumTile(
            album: widget.album.children[index],
            disabledAlbums: widget.disabledAlbums,
            index: widget.index + 1,
            onTap: widget.onTap,
          );
        },
        separatorBuilder: (context, index) => _divider,
      );
    }
    return const SizedBox(width: double.infinity);
  }
}
