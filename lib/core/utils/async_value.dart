import 'package:equatable/equatable.dart';

class AsyncValue<T> extends Equatable {
  final T? data;
  final String? error;
  final bool isLoading;

  const AsyncValue._({this.data, this.error, this.isLoading = false});

  factory AsyncValue.loading() => const AsyncValue._(isLoading: true);
  factory AsyncValue.data(T value) => AsyncValue._(data: value);
  factory AsyncValue.error(String error) => AsyncValue._(error: error);

  bool get hasError => error != null;
  bool get hasData => data is T;

  AsyncValue<R> cast<R>() {
    if (isLoading) return AsyncValue.loading();
    if (error != null) return AsyncValue.error(error!);
    if (data != null) return AsyncValue.data(data as R);
    return AsyncValue.loading();
  }

  R when<R>({
    required R Function() loading,
    required R Function(T data) data,
    required R Function(String error) error,
  }) {
    if (isLoading) return loading();
    if (hasError) return error(this.error!);
    if (hasData) return data(this.data as T);
    throw StateError('Invalid AsyncValue state');
  }

  @override
  List<Object?> get props => [data, error, isLoading];
}
