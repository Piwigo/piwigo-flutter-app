// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_derivative_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageDerivativeModel _$ImageDerivativeModelFromJson(Map<String, dynamic> json) => ImageDerivativeModel(
      url: json['url'] as String,
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ImageDerivativeModelToJson(ImageDerivativeModel instance) => <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };
