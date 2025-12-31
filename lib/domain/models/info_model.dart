class InfoModel {
  String? version;
  late int nbElements;
  late int nbCategories;
  late int nbVirtual;
  late int nbPhysical;
  late int nbImageCategory;
  late int nbTags;
  late int nbImageTag;
  late int nbUsers;
  late int nbGroups;
  late int nbComments;
  String? firstDate;
  late int cacheSize;

  InfoModel({
    this.version,
    this.nbElements = 0,
    this.nbCategories = 0,
    this.nbVirtual = 0,
    this.nbPhysical = 0,
    this.nbImageCategory = 0,
    this.nbTags = 0,
    this.nbImageTag = 0,
    this.nbUsers = 0,
    this.nbGroups = 0,
    this.nbComments = 0,
    this.firstDate,
    this.cacheSize = 0,
  });

  InfoModel.fromJson(Map<String, dynamic> json) {
    for (Map<String, dynamic> info in json['infos']) {
      switch (info['name']) {
        case 'version':
          version = info['value'];
          break;
        case 'nb_elements':
          nbElements = int.tryParse(info['value']) ?? 0;
          break;
        case 'nb_categories':
          nbCategories = int.tryParse(info['value']) ?? 0;
          break;
        case 'nb_virtual':
          nbVirtual = int.tryParse(info['value']) ?? 0;
          break;
        case 'nb_physical':
          nbPhysical = int.tryParse(info['value']) ?? 0;
          break;
        case 'nb_image_category':
          nbImageCategory = int.tryParse(info['value']) ?? 0;
          break;
        case 'nb_tags':
          nbTags = int.tryParse(info['value']) ?? 0;
          break;
        case 'nb_image_tag':
          nbImageTag = int.tryParse(info['value']) ?? 0;
          break;
        case 'nb_users':
          nbUsers = int.tryParse(info['value']) ?? 0;
          break;
        case 'nb_groups':
          nbGroups = int.tryParse(info['value']) ?? 0;
          break;
        case 'nb_comments':
          nbComments = int.tryParse(info['value']) ?? 0;
          break;
        case 'first_date':
          firstDate = info['value'];
          break;
        case 'cache_size':
          cacheSize = info['value'] ?? 0;
          break;
      }
    }
  }
}
