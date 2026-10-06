import 'package:flutter_bloc/flutter_bloc.dart';

import 'session_state.dart';
import 'user.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState());

  User? get user => state.user;

  bool get isSignedIn => state.isSignedIn;

  void start(User user) => emit(SessionState(user: user));

  void clear() {
    if (!isSignedIn) return;
    emit(const SessionState());
  }
}
