import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/features/auth/data/repositories/auth_repository.dart';
import 'package:project_starter/features/auth/data/services/auth_service.dart';
import 'package:project_starter/features/home/data/repositories/home_repository.dart';
import 'package:project_starter/features/home/data/services/home_service.dart';
import 'package:project_starter/features/profile/data/repositories/profile_repository.dart';
import 'package:project_starter/features/profile/data/services/profile_service.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.session, required this.child});

  final SessionCubit session;
  final Widget child;

  static void clearAll(BuildContext context) {
    context.read<SessionCubit>().clear();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: session)],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (_) => AuthService(FakeAuthRepository(), session),
          ),
          RepositoryProvider(create: (_) => HomeService(HomeRepository())),
          RepositoryProvider(
            create: (_) => ProfileService(ProfileRepository(), session),
          ),
        ],
        child: child,
      ),
    );
  }
}
