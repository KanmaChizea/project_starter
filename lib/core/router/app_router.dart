import 'package:go_router/go_router.dart';
import 'app_route.dart';
import 'package:project_starter/core/session/session_cubit.dart';

import 'auth_router.dart';
import 'not_found_view.dart';
import 'shell_router.dart';
import 'stream_listenable.dart';

GoRouter createAppRouter(SessionCubit session) {
  return GoRouter(
    initialLocation: AppRoute.home.path,
    refreshListenable: StreamListenable(session.stream),
    redirect: (context, state) => authRedirect(session, state),
    errorBuilder: (context, state) => const NotFoundView(),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => AppRoute.home.path),
      ...authRoutes(),
      shellRoute(),
    ],
  );
}
