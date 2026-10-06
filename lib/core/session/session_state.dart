import 'package:equatable/equatable.dart';

import 'user.dart';

class SessionState extends Equatable {
  const SessionState({this.user});

  final User? user;

  bool get isSignedIn => user != null;

  @override
  List<Object?> get props => [user];
}
