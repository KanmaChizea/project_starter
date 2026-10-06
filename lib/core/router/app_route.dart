import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Every route in the app. [name] is the enum name; [path] is relative for
/// nested routes. Navigate by name: `context.goNamed(AppRoute.home.name)`.
enum AppRoute {
  splash('/splash', isPublic: true),
  login('/login', isPublic: true),
  home('/home'),
  profile('/profile');

  const AppRoute(this.path, {this.isPublic = false});

  final String path;

  final bool isPublic;

  static AppRoute? fromName(String? name) => AppRoute.values.asNameMap()[name];

  GoRoute toGoRoute(
    Widget Function(GoRouterState state) build, {
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      name: name,
      path: path,
      builder: (context, state) => build(state),
      routes: routes,
    );
  }
}
