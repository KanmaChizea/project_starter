import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_starter/core/config/flavor.dart';
import 'package:project_starter/core/router/app_router.dart';
import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/provider.dart';

void main() {
  final session = SessionCubit();

  runApp(
    AppProvider(
      session: session,
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
