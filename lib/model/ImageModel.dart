import 'package:piwigo_ng/model/DerivativeModel.dart';

class ImageModel {
  int id;
  int width;
  int height;
  int hit;
  String file;
  String name;
  String comment;
  String creationDate;
  String availableDate;
  String pageUrl;
  String elementUrl;
  Map<String, DerivativeModel> derivatives;

  ImageModel(this.id,
    this.file,
    this.name,
    this.comment,
    this.elementUrl,
    this.derivatives,
    {
      this.width,
      this.height,
      this.availableDate,
      this.creationDate,
      this.hit,
      this.pageUrl
    }
  );
}