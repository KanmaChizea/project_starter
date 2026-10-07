import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_starter/core/config/env_config.dart';
import 'package:project_starter/core/config/flavor.dart';
import 'package:project_starter/core/network/dio_api_client.dart';
import 'package:project_starter/core/router/app_router.dart';
import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/core/storage/local_storage.dart';
import 'package:project_starter/core/theme/app_theme.dart';
import 'package:project_starter/core/theme/theme_cubit.dart';
import 'package:project_starter/core/utils/scale_util.dart';
import 'package:project_starter/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ScaleUtil.init();
  await EnvConfig.init(Flavor.current);
  final localStorage = await LocalStorage.create();

  final session = SessionCubit();
  final themeCubit = ThemeCubit(localStorage);
  final apiClient = DioApiClient(onSessionExpired: session.clear);

  runApp(
    AppProvider(
      session: session,
      themeCubit: themeCubit,
      apiClient: apiClient,
      localStorage: localStorage,
      child: App(router: createAppRouter(session)),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: Flavor.current.appName,
      debugShowCheckedModeBanner: !Flavor.current.isProd,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: context.watch<ThemeCubit>().state,
      routerConfig: router,
    );
  }
}
