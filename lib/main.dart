import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_starter/core/config/flavor.dart';
import 'package:project_starter/core/router/app_router.dart';
import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/core/storage/local_storage.dart';
import 'package:project_starter/core/storage/secure_storage.dart';
import 'package:project_starter/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorage = await LocalStorage.create();
  final secureStorage = SecureStorage();
  await secureStorage.clearOnFirstLaunch(localStorage);

  final session = SessionCubit(secureStorage);

  runApp(
    AppProvider(
      session: session,
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
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: router,
    );
  }
}
