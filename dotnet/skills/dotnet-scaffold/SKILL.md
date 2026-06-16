---
name: dotnet-scaffold
description: 'Scaffold a new .NET project with Clean Architecture or Vertical Slice Architecture structure. Use when creating a new .NET solution, initializing project structure, setting up layers or slices, configuring DI, or bootstrapping a C# project from scratch.'
argument-hint: 'Project name, type (Web API / MAUI / Blazor) and main features'
---

# .NET Project Scaffolding

## When to Use
- Creating a new .NET application from scratch.
- Setting up the initial solution structure following Clean Architecture or Vertical Slice Architecture (as chosen in the Design phase).

## Pre-Scaffold Questions

Ask the user **before starting** if any of these are undefined:
- Architecture style: Clean Architecture or Vertical Slice Architecture? If not decided, refer to the kickoff diagnostic questions.

## Procedure

### Clean Architecture Path

1. **Create the solution and projects**
   ```bash
   dotnet new sln -n <SolutionName>
   dotnet new classlib -n <SolutionName>.Domain
   dotnet new classlib -n <SolutionName>.Application
   dotnet new classlib -n <SolutionName>.Infrastructure
   # Choose Presentation based on app type and API style:
   dotnet new web -n <SolutionName>.Presentation         # Minimal API or FastEndpoints
   dotnet new webapi -n <SolutionName>.Presentation      # Controllers
   dotnet new maui -n <SolutionName>.Presentation        # MAUI
   dotnet new blazorserver -n <SolutionName>.Presentation # Blazor
   ```
   For FastEndpoints, use `dotnet new web` (empty web project) and add packages:
   ```bash
   dotnet add <SolutionName>.Presentation package FastEndpoints
   dotnet add <SolutionName>.Presentation package FastEndpoints.Swagger
   ```

2. **Add projects to solution and set references**
   ```
   Application → Domain
   Infrastructure → Domain, Application
   Presentation → Application (NEVER Infrastructure directly)
   Host/Presentation → all (composition root only)
   ```

3. **Set up folder structure per project**
   ```
   Domain/
   ├── Entities/
   ├── ValueObjects/
   ├── Interfaces/
   └── Exceptions/
   Application/
   ├── UseCases/
   ├── DTOs/
   ├── Interfaces/
   └── Mappings/
   Infrastructure/
   ├── Persistence/
   ├── Repositories/
   └── Services/
   ```

4. **Add core NuGet packages**
   - `Microsoft.EntityFrameworkCore` (Infrastructure)
   - `FluentValidation` (Application)
   - `Microsoft.Extensions.Logging` (built-in — default for all projects). Only add `Serilog` if the user explicitly requests it.
   - **OpenAPI / Swagger** (Presentation, if Web API):
     - Controllers or Minimal API → `Microsoft.AspNetCore.OpenApi` (built-in in .NET 10) + `Scalar.AspNetCore` for UI (or ask user preference)
     - FastEndpoints → `FastEndpoints.Swagger` (NSwag-based, provides `SwaggerDocument()` + `UseSwaggerGen()`)
   - `FastEndpoints` (Presentation, if using FastEndpoints)
   - Mapping (`AutoMapper` or `Mapster`) — **only if the user explicitly requests it**. Prefer manual mapping or record projections by default.

   > **Ask the user** during implementation for any package not listed above that the feature requires.

5. **Create base files**
   - `Domain/Interfaces/IRepository.cs` — Generic repository interface
   - `Application/Interfaces/IUnitOfWork.cs` — Unit of work contract
   - `Infrastructure/Persistence/AppDbContext.cs` — EF Core context
   - `Host/Program.cs` — DI registration (composition root)

6. **Create test projects**
   ```bash
   dotnet new xunit -n <SolutionName>.Domain.Tests
   dotnet new xunit -n <SolutionName>.Application.Tests
   dotnet new xunit -n <SolutionName>.Infrastructure.Tests
   dotnet new xunit -n <SolutionName>.Presentation.Tests
   ```

7. **Verify**
   - Run `dotnet build` — no errors.
   - Verify `Domain` project has zero framework package references.
   - Verify `Application` references only `Domain`.

### Vertical Slice Architecture Path

1. **Create the solution and host project**
   ```bash
   dotnet new sln -n <SolutionName>
   dotnet new web -n <SolutionName>.Host
   ```

2. **Set up VSA folder structure in the Host project**
   ```
   <SolutionName>.Host/
   ├── Features/
   │   └── <FeatureName>/
   │       ├── <Action>/
   │       │   ├── <Action>Endpoint.cs
   │       │   ├── <Action>Handler.cs
   │       │   ├── <Action>Request.cs
   │       │   ├── <Action>Response.cs
   │       │   └── <Action>Validator.cs
   │       └── <FeatureName>Feature.cs     ← DI registration extension
   ├── Shared/
   │   ├── Kernel/
   │   │   ├── Entities/                   ← Shared domain types (minimal)
   │   │   └── Interfaces/                 ← Shared contracts
   │   ├── Persistence/
   │   │   └── AppDbContext.cs
   │   ├── Middleware/
   │   └── Extensions/
   ├── Contracts/
   │   └── Events/                         ← Integration events
   ├── Program.cs
   └── appsettings.json
   ```

3. **Add core NuGet packages**
   - `Microsoft.EntityFrameworkCore` (Shared/Persistence)
   - `FastEndpoints` (for endpoint auto-discovery)
   - `FastEndpoints.Swagger` (for API docs)
   - `FluentValidation`
   - `Microsoft.Extensions.Logging` (built-in)

4. **Create base files**
   - `Shared/Kernel/Interfaces/IDateTime.cs` — Shared contracts
   - `Shared/Persistence/AppDbContext.cs` — EF Core context
   - `Contracts/Events/` — Empty folder, add events as slices need them
   - `Program.cs` — DI registration, FastEndpoints setup, middleware

5. **Register slices in Program.cs**
   ```csharp
   var bld = WebApplication.CreateBuilder(args);
   bld.Services.AddFastEndpoints();
   bld.Services.AddDbContext<AppDbContext>(...);
   // Each slice registers itself:
   bld.Services.AddOrdersFeature();
   bld.Services.AddProductsFeature();
   
   var app = bld.Build();
   app.UseFastEndpoints();
   app.Run();
   ```

6. **Create test projects**
   ```bash
   dotnet new xunit -n <SolutionName>.Orders.Tests
   dotnet new xunit -n <SolutionName>.Products.Tests
   dotnet new xunit -n <SolutionName>.Shared.Tests
   ```
   - One test project per feature slice.

7. **Verify**
   - Run `dotnet build` — no errors.
   - Verify no slice imports another slice's handler or endpoint.
   - Verify `Shared/` contains only infrastructure, not business logic.

## Decoupling Validation

### Clean Architecture
- `Domain/` must contain only pure C# (no EF Core, no ASP.NET, no MAUI).
- `Application/` references only `Domain/`.
- `Infrastructure/` implements interfaces from `Domain/` and `Application/`.
- `Presentation/` accesses `Application/` only through use cases or ViewModels.

### Vertical Slice Architecture
- No slice imports another slice's handler or endpoint.
- Cross-slice communication uses `Contracts/` events only.
- `Shared/` contains only infrastructure (DbContext, middleware, extensions).
- Each slice can be compiled independently (no hard dependency on other slices).

## Reference
- Refer to `conventions.md` in the project root for .NET conventions.
