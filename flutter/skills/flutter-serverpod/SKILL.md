---
name: flutter-serverpod
description: 'Build a full-stack Dart backend with Serverpod for a Flutter app. Use when adding a backend to a Flutter project, creating a Serverpod server, defining models (.spy.yaml) and endpoints, generating client code, integrating the generated client into the Flutter data layer, or writing Serverpod tests. Serverpod is an opt-in backend sub-option of the Flutter pattern (single language: Dart across app and server).'
argument-hint: 'Server, model, endpoint, or feature name'
---

# Flutter + Serverpod (Full-Stack Dart)

> **Status:** Opt-in backend sub-option of the Flutter pattern. Serverpod is
> offered at kickoff/design as a backend choice: **Serverpod (Dart full-stack)**
> vs **external REST/GraphQL API** vs **no backend**. It is only enabled when
> the user explicitly selects it.

Serverpod (https://docs.serverpod.dev/) is an open-source, full-stack backend
framework for Dart. It gives Flutter developers a single-language environment:
models, endpoints, and database access on the server, plus a generated Dart
client that the Flutter app consumes — all in Dart, no hand-written
serialization.

## 1. Prerequisites

- Flutter SDK installed and healthy (`flutter doctor`).
- Docker — each project ships its own `docker-compose.yaml` for a local
  PostgreSQL instance.
- Recommended: the Serverpod VS Code extension (`serverpod.serverpod`) and
  Serverpod Insights for logs/health metrics.

## 2. Install the CLI

```bash
dart pub global activate serverpod_cli
serverpod          # verify: shows the CLI help
```

## 3. Create the project (single command)

```bash
serverpod create <project_name>   # name must be a valid Dart package name (snake_case)
```

Creates a Dart **pub workspace** at the root:

```
<project_name>/
├── <project_name>_server/   # Server-side code (endpoints, models, config)
├── <project_name>_client/   # Client package (generated + manual code)
├── <project_name>_flutter/  # Flutter app, pre-configured to talk to the server
└── pubspec.yaml             # Dart pub workspaces — `dart pub get` at root fetches all
```

> Always open the **root** directory of the workspace in the IDE so the analyzer
> stays in sync after code generation.

## 4. Run locally

```bash
# 1. Start PostgreSQL (from the server directory)
cd <project_name>_server
docker compose up -d

# 2. Start the server (first run applies migrations; safe to repeat in dev)
dart run bin/main.dart --apply-migrations
# Server: http://localhost:8080  |  Web server: http://localhost:8082

# 3. Run the Flutter app
cd ../<project_name>_flutter
flutter run -d chrome
```

## 5. Backend structure (three options)

Serverpod allows **any directory structure** under the server's `lib/src/`.
Ask the user which one they want for the backend in the Design phase. All three
keep generated code under `lib/src/generated/`.

### 5.1 Idiomatic Serverpod (default)

Group by responsibility, Serverpod-style:

```
<project>_server/lib/src/
├── endpoints/       # one file per endpoint (class extends Endpoint)
├── models/          # .spy.yaml model definitions
└── generated/       # generated code (protocol.dart, models) — DO NOT EDIT
```

### 5.2 Clean Architecture (layer-first)

Mirror the Flutter app's layer separation inside the server:

```
<project>_server/lib/src/
├── domain/          # pure Dart entities + repository interfaces (no Serverpod/DB imports)
├── data/            # data sources + repository implementations (uses Session/DB)
├── presentation/    # endpoints (thin: validate + delegate to domain/data)
└── generated/       # generated code — DO NOT EDIT
```

- Endpoints are the "presentation" entry point; business rules stay in `domain/`.
- `domain/` must not import `serverpod` or generated protocol types.

### 5.3 Vertical Slice Architecture (feature-first)

```
<project>_server/lib/src/
├── features/
│   └── <feature>/
│       ├── <feature>_endpoint.dart   # Endpoint for this slice
│       ├── <feature>.spy.yaml        # Model(s) for this slice
│       └── <feature>_repository.dart # Data access for this slice
└── generated/       # generated code — DO NOT EDIT
```

- Each feature is self-contained; no cross-feature imports.
- Cross-slice communication through shared kernel types or events.

## 6. Models

Model definitions live in `.spy.yaml` files anywhere under the server's `lib/`:

```yaml
# <project>_server/lib/src/models/recipe.spy.yaml
class: Recipe
table: recipes
fields:
  author: String
  text: String
  date: DateTime
  ingredients: String
```

- Use primitive Dart types, other models, or typed `List`/`Map`/`Set`.
- Add the `table:` keyword to map a model to a database table (enables ORM).

Generate code after adding or changing a model:

```bash
cd <project>_server
serverpod generate
```

This produces `lib/src/generated/recipe.dart` and updates the client package.
Use generated models on the server via:

```dart
import 'package:<project>_server/src/generated/protocol.dart';
```

When a model change affects the database schema, also create a migration:

```bash
serverpod create-migration
```

## 7. Endpoints

```dart
// <project>_server/lib/src/endpoints/recipe_endpoint.dart
import 'package:serverpod/serverpod.dart';
import 'package:<project>_server/src/generated/protocol.dart';

class RecipeEndpoint extends Endpoint {
  Future<Recipe> createRecipe(Session session, Recipe recipe) async {
    return Recipe.db.insertRow(session, recipe); // returns the row with id set
  }

  Future<List<Recipe>> listRecipes(Session session) async {
    return Recipe.db.find(
      session,
      orderBy: (t) => t.date,
      orderDescending: true,
    );
  }
}
```

Rules:

- The first parameter must be `Session session`.
- Methods return a typed `Future<T>` or `Stream<T>` where `T` is `void`, `bool`,
  `int`, `double`, `String`, `UuidValue`, `Duration`, `DateTime`, `ByteData`,
  `Uri`, `BigInt`, or a serializable model. Parameters accept serializable types,
  including typed `List`, `Map`, `Set`, and Dart records.
- Keep server code **stateless**: no global/static state; each method does a
  sub-second unit of work and returns data/status (or a `Stream` for progress).
- After adding an endpoint, run `serverpod generate` to create bindings and
  client code.

## 8. Client integration (Flutter data layer)

The generated client is consumed from the Flutter app's **data layer** behind a
repository, keeping the existing Clean Architecture / VSA rules intact. The
domain layer stays pure Dart; map generated model types to domain entities at
the repository boundary (or use them directly if the project chooses to share
them).

```dart
// app/lib/core/api/serverpod_client.dart
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:<project>_client/<project>_client.dart';

const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
final serverUrl = serverUrlFromEnv.isEmpty
    ? 'http://$localhost:8080/'
    : serverUrlFromEnv;

final client = Client(serverUrl)
  ..connectivityMonitor = FlutterConnectivityMonitor();
```

```dart
// app/lib/data/datasources/recipe_remote_source.dart
import 'package:<project>_client/<project>_client.dart';

class RecipeRemoteSource {
  final Client client;
  RecipeRemoteSource(this.client);

  Future<List<Recipe>> getRecipes() => client.recipe.listRecipes();
  Future<Recipe> createRecipe(Recipe recipe) => client.recipe.createRecipe(recipe);
}
```

- Wire `client` and the data source as Riverpod `Provider`s (see the
  `flutter-riverpod-viewmodel` skill); repositories, use cases, and ViewModels
  are unchanged.
- Never call `client.*` directly from widgets or ViewModels — always behind the
  repository.
- On a physical device, pass the computer's LAN IP via
  `flutter run --dart-define=SERVER_URL=...`.

## 9. Testing

Server tests live in `<project>_server/test/` and run with `serverpod test`:

```dart
import 'package:serverpod_test/serverpod_test.dart';

void main() {
  withServerpod('given recipe endpoint when create then persists',
      (session, endpoints) async {
    final created = await endpoints.recipe.createRecipe(session, /* ... */);
    expect(created.author, '...');
  });
}
```

- `serverpod test` spins up a test database and server.
- Test endpoints, models, and database access; assert serialization round-trips.
- Flutter-side repository tests mock the generated client (see the
  `flutter-testing` skill).

## 10. Checklist

- [ ] Backend structure chosen (idiomatic / CA / VSA) and documented in Design.
- [ ] `serverpod create` workspace opened at the root directory.
- [ ] `serverpod generate` run after every model/endpoint change.
- [ ] `serverpod create-migration` run after any schema-affecting model change.
- [ ] Endpoints: first param `Session`, typed `Future`/`Stream`, stateless.
- [ ] `generated/` directory never hand-edited.
- [ ] Client consumed only behind the repository in the Flutter data layer.
- [ ] Server tests use `withServerpod`; `serverpod test` runs green.

## Reference

- https://docs.serverpod.dev/
- Follow `flutter/conventions.md` and the `flutter-riverpod-viewmodel` skill for
  the Flutter side.
