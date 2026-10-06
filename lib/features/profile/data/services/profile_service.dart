import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/core/session/user.dart';

import '../repositories/profile_repository.dart';

class ProfileService {
  ProfileService(this._repository, this._session);

  // ignore: unused_field
  final ProfileRepository _repository;
  final SessionCubit _session;

  User? get currentUser => _session.user;

  void signOut() => _session.clear();
}
