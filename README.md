# project_starter

A Flutter boilerplate for mobile apps (iOS + Android).

## Requirements

- Flutter 3.44+ (Dart 3.12+)
- Xcode (for iOS) and Android SDK (for Android)

## Starting a new app from this template

Rename the app before anything else:

```sh
dart run tool/rename.dart --name "My App" --id com.acme.myapp --package my_app
flutter clean && flutter pub get
```

| Option | What it changes |
|---|---|
| `--name` | Display name on both platforms and in `Flavor`. Flavor suffixes are added automatically: `My App Dev`, `My App Staging`, and plain `My App` for prod. |
| `--id` | Android `applicationId` + `namespace` (and moves `MainActivity.kt` to the new package), iOS `PRODUCT_BUNDLE_IDENTIFIER` (`RunnerTests` becomes `<id>.RunnerTests`). |
| `--package` | Dart package name in `pubspec.yaml`, all `package:` imports, iOS `CFBundleName`, and the IntelliJ `.iml` files. |

All options are optional — pass only what you want to change. The script can be re-run any time.

The ID is shared by Android and iOS, so it may only contain letters and digits separated by dots (`com.acme.myapp`); `_` and `-` are rejected because each is invalid on one of the platforms.

In VS Code you can run the same thing via **Tasks: Run Task → Rename app** (leave a prompt blank to keep the current value).

> After changing the ID, update anything registered against the old one: Firebase/Google config files, Apple Developer / App Store Connect, Play Console, OAuth redirect URIs, etc.

## Flavors

| Flavor | App name | App/bundle ID |
|---|---|---|
| `dev` (default) | `<Name> Dev` | same for all flavors |
| `staging` | `<Name> Staging` | same for all flavors |
| `prod` | `<Name>` | same for all flavors |

All flavors share one application/bundle ID (to simplify third-party integrations), so **only one flavor can be installed on a device at a time**.

In Dart, the current flavor is available as `Flavor.current` (`lib/core/config/flavor.dart`), resolved from Flutter's `appFlavor`. No `--dart-define` is needed.

Where flavors are configured:

- **Android** — `productFlavors` in `android/app/build.gradle.kts` (app name via `resValue`).
- **iOS** — build configurations `{Debug,Release,Profile}-{dev,staging,prod}` and schemes `dev` / `staging` / `prod` in `ios/Runner.xcodeproj`. The app name comes from the `APP_DISPLAY_NAME` build setting. In Xcode, pick a flavor scheme (there is no `Runner` scheme).
- **Default flavor** — `default-flavor: dev` in `pubspec.yaml`, so a plain `flutter run` uses `dev`.

### Adding a flavor

1. Add a `create("<flavor>")` block to `android/app/build.gradle.kts`.
2. In Xcode, duplicate the `Debug`/`Release`/`Profile` configurations as `*-<flavor>` (set `APP_DISPLAY_NAME`), and duplicate a scheme named `<flavor>` using them.
3. Add the value to the `Flavor` enum.
4. Add its suffix (or `''` for none) to `flavorSuffixes` in `tool/rename.dart`, and to `.vscode/launch.json` / `tasks.json`.

## Running

```sh
flutter run                          # dev
flutter run --flavor staging
flutter run --flavor prod --release
```

In VS Code, pick a configuration in **Run and Debug** (`Dev (debug)`, `Staging (profile)`, `Prod (release)`, …).

## Building

```sh
flutter build apk       --flavor <flavor> --release
flutter build appbundle --flavor <flavor> --release
flutter build ipa       --flavor <flavor> --release
```

Outputs land in `build/app/outputs/` (Android) and `build/ios/ipa/` (iOS).

In VS Code: **Tasks: Run Task** (or `Cmd+Shift+B`) → `Build: Android APK`, `Build: Android App Bundle`, `Build: iOS IPA`, `Build: iOS (no codesign)`, or `Build: All platforms`. Each asks for the flavor and build mode.

> Android release builds are currently signed with the debug key. Configure a release `signingConfig` before publishing.

## Project structure

```
lib/
  core/
    config/
      flavor.dart     # Flavor enum + Flavor.current
  main.dart
tool/
  rename.dart         # App name / ID / package rename script
.vscode/
  launch.json         # Run configurations per flavor and mode
  tasks.json          # Build and rename tasks
```
