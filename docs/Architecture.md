# Architecture

This file documents the different directories of this project.
Each section will contain explanations and a corresponding directory tree.

## Flutter

### Dependencies and generated files

The `.fvmrc` is used by [fvm](https://fvm.app/) to specify the flutter version.  
`lib/` contains the flutter code.  
`pubspec.lock` is a lock file to handle dependency versions.  
`pubspec.yaml` is a configuration file that specifies :

- the app version
- the flutter sdk requirement
- the project dependencies
- the assets directory 

```
├── .fvmrc
├── lib
├── pubspec.lock
└── pubspec.yaml
```

### Flutter code

This directory contains the flutter code that builds the app.  
This project follows a view-model structure where `components` contain reusable UI parts.

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

The android directory contain all elements needed to build the app for Android, primarily Gradle configurations.
to upgrade the `AGP (Android Gradle Plugin)` open the `android` directory with Android Studio and use **Tools > AGP Upgrade Assitant** or manually update the Gradle configuration files (at your own risk).

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

Translations are managed on [crowdin](https://crowdin.com/project/piwigo-ng), with all translations based on English.  
Flutter processes the `app_%%.arb` files and generate Dart code in the `lib/l10n` directory.   
An `untranslated.json` is generated at compile time to indicate any missing translations.

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
