import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_parent_entity.dart';

part 'image_parent_model.g.dart';

@JsonSerializable()
class ImageParentModel extends ImageParentEntity {
  ImageParentModel({
    required super.id,
    super.url,
    super.pageUrl,
  });

  //region Serialization
  factory ImageParentModel.fromJson(Map<String, dynamic> json) => _$ImageParentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageParentModelToJson(this);
//endregion
}
