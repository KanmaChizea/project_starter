import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/home_service.dart';
import '../models/home_ui_state.dart';

class HomeViewModel extends Cubit<HomeUiState> {
  HomeViewModel({required this._homeService}) : super(const HomeUiState());

  // ignore: unused_field
  final HomeService _homeService;

  // TODO: add actions; change state with emit(state.copyWith(...)).
}
