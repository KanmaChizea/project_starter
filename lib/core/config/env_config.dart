import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'flavor.dart';

/// Per-flavor configuration, loaded from `env/.env.<flavor>`.
class EnvConfig {
  static late final Flavor _flavor;

  static const _baseUrlKey = 'BASE_URL';

  static Future<void> init(Flavor flavor) async {
    _flavor = flavor;
    await dotenv.load(fileName: 'env/.env.${flavor.name}');
    for (final key in [_baseUrlKey]) {
      if (dotenv.maybeGet(key)?.isNotEmpty != true) {
        throw StateError('$key is missing from env/.env.${flavor.name}');
      }
    }
  }

  static Flavor get flavor => _flavor;
  static String get envName => _flavor.name;
  static String get baseUrl => dotenv.get(_baseUrlKey);

  static bool get isProd => _flavor == Flavor.prod;
  static bool get isStaging => _flavor == Flavor.staging;
  static bool get isDev => _flavor == Flavor.dev;
}
