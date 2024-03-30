import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/features/authentication/data/enums/user_status_enum.dart';
import 'package:piwigo_ng/features/authentication/domain/entities/session_status_entity.dart';
import 'package:piwigo_ng/features/images/data/enums/image_size_enum.dart';

part 'session_status_model.g.dart';

@JsonSerializable()
class SessionStatusModel extends SessionStatusEntity {
  const SessionStatusModel({
    required super.username,
    required super.status,
    required super.pwgToken,
    required super.version,
    super.theme,
    super.languageCode,
    super.charset,
    super.currentDateTime,
    super.saveVisits,
    super.availableSizes = const <ImageSizeEnum>[],
    super.uploadFileTypes,
    super.uploadFormChunkSize,
  });

  //region Serialization
  factory SessionStatusModel.fromJson(Map<String, dynamic> json) => _$SessionStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionStatusModelToJson(this);
//end_region
}
