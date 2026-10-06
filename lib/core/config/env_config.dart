import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'flavor.dart';

/// Per-flavor configuration, loaded from `env/.env.<flavor>`.
class EnvConfig {
  static const _baseUrlKey = 'BASE_URL';

  static Future<void> init(Flavor flavor) async {
    await dotenv.load(fileName: 'env/.env.${flavor.name}');
    for (final key in [_baseUrlKey]) {
      if (dotenv.maybeGet(key)?.isNotEmpty != true) {
        throw StateError('$key is missing from env/.env.${flavor.name}');
      }
    }
  }

  static String get baseUrl => dotenv.get(_baseUrlKey);
}
