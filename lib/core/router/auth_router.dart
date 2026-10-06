import 'package:go_router/go_router.dart';
import 'app_route.dart';
import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/features/auth/ui/views/login_view.dart';

List<RouteBase> authRoutes() => [
  AppRoute.login.toGoRoute((_) => const LoginView()),
];

/// Signed out: everything except public routes goes to login, remembering
/// where the user was headed in `?from=`. Signed in: login goes to `from`
/// (if it is a safe in-app path) or home.
String? authRedirect(SessionCubit session, GoRouterState state) {
  final route = AppRoute.fromName(state.topRoute?.name);
  final isPublic = route?.isPublic ?? false;

  if (!session.isSignedIn) {
    if (isPublic) return null;
    final from = state.uri.toString();
    return Uri(
      path: AppRoute.login.path,
      queryParameters: from == AppRoute.home.path ? null : {'from': from},
    ).toString();
  }

  if (route == AppRoute.login) {
    return _safeReturnPath(state.uri.queryParameters['from']) ??
        AppRoute.home.path;
  }
  return null;
}

String? _safeReturnPath(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  if (Uri.tryParse(from)?.path == AppRoute.login.path) return null;
  return from;
}
