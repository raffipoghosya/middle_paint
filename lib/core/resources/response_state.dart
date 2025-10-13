import 'package:middle_paint/core/resources/base_exception.dart';

/// This pattern helps clearly distinguish between a successful result ([DataSuccess])
/// and a failed result ([DataFailed]), centralizing error handling.
abstract class DataState<T> {
  final T? data;
  final BaseException? exception;

  const DataState({this.data, this.exception});
}

/// Represents a successful data operation, containing the result data.
class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

/// Represents a failed data operation, containing a structured exception.
class DataFailed<T> extends DataState<T> {
  const DataFailed(BaseException exception) : super(exception: exception);
}
