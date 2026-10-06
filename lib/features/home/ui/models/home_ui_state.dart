import 'package:equatable/equatable.dart';

class HomeUiState extends Equatable {
  const HomeUiState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  @override
  List<Object?> get props => [isLoading, errorMessage];

  HomeUiState copyWith({bool? isLoading, String? Function()? errorMessage}) {
    return HomeUiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
