import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:project_starter/core/config/flavor.dart';
import 'package:project_starter/core/session/session_service.dart';
import 'package:project_starter/features/auth/data/repositories/auth_repository.dart';
import 'package:project_starter/features/auth/data/services/auth_service.dart';
import 'package:project_starter/features/auth/ui/views/login_view.dart';
import 'package:project_starter/features/home/data/repositories/home_repository.dart';
import 'package:project_starter/features/home/data/services/home_service.dart';

void main() {
  final session = SessionService();
  final authService = AuthService(FakeAuthRepository(), session);

  runApp(
    // App-wide dependencies. View models are created per route by their views.
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: session),
        RepositoryProvider.value(value: authService),
        RepositoryProvider(create: (_) => HomeService(HomeRepository())),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Flavor.current.appName,
      debugShowCheckedModeBanner: !Flavor.current.isProd,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const LoginView(),
    );
  }
}
