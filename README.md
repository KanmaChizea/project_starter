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
5. Create `env/.env.<flavor>` with every key and add it to the flavor-specific assets in `pubspec.yaml`.

### Environment config

Per-flavor values live in `env/.env.dev`, `env/.env.staging` and `env/.env.prod`:

```
BASE_URL=https://api.dev.example.com
```

`main()` calls `EnvConfig.init(Flavor.current)`, which loads the matching file and fails fast if a required key is missing. Read values through `EnvConfig` (`lib/core/config/env_config.dart`): `EnvConfig.baseUrl`, `EnvConfig.envName`, `EnvConfig.isProd` / `isStaging` / `isDev`.

Each file is declared as a flavor-specific asset in `pubspec.yaml`, so a build only bundles its own flavor's file (a prod build contains no dev or staging URLs).

To add a value: add the key to all three files, then a getter in `EnvConfig` and the key to its required list in `init`.

> Env files are bundled into the app and can be read by anyone with the APK/IPA. Use them for configuration (URLs, feature flags), not secrets.

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
      env_config.dart             # EnvConfig: per-flavor values from env/.env.<flavor>
    constants/
      endpoints.dart              # Endpoints: API paths
    router/
      app_route.dart              # AppRoute enum (name, path, isPublic)
      app_router.dart             # GoRouter: combines route groups, 404, root redirect
      auth_router.dart            # Auth routes (login, …) + auth redirect
      shell_router.dart           # Tab shell (StatefulShellRoute) and its branches
      app_shell.dart              # Bottom navigation bar for the tab branches
      not_found_view.dart
      stream_listenable.dart      # Adapts a Cubit stream to GoRouter.refreshListenable
      navigation.dart             # popUntil / popUntilNamed for go_router
    network/
      api_client.dart             # ApiClient interface: every call returns Result<Response<T>>
      dio_api_client.dart         # DioApiClient: the Dio implementation
      dio_exception_mapper.dart   # Default DioException → AppException mapping (used by the client)
      network_exception.dart      # AppException subclasses: Network / Unauthorized / Server
      auth_interceptor.dart       # Bearer token, 401 → refresh → retry
      auth_tokens.dart            # Access + refresh token pair
      logging_interceptor.dart    # Hooks NetworkLogger into Dio
      network_logger.dart         # NetworkLogger: boxed request/response/error logs via debugPrint
    session/
      session_cubit.dart          # Who is signed in (Cubit<SessionState>); cached user, saves tokens on sign-in
      session_state.dart          # unknown / authenticated / unauthenticated + user
      user.dart                   # User entity
    storage/
      secure_storage.dart         # SecureStorage: Keychain / Keystore wrapper (tokens, cached user)
      local_storage.dart          # LocalStorage: shared_preferences wrapper for non-sensitive values
    utils/
      result.dart                 # Result<T>: Ok / Error(AppException) + map / fold
      app_exception.dart          # AppException(message, statusCode) + Parse / Unknown
      async_value.dart            # AsyncValue<T>: loading / data / error for UI state
  features/
    auth/
      data/
        models/                   # Entities and API request/response models for this feature
        repositories/             # Data access: API/SDK/storage calls; parse responses, return typed models
        services/                 # Business logic on entities; never sees raw JSON
      ui/
        models/                   # UI state, one per screen or flow (LoginUiState)
        views/                    # Views and their view models side by side (login_view, login_view_model)
        widgets/                  # Feature widgets (login_form, auth_text_field, ...)
  main.dart                       # Entry point: creates the session and router, runs App (MaterialApp.router)
  provider.dart                   # AppProvider: app-wide Cubits (BlocProvider) and services (RepositoryProvider)
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
- Parsing and endpoint-specific error handling happen in repositories: they `map` API/storage responses into typed models (entities, or result types like `SignInResult` in `data/models/`), special-case errors where an endpoint needs it, and return a `Result`. If the backend's shape differs from an entity, parse into a response model in `data/models/` and convert it inside the repository. Services and view models never see raw JSON.
- Views talk only to their view model. View models depend on services, never on repositories.
- Exception: a view with no UI state that only triggers a one-off call may call its feature's service directly instead of having a view model (e.g. `SplashView` → `AuthService.restoreSession()`).
- Features never import other features. Anything several features need lives in `core/` (e.g. `core/session`, `core/router`).
- `core/` doesn't import from `features/`, with one exception: the route tables in `core/router/` (`auth_router.dart`, `shell_router.dart`) import feature views to register them.
- Widgets get state and callbacks via constructors; they don't talk to view models.
- One-off effects (navigation, snackbars) go in a `BlocListener` in the view, not in `build`.
- Imports outside the current feature use `package:` imports; relative imports only within a feature.

### Navigation

[go_router](https://pub.dev/packages/go_router), configured in `lib/core/router/`:

- `app_router.dart` creates the `GoRouter` and combines the route groups.
- `auth_router.dart` holds the public auth routes and the auth redirect.
- `shell_router.dart` holds the tab shell; each tab is a branch.

| Route | Path | Notes |
|---|---|---|
| `splash` | `/splash` | Public. Initial route; resolves the session, then leaves. |
| `login` | `/login` | Public. Outside the tab shell. |
| `home` | `/home` | Tab 1 |
| `itemDetail` | `/home/items/:id` | Inside the home tab; `id` must be a positive integer |
| `profile` | `/profile` | Tab 2 |

- **Routes** are declared once in the `AppRoute` enum (`lib/core/router/app_route.dart`): the enum name is the route name, plus its path and whether it is public.
- **Navigate by name** using the enum, never raw path strings:

  ```dart
  context.goNamed(AppRoute.home.name);
  context.pushNamed(AppRoute.itemDetail.name, pathParameters: {'id': '$id'});
  ```

- **Pop until** a page further down the stack (`lib/core/router/navigation.dart`), mirroring `go` / `goNamed`:

  ```dart
  context.popUntilNamed(AppRoute.home.name);   // by route name
  context.popUntil('/home');                   // by location
  ```

  Works inside tabs, from dialogs and with pushed routes, and keeps go_router's location in sync (unlike `Navigator.popUntil`). Does nothing if the target is not in the stack (asserts in debug). If a route on the way has an `onExit` (e.g. an "unsaved changes?" dialog), it stops there; call it again after the user confirms.
- **Tabs** use `StatefulShellRoute.indexedStack`: each tab keeps its own stack and state. Tapping the active tab pops it back to its root.
- **Splash and session restore**: the session starts as `unknown`. Until it is resolved, every location redirects to `/splash` (keeping the original in `?from=`). `SplashView` calls `AuthService.restoreSession()`, which reads the stored access token and asks the repository for its user (see **Session and storage**). Once resolved, the splash redirects to `from` / `/home` if signed in, otherwise to `/login` (still carrying `from`).
- **Auth redirect**: the router refreshes on every `SessionCubit` change (via `StreamListenable`). Signed out, any non-public route goes to `/login?from=<where you were going>`; after sign-in the user lands on `from` (only if it is an in-app path), otherwise `/home`. Signing out from anywhere returns to login. Views never navigate after restore/sign-in/sign-out themselves.
- **Argument protection**: path parameters are constrained in the path pattern (`items/:id([1-9]\d*)`), so a malformed deep link such as `/home/items/abc` never matches and shows the 404 page. Builders can then parse safely. Pass IDs, not objects: `extra` is lost on deep links and app restarts.
- **404**: any unmatched location renders `NotFoundView` with a way back home. `/` redirects to `/home`.

#### Adding a route

1. Add it to `AppRoute` (relative `path` if nested; constrain parameters with a regex).
2. Register it with `AppRoute.x.toGoRoute((state) => XView(...))`: in `shell_router.dart` under the right branch for a tab screen, in `auth_router.dart` for auth screens, or in `app_router.dart` for other full-screen routes.
3. A new tab also needs a `StatefulShellBranch` in `shell_router.dart` and a destination in `app_shell.dart` (same order).

### State management

View models are Cubits from [`flutter_bloc`](https://pub.dev/packages/flutter_bloc): `LoginViewModel extends Cubit<LoginUiState>`.

- UI state classes are immutable, extend `Equatable`, and expose `copyWith`. View models change state only with `emit(state.copyWith(...))`.
- A view creates its own view model with `BlocProvider(create: ...)`, so the view model lives exactly as long as the route.
- App-wide state and services are registered in `AppProvider` (`lib/provider.dart`): Cubits with `BlocProvider`, plain services with `RepositoryProvider`. Services that need the session take it in their constructor.
- `AppProvider.clearAll(context)` resets app-wide state (currently the session). When a service starts holding state (caches, sockets), give it a `reset()` and call it there.
- Views rebuild with `BlocBuilder` / `BlocSelector` and run side effects with `BlocListener`.
- View models are tested with `bloc_test` (`blocTest`), views with widget tests that provide fakes through `RepositoryProvider`.

### Session and storage

Two stores in `lib/core/storage/`, both with typed key enums:

| | `SecureStorage` | `LocalStorage` |
|---|---|---|
| Backed by | [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) (Keychain / Keystore) | [`shared_preferences`](https://pub.dev/packages/shared_preferences) (`SharedPreferencesWithCache`) |
| For | Secrets and personal data | Non-sensitive settings and flags |
| Keys | `SecureStorageKey`: `accessToken`, `refreshToken`, `cachedUser` | `LocalStorageKey`: `hasLaunchedBefore` |
| Reads | async | sync (cache loaded at startup) |
| Available via | `SecureStorage()` (singleton) | `context.read<LocalStorage>()` (provided by `AppProvider`) |

New keys must be added to the enum (`LocalStorage` only loads keys on its allow-list). Secure values that can't be decrypted are deleted and read as `null`.

- `SecureStorage` is a singleton: `SecureStorage()` always returns the same instance, so classes use it directly instead of having it passed in. It keeps an in-memory cache: each key is read from the device once, then served from memory, so attaching the token to every request costs a map lookup. Writes and deletes update the cache, so it can't go stale (unless another isolate writes to secure storage directly). In tests that swap the mocked storage between cases, call `SecureStorage().resetCache()`. Tokens are read and written by `AuthInterceptor` (attach, refresh) and `SessionCubit` (save on sign-in, delete on sign-out).
- `SessionCubit`: `start(user, tokens: ...)` saves the tokens and caches the user, `clear()` deletes everything, from wherever sign-out happens.
- On launch, `AuthService.restoreSession()`:
  - no access token → signed out;
  - `AuthRepository.fetchCurrentUser()` → `Ok(user)` → signed in; `Error(UnauthorizedException)` (refresh also failed) → everything deleted, signed out;
  - any other error (e.g. offline) → signed in as the **cached user**; with no usable cache, shown as signed out but the tokens are kept so the next launch retries.
- **First launch**: `main()` calls `SecureStorage.clearOnFirstLaunch(localStorage)` before `runApp`. iOS deletes preferences on uninstall but keeps Keychain items, so a missing `hasLaunchedBefore` flag means a fresh install and leftover secrets are wiped; a reinstall starts signed out. (If you add this to an app that is already released, existing users are signed out once on update, since they don't have the flag yet.)
- iOS: Keychain items use `KeychainAccessibility.first_unlock`, so they stay readable for background work after the first unlock.
- Android: `android:allowBackup="false"` in `AndroidManifest.xml`. Auto Backup would restore encrypted values onto a device without the key, which can't decrypt them.

### Networking

[Dio](https://pub.dev/packages/dio) behind the `ApiClient` interface (`lib/core/network/api_client.dart`), implemented by `DioApiClient`. Repositories depend on `ApiClient`, so tests can hand them a fake. `DioApiClient` reads `EnvConfig.baseUrl` and enables logging outside prod by itself. `main()` creates the single instance and passes it to `AppProvider`, which hands it to repositories through their constructors (e.g. `AuthRepository(apiClient)`); it is not in the widget tree. Keep it to one instance: concurrent 401s share a refresh only within the same client.

The network layer doesn't know about the session: `DioApiClient` only takes an `onSessionExpired` callback, which `main()` wires to `session.clear`.

**The client returns `Result`; repositories map it.** Every `ApiClient` call returns `Ok(response)` or `Error(AppException)`, already mapped with the HTTP `statusCode` and the server's message. A repository usually just parses the body with `map`, and handles an endpoint-specific error by matching on it before falling back to the default:

```dart
// Default handling: one line.
Future<Result<User>> fetchCurrentUser() async {
  final result = await _api.get<Map<String, Object?>>(Endpoints.me);
  return result.map((response) => User.fromJson(response.data!));
}

// Endpoint-specific handling: match the error first.
Future<Result<SignInResult>> signIn({required String email, required String password}) async {
  final result = await _api.post<Map<String, Object?>>(
    Endpoints.login,
    data: {'email': email, 'password': password},
  );
  return switch (result) {
    Error(error: AppException(statusCode: 401)) =>
      const Result.error(AppException('Invalid email or password.', statusCode: 401)),
    _ => result.map((response) => SignInResult.fromJson(response.data!)),
  };
}
```

- `result.map(transform)` converts the value; if `transform` throws (the body doesn't match the model) the result is a `ParseException`, so a bad response never crashes.
- `result.fold(onError, onOk)` is there when you want `Either`-style branching.

Services and view models never see Dio; they switch on the `Result`:

```dart
// Service / view model: switch on it.
switch (await _authService.signIn(email: email, password: password)) {
  case Ok(:final value): ...
  case Error(:final error): ...   // error.message, error.statusCode
}
```

- `Result.error` always carries an `AppException` (`lib/core/utils/app_exception.dart`): a `message` safe to show the user and a `statusCode` (the HTTP status when there was a response, otherwise `null`). View models can show `error.message` directly.
- `ApiClient`: `get/post/put/patch/delete<T>` (with `query`, `data`), `upload<T>(FormData)` (Dio sets the multipart boundary; optional `onSendProgress` and `method`), `download(path, savePath)`.
- The default mapping (`e.toAppException()` in `lib/core/network/dio_exception_mapper.dart`, applied by the client) produces the network subclasses (`lib/core/network/network_exception.dart`):
  - `NetworkException`: offline, DNS, timeouts.
  - `UnauthorizedException`: 401 on a request that carried a token, after a failed refresh (`statusCode` 401).
  - `ServerException`: any other non-2xx; `message` comes from the body's `message` field.
  - `UnknownException`: anything else.
- `ParseException` (`lib/core/utils/app_exception.dart`): produced by `result.map` when parsing throws.
- For non-network failures (validation, storage, …), return `AppException('message')` or a subclass of it.
- Note: `Error` here is the `Result` subclass and shadows `dart:core`'s `Error` in files that import `result.dart`.
- `AsyncValue<T>` (`lib/core/utils/async_value.dart`) is available for UI state that is simply loading / data / error: convert a `Result` with `AsyncValue.data(value)` / `AsyncValue.error(error.message)` and render with `state.when(...)`.

**Auth.** No per-call flag: the token is attached whenever one is stored, and only to our own API.

- `AuthInterceptor` adds `Authorization: Bearer <accessToken>` from `SecureStorage` when a token exists **and** the request goes to `BASE_URL`'s scheme, host and port. Full URLs to other hosts (presigned S3 uploads/downloads, CDNs, third-party APIs) never get the token. Signed out, there is no token, so login/sign-up/password-reset calls go out without one.
- On a 401 it refreshes once (`POST /auth/refresh` with the refresh token), saves the new tokens and retries the request. Concurrent 401s share a single refresh.
- Refresh rejected (400/401/403) → `onSessionExpired` (clears the session → router goes to login); the request returns `UnauthorizedException`. Refresh failed for other reasons (offline, 5xx) → session kept, request fails.
- Retried uploads re-send a clone of the `FormData` (a sent `FormData` can't be reused).
- Only a request that carried a token triggers a refresh. A 401 without one (e.g. wrong password on login) is a `ServerException` with `statusCode` 401, not a sign-out.

**Logging.** `LoggingInterceptor` passes every request, response and error to `NetworkLogger` (`lib/core/network/network_logger.dart`), which prints boxed blocks (method, URL, query, headers, body / status, data / error type) with `debugPrint`. It only logs in debug builds (`kDebugMode`), and the interceptor is only added outside prod. Bodies are never truncated: long lines are split into 800-character chunks so Android's logcat doesn't cut them off. `Authorization`, `Cookie` and `Set-Cookie` show as `***HIDDEN***`; comment them out of `_sensitiveHeaders` locally if you need to see them. `NetworkLogger.log('...')` is available for ad-hoc messages.

**Adapting to your backend** (marked with `TODO`):

- API hosts: `BASE_URL` in `env/.env.<flavor>`.
- Endpoint paths: `lib/core/constants/endpoints.dart` (`Endpoints`). Add new paths there rather than inline in repositories.
- Refresh request/response body: `AuthInterceptor._refresh()` and `AuthTokens.fromJson`.
- Error message field: `serverMessage` in `dio_exception_mapper.dart`.
- Auth payloads and error statuses: `AuthRepository` (`lib/features/auth/data/repositories/auth_repository.dart`).

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
```

For a new feature it prints the line to register its service in `lib/provider.dart`. Add `data/models/` and `ui/widgets/` when the feature needs them, and put its tests under `test/features/<feature>/`, mirroring `lib/`.

In VS Code: **Tasks: Run Task → New feature / screen**.
