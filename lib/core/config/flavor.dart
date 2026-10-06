import 'package:flutter/services.dart';

/// Build environment, selected with `flutter run --flavor <name>`.
enum Flavor {
  dev('Project Starter Dev'),
  staging('Project Starter Staging'),
  prod('Project Starter');

  const Flavor(this.appName);

  final String appName;

  bool get isProd => this == Flavor.prod;

  /// Resolved from the native flavor the app was built with.
  static final Flavor current = Flavor.values.firstWhere(
    (f) => f.name == appFlavor,
    orElse: () => throw StateError('Unknown flavor: $appFlavor'),
  );
}
