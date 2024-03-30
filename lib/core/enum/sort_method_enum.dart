import 'package:flutter/cupertino.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';

enum SortMethodEnum {
  nameAsc('name ASC'),
  nameDesc('name DESC'),
  fileAsc('file ASC'),
  fileDesc('file DESC'),
  dateCreatedAsc('date_creation ASC'),
  dateCreatedDesc('date_creation DESC'),
  dateAvailableAsc('date_available ASC'),
  dateAvailableDesc('date_available DESC'),
  rateAsc('rating_score ASC'),
  rateDesc('rating_score DESC'),
  hitAsc('hit ASC'),
  hitDesc('hit DESC'),
  random('random'),
  custom('');

  const SortMethodEnum(this.value);

  final String value;
}

extension SortMethodExtension on SortMethodEnum {
  String getLabel(BuildContext context) {
    switch (this) {
      case SortMethodEnum.nameAsc:
        return context.localizations.categorySort_nameAscending;
      case SortMethodEnum.nameDesc:
        return context.localizations.categorySort_nameDescending;
      case SortMethodEnum.fileAsc:
        return context.localizations.categorySort_fileNameAscending;
      case SortMethodEnum.fileDesc:
        return context.localizations.categorySort_fileNameDescending;
      case SortMethodEnum.dateCreatedAsc:
        return context.localizations.categorySort_dateCreatedAscending;
      case SortMethodEnum.dateCreatedDesc:
        return context.localizations.categorySort_dateCreatedDescending;
      case SortMethodEnum.dateAvailableAsc:
        return context.localizations.categorySort_datePostedAscending;
      case SortMethodEnum.dateAvailableDesc:
        return context.localizations.categorySort_datePostedDescending;
      case SortMethodEnum.rateAsc:
        return context.localizations.categorySort_ratingScoreAscending;
      case SortMethodEnum.rateDesc:
        return context.localizations.categorySort_ratingScoreDescending;
      case SortMethodEnum.hitAsc:
        return context.localizations.categorySort_visitsAscending;
      case SortMethodEnum.hitDesc:
        return context.localizations.categorySort_visitsDescending;
      case SortMethodEnum.random:
        return context.localizations.categorySort_random;
      default:
        return context.localizations.categorySort_manual;
    }
  }
}
