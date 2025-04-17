# Architecture :

This file document the different directory of this project.
Each section will contain explanation and a directory tree.

## Translations :

Translations are hosted on [crowdin](https://crowdin.com/project/piwigo-ng), everything is translated from english.  
Flutter take the `app_%%.arb` files and generate dart code inside the `lib/l10n` directory.   

```sh
# %% = country code
.
├── crowdin.yml
├── l10n
│  ├── app_en.arb
│  ├── app_%%.arb
│  └── untranslated.json
└── l10n.yaml
   └── l10n
      ├── app_localizations.dart
      └── app_localizations_%%.dart
```