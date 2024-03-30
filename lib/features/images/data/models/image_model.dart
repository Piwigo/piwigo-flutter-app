import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/features/images/data/models/image_derivative_model.dart';
import 'package:piwigo_ng/features/images/data/models/image_parent_model.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_entity.dart';

part 'image_model.g.dart';

@JsonSerializable()
class ImageModel extends ImageEntity {
  const ImageModel({
    required super.id,
    super.width,
    super.height,
    super.hit = 0,
    super.favorite = false,
    super.file = '',
    required super.name,
    super.comment,
    super.dateCreation,
    super.dateAvailable,
    super.pageUrl,
    super.elementUrl,
    super.downloadUrl,
    required ImageDerivativesModel derivatives,
    List<ImageParentModel> parents = const <ImageParentModel>[],
  }) : super(
          derivatives: derivatives,
          parents: parents,
        );

  //region Serialization
  factory ImageModel.fromJson(Map<String, dynamic> json) => _$ImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageModelToJson(this);
//endregion
}

@JsonSerializable()
class ImageDerivativesModel extends ImageDerivativesEntity {
  const ImageDerivativesModel({
    required ImageDerivativeModel square,
    required ImageDerivativeModel thumb,
    ImageDerivativeModel? xxSmall,
    ImageDerivativeModel? xSmall,
    ImageDerivativeModel? small,
    required ImageDerivativeModel medium,
    ImageDerivativeModel? large,
    ImageDerivativeModel? xLarge,
    ImageDerivativeModel? xxLarge,
    ImageDerivativeModel? full,
  }) : super(
          square: square,
          thumb: thumb,
          xxSmall: xxSmall,
          xSmall: xSmall,
          small: small,
          medium: medium,
          large: large,
          xLarge: xLarge,
          xxLarge: xxLarge,
          full: full,
        );

  //region Serialization
  factory ImageDerivativesModel.fromJson(Map<String, dynamic> json) => _$ImageDerivativesModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageDerivativesModelToJson(this);
//endregion
}
