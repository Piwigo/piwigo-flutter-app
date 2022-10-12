import 'package:flutter/material.dart';

import '../../views/settings/settings_view_page.dart';
import '../fields/app_field.dart';

class RootSearchAppBar extends StatefulWidget {
  const RootSearchAppBar({
    Key? key,
    required this.scrollController,
    required this.onSearch,
  }) : super(key: key);

  final ScrollController scrollController;
  final Function() onSearch;

  @override
  State<RootSearchAppBar> createState() => _RootSearchAppBarState();
}

class _RootSearchAppBarState extends State<RootSearchAppBar> {
  final _expandedHeight = kToolbarHeight * 2;
  final _opacityScale = 0.3;

  @override
  initState() {
    widget.scrollController.addListener(() => setState(() {}));
    super.initState();
  }

  double get _titleOpacity {
    if (widget.scrollController.hasClients) {
      if (widget.scrollController.offset > _expandedHeight * _opacityScale) {
        return 0.0;
      }
      return (_expandedHeight * _opacityScale -
              widget.scrollController.offset) /
          (_expandedHeight * _opacityScale);
    }
    return 1.0;
  }

  double get _horizontalTitlePadding {
    const basePadding = 16.0;
    const delta = (kToolbarHeight - basePadding) / basePadding;

    if (widget.scrollController.hasClients) {
      if (widget.scrollController.offset > (_expandedHeight - kToolbarHeight)) {
        // In case 0% of the expanded height is viewed
        return basePadding * delta + basePadding;
      }

      // In case 0%-100% of the expanded height is viewed
      double scrollDelta =
          (_expandedHeight - widget.scrollController.offset) / _expandedHeight;
      double scrollPercent = (scrollDelta * 2 - 1);
      return (1 - scrollPercent) * delta * basePadding + basePadding;
    }

    return basePadding;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(SettingsViewPage.routeName),
        icon: const Icon(Icons.settings),
      ),
      pinned: true,
      centerTitle: true,
      titleSpacing: 0,
      title: Opacity(
        opacity: _titleOpacity,
        child: GestureDetector(
          onTap: widget.onSearch,
          child: const Hero(
            tag: 'search-bar',
            child: Material(
              color: Colors.transparent,
              child: IgnorePointer(
                child: AppField(
                  icon: Icon(Icons.search),
                  hint: "Search...",
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
        ),
      ],
      expandedHeight: _expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(
          horizontal: _horizontalTitlePadding,
          vertical: 16,
        ),
        title: Text(
          'Albums', // Todo: Use translations
          textScaleFactor: 1,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}
