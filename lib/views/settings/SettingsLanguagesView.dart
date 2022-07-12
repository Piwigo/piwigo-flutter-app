import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants/SettingsConstants.dart';
import '../../services/LocaleProvider.dart';

class SettingsLanguageView extends StatefulWidget {
  const SettingsLanguageView({Key key}) : super(key: key);

  @override
  State<SettingsLanguageView> createState() => _SettingsLanguageViewState();
}

class _SettingsLanguageViewState extends State<SettingsLanguageView> {

  List<Locale> _locales = [];

  @override
  void initState() {
    _locales = AppLocalizations.supportedLocales;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(appStrings(context).settings_language),
      ),
      body: ListView.builder(
        itemCount: _locales.length,
        itemBuilder: (context, index) {
          Locale locale = _locales[index];
          return ListTile(
            title: Text(getLanguageFromCode(locale.languageCode)),
            onTap: () {
              final localeProvider = Provider.of<LocaleNotifier>(context, listen: false);
              localeProvider.changeLocale(locale);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}