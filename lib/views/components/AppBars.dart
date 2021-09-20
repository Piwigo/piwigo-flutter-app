import 'package:flutter/material.dart';

import 'TextFields.dart';

class FlexibleSpaceCustom extends StatelessWidget {
  const FlexibleSpaceCustom({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double percent = (constraints.maxHeight - kToolbarHeight);
          double dx = 0;

          dx = 80 - percent;
          if (constraints.maxHeight == 100) {
            dx = 0;
          }
          return Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight / 4, left: 0.0),
                child: Transform.translate(
                  child: Text(title,
                    style: _theme.textTheme.headline1,
                  ),
                  offset: Offset(
                      dx, constraints.maxHeight - kToolbarHeight),
                ),
              ),
            ],
          );
        }
    );
  }
}


class AppBarExpandable extends StatelessWidget {
  const AppBarExpandable({Key key, this.leading, this.title = '', this.actions}) : super(key: key);

  final Widget leading;
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      snap: false,
      floating: false,
      expandedHeight: 100.0,
      centerTitle: true,
      backgroundColor: _theme.appBarTheme.backgroundColor,
      leading: leading ?? IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.chevron_left, color: _theme.iconTheme.color),
      ),
      flexibleSpace: FlexibleSpaceCustom(title: title),
      actions: actions ?? [],
    );
  }
}
