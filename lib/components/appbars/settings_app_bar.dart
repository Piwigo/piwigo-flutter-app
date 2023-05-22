import 'package:flutter/material.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class SettingsAppBar extends StatefulWidget {
  const SettingsAppBar({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  State<SettingsAppBar> createState() => _SettingsAppBarState();
}

class _SettingsAppBarState extends State<SettingsAppBar> {
  final _expandedHeight = kToolbarHeight * 2;

  @override
  initState() {
    widget.scrollController.addListener(() => setState(() {}));
    super.initState();
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
      leading: BackButton(
        onPressed: () => Navigator.of(context).pop(),
      ),
      pinned: true,
      expandedHeight: _expandedHeight,
      elevation: 5.0,
      scrolledUnderElevation: 5.0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(
          horizontal: _horizontalTitlePadding,
          vertical: 16,
        ),
        title: Text(
          appStrings.tabBar_preferences,
          textScaleFactor: 1,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}
