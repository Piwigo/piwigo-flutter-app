import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_derivative_entity.dart';

part 'image_derivative_model.g.dart';

@JsonSerializable()
class ImageDerivativeModel extends ImageDerivativeEntity {
  const ImageDerivativeModel({
    required super.url,
    super.width,
    super.height,
  });

  //region Serialization
  factory ImageDerivativeModel.fromJson(Map<String, dynamic> json) => _$ImageDerivativeModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDerivativeModelToJson(this);
//endregion
}
