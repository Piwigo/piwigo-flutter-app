// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionStatusModel _$SessionStatusModelFromJson(Map<String, dynamic> json) => SessionStatusModel(
      username: json['username'] as String,
      status: $enumDecode(_$UserStatusEnumEnumMap, json['status']),
      pwgToken: json['pwg_token'] as String?,
      version: json['version'] as String,
      theme: json['theme'] as String?,
      languageCode: json['language'] as String?,
      charset: json['charset'] as String?,
      currentDateTime: json['current_datetime'] == null ? null : DateTime.parse(json['current_datetime'] as String),
      saveVisits: json['saveVisits'] as bool?,
      availableSizes:
          (json['available_sizes'] as List<dynamic>?)?.map((e) => $enumDecode(_$ImageSizeEnumEnumMap, e)).toList() ??
              const <ImageSizeEnum>[],
      uploadFileTypes: json['upload_file_types'] as String?,
      uploadFormChunkSize: json['upload_form_chunk_size'] as int?,
    );

Map<String, dynamic> _$SessionStatusModelToJson(SessionStatusModel instance) => <String, dynamic>{
      'username': instance.username,
      'status': _$UserStatusEnumEnumMap[instance.status]!,
      'pwg_token': instance.pwgToken,
      'version': instance.version,
      'theme': instance.theme,
      'language': instance.languageCode,
      'charset': instance.charset,
      'current_datetime': instance.currentDateTime?.toIso8601String(),
      'saveVisits': instance.saveVisits,
      'available_sizes': instance.availableSizes.map((e) => _$ImageSizeEnumEnumMap[e]!).toList(),
      'upload_file_types': instance.uploadFileTypes,
      'upload_form_chunk_size': instance.uploadFormChunkSize,
    };

const _$UserStatusEnumEnumMap = {
  UserStatusEnum.guest: 'guest',
  UserStatusEnum.webmaster: 'webmaster',
  UserStatusEnum.admin: 'admin',
  UserStatusEnum.user: 'user',
};

const _$ImageSizeEnumEnumMap = {
  ImageSizeEnum.square: 'square',
  ImageSizeEnum.thumb: 'thumb',
  ImageSizeEnum.xxSmall: '2small',
  ImageSizeEnum.xSmall: 'xsmall',
  ImageSizeEnum.small: 'small',
  ImageSizeEnum.medium: 'medium',
  ImageSizeEnum.large: 'large',
  ImageSizeEnum.xLarge: 'xlarge',
  ImageSizeEnum.xxLarge: 'xxlarge',
  ImageSizeEnum.full: 'full',
};
