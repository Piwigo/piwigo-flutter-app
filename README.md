# DO NOT MERGE !!!

This branch is dedicated to create a template for implementing cleaner code standard from the flutter doc and should not be merged

see https://docs.flutter.dev/app-architecture/

## Main differences 

- Use the native [`http`](https://pub.dev/packages/http) stack instead of [`dio`](https://pub.dev/packages/dio)
- Implement testing 
- Use [Go_Router](https://pub.dev/packages/go_router) instead of the deprecated named navigation

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

## API details 

```xml
<rsp stat="ok">
    <methods>
        <method>pwg.activity.downloadLog</method>
        <method>pwg.activity.getList</method>
        <method>pwg.caddie.add</method>
        <method>pwg.categories.add</method>
        <method>pwg.categories.calculateOrphans</method>
        <method>pwg.categories.delete</method>
        <method>pwg.categories.deleteRepresentative</method>
        <method>pwg.categories.getAdminList</method>
        <method>pwg.categories.getImages</method>
        <method>pwg.categories.getList</method>
        <method>pwg.categories.move</method>
        <method>pwg.categories.refreshRepresentative</method>
        <method>pwg.categories.setInfo</method>
        <method>pwg.categories.setRank</method>
        <method>pwg.categories.setRepresentative</method>
        <method>pwg.extensions.checkUpdates</method>
        <method>pwg.extensions.ignoreUpdate</method>
        <method>pwg.extensions.update</method>
        <method>pwg.getCacheSize</method>
        <method>pwg.getInfos</method>
        <method>pwg.getMissingDerivatives</method>
        <method>pwg.getVersion</method>
        <method>pwg.groups.add</method>
        <method>pwg.groups.addUser</method>
        <method>pwg.groups.delete</method>
        <method>pwg.groups.deleteUser</method>
        <method>pwg.groups.duplicate</method>
        <method>pwg.groups.getList</method>
        <method>pwg.groups.merge</method>
        <method>pwg.groups.setInfo</method>
        <method>pwg.history.log</method>
        <method>pwg.history.search</method>
        <method>pwg.images.add</method>
        <method>pwg.images.addChunk</method>
        <method>pwg.images.addComment</method>
        <method>pwg.images.addFile</method>
        <method>pwg.images.addSimple</method>
        <method>pwg.images.checkFiles</method>
        <method>pwg.images.checkUpload</method>
        <method>pwg.images.delete</method>
        <method>pwg.images.deleteOrphans</method>
        <method>pwg.images.emptyLounge</method>
        <method>pwg.images.exist</method>
        <method>pwg.images.filteredSearch.create</method>
        <method>pwg.images.formats.delete</method>
        <method>pwg.images.formats.searchImage</method>
        <method>pwg.images.getInfo</method>
        <method>pwg.images.rate</method>
        <method>pwg.images.search</method>
        <method>pwg.images.setCategory</method>
        <method>pwg.images.setInfo</method>
        <method>pwg.images.setMd5sum</method>
        <method>pwg.images.setPrivacyLevel</method>
        <method>pwg.images.setRank</method>
        <method>pwg.images.syncMetadata</method>
        <method>pwg.images.upload</method>
        <method>pwg.images.uploadAsync</method>
        <method>pwg.images.uploadCompleted</method>
        <method>pwg.permissions.add</method>
        <method>pwg.permissions.getList</method>
        <method>pwg.permissions.remove</method>
        <method>pwg.plugins.getList</method>
        <method>pwg.plugins.performAction</method>
        <method>pwg.rates.delete</method>
        <method>pwg.session.getStatus</method>
        <method>pwg.session.login</method>
        <method>pwg.session.logout</method>
        <method>pwg.tags.add</method>
        <method>pwg.tags.delete</method>
        <method>pwg.tags.duplicate</method>
        <method>pwg.tags.getAdminList</method>
        <method>pwg.tags.getImages</method>
        <method>pwg.tags.getList</method>
        <method>pwg.tags.merge</method>
        <method>pwg.tags.rename</method>
        <method>pwg.themes.performAction</method>
        <method>pwg.users.add</method>
        <method>pwg.users.delete</method>
        <method>pwg.users.favorites.add</method>
        <method>pwg.users.favorites.getList</method>
        <method>pwg.users.favorites.remove</method>
        <method>pwg.users.generatePasswordLink</method>
        <method>pwg.users.getAuthKey</method>
        <method>pwg.users.getList</method>
        <method>pwg.users.preferences.set</method>
        <method>pwg.users.setInfo</method>
        <method>pwg.users.setMainUser</method>
        <method>reflection.getMethodDetails</method>
        <method>reflection.getMethodList</method>
    </methods>
</rsp>
```
