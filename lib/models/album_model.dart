class AlbumModel {
  int id;
  String name;
  String fullName;
  String? comment;
  String url;
  String? urlRepresentative;
  String? permalink;
  String? status;
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

  AlbumModel({
    required this.id,
    required this.name,
    String? fullName,
    this.comment,
    this.url = '',
    this.urlRepresentative,
    this.permalink,
    this.status,
    this.upperCategories = '',
    this.idUpperCategory,
    this.globalRank = '',
    this.nbImages = 0,
    this.nbTotalImages = 0,
    this.nbCategories = 0,
    this.idRepresentative,
    this.dateLast,
    this.dateLastMax,
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
        status = json['status'],
        upperCategories = json['uppercats'] ?? '',
        idUpperCategory = json['id_uppercat'],
        globalRank = json['global_rank'] ?? '',
        nbImages = json['nb_images'] ?? 0,
        nbTotalImages = json['total_nb_images'] ?? 0,
        nbCategories = json['nb_categories'] ?? 0,
        children = json['sub_categories']?.map<AlbumModel>((a) => AlbumModel.fromJson(a)).toList() ?? [],
        idRepresentative = json['representative_picture_id'],
        dateLast = json['date_last'],
        dateLastMax = json['max_date_last'];
}
