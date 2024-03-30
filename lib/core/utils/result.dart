import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/core/errors/failures.dart';

part 'result.freezed.dart';

@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = ResultSuccess<T>;

  const factory Result.failure(Failure failure) = ResultFailure<T>;
}
