import 'package:flutter/material.dart';
import 'package:piwigo_ng/services/theme_provider.dart';
import 'package:provider/provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({Key? key, required this.builder}) : super(key: key);

  final Widget Function(ThemeNotifier) builder;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return builder(themeNotifier);
        },
      ),
    );
  }
}
