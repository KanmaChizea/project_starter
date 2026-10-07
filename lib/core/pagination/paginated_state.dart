import 'package:equatable/equatable.dart';

class PaginatedState<T> extends Equatable {
  const PaginatedState({
    this.items = const [],
    required this.nextPage,
    this.hasMore = true,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<T> items;
  final int nextPage;
  final bool hasMore;
  final bool isLoading;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    items,
    nextPage,
    hasMore,
    isLoading,
    errorMessage,
  ];

  PaginatedState<T> copyWith({
    List<T>? items,
    int? nextPage,
    bool? hasMore,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return PaginatedState(
      items: items ?? this.items,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
