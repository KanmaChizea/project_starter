import 'package:equatable/equatable.dart';

/// An authenticated user.
class User extends Equatable {
  const User({required this.id, required this.email, this.displayName});

  final String id;
  final String email;
  final String? displayName;

  @override
  List<Object?> get props => [id, email, displayName];
}
