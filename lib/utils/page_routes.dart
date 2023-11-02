import 'package:flutter/material.dart';

class FadePageRoute extends PageRouteBuilder {
  final Widget page;

  FadePageRoute({required this.page, RouteSettings? settings})
      : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (animation.status == AnimationStatus.reverse) {
              return FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.ease)),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.ease,
                      reverseCurve: Curves.easeInOut,
                    ),
                  ),
                  child: child,
                ),
              );
            }
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.ease,
                  reverseCurve: Curves.easeInOut,
                ),
              ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.ease)),
                child: child,
              ),
            );
          },
        );
}

class SlideUpPageRoute extends PageRouteBuilder {
  final Widget page;

  static const Duration duration = const Duration(milliseconds: 500);

  SlideUpPageRoute({required this.page, RouteSettings? settings})
      : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.ease,
                  reverseCurve: Curves.easeInOut,
                ),
              ),
              child: child,
            );
          },
        );
}
