// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageModel _$ImageModelFromJson(Map<String, dynamic> json) => ImageModel(
      id: json['id'] as int,
      width: json['width'] as int?,
      height: json['height'] as int?,
      hit: json['hit'] as int? ?? 0,
      favorite: json['favorite'] as bool? ?? false,
      file: json['file'] as String? ?? '',
      name: json['name'] as String,
      comment: json['comment'] as String?,
      dateCreation: json['date_creation'] as String?,
      dateAvailable: json['date_available'] as String?,
      pageUrl: json['page_url'] as String?,
      elementUrl: json['element_url'] as String?,
      downloadUrl: json['download_url'] as String?,
      derivatives: ImageDerivativesModel.fromJson(json['derivatives'] as Map<String, dynamic>),
      parents: (json['categories'] as List<dynamic>?)
              ?.map((e) => ImageParentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ImageParentModel>[],
    );

Map<String, dynamic> _$ImageModelToJson(ImageModel instance) => <String, dynamic>{
      'id': instance.id,
      'width': instance.width,
      'height': instance.height,
      'hit': instance.hit,
      'favorite': instance.favorite,
      'file': instance.file,
      'name': instance.name,
      'comment': instance.comment,
      'date_creation': instance.dateCreation,
      'date_available': instance.dateAvailable,
      'page_url': instance.pageUrl,
      'element_url': instance.elementUrl,
      'download_url': instance.downloadUrl,
    };

ImageDerivativesModel _$ImageDerivativesModelFromJson(Map<String, dynamic> json) => ImageDerivativesModel(
      square: ImageDerivativeModel.fromJson(json['square'] as Map<String, dynamic>),
      thumb: ImageDerivativeModel.fromJson(json['thumb'] as Map<String, dynamic>),
      xxSmall: json['2small'] == null ? null : ImageDerivativeModel.fromJson(json['2small'] as Map<String, dynamic>),
      xSmall: json['xsmall'] == null ? null : ImageDerivativeModel.fromJson(json['xsmall'] as Map<String, dynamic>),
      small: json['small'] == null ? null : ImageDerivativeModel.fromJson(json['small'] as Map<String, dynamic>),
      medium: ImageDerivativeModel.fromJson(json['medium'] as Map<String, dynamic>),
      large: json['large'] == null ? null : ImageDerivativeModel.fromJson(json['large'] as Map<String, dynamic>),
      xLarge: json['xlarge'] == null ? null : ImageDerivativeModel.fromJson(json['xlarge'] as Map<String, dynamic>),
      xxLarge: json['xxlarge'] == null ? null : ImageDerivativeModel.fromJson(json['xxlarge'] as Map<String, dynamic>),
      full: json['full'] == null ? null : ImageDerivativeModel.fromJson(json['full'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ImageDerivativesModelToJson(ImageDerivativesModel instance) => <String, dynamic>{
      'square': instance.square,
      'thumb': instance.thumb,
      '2small': instance.xxSmall,
      'xsmall': instance.xSmall,
      'small': instance.small,
      'medium': instance.medium,
      'large': instance.large,
      'xlarge': instance.xLarge,
      'xxlarge': instance.xxLarge,
      'full': instance.full,
    };
