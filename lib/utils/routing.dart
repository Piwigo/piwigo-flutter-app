import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:piwigo_ng/ui/album/album_screen.dart';
import 'package:piwigo_ng/ui/authentification/widgets/instance_screen.dart';
import 'package:piwigo_ng/ui/authentification/widgets/login_screen.dart';
import 'package:piwigo_ng/ui/authentification/widgets/two_factor_auth_screen.dart';

//Temporary
var isLogged = false;
// TODO Need to switch navigator calls in screens to https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => AlbumScreen()),
    GoRoute(
      path: '/authentification',
      builder: (context, state) => InstanceScreen(),
      routes: [
        GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
        GoRoute(
          path: '/2FA',
          builder: (context, state) => TwoFactorAuthScreen(),
        ),
      ],
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    if (!isLogged) {
      return '/authentification';
    } else {
      return null;
    }
  },
);
