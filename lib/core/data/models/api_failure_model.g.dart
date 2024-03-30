// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_failure_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiFailureModel _$ApiFailureModelFromJson(Map<String, dynamic> json) => ApiFailureModel(
      code: json['err'] as int,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ApiFailureModelToJson(ApiFailureModel instance) => <String, dynamic>{
      'err': instance.code,
      'message': instance.message,
    };
