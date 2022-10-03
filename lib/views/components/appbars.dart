import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/components/textfields.dart';


class AppBarExpandable extends StatefulWidget {
  const AppBarExpandable({Key key,
    this.leading,
    this.title = '',
    this.actions,
    this.scrollController,
    this.forceElevated = false,
  }) : super(key: key);

  final ScrollController scrollController;
  final Widget leading;
  final String title;
  final List<Widget> actions;
  final bool forceElevated;

  @override
  _AppBarExpandableState createState() => _AppBarExpandableState();
}

class _AppBarExpandableState extends State<AppBarExpandable> {

  @override
  initState() {
    widget.scrollController.addListener(() => refresh());
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
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


class AppBarSearch extends StatelessWidget {
  const AppBarSearch({Key key, this.leading, this.title = '', this.actions, this.textController, this.onSubmit, this.onTap, this.focusNode,}) : super(key: key);

  final TextEditingController textController;
  final Widget leading;
  final String title;
  final List<Widget> actions;
  final Function(String) onSubmit;
  final Function() onTap;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 30,
      toolbarHeight: 0.0,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Center(
          child: TextFieldSearch(
            controller: textController,
            focusNode: focusNode,
            hint: "Search...", // TODO Localization
            margin: EdgeInsets.symmetric(horizontal: 10),
            onTap: onTap,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }
}
