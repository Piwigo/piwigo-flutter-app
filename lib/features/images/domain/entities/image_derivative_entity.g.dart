// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_derivative_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageDerivativeEntity _$ImageDerivativeEntityFromJson(Map<String, dynamic> json) => ImageDerivativeEntity(
      url: json['url'] as String,
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ImageDerivativeEntityToJson(ImageDerivativeEntity instance) => <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };
