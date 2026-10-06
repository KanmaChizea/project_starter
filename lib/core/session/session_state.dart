import 'package:equatable/equatable.dart';

import 'user.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionState extends Equatable {
  const SessionState.unknown() : status = SessionStatus.unknown, user = null;

  const SessionState.authenticated(User this.user)
    : status = SessionStatus.authenticated;

  const SessionState.unauthenticated()
    : status = SessionStatus.unauthenticated,
      user = null;

  final SessionStatus status;
  final User? user;

  bool get isSignedIn => status == SessionStatus.authenticated;

  bool get isResolved => status != SessionStatus.unknown;

  @override
  List<Object?> get props => [status, user];
}
