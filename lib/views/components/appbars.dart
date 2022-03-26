import 'package:flutter/material.dart';
import 'package:piwigo_ng/views/components/textfields.dart';


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


class AppBarExpandableSearch extends StatefulWidget {
  const AppBarExpandableSearch({Key key, this.leading, this.title = '', this.actions, this.scrollController, this.textController}) : super(key: key);

  final ScrollController scrollController;
  final TextEditingController textController;
  final Widget leading;
  final String title;
  final List<Widget> actions;

  @override
  _AppBarExpandableSearchState createState() => _AppBarExpandableSearchState();
}

class _AppBarExpandableSearchState extends State<AppBarExpandableSearch> {


  @override
  initState() {
    widget.scrollController.addListener(() => refresh());
    super.initState();
  }

  void refresh() {
    setState(() {

    });
  }

  double horizontalTitlePadding(height) {

    if (height <= 100) {
      return 50;
    }

    const kBasePadding = 10.0;
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

  double verticalTitlePadding(height) {

    if (height <= 100) {
      return 15.0;
    }

    const kBasePadding = 15.0;
    const kMultiplier = 0.11;
    const kExpandedHeight = 20;

    if (widget.scrollController.hasClients) {

      return kBasePadding - (widget.scrollController.offset) * kMultiplier;
    }

    return kBasePadding;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        pinned: true,
        expandedHeight: 150,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: widget.leading ?? SizedBox(),
        actions: widget.actions ?? [],
        flexibleSpace: LayoutBuilder(builder: (context, constraints) {
          // print(constraints.biggest.height);
          Widget flexibleTitle;
          Widget textTitle = Container(
            child: Text(widget.title),
            padding: EdgeInsets.symmetric(
                vertical: verticalTitlePadding(constraints.biggest.height),
                horizontal: horizontalTitlePadding(constraints.biggest.height)
            ),
          );

          if (constraints.biggest.height > 100) {
            flexibleTitle = Column(
              children: [
                textTitle,
                TextFieldSearch(
                  controller: widget.textController,
                  hint: "Search...", // TODO Localization
                  margin: EdgeInsets.symmetric(horizontal: 10),
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,

            );

          } else {
            flexibleTitle = textTitle;
          }
          return FlexibleSpaceBar(
            title: flexibleTitle,
            titlePadding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 0
            ),
          );

        })
    );
  }
}
