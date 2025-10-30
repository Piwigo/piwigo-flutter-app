import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:piwigo_ng/ui/album/album_screen.dart';
import 'package:piwigo_ng/ui/authentification/widgets/instance_screen.dart';

//Temporary
var isLogged = false;
// TODO Need to switch navigator calls in screens to https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => AlbumScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => InstanceScreen(),
      routes: [
        GoRoute(
            path: ''
        )
      ]
    )
  ],
  redirect: (BuildContext context, GoRouterState state) {
    if (!isLogged) {
      return '/login';
    } else {
      return null;
    }
  },
  );