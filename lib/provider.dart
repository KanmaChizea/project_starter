import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_starter/core/network/api_client.dart';
import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/core/session/session_state.dart';
import 'package:project_starter/core/storage/local_storage.dart';
import 'package:project_starter/core/theme/theme_cubit.dart';
import 'package:project_starter/features/auth/data/repositories/auth_repository.dart';
import 'package:project_starter/features/auth/data/services/auth_service.dart';
import 'package:project_starter/features/home/data/repositories/home_repository.dart';
import 'package:project_starter/features/home/data/services/home_service.dart';
import 'package:project_starter/features/profile/data/repositories/profile_repository.dart';
import 'package:project_starter/features/profile/data/services/profile_service.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({
    super.key,
    required this.session,
    required this.themeCubit,
    required this.apiClient,
    required this.localStorage,
    required this.child,
  });

  final SessionCubit session;
  final ThemeCubit themeCubit;
  final ApiClient apiClient;
  final LocalStorage localStorage;
  final Widget child;

  static Future<void> clearAll(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider.value(value: themeCubit),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: localStorage),
          RepositoryProvider(
            create: (_) => AuthService(AuthRepository(apiClient), session),
          ),
          RepositoryProvider(
            create: (_) => HomeService(HomeRepository(apiClient)),
          ),
          RepositoryProvider(
            create: (_) => ProfileService(ProfileRepository(apiClient)),
          ),
        ],
        child: BlocListener<SessionCubit, SessionState>(
          listenWhen: (previous, current) =>
              previous.isSignedIn && !current.isSignedIn,
          listener: (context, _) => clearAll(context),
          child: child,
        ),
      ),
    );
  }
}
