# CONTRIBUTING

## Environment setup

### Flutter

Install and configure flutter using the [Official Flutter documentation](https://docs.flutter.dev/get-started/install).  
Check `pubspec.yaml` or `.fvmrc` and change the flutter version accordingly

Using git and the [commit hash of the release](https://docs.flutter.dev/release/archive)  :
```sh
cd <flutter path>
git checkout d8a9f9a # Commit hash of the release
flutter --version
# Optional disable analytics/telemetry
flutter config --no-analytics
```

Using [fvm](https://fvm.app/) :
```sh
fvm install 3.27.4
cd <Project-dir>
fvm use 3.27.4
```

### Android Studio

Install the flutter plugin and restart, then go to **Settings > Languages & Framework > Android SDK > SDK Tools** and install the following :

- Android SDK Build-Tools
- NDK
- Android SDK Command-line Tools
- Cmake
- Android SDK Platform-Tools
- Android Emulator

**Enable flutter android support**
```sh
flutter doctor --android-licenses # Accept the Android License
# Check that Android toolchain is working
flutter doctor -v
```

If Android studio doesn't pickup the path of the flutter toolchain or dart :

In **Settings > Languages & Framework > Flutter** set the flutter SDK path using the absolute path of your install.  
And in **Settings > Languages & Framework > Dart** specify the Dark SDK path `<Absolute-Flutter-Path>/bin/cache/dart-sdk`

## Debugging

By default running the app via Android Studio or `flutter run` will use the debug APK (located in `build/app/outputs/flutter-apk/app-debug.apk`).
Background tasks are done with [workmanager](https://docs.page/fluttercommunity/flutter_workmanager) debugging must be enabled via the kotlin flag `WorkmanagerDebug.setCurrent(LoggingDebugHandler())`

See more info in https://docs.page/fluttercommunity/flutter_workmanager/debugging

## Contributing guidelines

Contribution must target the `develop` branch and must have documented changes.

if you are fixing an existing issue or bug, tag it in your merge request (example : `fixing #X - button Y not working`)

if you are doing maintenance work, be sure to add the changelog of the libraries you are updating.

Translation are done via [crowdin](https://crowdin.com/project/piwigo-ng)