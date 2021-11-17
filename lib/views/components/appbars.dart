import 'package:flutter/material.dart';


class AppBarExpandable extends StatefulWidget {
  const AppBarExpandable({Key key, this.leading, this.title = '', this.actions, this.scrollController}) : super(key: key);

  final ScrollController scrollController;
  final Widget leading;
  final String title;
  final List<Widget> actions;

  @override
  _AppBarExpandableState createState() => _AppBarExpandableState();
}

class _AppBarExpandableState extends State<AppBarExpandable> {


  @override
  initState() {
    widget.scrollController.addListener(() => refresh());
    super.initState();
  }

  void refresh() {
    setState(() {

    });
  }

  double get _horizontalTitlePadding {
    const kBasePadding = 15.0;
    const kMultiplier = 0.7;
    const kExpandedHeight = 120;

    if (widget.scrollController.hasClients) {

      if (widget.scrollController.offset > (kExpandedHeight - kToolbarHeight)) {
        return (kExpandedHeight - kToolbarHeight) * kMultiplier +
            kBasePadding;
      }

      return (widget.scrollController.offset) * kMultiplier + kBasePadding;
    }

    return kBasePadding;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      leading: widget.leading ?? SizedBox(),
      actions: widget.actions ?? [],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.title),
        titlePadding: EdgeInsets.symmetric(
          vertical: 16.0, horizontal: _horizontalTitlePadding,
        ),
      ),
    );
  }
}
