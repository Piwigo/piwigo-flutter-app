import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_failure_model.g.dart';

@JsonSerializable()
class ApiFailureModel {
  factory ApiFailureModel.fromJson(Map<String, dynamic> json) => _$ApiFailureModelFromJson(json);

  const ApiFailureModel({
    required this.code,
    this.message,
  });

  @JsonKey(name: 'err')
  final int code;

  final String? message;

  Map<String, dynamic> toJson() => _$ApiFailureModelToJson(this);
}
