import 'package:equatable/equatable.dart';

class ProfileUiState extends Equatable {
  const ProfileUiState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  @override
  List<Object?> get props => [isLoading, errorMessage];

  ProfileUiState copyWith({bool? isLoading, String? Function()? errorMessage}) {
    return ProfileUiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
