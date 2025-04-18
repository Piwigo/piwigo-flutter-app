# Architecture

This file document the different directory of this project.
Each section will contain explanation and a directory tree.

## Flutter

### Dependencies and generated files

The `.fvmrc` is used by [fvm](https://fvm.app/) to specify the flutter version.  
`lib/` contain the flutter code.  
`pubspec.lock` is a lock file to handle dependencies.  
`pubspec.yaml` is configuration file specifying :

- the app version
- the flutter sdk requirement
- the dependencies
- the asset directory 

```
├── .fvmrc
├── lib
├── pubspec.lock
└── pubspec.yaml
```

### Flutter code

Contain the flutter code that make the app.  
Follow a view-model structure where `components` contain reusable parts.

```sh
.
├── lib
│  ├── app.dart
│  ├── components
│  ├── l10n		# see Translations
│  ├── main.dart
│  ├── models
│  ├── network
│  ├── services
│  ├── utils
│  └── views
```

## Android

The android directory contain all elements necessary to target Android, most of it is gradle configuration.
Upgrading the `AGP (Android Gradle Plugin)` open the `android` directory with Android Studio and use **Tools > AGP Upgrade Assitant** or manually update the gradle configuration at your own risk.

```
.
└── android
   ├── app
   ├── build.gradle
   ├── gradle/wrapper/gradle-wrapper.properties
   ├── gradle.properties
   └── settings.gradle
```

## Translations

Translations are hosted on [crowdin](https://crowdin.com/project/piwigo-ng), everything is translated from english.  
Flutter take the `app_%%.arb` files and generate dart code inside the `lib/l10n` directory.   
`untranslated.json` is generated at compile time to indicate missing string.

```sh
# %% = country code, one file per translation
.
├── crowdin.yml
├── l10n
│  ├── app_en.arb
│  ├── app_%%.arb
│  └── untranslated.json
└── l10n.yaml
	├── lib
   └── l10n
      ├── app_localizations.dart
      ├── app_localizations_en.dart
      └── app_localizations_%%.dart
```