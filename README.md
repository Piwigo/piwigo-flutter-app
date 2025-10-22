# DO NOT MERGE !!!

This branch is dedicated to create a template for implementing cleaner code standard from the flutter doc and should not be merged

see https://docs.flutter.dev/app-architecture/


## Architecture 

```
lib
├─┬─ ui
│ ├─┬─ core
│ │ ├─── l10n
│ │ ├─── themes
│ │ └─┬─ ui
│ │   └─── <shared widgets>
│ └─┬─ <FEATURE NAME>
│   ├─┬─ view_model
│   │ └─── <view_model class>.dart
│   └─┬─ widgets
│     ├── <feature name>_screen.dart
│     └── <other widgets>
├─┬─ data
│ ├─┬─ repositories
│ │ └─── <repository class>.dart
│ ├─┬─ services
│ │ └─── <service class>.dart
│ └─┬─ model
│   └─── <api model class>.dart
├─── utils
│ └─┬─── config.dart
│   ├─── routing.dart
│   └─── utils.dart
└─── main.dart
```