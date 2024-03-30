import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';

class ExpandedAppBar extends AnimatedWidget {
  const ExpandedAppBar({
    super.key,
    required this.scrollController,
    required this.title,
    this.leading,
    this.actions,
    this.child,
  }) : super(listenable: scrollController);

  final ScrollController scrollController;
  final String title;
  final Widget? child;
  final Widget? leading;
  final List<Widget>? actions;

  static const double _expandedHeight = kToolbarHeight * 2;
  static const double _opacityScale = 0.3;

  double get _titleOpacity {
    if (scrollController.hasClients) {
      if (scrollController.offset > _expandedHeight * _opacityScale) {
        return 0.0;
      }
      return (_expandedHeight * _opacityScale - scrollController.offset) / (_expandedHeight * _opacityScale);
    }
    return 1.0;
  }

  double get _horizontalTitlePadding {
    double basePadding = UIConstants.paddingMedium;
    double delta = (kToolbarHeight - basePadding) / basePadding;

    if (scrollController.hasClients) {
      if (scrollController.offset > (_expandedHeight - kToolbarHeight)) {
        // In case 0% of the expanded height is viewed
        return basePadding * delta + basePadding;
      }

      // In case 0%-100% of the expanded height is viewed
      double scrollDelta = (_expandedHeight - scrollController.offset) / _expandedHeight;
      double scrollPercent = (scrollDelta * 2 - 1);
      return (1 - scrollPercent) * delta * basePadding + basePadding;
    }

    return basePadding;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: leading,
      pinned: true,
      centerTitle: true,
      titleSpacing: 0.0,
      title: Opacity(
        opacity: _titleOpacity,
        child: child,
      ),
      actions: actions,
      expandedHeight: _expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(
          horizontal: _horizontalTitlePadding,
          vertical: UIConstants.paddingMedium,
        ),
        title: Text(
          title,
          textScaleFactor: 1,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}
