---
name: flutter-dart-frog
description: 'Build a lightweight Dart REST backend with Dart Frog for a Flutter app. Use when adding a backend to a Flutter project, creating a Dart Frog API, defining route handlers and middleware, configuring dependency injection with provider, integrating the REST API into the Flutter data layer, or writing Dart Frog tests. Dart Frog is an opt-in backend sub-option of the Flutter pattern (single language: Dart across app and API).'
argument-hint: 'API, route, handler, middleware, or feature name'
---

# Flutter + Dart Frog (Single-Language REST Backend)

> **Status:** Opt-in backend sub-option of the Flutter pattern. Dart Frog is
> offered at kickoff/design as a backend choice alongside Serverpod: **Serverpod
> (Dart full-stack with codegen/ORM)** vs **Dart Frog (lightweight Dart REST
> API)** vs **external REST/GraphQL API** vs **no backend**. A project picks one
> backend — Serverpod and Dart Frog are mutually exclusive alternatives.

Dart Frog (https://dart-frog.dev/) is a lightweight backend framework for Dart,
built on top of `shelf`. It gives Flutter developers a single-language
environment with file-system routing, middleware, and dependency injection —
without code generation or an ORM. The Flutter app consumes it over HTTP.

## 1. Prerequisites

- Dart SDK `>=3.0.0 <4.0.0` (and Flutter, since the app is Flutter).
- Recommended: the Dart Frog VS Code extension (`DartFrog.dart-frog-dev`).

## 2. Install the CLI

```bash
dart pub global activate dart_frog_cli
dart_frog          # verify: shows the CLI help
```

## 3. Create the project (sibling projects)

Dart Frog has no full-stack template, so create two sibling projects:

```bash
flutter create <name>_app    # Flutter app
dart_frog create <name>_api  # Dart Frog API
```

```
<name>/
├── <name>_app/   # Flutter app
└── <name>_api/   # Dart Frog backend
    ├── routes/   # file-system routes (one .dart file per endpoint)
    ├── lib/      # models, services, shared code (codegen must live under lib/)
    └── pubspec.yaml
```

## 4. Run locally

```bash
cd <name>_api
dart_frog dev          # hot reload; defaults to http://localhost:8080
```

- `--port`, `--host`, `--dart-vm-service-port` customize the dev server.
- Production build (includes a `Dockerfile`): `dart_frog build`.

## 5. Backend structure (three options)

Dart Frog routes map 1:1 to files under `routes/`. Ask the user which structure
they want for the backend in the Design phase.

### 5.1 Idiomatic Dart Frog (default)

Feature-first routes + shared `lib/` for models/services:

```
<name>_api/
├── routes/
│   ├── index.dart            # GET /
│   └── users/
│       ├── index.dart        # /users
│       └── [id].dart         # /users/:id
└── lib/
    └── models/
```

### 5.2 Clean Architecture (layer-first)

Business logic in layers; `routes/` becomes a thin presentation entry:

```
<name>_api/
├── lib/
│   ├── domain/          # pure Dart entities + repository interfaces (no shelf/dart_frog imports)
│   └── data/            # data sources + repository implementations (uses providers/DB)
└── routes/              # presentation: thin handlers that delegate to domain/data
```

### 5.3 Vertical Slice Architecture (feature-first)

Each feature owns its route, logic, and data:

```
<name>_api/
├── routes/
│   └── <feature>/
│       ├── index.dart          # route handler for this slice
│       └── [id].dart
└── lib/
    └── features/
        └── <feature>/
            ├── <feature>_service.dart
            └── <feature>_repository.dart
```

## 6. Routes

A route is an `onRequest` function exported from a `.dart` file in `routes/`.
`index.dart` maps to `/`.

```dart
// routes/hello.dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Hello World');
}
```

- Dynamic routes: `routes/posts/[id].dart` → `/posts/:id`;
  the handler receives the parameter:
  ```dart
  Response onRequest(RequestContext context, String id) {
    return Response(body: 'post id: $id');
  }
  ```
- Wildcard routes: `routes/posts/[...page].dart`.
- Create a route via CLI: `dart_frog new route "/hello"`.
- Route conflicts and rogue routes fail `dart_frog build`.

## 7. Requests & Responses

```dart
Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method.value;              // GET / POST / ...
  final params = request.uri.queryParameters;       // query string
  final body = await request.body();                // raw String (read once)
  final json = await request.json();                // Map<String, dynamic> (Content-Type: application/json)

  return Response.json(
    body: {'method': method, 'received': json},
    statusCode: 201,
    headers: {'x-custom': 'value'},
  );
}
```

- Handlers may be sync (`Response`) or async (`Future<Response>`).
- `Response.json` serializes any object with a `toJson() → Map<String, dynamic>`
  (use `json_serializable`; generated code must live under `lib/`).

## 8. Middleware & Dependency Injection

Dependencies are provided via `provider<T>` middleware and read with
`context.read<T>()`:

```dart
// middleware — provide a value
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(provider<String>((context) => 'Hello World'));
}
```

```dart
// route handler — consume it
Response onRequest(RequestContext context) {
  final greeting = context.read<String>();
  return Response(body: greeting);
}
```

- Async values: `provider<Future<T>>(...)` then `await context.read<Future<T>>()`.
- Providers are lazy and cached when you store the value in a captured variable.
- **Order matters:** dependencies resolve bottom-to-top — declare dependent
  providers *before* the providers they depend on (e.g. `handler.use(car())..use(wheel())`
  resolves `Car` first, then `Wheel`).
- Dart Frog is database-agnostic — inject a database client (e.g. `postgres`,
  `drift`) through a `provider`.

## 9. Client integration (Flutter data layer)

The Flutter app calls the REST API from the **data layer** behind a repository,
keeping the existing Clean Architecture / VSA rules intact. `domain/` stays
pure Dart; never call HTTP directly from widgets or ViewModels.

```dart
// app/lib/data/datasources/users_remote_source.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsersRemoteSource {
  final http.Client client;
  final String baseUrl;
  UsersRemoteSource(this.client, {this.baseUrl = 'http://localhost:8080'});

  Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await client.get(Uri.parse('$baseUrl/users'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load users: ${res.statusCode}');
    }
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }
}
```

- Use `http` or `dio` (per `flutter/conventions.md`: `http` > `dio`).
- Wire the base URL via `--dart-define=API_URL=...` with a localhost default.

## 10. Testing

Route handlers and middleware are plain Dart functions — test them with
`package:test` and `package:mocktail`:

```dart
// test/routes/hello_test.dart
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../../routes/hello.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  test('GET /hello responds 200 with greeting', () async {
    final context = _MockRequestContext();
    final response = route.onRequest(context);
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body(), completion(equals('Hello World')));
  });
}
```

- Stub injected dependencies: `when(() => context.read<String>()).thenReturn('x')`.
- Test middleware by applying it to a dummy handler and asserting the provided value.

## 11. Checklist

- [ ] Backend structure chosen (idiomatic / CA / VSA) and documented in Design.
- [ ] Sibling projects created: `<name>_app/` (Flutter) + `<name>_api/` (Dart Frog).
- [ ] Routes under `routes/`; `index.dart` for `/`; dynamic params via `[id].dart`.
- [ ] Handlers: `Response`/`Future<Response> onRequest(RequestContext context, ...)`.
- [ ] DI via `provider<T>` + `context.read<T>()`; provider order correct (bottom-to-top).
- [ ] Flutter app calls the API only behind repositories (`http`/`dio`).
- [ ] `dart_frog build` passes (no route conflicts/rogue routes).
- [ ] Route handlers and middleware tested with `package:test` + `mocktail`.

## Reference

- https://dart-frog.dev/
- Follow `flutter/conventions.md` and the `flutter-riverpod-viewmodel` skill for
  the Flutter side.
