class ApiConstants {
  static const String webServiceUrl = '/ws.php';
  static const String basicPrefix = 'Basic';

  //region API Methods

  //region pcom
  static const String imageFileConvertedMethod = 'pcom.images.fileConverted';

  //endregion

  //region Activity
  static const String downloadActivityLogMethod = 'pwg.activity.downloadLog';
  static const String getActivityListMethod = 'pwg.activity.getList';

  //endregion

  //region Caddie
  static const String addCaddieMethod = 'pwg.caddie.add';

  //endregion

  //region Albums
  static const String getAlbumsMethod = 'pwg.categories.getList';
  static const String getAdminAlbumsMethod = 'pwg.categories.getAdminList';
  static const String getAlbumImagesMethod = 'pwg.categories.getImageList';

  static const String addAlbumMethod = 'pwg.categories.add';
  static const String editAlbumMethod = 'pwg.categories.setInfo';
  static const String moveAlbumMethod = 'pwg.categories.move';
  static const String deleteAlbumMethod = 'pwg.categories.delete';
  static const String setAlbumRankMethod = 'pwg.categories.setRank';
  static const String calculateAlbumOrphansMethod = 'pwg.categories.calculateOrphans';

  static const String setRepresentativeMethod = 'pwg.categories.setRepresentative';
  static const String deleteRepresentativeMethod = 'pwg.categories.deleteRepresentative';
  static const String refreshRepresentativeMethod = 'pwg.categories.refreshRepresentative';

  //endregion

  //region Extensions
  static const String checkUpdatesMethod = 'pwg.extensions.checkUpdates';
  static const String ignoreUpdateMethod = 'pwg.extensions.ignoreUpdate';
  static const String updateMethod = 'pwg.extensions.update';

  //endregion

  //region Groups
  static const String getGroupsMethod = 'pwg.groups.getList';

  static const String addGroupMethod = 'pwg.groups.add';
  static const String editGroupMethod = 'pwg.groups.setInfo';
  static const String deleteGroupMethod = 'pwg.groups.delete';
  static const String duplicateGroupMethod = 'pwg.groups.duplicate';
  static const String mergeGroupsMethod = 'pwg.groups.merge';

  static const String addGroupUserMethod = 'pwg.groups.addUser';
  static const String deleteGroupUserMethod = 'pwg.groups.deleteUser';

  //endregion

  //region History
  static const String getHistoryMethod = 'pwg.history.log';
  static const String searchHistoryMethod = 'pwg.history.search';

  //endregion

  //region Images
  static const String addImageMethod = 'pwg.images.add';
  static const String addImageChunkMethod = 'pwg.images.addChunk';
  static const String addImageCommentMethod = 'pwg.images.addComment';
  static const String addFileMethod = 'pwg.images.addFile';
  static const String addSimpleMethod = 'pwg.images.addSimple';

  static const String checkFilesMethod = 'pwg.images.checkFiles';
  static const String checkUploadMethod = 'pwg.images.checkUpload';

  static const String deleteImageMethod = 'pwg.images.delete';
  static const String deleteOrphansMethod = 'pwg.images.deleteOrphans';
  static const String imageExistMethod = 'pwg.images.exist';
  static const String getImageMethod = 'pwg.images.getInfo';
  static const String rateImageMethod = 'pwg.images.rate';
  static const String searchImagesMethod = 'pwg.images.search';
  static const String editImageAlbumsMethod = 'pwg.images.setCategory';
  static const String editImageMethod = 'pwg.images.setInfo';
  static const String setImageMd5sumMethod = 'pwg.images.setMd5sum';
  static const String setImagePrivacyMethod = 'pwg.images.setPrivacyLevel';
  static const String setImageRankMethod = 'pwg.images.setRank';
  static const String syncImageMetadataMethod = 'pwg.images.syncMetadata';

  static const String uploadImageMethod = 'pwg.images.upload';
  static const String uploadImageAsyncMethod = 'pwg.images.uploadAsync';
  static const String uploadCompletedMethod = 'pwg.images.uploadCompleted';
  static const String emptyLoungeMethod = 'pwg.images.emptyLounge';

  // Filtered search
  static const String filteredImageSearchMethod = 'pwg.images.filteredSearch.create';

  // Format
  static const String deleteImageFormatMethod = 'pwg.images.format.delete';
  static const String searchImageFormatMethod = 'pwg.images.format.searchImage';

  //endregion

  //region Permissions
  static const String addPermissionMethod = 'pwg.permissions.add';
  static const String getPermissionsMethod = 'pwg.permissions.getList';
  static const String revokePermissionMethod = 'pwg.permissions.remove';

  //endregion

  //region Plugins
  static const String getPluginsMethod = 'pwg.plugins.getList';
  static const String performPluginActionMethod = 'pwg.plugins.performAction';

  //endregion

  //region Rates
  static const String deleteUserRatesMethod = 'pwg.rates.delete';

  //endregion

  //region Session
  static const String loginMethod = 'pwg.session.login';
  static const String logoutMethod = 'pwg.session.logout';
  static const String getStatusMethod = 'pwg.session.getStatus';

  //endregion

  //region Tags
  static const String getTagsMethod = 'pwg.tags.getList';
  static const String getAdminTagsMethod = 'pwg.tags.getAdminList';

  static const String addTagMethod = 'pwg.tags.add';
  static const String renameTagMethod = 'pwg.tags.rename';
  static const String deleteTagMethod = 'pwg.tags.delete';
  static const String duplicateTagMethod = 'pwg.tags.duplicate';
  static const String mergeTagsMethod = 'pwg.tags.merge';

  static const String getTagImagesMethod = 'pwg.tags.getImages';

//endregion

  //region Themes
  static const String performThemeActionMethod = 'pwg.themes.performAction';

  //endregion

  //region Users
  static const String getUsersMethod = 'pwg.users.getList';

  static const String addUserMethod = 'pwg.users.add';
  static const String editUserMethod = 'pwg.users.setInfo';
  static const String deleteUserMethod = 'pwg.users.delete';
  static const String getUserAuthKeyMethod = 'pwg.users.getAuthKey';

  static const String setUserPreferencesMethod = 'pwg.users.preferences.set';

  //endregion

  //region Favorites
  static const String getFavoritesMethod = 'pwg.users.favorites.getList';
  static const String addFavoriteMethod = 'pwg.users.favorites.add';
  static const String removeFavoriteMethod = 'pwg.users.favorites.remove';

  //endregion

  //region Others
  static const String getCacheSizeMethod = 'pwg.getCacheSize';
  static const String getPiwigoInfoMethod = 'pwg.getInfos';
  static const String getMissingDerivativesMethod = 'pwg.getMissingDerivatives';
  static const String getPiwigoVersionMethod = 'pwg.getVersion';

  //endregion

  //region Reflexion
  static const String getMethodDetailsMethod = 'reflection.getMethodDetails';
  static const String getMethodsMethod = 'reflection.getMethodList';
//endregion

//endregion
}
