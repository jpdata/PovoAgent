# .NET + C# Conventions

## Decision Protocol

When a technology choice, library, or architectural decision is not explicitly defined in the project, **ask the user before assuming**. The question should be asked at the appropriate lifecycle phase:

- **Analysis phase:** App type (Web API / MAUI / Blazor / WPF), target .NET version.
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

## Decoupling Rules for .NET

- **Domain/** must contain only pure C#. No framework references (no ASP.NET, no EF Core, no MAUI).
- **Application/** depends only on **Domain/**. No infrastructure or presentation imports.
- **Infrastructure/** implements interfaces defined in **Domain/** and **Application/**. Never imports from **Presentation/**.
- **Presentation/** depends on **Application/** only through use cases or ViewModels. Never imports from **Infrastructure/** directly.
- **Host/** is the composition root — wires DI, configuration, and middleware. Only place that references all layers.

## SOLID in .NET

- **S:** Each class has one responsibility. `UserService` doesn't send emails — delegate to `IEmailService`. Use cases orchestrate, don't implement.
- **O:** New features create new classes implementing existing interfaces. Never modify a working use case to add unrelated behavior.
- **L:** Any `IRepository<T>` implementation must honor the contract. `InMemoryUserRepository` and `SqlUserRepository` are interchangeable.
- **I:** Split `IUserService` into `IUserQueryService` and `IUserCommandService` if consumers don't need both. No method bloat.
- **D:** Domain and Application define interfaces (`IUserRepository`, `IEmailService`). Infrastructure provides `SqlUserRepository`, `SmtpEmailService`. Wired in `Host/Program.cs`.

## Design Patterns in .NET

- **Repository:** Generic `IRepository<T>` in Domain with entity-specific extensions. Implemented in Infrastructure with EF Core.
- **Use Case / Interactor:** One class per operation in `Application/UseCases/`. Receives interfaces via constructor injection.
- **Dependency Injection:** `Microsoft.Extensions.DependencyInjection`. All registration in `Host/Program.cs` composition root.
- **Mediator (optional):** `Mediator.Net` for CQRS-style command/query/event separation with pipeline middleware support. Install: `Mediator.Net` + `Mediator.Net.MicrosoftDependencyInjection`. Docs: <https://github.com/mayuanyang/Mediator.Net>
- **Factory:** For complex entity creation or when the creation strategy varies (e.g., different payment processors).
- **Strategy:** For interchangeable algorithms (e.g., pricing rules, notification channels). Define interface in Domain, implement in Infrastructure.
- **Adapter:** Wrap external APIs (payment gateways, cloud services) behind interfaces defined in Application.
- **Specification (optional):** For complex query filters in Domain without coupling to EF Core.
- **Criteria (optional):** For complex query filters in domain without coupling to EF Core.

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

- Unit tests for **Domain/** entities and value objects (no mocking needed, pure C#).
- Unit tests for **Application/** use cases (mock repositories with `Moq` or `NSubstitute`).
- Integration tests for **Infrastructure/** (use `TestContainers` or in-memory database).
- UI tests for **Presentation/** (mock Application layer services).

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
