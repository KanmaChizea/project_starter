import 'package:flutter_test/flutter_test.dart';
import 'package:project_starter/features/home/data/repositories/home_repository.dart';
import 'package:project_starter/features/home/data/services/home_service.dart';
import 'package:project_starter/features/home/ui/models/home_ui_state.dart';
import 'package:project_starter/features/home/ui/views/home_view_model.dart';

void main() {
  late HomeViewModel viewModel;

  setUp(() {
    viewModel = HomeViewModel(homeService: HomeService(HomeRepository()));
  });

  tearDown(() => viewModel.close());

  test('starts in the initial state', () {
    expect(viewModel.state, const HomeUiState());
  });
}
