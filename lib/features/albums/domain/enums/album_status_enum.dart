import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum AlbumStatusEnum {
  public('public'),
  private('private');

  const AlbumStatusEnum(this.value);

  final String value;
}
