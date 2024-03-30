// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbumModel _$AlbumModelFromJson(Map<String, dynamic> json) => AlbumModel(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['fullname'] as String?,
      comment: json['comment'] as String?,
      url: json['url'] as String,
      urlRepresentative: json['tn_url'] as String?,
      permalink: json['permalink'] as String?,
      status: $enumDecode(_$AlbumStatusEnumEnumMap, json['status']),
      upperCategories: json['uppercats'] as String,
      idUpperCategory: json['id_uppercat'] as String?,
      globalRank: json['global_rank'] as String,
      nbImages: json['nb_images'] as int,
      nbTotalImages: json['total_nb_images'] as int,
      nbCategories: json['nb_categories'] as int,
      idRepresentative: json['representative_picture_id'] as String?,
      dateLast: json['date_last'] == null ? null : DateTime.parse(json['date_last'] as String),
      maxDateLast: json['max_date_last'] == null ? null : DateTime.parse(json['max_date_last'] as String),
      imageOrder: json['image_order'] as String?,
    );

Map<String, dynamic> _$AlbumModelToJson(AlbumModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'fullname': instance.fullName,
      'comment': instance.comment,
      'url': instance.url,
      'tn_url': instance.urlRepresentative,
      'permalink': instance.permalink,
      'status': _$AlbumStatusEnumEnumMap[instance.status]!,
      'uppercats': instance.upperCategories,
      'id_uppercat': instance.idUpperCategory,
      'global_rank': instance.globalRank,
      'nb_images': instance.nbImages,
      'total_nb_images': instance.nbTotalImages,
      'nb_categories': instance.nbCategories,
      'representative_picture_id': instance.idRepresentative,
      'date_last': instance.dateLast?.toIso8601String(),
      'max_date_last': instance.maxDateLast?.toIso8601String(),
      'image_order': instance.imageOrder,
    };

const _$AlbumStatusEnumEnumMap = {
  AlbumStatusEnum.public: 'public',
  AlbumStatusEnum.private: 'private',
};
