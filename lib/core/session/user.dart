import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id, required this.email, this.displayName});

  factory User.fromJson(Map<String, Object?> json) => User(
    id: json['id']! as String,
    email: json['email']! as String,
    displayName: json['displayName'] as String?,
  );

  final String id;
  final String email;
  final String? displayName;

  Map<String, Object?> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
  };

  @override
  List<Object?> get props => [id, email, displayName];
}
