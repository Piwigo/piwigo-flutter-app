import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/features/albums/domain/enums/album_status_enum.dart';

class AlbumEntity {
  const AlbumEntity({
    required this.id,
    required this.name,
    this.fullName,
    this.comment,
    required this.url,
    this.urlRepresentative,
    this.permalink,
    required this.status,
    required this.upperCategories,
    this.idUpperCategory,
    required this.globalRank,
    required this.nbImages,
    required this.nbTotalImages,
    required this.nbCategories,
    this.idRepresentative,
    this.dateLast,
    this.maxDateLast,
    this.imageOrder,
  });

  final int id;

  final String name;

  @JsonKey(name: 'fullname')
  final String? fullName;

  final String? comment;

  final String url;

  @JsonKey(name: 'tn_url')
  final String? urlRepresentative;

  final String? permalink;

  final AlbumStatusEnum status;

  @JsonKey(name: 'uppercats')
  final String upperCategories;

  @JsonKey(name: 'id_uppercat')
  final String? idUpperCategory;

  @JsonKey(name: 'global_rank')
  final String globalRank;

  @JsonKey(name: 'nb_images')
  final int nbImages;

  @JsonKey(name: 'total_nb_images')
  final int nbTotalImages;

  @JsonKey(name: 'nb_categories')
  final int nbCategories;

  @JsonKey(name: 'representative_picture_id')
  final String? idRepresentative;

  @JsonKey(name: 'date_last')
  final DateTime? dateLast;

  @JsonKey(name: 'max_date_last')
  final DateTime? maxDateLast;

  @JsonKey(name: 'image_order')
  final String? imageOrder;
}
