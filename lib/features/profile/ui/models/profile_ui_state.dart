import 'package:equatable/equatable.dart';
import 'package:project_starter/core/session/user.dart';

class ProfileUiState extends Equatable {
  const ProfileUiState({this.user, this.isLoading = false, this.errorMessage});

  final User? user;
  final bool isLoading;
  final String? errorMessage;

  @override
  List<Object?> get props => [user, isLoading, errorMessage];

  ProfileUiState copyWith({bool? isLoading, String? Function()? errorMessage}) {
    return ProfileUiState(
      user: user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
