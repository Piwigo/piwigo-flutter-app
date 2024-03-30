import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum ImageSizeEnum {
  square('square'),
  thumb('thumb'),
  xxSmall('2small'),
  xSmall('xsmall'),
  small('small'),
  medium('medium'),
  large('large'),
  xLarge('xlarge'),
  xxLarge('xxlarge'),
  full('full');

  const ImageSizeEnum(this.value);

  final String value;

  static ImageSizeEnum fromJson(String json) {
    switch (json) {
      case 'square':
        return ImageSizeEnum.square;
      case 'thumb':
        return ImageSizeEnum.thumb;
      case '2small':
        return ImageSizeEnum.xxSmall;
      case 'xsmall':
        return ImageSizeEnum.xSmall;
      case 'small':
        return ImageSizeEnum.small;
      case 'medium':
        return ImageSizeEnum.medium;
      case 'large':
        return ImageSizeEnum.large;
      case 'xlarge':
        return ImageSizeEnum.xLarge;
      case 'xxlarge':
        return ImageSizeEnum.xxLarge;
      case 'full':
        return ImageSizeEnum.full;
      default:
        throw UnimplementedError();
    }
  }
}
