// Renames the app: display name, application/bundle ID and (optionally) the
// Dart package name, across Android, iOS and Dart.
//
// Usage:
//   dart run tool/rename.dart --name "My App" --id com.acme.myapp [--package my_app]
//
// Flavor suffixes (" Dev", " Staging") are appended automatically; prod has none.
import 'dart:io';

const flavorSuffixes = {'dev': ' Dev', 'staging': ' Staging', 'prod': ''};

const gradlePath = 'android/app/build.gradle.kts';
const pbxprojPath = 'ios/Runner.xcodeproj/project.pbxproj';
const infoPlistPath = 'ios/Runner/Info.plist';
const flavorDartPath = 'lib/core/config/flavor.dart';
const kotlinRoot = 'android/app/src/main/kotlin';

final idPattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)+$');
final packagePattern = RegExp(r'^[a-z][a-z0-9_]*$');

void main(List<String> argv) {
  final args = _parseArgs(argv);
  final name = args['name'];
  final id = args['id'];
  final package = args['package'];

  if (args.containsKey('help') || (name == null && id == null && package == null)) {
    _usage();
    exit(args.containsKey('help') ? 0 : 64);
  }
  if (!File('pubspec.yaml').existsSync()) {
    _fail('Run this from the project root.');
  }
  if (id != null && !idPattern.hasMatch(id)) {
    _fail('--id must be reverse-DNS with letters/digits only, e.g. com.acme.myapp '
        '(no "_" or "-": they are not valid on both Android and iOS).');
  }
  if (package != null && !packagePattern.hasMatch(package)) {
    _fail('--package must be lower_snake_case, e.g. my_app.');
  }

  if (name != null) _renameApp(name.trim());
  if (id != null) _changeId(id);
  if (package != null) _renamePackage(package);

  stdout.writeln('\nDone. Run `flutter clean && flutter pub get` before the next build.');
}

// ---------------------------------------------------------------------------
// Display name
// ---------------------------------------------------------------------------

void _renameApp(String name) {
  // Android: resValue("string", "app_name", "...") inside each create("<flavor>") block.
  _edit(gradlePath, (s) => s.replaceAllMapped(
        RegExp(r'(create\("(\w+)"\)\s*\{[^}]*?resValue\("string", "app_name", ")(?:[^"\\]|\\.)*(")'),
        (m) => '${m[1]}${_kotlinString(_androidResource(_flavored(name, m[2]!)))}${m[3]}',
      ));

  // iOS: APP_DISPLAY_NAME inside each <Config>-<flavor> build configuration.
  _edit(pbxprojPath, (s) => s.replaceAllMapped(
        RegExp(r'/\* \w+-(\w+) \*/ = \{\s*isa = XCBuildConfiguration;.*?\n\t\t\};', dotAll: true),
        (m) => m[0]!.replaceAllMapped(
          RegExp(r'APP_DISPLAY_NAME = (?:"(?:[^"\\]|\\.)*"|[^;]*);'),
          (_) => 'APP_DISPLAY_NAME = "${_pbxString(_flavored(name, m[1]!))}";',
        ),
      ));

  // Dart: Flavor enum values, e.g. dev('My App Dev').
  _edit(flavorDartPath, (s) => s.replaceAllMapped(
        RegExp(r"^(\s*)(\w+)\('(?:[^'\\]|\\.)*'\)", multiLine: true),
        (m) => flavorSuffixes.containsKey(m[2])
            ? "${m[1]}${m[2]}('${_dartString(_flavored(name, m[2]!))}')"
            : m[0]!,
      ));

  stdout.writeln('✓ App name → "$name" (+ flavor suffixes)');
}

String _flavored(String name, String flavor) {
  final suffix = flavorSuffixes[flavor];
  if (suffix == null) _fail('Unknown flavor "$flavor" — update flavorSuffixes in tool/rename.dart.');
  return '$name$suffix';
}

// ---------------------------------------------------------------------------
// Application ID / bundle identifier
// ---------------------------------------------------------------------------

void _changeId(String id) {
  // Android
  final gradle = File(gradlePath).readAsStringSync();
  final oldNamespace = RegExp(r'namespace = "([^"]+)"').firstMatch(gradle)?[1];
  if (oldNamespace == null) _fail('Could not find namespace in $gradlePath.');

  _edit(gradlePath, (s) => s
      .replaceFirst(RegExp(r'namespace = "[^"]+"'), 'namespace = "$id"')
      .replaceFirst(RegExp(r'applicationId = "[^"]+"'), 'applicationId = "$id"'));
  _moveKotlinPackage(oldNamespace, id);

  // iOS: Runner gets the ID, RunnerTests gets <id>.RunnerTests.
  _edit(pbxprojPath, (s) => s.replaceAllMapped(
        RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = "?([^;"]+)"?;'),
        (m) => m[1]!.endsWith('.RunnerTests')
            ? 'PRODUCT_BUNDLE_IDENTIFIER = $id.RunnerTests;'
            : 'PRODUCT_BUNDLE_IDENTIFIER = $id;',
      ));

  stdout.writeln('✓ Application/bundle ID → $id (Android + iOS)');
}

void _moveKotlinPackage(String oldPackage, String newPackage) {
  if (oldPackage == newPackage) return;
  final oldDir = Directory('$kotlinRoot/${oldPackage.replaceAll('.', '/')}');
  final newDir = Directory('$kotlinRoot/${newPackage.replaceAll('.', '/')}');
  if (!oldDir.existsSync()) _fail('Expected Kotlin sources at ${oldDir.path}.');

  newDir.createSync(recursive: true);
  for (final entity in oldDir.listSync()) {
    if (entity is! File) continue;
    final target = File('${newDir.path}/${entity.uri.pathSegments.last}');
    target.writeAsStringSync(entity
        .readAsStringSync()
        .replaceFirst(RegExp('^package ${RegExp.escape(oldPackage)}\$', multiLine: true), 'package $newPackage'));
    entity.deleteSync();
  }
  _deleteEmptyParents(oldDir, Directory(kotlinRoot));
}

void _deleteEmptyParents(Directory dir, Directory stopAt) {
  var current = dir;
  while (current.absolute.path != stopAt.absolute.path &&
      current.existsSync() &&
      current.listSync().isEmpty) {
    current.deleteSync();
    current = current.parent;
  }
}

// ---------------------------------------------------------------------------
// Dart package name
// ---------------------------------------------------------------------------

void _renamePackage(String package) {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final old = RegExp(r'^name: (\S+)', multiLine: true).firstMatch(pubspec)?[1];
  if (old == null) _fail('Could not find name in pubspec.yaml.');
  if (old == package) return;

  _edit('pubspec.yaml', (s) => s.replaceFirst(RegExp(r'^name: \S+', multiLine: true), 'name: $package'));

  for (final dir in ['lib', 'test', 'integration_test', 'tool']) {
    if (!Directory(dir).existsSync()) continue;
    for (final f in Directory(dir).listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      _edit(f.path, (s) => s.replaceAll('package:$old/', 'package:$package/'), quiet: true);
    }
  }

  _edit(infoPlistPath, (s) => s.replaceFirstMapped(
        RegExp(r'(<key>CFBundleName</key>\s*<string>)[^<]*(</string>)'),
        (m) => '${m[1]}$package${m[2]}',
      ));

  // IntelliJ / Android Studio module files.
  _renameFile('$old.iml', '$package.iml');
  _renameFile('android/${old}_android.iml', 'android/${package}_android.iml');
  if (File('.idea/modules.xml').existsSync()) {
    _edit('.idea/modules.xml', (s) => s.replaceAll('$old.iml', '$package.iml').replaceAll('${old}_android.iml', '${package}_android.iml'));
  }

  stdout.writeln('✓ Dart package → $package');
}

void _renameFile(String from, String to) {
  final f = File(from);
  if (f.existsSync()) f.renameSync(to);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void _edit(String path, String Function(String) transform, {bool quiet = false}) {
  final file = File(path);
  if (!file.existsSync()) _fail('Missing $path.');
  final before = file.readAsStringSync();
  final after = transform(before);
  if (after != before) {
    file.writeAsStringSync(after);
    if (!quiet) stdout.writeln('  updated $path');
  }
}

/// Android string resources treat \, ' and " specially.
String _androidResource(String s) =>
    s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll('"', r'\"');

/// Contents of a Kotlin "..." literal.
String _kotlinString(String s) =>
    s.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll(r'$', r'\$');

/// Contents of a quoted pbxproj value.
String _pbxString(String s) => s.replaceAll(r'\', r'\\').replaceAll('"', r'\"');

/// Contents of a Dart '...' literal.
String _dartString(String s) =>
    s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$');

Map<String, String> _parseArgs(List<String> argv) {
  final result = <String, String>{};
  for (var i = 0; i < argv.length; i++) {
    final arg = argv[i];
    if (arg == '-h' || arg == '--help') {
      result['help'] = '';
    } else if (arg.startsWith('--')) {
      final eq = arg.indexOf('=');
      if (eq != -1) {
        result[arg.substring(2, eq)] = arg.substring(eq + 1);
      } else if (i + 1 < argv.length) {
        result[arg.substring(2)] = argv[++i];
      } else {
        _fail('Missing value for $arg.');
      }
    } else {
      _fail('Unexpected argument: $arg');
    }
  }
  // Blank values mean "leave unchanged" (lets the VS Code task skip a field).
  result.removeWhere((key, value) => key != 'help' && value.trim().isEmpty);
  final unknown = result.keys.toSet().difference({'name', 'id', 'package', 'help'});
  if (unknown.isNotEmpty) _fail('Unknown option(s): ${unknown.map((k) => '--$k').join(', ')}');
  return result;
}

void _usage() {
  stdout.writeln('''
Rename the app across Android, iOS and Dart.

  dart run tool/rename.dart --name "My App" --id com.acme.myapp [--package my_app]

Options (any combination, at least one; blank values are ignored):
  --name      Base display name. Flavor suffixes are added: "My App Dev", "My App Staging", "My App" (prod).
  --id        Application ID (Android) and bundle identifier (iOS). Same value on both platforms.
  --package   Dart package name in pubspec.yaml (updates package: imports).''');
}

Never _fail(String message) {
  stderr.writeln('✗ $message');
  exit(1);
}
