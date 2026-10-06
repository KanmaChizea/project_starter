import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Every route in the app. [name] is the enum name; [path] is relative for
/// nested routes. Navigate with the [AppNavigation] helpers, not raw strings.
enum AppRoute {
  login('/login', isPublic: true),
  home('/home'),
  itemDetail(r'items/:id([1-9]\d*)'),
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
