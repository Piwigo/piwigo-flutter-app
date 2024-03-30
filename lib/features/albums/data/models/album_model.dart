import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/features/albums/domain/entities/album_entity.dart';
import 'package:piwigo_ng/features/albums/domain/enums/album_status_enum.dart';

part 'album_model.g.dart';

@JsonSerializable()
class AlbumModel extends AlbumEntity {
  const AlbumModel({
    required super.id,
    required super.name,
    super.fullName,
    super.comment,
    required super.url,
    super.urlRepresentative,
    super.permalink,
    required super.status,
    required super.upperCategories,
    super.idUpperCategory,
    required super.globalRank,
    required super.nbImages,
    required super.nbTotalImages,
    required super.nbCategories,
    super.idRepresentative,
    super.dateLast,
    super.maxDateLast,
    super.imageOrder,
  });

  //region Serialization
  factory AlbumModel.fromJson(Map<String, dynamic> json) => _$AlbumModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlbumModelToJson(this);
//end_region
}
