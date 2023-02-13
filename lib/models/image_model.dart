import 'package:mime_type/mime_type.dart';

class ImageModel {
  int id;
  int width;
  int height;
  int hit;
  bool favorite;
  String file;
  String name;
  String? comment;
  String? dateCreation;
  String? dateAvailable;
  String? pageUrl;
  String? elementUrl;
  Derivatives derivatives;
  List<dynamic> categories;

  ImageModel({
    required this.id,
    this.width = 1,
    this.height = 1,
    this.hit = 0,
    this.favorite = false,
    this.file = '',
    required this.name,
    this.comment,
    this.dateCreation,
    this.dateAvailable,
    this.pageUrl,
    this.elementUrl,
    required this.derivatives,
    this.categories = const [],
  });

  ImageModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        width = int.tryParse(json['width'].toString()) ?? 0,
        height = int.tryParse(json['height'].toString()) ?? 0,
        hit = int.tryParse(json['hit'].toString()) ?? 0,
        favorite = json['is_favorite'] ?? false,
        file = json['file'].toString(),
        name = json['name'].toString(),
        comment = json['comment'],
        dateCreation = json['date_creation'],
        dateAvailable = json['date_available'],
        pageUrl = json['page_url'],
        elementUrl = json['element_url'],
        derivatives = Derivatives.fromJson(json['derivatives']),
        categories = json['categories'] ?? [];

  Derivative? getDerivativeFromString(String derivative) {
    switch (derivative) {
      case 'square':
        return derivatives.square;
      case 'thumb':
        return derivatives.thumbnail;
      case '2small':
        return derivatives.xxsmall;
      case 'xsmall':
        return derivatives.xsmall;
      case 'small':
        return derivatives.small;
      case 'medium':
        return derivatives.medium;
      case 'large':
        return derivatives.large;
      case 'xlarge':
        return derivatives.xlarge;
      case 'xxlarge':
        return derivatives.xxlarge;
      case 'full':
        return derivatives.full;
      default:
        return null;
    }
  }

  bool get isVideo {
    String? mimeType = mime(file) ?? mime(elementUrl) ?? mime(derivatives.medium.url);
    return mimeType != null && mimeType.startsWith('video');
  }

  @override
  operator ==(other) => other is ImageModel && id == other.id;

  @override
  int get hashCode => Object.hash(id, name);
}

class Derivatives {
  Derivative square;
  Derivative thumbnail;
  Derivative? xxsmall;
  Derivative? xsmall;
  Derivative? small;
  Derivative medium;
  Derivative? large;
  Derivative? xlarge;
  Derivative? xxlarge;
  Derivative? full;

  Derivatives({
    required this.square,
    required this.thumbnail,
    this.xxsmall,
    this.xsmall,
    this.small,
    required this.medium,
    this.large,
    this.xlarge,
    this.xxlarge,
    this.full,
  });

  Derivatives.fromJson(Map<String, dynamic> json)
      : square = Derivative.fromJson(json['square']),
        thumbnail = Derivative.fromJson(json['thumb']),
        xxsmall = getDerivativeFromJson(json['2small']),
        xsmall = getDerivativeFromJson(json['xsmall']),
        small = getDerivativeFromJson(json['small']),
        medium = Derivative.fromJson(json['medium']),
        large = getDerivativeFromJson(json['large']),
        xlarge = getDerivativeFromJson(json['xlarge']),
        xxlarge = getDerivativeFromJson(json['xxlarge']),
        full = getDerivativeFromJson(json['full']);

  static Derivative? getDerivativeFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return Derivative.fromJson(json);
  }

  @override
  String toString() {
    return 'square: ${square.url},\nthumb: ${thumbnail.url},\n2small: ${xxsmall?.url},\nxsmall: ${xsmall?.url},\nsmall: ${small?.url},\nmedium: ${medium.url},\nlarge: ${large?.url},\nxlarge: ${xlarge?.url},\nxxlarge: ${xxlarge?.url},\nfull: ${full?.url},';
  }
}

class Derivative {
  String url;
  int width;
  int height;

  Derivative({required this.url, this.width = 0, this.height = 0});

  Derivative.fromJson(Map<String, dynamic> json)
      : url = json['url'].toString(),
        width = int.tryParse(json['width'].toString()) ?? 0,
        height = int.tryParse(json['height'].toString()) ?? 0;
}
