import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/profile_service.dart';
import '../models/profile_ui_state.dart';

class ProfileViewModel extends Cubit<ProfileUiState> {
  ProfileViewModel({required this._profileService})
    : super(const ProfileUiState());

  // ignore: unused_field
  final ProfileService _profileService;

  // TODO: add actions; change state with emit(state.copyWith(...)).
}
