import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Constants {
  static Map<int, String> albumSort = {
    0: "Photo Title, A > Z",
    1: "Photo Title, Z > A",
    2: "Creation Date, New > Old",
    3: "Creation Date, Old > New",
    4: "Addition Date, New > Old",
    5: "Addition Date, Old > New",
    6: "File Name, A > Z",
    7: "File Name, Z > A",
    8: "Rate, High > Low",
    9: "Rate, Low > High",
    10: "Views, High > Low",
    11: "Views, Low > High",
    12: "Manual Sort",
    13: "Random Sort"
  };
  static Map<int, String> privacyLevels = {
    0: 'Everyone',
    1: 'Admins, Family, Friends, Contacts',
    2: 'Admins, Family, Friends',
    4: 'Admins, Family',
    8: 'Admins',
  };

}

AppLocalizations appStrings(context) {
  return AppLocalizations.of(context);
}