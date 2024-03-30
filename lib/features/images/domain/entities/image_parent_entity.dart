import 'package:json_annotation/json_annotation.dart';

part 'image_parent_entity.g.dart';

@JsonSerializable()
class ImageParentEntity {
  ImageParentEntity({
    required this.id,
    this.url,
    this.pageUrl,
  });

  factory ImageParentEntity.fromJson(Map<String, dynamic> json) => _$ImageParentEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ImageParentEntityToJson(this);

  final int id;

  final String? url;

  @JsonKey(name: 'page_url')
  final String? pageUrl;
}
