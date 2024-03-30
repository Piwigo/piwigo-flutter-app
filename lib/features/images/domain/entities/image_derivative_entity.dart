import 'package:json_annotation/json_annotation.dart';

part 'image_derivative_entity.g.dart';

@JsonSerializable()
class ImageDerivativeEntity {
  const ImageDerivativeEntity({
    required this.url,
    this.width,
    this.height,
  });

  factory ImageDerivativeEntity.fromJson(Map<String, dynamic> json) => _$ImageDerivativeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDerivativeEntityToJson(this);

  final String url;
  final double? width;
  final double? height;
}
