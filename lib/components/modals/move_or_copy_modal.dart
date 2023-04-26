import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class MoveOrCopyModal extends StatefulWidget {
  const MoveOrCopyModal({
    Key? key,
    this.album,
    this.isImage = false,
    this.onSelected,
    this.title,
    this.subtitle,
  }) : super(key: key);

  final AlbumModel? album;
  final bool isImage;
  final String? title;
  final String? subtitle;
  final Future<dynamic> Function(AlbumModel)? onSelected;

  @override
  _MoveOrCopyModalState createState() => _MoveOrCopyModalState();
}

class _MoveOrCopyModalState extends State<MoveOrCopyModal> {
  final ScrollController _scrollController = ScrollController();
  late final Future<ApiResult<List<AlbumModel>>> _albumFuture;
  late final List<int> _disabledAlbums;

  List<AlbumModel> _albums = [];

  @override
  void initState() {
    _albumFuture = getAlbumTree();
    List<String> parentAlbums = widget.album?.upperCategories.split(',') ?? [];
    _disabledAlbums = [
      if (widget.album != null) widget.album!.id,
      if (parentAlbums.length == 1 || widget.isImage) 0,
      if (!widget.isImage && parentAlbums.length > 1)
        int.parse(parentAlbums[parentAlbums.length - 2]),
    ];

    super.initState();
  }

  Future<void> _onTapAlbum(AlbumModel album) async {
    bool? result = await widget.onSelected?.call(album);
    Navigator.of(context).pop(result ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _appBar,
      body: Theme(
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            children: [
              if (widget.subtitle != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                  child: Text(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                ),
                child: _albumTreeList,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget get _appBar => AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15.0),
          ),
        ),
        elevation: 0.0,
        scrolledUnderElevation: 5.0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title ?? ''),
      );

  Widget get _albumTreeList => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: _rootAlbum,
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
              isParent: true,
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
    this.isParent = false,
    this.index = 0,
    this.onTap,
  }) : super(key: key);

  final AlbumModel album;
  final List<int> disabledAlbums;
  final bool isParent;
  final int index;
  final Function(AlbumModel)? onTap;

  @override
  State<ExpansionAlbumTile> createState() => _ExpansionAlbumTileState();
}

class _ExpansionAlbumTileState extends State<ExpansionAlbumTile> {
  bool _expanded = false;

  @override
  void initState() {
    if (widget.isParent) {
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
                      style: _disabled
                          ? Theme.of(context).textTheme.bodySmall
                          : Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              if (widget.album.children.isNotEmpty && !widget.isParent)
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
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.7),
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
