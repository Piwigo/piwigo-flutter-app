import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mime_type/mime_type.dart';
import 'package:piwigo_ng/features/images/data/enums/image_size_enum.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_derivative_entity.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_parent_entity.dart';

part 'image_entity.g.dart';

@CopyWith()
@JsonSerializable()
class ImageEntity {
  const ImageEntity({
    required this.id,
    this.width,
    this.height,
    this.hit = 0,
    this.favorite = false,
    this.file = '',
    required this.name,
    this.comment,
    this.dateCreation,
    this.dateAvailable,
    this.pageUrl,
    this.elementUrl,
    this.downloadUrl,
    required this.derivatives,
    this.parents = const <ImageParentEntity>[],
  });

  factory ImageEntity.fromJson(Map<String, dynamic> json) => _$ImageEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ImageEntityToJson(this);

  final int id;

  final int? width;

  final int? height;

  final int hit;

  final bool favorite;

  final String file;

  final String name;

  final String? comment;

  @JsonKey(name: 'date_creation')
  final String? dateCreation;

  @JsonKey(name: 'date_available')
  final String? dateAvailable;

  @JsonKey(name: 'page_url')
  final String? pageUrl;

  @JsonKey(name: 'element_url')
  final String? elementUrl;

  @JsonKey(name: 'download_url')
  final String? downloadUrl;

  @JsonKey(includeToJson: false)
  final ImageDerivativesEntity derivatives;

  @JsonKey(name: 'categories', includeToJson: false)
  final List<ImageParentEntity> parents;

  ImageDerivativeEntity getDerivative(ImageSizeEnum size) => derivatives.mapToSize(size) ?? derivatives.medium;

  bool get isVideo {
    String? mimeType = mime(file) ?? mime(elementUrl) ?? mime(derivatives.medium.url);
    return mimeType != null && mimeType.startsWith('video');
  }
}

@CopyWith()
@JsonSerializable()
class ImageDerivativesEntity {
  const ImageDerivativesEntity({
    required this.square,
    required this.thumb,
    this.xxSmall,
    this.xSmall,
    this.small,
    required this.medium,
    this.large,
    this.xLarge,
    this.xxLarge,
    this.full,
  });

  factory ImageDerivativesEntity.fromJson(Map<String, dynamic> json) => _$ImageDerivativesEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDerivativesEntityToJson(this);

  final ImageDerivativeEntity square;

  final ImageDerivativeEntity thumb;

  @JsonKey(name: '2small')
  final ImageDerivativeEntity? xxSmall;

  @JsonKey(name: 'xsmall')
  final ImageDerivativeEntity? xSmall;

  final ImageDerivativeEntity? small;

  final ImageDerivativeEntity medium;

  final ImageDerivativeEntity? large;

  @JsonKey(name: 'xlarge')
  final ImageDerivativeEntity? xLarge;

  @JsonKey(name: 'xxlarge')
  final ImageDerivativeEntity? xxLarge;

  final ImageDerivativeEntity? full;

  ImageDerivativeEntity? mapToSize(ImageSizeEnum size) {
    switch (size) {
      case ImageSizeEnum.square:
        return square;
      case ImageSizeEnum.thumb:
        return thumb;
      case ImageSizeEnum.xxSmall:
        return xxSmall;
      case ImageSizeEnum.xSmall:
        return xSmall;
      case ImageSizeEnum.small:
        return small;
      case ImageSizeEnum.medium:
        return medium;
      case ImageSizeEnum.large:
        return large;
      case ImageSizeEnum.xLarge:
        return xLarge;
      case ImageSizeEnum.xxLarge:
        return xxLarge;
      case ImageSizeEnum.full:
        return full;
    }
  }
}
