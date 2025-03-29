# Piwigo-NG developpement guide :

## Setup :

### Install flutter SDK :

This app require the flutter SDK (or flutter + dart sdk)
The documentation assume the following paths :

- Flutter SDK `~/local/share/flutter`
- Dart SDK  `~/.local/share/flutter/bin/cache/dart-sdk/`

Use the [Official Flutter documentation](https://docs.flutter.dev/get-started/install) or follow the steps bellow (Linux) :

- Download the flutter archive in the "[Download then install Flutter section](https://docs.flutter.dev/get-started/install/linux/android#download-then-install-flutter)"

```sh
# Untar the archive (replace the version number if applicable)
tar -xf ~/Downloads/flutter_linux_3.29.2-stable.tar.xz -C ~/.local/share/
```

- Follow the instruction for you default `$SHELL`

```sh
# Add flutter to PATH (bash) :
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bash_profile
```

```sh
# Add flutter to PATH (fish)
fish_add_path -g -p ~/.local/share/flutter/bin
```

More shells at the [Add Flutter to your PATH](https://docs.flutter.dev/get-started/install/linux/android#add-flutter-to-your-path) section

### Downgrading Flutter to 3.27 :

You may run into compilation issues with the generated localization, see [Flutter - #163627](https://github.com/flutter/flutter/issues/163627)

```sh
cd ~/.local/share/flutter
git checkout d8a9f9a
# To swap back 
git switch -
```

## IDE - Android studio 

Install the flutter android studio plugin.
Before running the app check that the dart sdk as been found.

Go to **File > Settings > Languages & Framework > Dart**
Enable dart for the project and check that the SDK location is in the flutter directory :

```sh
# Exemple :
/home/_username_/.local/share/flutter/bin/cache/dart-sdk
```