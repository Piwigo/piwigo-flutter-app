enum AlbumStatus { public, private }

extension AlbumStatusSerialization on AlbumStatus {
  String toJson() {
    return this.name;
  }

  static AlbumStatus fromJson(String? json) {
    switch (json) {
      case 'public':
        return AlbumStatus.public;
      case 'private':
        return AlbumStatus.private;
      default:
        return AlbumStatus.public;
    }
  }
}

class AlbumModel {
  int id;
  String name;
  String fullName;
  String? comment;
  String url;
  String? urlRepresentative;
  String? permalink;
  AlbumStatus status;
  String upperCategories;
  String? idUpperCategory;
  String globalRank;
  int nbImages;
  int nbTotalImages;
  int nbCategories;
  String? idRepresentative;
  String? dateLast;
  String? dateLastMax;
  List<AlbumModel> children;
  bool canUpload;

  AlbumModel({
    required this.id,
    required this.name,
    String? fullName,
    this.comment,
    this.url = '',
    this.urlRepresentative,
    this.permalink,
    this.status = AlbumStatus.public,
    this.upperCategories = '',
    this.idUpperCategory,
    this.globalRank = '',
    this.nbImages = 0,
    this.nbTotalImages = 0,
    this.nbCategories = 0,
    this.idRepresentative,
    this.dateLast,
    this.dateLastMax,
    this.canUpload = true,
    List<AlbumModel>? children,
  })  : children = children ?? [],
        fullName = fullName ?? name;

  AlbumModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] ?? '',
        fullName = json['fullname'] ?? json['name'] ?? '',
        comment = json['comment'],
        url = json['url'],
        urlRepresentative = json['tn_url'],
        permalink = json['permalink'],
        status = AlbumStatusSerialization.fromJson(json['status']),
        upperCategories = json['uppercats'] ?? '',
        idUpperCategory = json['id_uppercat'],
        globalRank = json['global_rank'] ?? '',
        nbImages = json['nb_images'] ?? 0,
        nbTotalImages = json['total_nb_images'] ?? 0,
        nbCategories = json['nb_categories'] ?? 0,
        children = json['sub_categories']
                ?.map<AlbumModel>((a) => AlbumModel.fromJson(a))
                .toList() ??
            [],
        idRepresentative = json['representative_picture_id'],
        dateLast = json['date_last'],
        dateLastMax = json['max_date_last'],
        canUpload = json['can_upload'] ?? true;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fullname': fullName,
        'comment': comment,
        'url': url,
        'tn_url': urlRepresentative,
        'permalink': permalink,
        'status': status.toJson(),
        'uppercats': upperCategories,
        'id_uppercat': idUpperCategory,
        'global_rank': globalRank,
        'nb_images': nbImages,
        'total_nb_images': nbTotalImages,
        'nb_categories': nbCategories,
        'sub_categories':
            List.generate(children.length, (i) => children[i].toJson()),
        'representative_picture_id': idRepresentative,
        'date_last': dateLast,
        'max_date_last': dateLastMax,
        'can_upload': canUpload,
      };

  @override
  operator ==(other) => other is AlbumModel && id == other.id;

  @override
  int get hashCode => Object.hash(id, name);
}
