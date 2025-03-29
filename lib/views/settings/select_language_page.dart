import 'package:flutter/material.dart';
import 'package:piwigo_ng/services/locale_provider.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';

class SelectLanguagePage extends StatefulWidget {
  const SelectLanguagePage({Key? key}) : super(key: key);

  static const String routeName = '';

  @override
  State<SelectLanguagePage> createState() => _SelectLanguagePageState();
}

class _SelectLanguagePageState extends State<SelectLanguagePage> {
  late final List<Locale> _locales;

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
        title: Text(appStrings.settings_language),
      ),
      body: ListView.builder(
        itemCount: _locales.length,
        itemBuilder: (context, index) {
          Locale locale = _locales[index];
          return ListTile(
            title: Text(getLanguageFromCode(locale.languageCode)),
            onTap: () {
              final localeProvider =
                  Provider.of<LocaleNotifier>(context, listen: false);
              localeProvider.changeLocale(locale);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}
