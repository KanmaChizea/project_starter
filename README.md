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

Feature-first MVVM with a **data** and **ui** layer per feature. Each feature lives in `lib/features/<feature>/`; app-wide code lives in `lib/core/`.

```
lib/
  core/
    config/
      flavor.dart                 # Flavor enum + Flavor.current
    session/
      session_service.dart        # Who is signed in; ChangeNotifier the whole app can listen to
      user.dart                   # User entity
  features/
    auth/
      data/
        models/                   # Entities and API request/response models for this feature
        repositories/             # Data access: API/SDK/storage calls, return transport data
        services/                 # Business logic; map repository data to entities
      ui/
        models/                   # UI state, one per screen or flow (LoginUiState)
        views/                    # Views and their view models side by side (login_view, login_view_model)
        widgets/                  # Feature widgets (login_form, auth_text_field, ...)
  main.dart                       # Composition root: app-wide dependencies via RepositoryProvider
test/                             # Mirrors lib/
tool/
  rename.dart                     # App name / ID / package rename script
  new_feature.dart                # Feature / screen scaffolding
.vscode/
  launch.json                     # Run configurations per flavor and mode
  tasks.json                      # Build, rename and scaffolding tasks
```

### Dependency direction

```
view → view model → service → repository
  ↓         ↓           ↓
widgets  ui model    core/session
```

- `ui/` may import from `data/`; `data/` never imports from `ui/`.
- Views talk only to their view model. View models depend on services, never on repositories.
- Features never import other features. Anything several features need lives in `core/` (e.g. `core/session`).
- Widgets get state and callbacks via constructors; they don't talk to view models.
- One-off effects (navigation, snackbars) go in a `BlocListener` in the view, not in `build`.
- Imports outside the current feature use `package:` imports; relative imports only within a feature.

### State management

View models are Cubits from [`flutter_bloc`](https://pub.dev/packages/flutter_bloc): `LoginViewModel extends Cubit<LoginUiState>`.

- UI state classes are immutable, extend `Equatable`, and expose `copyWith`. View models change state only with `emit(state.copyWith(...))`.
- A view creates its own view model with `BlocProvider(create: ...)`, so the view model lives exactly as long as the route.
- App-wide services are provided once in `main.dart` with `RepositoryProvider` and read with `context.read<T>()`.
- Views rebuild with `BlocBuilder` / `BlocSelector` and run side effects with `BlocListener`.
- View models are tested with `bloc_test` (`blocTest`), views with widget tests that provide fakes through `RepositoryProvider`.

### Naming

Folders stay flat; the file name prefix shows ownership:

- `<screen>_view.dart`, `<screen>_view_model.dart`, `<screen>_ui_state.dart` — one screen.
- Multi-step flows (e.g. sign-up) share **one** view model and UI state across their views: `signup_view_model.dart`, `signup_ui_state.dart`, `signup_account_view.dart`, `signup_verify_view.dart`, …
- `<screen>_*.dart` widgets belong to one screen; `<feature>_*.dart` widgets are shared across the feature.

If a feature's `views/` gets crowded (15+ files), group by flow: `ui/views/signup/`.

### Adding a feature

```sh
dart run tool/new_feature.dart user_profile                         # new feature, screen = user_profile
dart run tool/new_feature.dart user_profile --screen edit_profile   # add a screen to it
```

Creates (never overwrites existing files):

```
lib/features/user_profile/
  data/repositories/user_profile_repository.dart
  data/services/user_profile_service.dart
  ui/models/edit_profile_ui_state.dart
  ui/views/edit_profile_view.dart
  ui/views/edit_profile_view_model.dart
test/features/user_profile/ui/views/edit_profile_view_model_test.dart
```

For a new feature it prints the line to register its service in `main.dart`. Add `data/models/` and `ui/widgets/` when the feature needs them.

In VS Code: **Tasks: Run Task → New feature / screen**.
