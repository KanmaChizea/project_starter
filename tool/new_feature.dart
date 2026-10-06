// Scaffolds a feature (data + ui layers) or adds a screen to an existing one.
//
// Usage:
//   dart run tool/new_feature.dart <feature> [--screen <screen>]
//
// Existing files are never overwritten, so this can be re-run to add screens.
import 'dart:io';

final namePattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

void main(List<String> argv) {
  final (feature, screenArg) = _parseArgs(argv);
  final screen = screenArg ?? feature;

  if (!File('pubspec.yaml').existsSync()) _fail('Run this from the project root.');
  for (final name in [feature, screen]) {
    if (!namePattern.hasMatch(name)) {
      _fail('"$name" must be lower_snake_case, e.g. user_profile.');
    }
  }

  final package = RegExp(r'^name: (\S+)', multiLine: true)
      .firstMatch(File('pubspec.yaml').readAsStringSync())?[1];
  if (package == null) _fail('Could not read the package name from pubspec.yaml.');

  final f = _Names(feature);
  final s = _Names(screen);
  final lib = 'lib/features/$feature';
  final isNewFeature = !Directory(lib).existsSync();

  final files = {
    '$lib/data/repositories/${f.snake}_repository.dart': _repository(package, f),
    '$lib/data/services/${f.snake}_service.dart': _service(f),
    '$lib/ui/models/${s.snake}_ui_state.dart': _uiState(s),
    '$lib/ui/views/${s.snake}_view_model.dart': _viewModel(f, s),
    '$lib/ui/views/${s.snake}_view.dart': _view(f, s),
  };

  stdout.writeln(isNewFeature ? 'Creating feature "$feature"' : 'Adding to feature "$feature"');
  for (final MapEntry(key: path, value: content) in files.entries) {
    final file = File(path);
    if (file.existsSync()) {
      stdout.writeln('  skip    $path (exists)');
      continue;
    }
    file
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
    stdout.writeln('  create  $path');
  }

  Process.runSync('dart', ['format', ...files.keys.where((p) => File(p).existsSync())]);

  if (isNewFeature) {
    stdout.writeln('''

Next: register the service in lib/provider.dart (AppProvider → MultiRepositoryProvider):

  import 'package:$package/features/$feature/data/repositories/${f.snake}_repository.dart';
  import 'package:$package/features/$feature/data/services/${f.snake}_service.dart';

  RepositoryProvider(
    create: (_) => ${f.pascal}Service(${f.pascal}Repository(apiClient)),
  ),''');
  }

  stdout.writeln('''

Then make ${s.pascal}View reachable (README → Navigation → Adding a route):
  1. lib/core/router/app_route.dart   add AppRoute.${s.camel}
  2. lib/core/router/shell_router.dart (tab) or auth_router.dart / app_router.dart (full screen):
     AppRoute.${s.camel}.toGoRoute((_) => const ${s.pascal}View())''');
}

// ---------------------------------------------------------------------------
// Templates
// ---------------------------------------------------------------------------

String _repository(String package, _Names f) => '''
import 'package:$package/core/network/api_client.dart';

class ${f.pascal}Repository {
  ${f.pascal}Repository(this._api);

  // ignore: unused_field
  final ApiClient _api;

  // TODO: add data access methods returning Result (README → Networking).
}
''';

String _service(_Names f) => '''
import '../repositories/${f.snake}_repository.dart';

class ${f.pascal}Service {
  ${f.pascal}Service(this._repository);

  // ignore: unused_field
  final ${f.pascal}Repository _repository;

  // TODO: add operations.
}
''';

String _uiState(_Names s) => '''
import 'package:equatable/equatable.dart';

class ${s.pascal}UiState extends Equatable {
  const ${s.pascal}UiState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  @override
  List<Object?> get props => [isLoading, errorMessage];

  ${s.pascal}UiState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return ${s.pascal}UiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
''';

String _viewModel(_Names f, _Names s) => '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/${f.snake}_service.dart';
import '../models/${s.snake}_ui_state.dart';

class ${s.pascal}ViewModel extends Cubit<${s.pascal}UiState> {
  ${s.pascal}ViewModel({required this._${f.camel}Service})
    : super(const ${s.pascal}UiState());

  // ignore: unused_field
  final ${f.pascal}Service _${f.camel}Service;

  // TODO: add actions; change state with emit(state.copyWith(...)).
}
''';

String _view(_Names f, _Names s) => '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/${f.snake}_service.dart';
import '../models/${s.snake}_ui_state.dart';
import '${s.snake}_view_model.dart';

class ${s.pascal}View extends StatelessWidget {
  const ${s.pascal}View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ${s.pascal}ViewModel(
        ${f.camel}Service: context.read<${f.pascal}Service>(),
      ),
      child: const _${s.pascal}Body(),
    );
  }
}

class _${s.pascal}Body extends StatelessWidget {
  const _${s.pascal}Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${s.title}')),
      body: BlocBuilder<${s.pascal}ViewModel, ${s.pascal}UiState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('${s.title}'));
        },
      ),
    );
  }
}
''';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _Names {
  _Names(this.snake) : _parts = snake.split('_');

  final String snake;
  final List<String> _parts;

  String get pascal => _parts.map(_capitalize).join();
  String get camel => _parts.first + _parts.skip(1).map(_capitalize).join();
  String get title => _parts.map(_capitalize).join(' ');

  static String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

(String, String?) _parseArgs(List<String> argv) {
  String? feature;
  String? screen;
  for (var i = 0; i < argv.length; i++) {
    final arg = argv[i];
    if (arg == '-h' || arg == '--help') {
      _usage();
      exit(0);
    } else if (arg == '--screen' || arg == '-s') {
      if (i + 1 >= argv.length) _fail('Missing value for $arg.');
      screen = argv[++i];
    } else if (arg.startsWith('--screen=')) {
      screen = arg.substring('--screen='.length);
    } else if (arg.startsWith('-')) {
      _fail('Unknown option: $arg');
    } else if (feature == null) {
      feature = arg;
    } else {
      _fail('Unexpected argument: $arg');
    }
  }
  if (feature == null || feature.isEmpty) {
    _usage();
    exit(64);
  }
  return (feature, (screen?.isEmpty ?? true) ? null : screen);
}

void _usage() {
  stdout.writeln('''
Scaffold a feature, or add a screen to an existing feature.

  dart run tool/new_feature.dart <feature> [--screen <screen>]

  <feature>   lower_snake_case feature name, e.g. user_profile.
  --screen    Screen to create (default: the feature name). Run again with a
              different --screen to add more screens to the same feature.''');
}

Never _fail(String message) {
  stderr.writeln('✗ $message');
  exit(1);
}
