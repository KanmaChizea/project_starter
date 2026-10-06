import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension GoRouterPopUntil on BuildContext {
  void popUntil(String location) =>
      _popUntil((match) => match.matchedLocation == location, location);

  void popUntilNamed(String name) =>
      _popUntil((match) => match.route.name == name, name);

  void _popUntil(bool Function(RouteMatch match) isTarget, String target) {
    final router = GoRouter.of(this);
    final delegate = router.routerDelegate;

    final inStack = _leaves(
      delegate.currentConfiguration.matches,
    ).any(isTarget);
    assert(inStack, 'popUntil: $target is not in the current stack.');
    if (!inStack) return;

    while (router.canPop()) {
      final before = delegate.currentConfiguration;
      final top = before.last;
      if (isTarget(top)) return;

      router.pop();

      final pendingOnExit =
          top.route.onExit != null &&
          identical(delegate.currentConfiguration, before);
      if (pendingOnExit) return;
    }
  }
}

Iterable<RouteMatch> _leaves(List<RouteMatchBase> matches) sync* {
  for (final match in matches) {
    switch (match) {
      case ShellRouteMatch():
        yield* _leaves(match.matches);
      case RouteMatch():
        yield match;
    }
  }
}
