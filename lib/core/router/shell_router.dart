import 'package:go_router/go_router.dart';
import 'app_route.dart';
import 'package:project_starter/features/home/ui/views/home_view.dart';
import 'package:project_starter/features/profile/ui/views/profile_view.dart';

import 'app_shell.dart';

RouteBase shellRoute() => StatefulShellRoute.indexedStack(
  builder: (context, state, shell) => AppShell(navigationShell: shell),
  branches: [
    StatefulShellBranch(
      routes: [AppRoute.home.toGoRoute((_) => const HomeView())],
    ),
    StatefulShellBranch(
      routes: [AppRoute.profile.toGoRoute((_) => const ProfileView())],
    ),
  ],
);
