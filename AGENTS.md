# AGENTS.md

## Project Context

This is a **template project** intended to establish a consistent structure, architecture, and development approach for Flutter applications.

The primary goal is to provide a clean, practical starting point for new features and projects. Prefer simple, maintainable solutions over unnecessary abstraction or complexity.

## Architecture

The project follows a **feature-first MVVM architecture**.

Organize code primarily by feature rather than by technical layer.

Example:

```text
lib/
├── core/
│   ├── ...
│
├── features/
│   ├── authentication/
│   │   ├── ui/
│   │   ├── data/
│   │   └── ...
│   │
│   └── payments/
│       ├── ui/
│       ├── data/
│       └── ...
```

Follow the established project structure when adding new features. Do not introduce a new architectural pattern or significantly restructure the project without a clear reason.

### MVVM

* **View**: Responsible for rendering UI and handling presentation concerns.
* **ViewModel**: Owns UI state and coordinates actions required by the view.
* **Repository**: Handles communication with external data sources such as APIs or platform services.
* **Service**: Acts as the source of truth for application data and handles data management.
* **Domain/use-case layers**: Optional. Introduce them only when business logic is sufficiently complex or reused across multiple ViewModels. Do not create use cases solely to wrap a repository call.

Avoid adding abstractions unless they provide a clear benefit.

## Testing

This is a **template project**, not a production application.

Do **not** add unit, widget, integration, or other automated tests unless explicitly requested.

The purpose of this project is to demonstrate and establish project structure and architecture. Spending time writing tests for template/example implementations is unnecessary unless the test itself is specifically being used to demonstrate an architectural pattern.

## Documentation

**Always update the README when making changes that affect the project structure, architecture, setup, conventions, or usage.**

The README should remain an accurate representation of how the template is intended to be used.

When introducing a new architectural pattern, dependency, convention, or significant structural change, update the relevant README section as part of the same change.

Do not leave documentation updates as a separate follow-up task.

## Comments

Keep comments to a minimum.

Prefer clear naming and straightforward code over comments that explain obvious implementation details.

Add comments only when they provide meaningful context, such as:

* Explaining complex or non-obvious logic.
* Explaining why an unusual implementation is necessary.
* Documenting methods or arguments whose purpose or behavior cannot be easily deduced from their names and types.

Avoid comments that simply restate what the code is already doing.

Bad:

```dart
// Get the user
final user = await repository.getUser();
```

Good:

```dart
// The API returns the balance in the account's settlement currency,
// so conversion is required before displaying it in the selected currency.
final balance = convertBalance(response.balance);
```

## General Guidelines

* Prefer readability and simplicity over cleverness.
* Follow existing project conventions before introducing new ones.
* Keep features self-contained within their feature directory.
* Avoid unnecessary dependencies.
* Avoid premature abstractions.
* Reuse existing components, utilities, and patterns where appropriate.
* Keep the architecture practical; the goal is to provide a useful template, not to demonstrate every possible architectural pattern.
* When making architectural decisions, optimize for maintainability and ease of understanding by developers using this template.
* Keep the project in a state where another developer can use it as a starting point without needing to remove unnecessary example code or infrastructure first.
* Always use package imports for imports outside the feature