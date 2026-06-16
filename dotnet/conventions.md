# .NET + C# Conventions

## Decision Protocol

When a technology choice, library, or architectural decision is not explicitly defined in the project, **ask the user before assuming**. The question should be asked at the appropriate lifecycle phase:

- **Analysis phase:** App type (Web API / MAUI / Blazor / WPF), target .NET version, **architecture style** (Clean Architecture / Vertical Slice Architecture — asked during Kickoff, confirmed in Design).
- **Design phase:** API style (Controllers / Minimal API / FastEndpoints), state management, caching strategy.
- **Implementation phase:** Mapping library (manual vs AutoMapper vs Mapster), logging library (native vs Serilog), testing framework (xUnit vs NUnit), mocking library (Moq vs NSubstitute), OpenAPI UI (Scalar vs SwaggerUI).

**Default choices** (used when the user does not specify):
- Logging: `Microsoft.Extensions.Logging` (native).
- Mapping: manual mapping (extension methods / record projections).
- Serialization: `System.Text.Json`.
- OpenAPI: `Microsoft.AspNetCore.OpenApi` (built-in .NET 10+), or `FastEndpoints.Swagger` if using FastEndpoints.

## Project Structure (Clean Architecture)

```
src/
├── Core/                              ← Domain + Application (pure C#, no framework deps)
│   ├── Domain/
│   │   ├── Entities/                  ← Business entities
│   │   ├── ValueObjects/              ← Immutable value types
│   │   ├── Interfaces/                ← Repository & service contracts
│   │   └── Exceptions/                ← Domain-specific exceptions
│   └── Application/
│       ├── UseCases/                  ← Application business rules
│       ├── DTOs/                      ← Data transfer objects
│       ├── Interfaces/                ← Application service contracts
│       └── Mappings/                  ← Entity ↔ DTO mappings
├── Infrastructure/                    ← Data access, external services
│   ├── Persistence/                   ← EF Core DbContext, migrations
│   ├── Repositories/                  ← Repository implementations
│   └── Services/                      ← External API clients, email, etc.
├── Presentation/                      ← UI / API layer
│   ├── Controllers/                   ← API controllers (if Controllers style)
│   ├── Endpoints/                     ← Static endpoint classes (if Minimal API)
│   ├── Features/                      ← Vertical slices (if FastEndpoints)
│   │   └── <Feature>/
│   │       ├── <Action>Endpoint.cs
│   │       ├── <Action>Request.cs
│   │       ├── <Action>Response.cs
│   │       └── <Action>Validator.cs
│   ├── ViewModels/                    ← MVVM ViewModels (if MAUI/WPF)
│   ├── Views/                         ← XAML views (if MAUI/WPF)
│   └── Pages/                         ← Razor/Blazor pages (if web)
└── Host/                              ← Entry point, DI composition root
    ├── Program.cs
    └── appsettings.json
tests/
├── Domain.Tests/
├── Application.Tests/
├── Infrastructure.Tests/
└── Presentation.Tests/
```

## Project Structure (Vertical Slice Architecture)

```
src/
├── Features/                          ← Each feature is a self-contained vertical slice
│   └── <FeatureName>/
│       ├── <Action>/                  ← One subfolder per operation (CQRS-friendly)
│       │   ├── <Action>Endpoint.cs    ← Endpoint definition (FastEndpoints or Minimal API)
│       │   ├── <Action>Handler.cs     ← Use case / business logic
│       │   ├── <Action>Request.cs     ← Input DTO
│       │   ├── <Action>Response.cs    ← Output DTO
│       │   ├── <Action>Validator.cs   ← FluentValidation rules
│       │   └── <Action>Mapper.cs      ← Optional: Request → Entity mapping
│       └── <Feature>Data.cs           ← Feature-scoped data access (if needed)
├── Shared/                            ← Cross-cutting concerns shared across slices
│   ├── Kernel/                        ← Shared types, base classes, common contracts
│   │   ├── Entities/                  ← Shared domain types (only when truly cross-slice)
│   │   └── Interfaces/               ← Shared contracts (e.g., IDateTime, IEmailSender)
│   ├── Persistence/                   ← DbContext, migrations (shared infra)
│   ├── Middleware/                    ← Global middleware (auth, logging, exception handling)
│   └── Extensions/                    ← DI registration extensions, common helpers
├── Contracts/                         ← Cross-slice communication contracts
│   ├── Events/                        ← Integration events (e.g., OrderPlacedEvent)
│   └── Services/                      ← Cross-slice service interfaces (when needed)
└── Host/                              ← Entry point, DI composition root
    ├── Program.cs                     ← Registers all slices and shared services
    └── appsettings.json
tests/
├── <FeatureName>.Tests/               ← One test project per feature slice
│   ├── <Action>EndpointTests.cs
│   ├── <Action>HandlerTests.cs
│   └── <Action>ValidatorTests.cs
└── Shared.Tests/                      ← Tests for shared kernel
```

### VSA Key Rules

- **Each slice owns its full vertical stack.** No splitting a feature across horizontal layers in different folders.
- **Slices do not reference each other directly.** Cross-slice communication goes through `Contracts/` (events or service interfaces).
- **Shared kernel is minimal.** Only types that are genuinely shared across multiple slices belong in `Shared/Kernel/`. When in doubt, keep it in the slice.
- **Data access per slice.** Each slice defines its own data access (e.g., a handler uses DbContext directly or through a thin slice-scoped repository). Do not create a global `Infrastructure/Repositories/` layer.
- **Slices are independently testable.** Each slice's tests run without requiring other slices to be loaded.

## Decoupling Rules for .NET

### Clean Architecture
- **Domain/** must contain only pure C#. No framework references (no ASP.NET, no EF Core, no MAUI).
- **Application/** depends only on **Domain/**. No infrastructure or presentation imports.
- **Infrastructure/** implements interfaces defined in **Domain/** and **Application/**. Never imports from **Presentation/**.
- **Presentation/** depends on **Application/** only through use cases or ViewModels. Never imports from **Infrastructure/** directly.
- **Host/** is the composition root — wires DI, configuration, and middleware. Only place that references all layers.

### Vertical Slice Architecture
- **Each slice is self-contained.** A slice must not import another slice's handler, endpoint, or internal types.
- **Cross-slice communication through Contracts/.** Use integration events (`Contracts/Events/`) or defined service interfaces (`Contracts/Services/`). Never call another slice's handler directly.
- **Shared/ is for infrastructure, not business logic.** Persistence, middleware, and DI extensions are shared. Business rules stay in slices.
- **Host/ is the composition root.** Registers all slices via extension methods (e.g., `builder.Services.AddOrdersFeature()`), wires middleware, and configures the pipeline.
- **Slices are independently deployable in principle.** Even if deployed as a monolith, the architecture allows extracting a slice into a separate service later.

## SOLID in .NET

These principles apply to both architectures. The unit of application differs:

- **Clean Architecture unit:** a layer or class.
- **Vertical Slice Architecture unit:** a feature slice.

- **S:** Clean Architecture — each class has one responsibility; Use cases orchestrate, don't implement. VSA — each slice handles one feature; a handler doesn't manage unrelated operations.
- **O:** Clean Architecture — new features create new classes implementing existing interfaces. VSA — new features create new slices; existing slices are not modified for unrelated behavior.
- **L:** Clean Architecture — any `IRepository<T>` implementation must honor the contract. VSA — any slice implementing a cross-slice contract must honor it.
- **I:** Clean Architecture — split `IUserService` into `IUserQueryService` and `IUserCommandService`. VSA — cross-slice interfaces are narrow; a slice exposes only what other slices need.
- **D:** Clean Architecture — Domain and Application define interfaces; Infrastructure provides implementations. VSA — slices depend on `Contracts/` abstractions, not on other slices' concretions.

## Design Patterns in .NET

### Clean Architecture Patterns
- **Repository:** Generic `IRepository<T>` in Domain with entity-specific extensions. Implemented in Infrastructure with EF Core.
- **Use Case / Interactor:** One class per operation in `Application/UseCases/`. Receives interfaces via constructor injection.
- **Dependency Injection:** `Microsoft.Extensions.DependencyInjection`. All registration in `Host/Program.cs` composition root.
- **Mediator (optional):** `Mediator.Net` for CQRS-style command/query/event separation with pipeline middleware support. Install: `Mediator.Net` + `Mediator.Net.MicrosoftDependencyInjection`. Docs: <https://github.com/mayuanyang/Mediator.Net>
- **Factory:** For complex entity creation or when the creation strategy varies (e.g., different payment processors).
- **Strategy:** For interchangeable algorithms (e.g., pricing rules, notification channels). Define interface in Domain, implement in Infrastructure.
- **Adapter:** Wrap external APIs (payment gateways, cloud services) behind interfaces defined in Application.
- **Specification (optional):** For complex query filters in Domain without coupling to EF Core.
- **Criteria (optional):** For complex query filters in domain without coupling to EF Core.

### Vertical Slice Architecture Patterns
- **Handler per operation:** Each action (CreateOrder, GetOrder, CancelOrder) is a self-contained handler class in its own subfolder.
- **FastEndpoints (recommended for VSA):** Each endpoint is a self-contained class inheriting `Endpoint<TRequest, TResponse>`. Auto-discovered, no manual route registration. Built-in FluentValidation via `Validator<TRequest>`.
- **CQRS (optional but natural in VSA):** Separate command and query handlers. Commands mutate, queries return data. Mediator pattern optional — handlers can be resolved directly from DI.
- **Integration Events:** Cross-slice communication via events (`Contracts/Events/`). Use `Mediator.Net` or a lightweight event dispatcher.
- **Feature-scoped data access:** Handlers use DbContext directly or through a thin slice-scoped query/command object. Avoid a global repository layer.
- **Slice registration extensions:** Each slice exposes `Add<FeatureName>Feature()` and `Map<FeatureName>Endpoints()` extension methods for clean composition in `Program.cs`.

## API Styles

The Presentation layer for Web APIs can follow one of three styles. The choice is made in the Design phase — ask the user if not defined.

### Controllers (traditional MVC)
- One controller per feature/resource in `Presentation/Controllers/`.
- Routes via `[Route]` and `[Http*]` attributes.
- Good for large teams familiar with MVC conventions.

### Minimal API
- One static class per feature in `Presentation/Endpoints/`.
- Routes grouped via `MapGroup("api/<feature>")` with static handler methods.
- Dependencies injected as method parameters.
- Register endpoint groups in `Program.cs`: `app.Map<Feature>Endpoints();`

### FastEndpoints (recommended for API-heavy projects)
- Vertical slice: each endpoint in its own folder under `Presentation/Features/<Feature>/`.
- Each folder contains: `Endpoint.cs`, `Request.cs`, `Response.cs`, `Validator.cs`, `Mapper.cs` (optional).
- Endpoints inherit `Endpoint<TRequest, TResponse>`, override `Configure()` + `HandleAsync()`.
- Auto-discovered — no manual route registration.
- Built-in FluentValidation via `Validator<TRequest>`.
- Install: `FastEndpoints` NuGet package. Setup: `bld.Services.AddFastEndpoints()` + `app.UseFastEndpoints()`.
- Swagger: install `FastEndpoints.Swagger` package. Setup: `bld.Services.SwaggerDocument()` + `app.UseSwaggerGen()` (after `UseFastEndpoints()`).
- Docs: https://fast-endpoints.com/docs/get-started

## Application Patterns

- **Web API**: ASP.NET Core — Controllers, Minimal API, or FastEndpoints.
- **Mobile**: .NET MAUI with MVVM (CommunityToolkit.Mvvm).
- **Desktop**: WPF or WinUI with MVVM.
- **Blazor**: Server or WASM with component-based UI.

## Naming Conventions

- Files: `PascalCase.cs`
- Classes/Interfaces: `PascalCase` (`IUserRepository`, `UserEntity`)
- Methods: `PascalCase` (`GetUserAsync`)
- Variables/parameters: `camelCase`
- Private fields: `_camelCase`
- Constants: `PascalCase`
- Projects: `<SolutionName>.<Layer>` (e.g., `MyApp.Domain`, `MyApp.Infrastructure`)
- Test files: `<ClassName>Tests.cs`

## Dependency Injection

- Register all services in `Host/Program.cs` (composition root).
- Use `Microsoft.Extensions.DependencyInjection`.
- Domain and Application layers define interfaces; Infrastructure provides implementations.
- Presentation receives dependencies through constructor injection only.

## Testing

### Clean Architecture
- Unit tests for **Domain/** entities and value objects (no mocking needed, pure C#).
- Unit tests for **Application/** use cases (mock repositories with `Moq` or `NSubstitute`).
- Integration tests for **Infrastructure/** (use `TestContainers` or in-memory database).
- UI tests for **Presentation/** (mock Application layer services).

### Vertical Slice Architecture
- Unit tests for each slice's **handler** (mock external dependencies, use in-memory or test doubles for data access).
- Integration tests for each slice's **endpoint** (test the full slice stack: endpoint → handler → data access, using `WebApplicationFactory` or `TestContainers`).
- Contract tests for **cross-slice contracts** (verify that slices honor their published event schemas and service interfaces).
- Slice isolation tests: each slice's test suite runs independently without loading other slices.

## Common Packages

| Purpose              | Package                                    | Notes                          |
|----------------------|--------------------------------------------|--------------------------------|
| ORM                  | `Microsoft.EntityFrameworkCore`             | Primary data access           |
| DI                   | `Microsoft.Extensions.DependencyInjection`  | Built-in                      |
| Mapping              | `AutoMapper`, `Mapster`                     | **Lowest priority** — only if user explicitly requests. Prefer manual mapping or record projections. |
| Validation           | `FluentValidation`                         | Application layer             |
| MVVM                 | `CommunityToolkit.Mvvm`                    | For MAUI/WPF                  |
| HTTP client          | `HttpClient`, `Refit`                      | `HttpClient` > `Refit`        |
| Testing              | `xUnit`, `NUnit`                           | Ask user preference           |
| Mocking              | `Moq`, `NSubstitute`                       | Ask user preference           |
| Logging              | `Microsoft.Extensions.Logging`             | Built-in, default. Use `Serilog` only if explicitly requested. |
| API docs             | `Microsoft.AspNetCore.OpenApi`             | Built-in .NET 10+. Use `Scalar.AspNetCore` or similar for UI (ask user). |
| API docs (FE)        | `FastEndpoints.Swagger`                    | NSwag-based. Provides `SwaggerDocument()` + `UseSwaggerGen()`. |
| API framework        | `FastEndpoints`                            | Vertical slice, auto-discovery|
| Serialization        | `System.Text.Json`                         | Built-in, preferred           |

## Package Version Selection

- Use the **latest stable version** of any NuGet package when adding it to the project.
- If the latest stable version causes a dependency conflict (version mismatch with an already-referenced package's transitive constraints), fall back to the **closest compatible version** — the highest patch/minor release that satisfies all existing constraints.
- Re-evaluate pinned packages on each major project update to move back toward latest stable when conflict no longer exists.
