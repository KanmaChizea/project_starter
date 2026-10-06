import 'package:flutter/services.dart';

enum Flavor {
  dev('Project Starter Dev'),
  staging('Project Starter Staging'),
  prod('Project Starter');

  const Flavor(this.appName);

  final String appName;

  bool get isProd => this == Flavor.prod;

  static final Flavor current = Flavor.values.firstWhere(
    (f) => f.name == appFlavor,
    orElse: () => throw StateError('Unknown flavor: $appFlavor'),
  );
}
