import 'package:equatable/equatable.dart';

class ItemDetailUiState extends Equatable {
  const ItemDetailUiState({
    required this.itemId,
    this.isLoading = false,
    this.errorMessage,
  });

  final int itemId;
  final bool isLoading;
  final String? errorMessage;

  @override
  List<Object?> get props => [itemId, isLoading, errorMessage];

  ItemDetailUiState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return ItemDetailUiState(
      itemId: itemId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
