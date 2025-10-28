import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:piwigo_ng/ui/album/album_screen.dart';
import 'package:piwigo_ng/ui/authentification/instance_screen.dart';

//Temporary
var isLogged = false;

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