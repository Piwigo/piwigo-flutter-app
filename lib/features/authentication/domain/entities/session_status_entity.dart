import 'package:json_annotation/json_annotation.dart';
import 'package:piwigo_ng/features/authentication/data/enums/user_status_enum.dart';
import 'package:piwigo_ng/features/images/data/enums/image_size_enum.dart';

class SessionStatusEntity {
  const SessionStatusEntity({
    required this.username,
    required this.status,
    this.pwgToken,
    required this.version,
    this.theme,
    this.languageCode,
    this.charset,
    this.currentDateTime,
    this.saveVisits,
    this.availableSizes = const <ImageSizeEnum>[],
    this.uploadFileTypes,
    this.uploadFormChunkSize,
  });

  /// Current user's username
  final String username;

  /// Current user status
  final UserStatusEnum status;

  /// PWG Token (for non-guest users)
  @JsonKey(name: 'pwg_token')
  final String? pwgToken;

  /// Piwigo Server version
  final String version;

  final String? theme;

  @JsonKey(name: 'language')
  final String? languageCode;

  final String? charset;

  @JsonKey(name: 'current_datetime')
  final DateTime? currentDateTime;

  final bool? saveVisits;

  /// Available Piwigo image sizes
  @JsonKey(name: 'available_sizes')
  final List<ImageSizeEnum> availableSizes;

  @JsonKey(name: 'upload_file_types')
  final String? uploadFileTypes;

  @JsonKey(name: 'upload_form_chunk_size')
  final int? uploadFormChunkSize;

  List<String> get uploadFileTypeList => uploadFileTypes?.split(',') ?? <String>[];
}
