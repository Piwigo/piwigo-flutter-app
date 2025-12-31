import 'package:flutter/material.dart';

class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({
    Key? key,
    this.route = const RouteSettings(),
  }) : super(key: key);

  final RouteSettings route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('No route defined for ${route.name}')),
    );
  }
}
