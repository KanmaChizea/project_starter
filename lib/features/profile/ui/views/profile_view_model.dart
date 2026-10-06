import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/profile_service.dart';
import '../models/profile_ui_state.dart';

class ProfileViewModel extends Cubit<ProfileUiState> {
  ProfileViewModel({required this._profileService})
    : super(ProfileUiState(user: _profileService.currentUser));

  final ProfileService _profileService;

  void signOut() => _profileService.signOut();
}
