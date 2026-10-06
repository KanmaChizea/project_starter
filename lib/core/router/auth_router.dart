import 'package:go_router/go_router.dart';
import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/features/auth/ui/views/login_view.dart';
import 'package:project_starter/features/auth/ui/views/splash_view.dart';

import 'app_route.dart';

List<RouteBase> authRoutes() => [
  AppRoute.splash.toGoRoute((_) => const SplashView()),
  AppRoute.login.toGoRoute((_) => const LoginView()),
];

/// - Session not resolved yet: everything waits on the splash.
/// - Splash, once resolved: home (or `from`) if signed in, otherwise login.
/// - Signed out: non-public routes go to login.
/// - Signed in: login goes to home (or `from`).
///
/// The original destination is carried in `?from=` through splash and login,
/// so deep links survive the redirects.
String? authRedirect(SessionCubit session, GoRouterState state) {
  final route = AppRoute.fromName(state.topRoute?.name);
  final location = state.uri.toString();
  final from = state.uri.queryParameters['from'];

  if (!session.isResolved) {
    return route == AppRoute.splash
        ? null
        : _withFrom(AppRoute.splash.path, location);
  }

  if (route == AppRoute.splash) {
    return session.isSignedIn
        ? _safeReturnPath(from) ?? AppRoute.home.path
        : _withFrom(AppRoute.login.path, from);
  }

  if (!session.isSignedIn) {
    if (route?.isPublic ?? false) return null;
    return _withFrom(AppRoute.login.path, location);
  }

  if (route == AppRoute.login) {
    return _safeReturnPath(from) ?? AppRoute.home.path;
  }
  return null;
}

String _withFrom(String path, String? from) {
  final returnPath = _safeReturnPath(from);
  final keep = returnPath != null && returnPath != AppRoute.home.path;
  return Uri(
    path: path,
    queryParameters: keep ? {'from': returnPath} : null,
  ).toString();
}

/// Only in-app paths, and never back to splash or login.
String? _safeReturnPath(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  final path = Uri.tryParse(from)?.path;
  if (path == AppRoute.splash.path || path == AppRoute.login.path) return null;
  return from;
}
