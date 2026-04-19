---
name: dotnet-scaffold
description: 'Scaffold a new .NET project with Clean Architecture structure. Use when creating a new .NET solution, initializing project structure, setting up layers (Domain, Application, Infrastructure, Presentation), configuring DI, or bootstrapping a C# project from scratch.'
argument-hint: 'Project name, type (Web API / MAUI / Blazor) and main features'
---

# .NET Project Scaffolding

## When to Use
- Creating a new .NET application from scratch.
- Setting up the initial solution structure following Clean Architecture.
- Configuring DI composition root, data access, and base services.

## Procedure

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

## Decoupling Validation
- `Domain/` must contain only pure C# (no EF Core, no ASP.NET, no MAUI).
- `Application/` references only `Domain/`.
- `Infrastructure/` implements interfaces from `Domain/` and `Application/`.
- `Presentation/` accesses `Application/` only through use cases or ViewModels.

## Reference
- [.NET Conventions](../conventions.md)
