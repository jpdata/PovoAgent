---
name: dotnet-feature
description: 'Create a new feature module in a .NET project (Clean Architecture or Vertical Slice Architecture). Use when adding a feature, creating a new endpoint/screen with its use case, repository, DTO, and ViewModel/Controller (CA) or full vertical handler per operation (VSA), or implementing a user story end-to-end.'
argument-hint: 'Feature name and description'
---

# .NET Feature Implementation

## When to Use
- Adding a new feature (endpoint/screen + logic + data) to an existing .NET project.
- Implementing a user story that spans all layers (CA) or owns its full vertical stack (VSA).
- Creating a new module following Clean Architecture or Vertical Slice Architecture.

## Procedure

1. **Define the feature scope**
   - Identify the entity, use case(s), data source, and UI endpoint/screen.
   - **Architecture style:** Confirm whether the project uses Clean Architecture or Vertical Slice Architecture. If not decided, refer to the kickoff diagnostic questions.
   - **Ask the user** if any of these are unclear: API style (Controllers / Minimal API / FastEndpoints), mapping library, logging library, or other technology choices not yet decided.

2. **Create Domain layer files**
   ```
   Domain/Entities/<Feature>Entity.cs          ← Business entity
   Domain/Interfaces/I<Feature>Repository.cs   ← Repository contract
   ```
   - Entity: plain C# class, no ORM attributes.
   - Repository interface: defines the data access contract.

3. **Create Application layer files**
   ```
   Application/UseCases/<Feature>/Get<Feature>UseCase.cs   ← Use case
   Application/DTOs/<Feature>Dto.cs                        ← Data transfer object
   Application/Interfaces/I<Feature>Service.cs             ← Service contract (if needed)
   ```
   - Use case: single-responsibility, depends on repository interface only.
   - DTO: serializable, no domain logic.
   - Mapping: use manual mapping (extension methods or constructor) by default. Only create `Application/Mappings/<Feature>Profile.cs` if the user has explicitly requested AutoMapper or Mapster.

4. **Create Infrastructure layer files**
   ```
   Infrastructure/Repositories/<Feature>Repository.cs      ← Repository implementation
   Infrastructure/Persistence/Configurations/<Feature>Configuration.cs ← EF Core config
   ```
   - Repository implementation uses DbContext, never UI.
   - Add entity configuration for EF Core.

5. **Create Presentation layer files**

   The Presentation layer depends on the **API style** chosen in the Design phase. Ask the user if not defined.

   #### Option A: Controllers (traditional MVC)
   ```
   Presentation/Controllers/<Feature>Controller.cs
   ```
   - One controller per feature/resource. Injects use cases via constructor.
   - Routes defined via `[Route("api/[controller]")]` and `[Http*]` attributes.

   #### Option B: Minimal API
   ```
   Presentation/Endpoints/<Feature>Endpoints.cs
   ```
   - One static class per feature grouping related endpoints.
   - Use `MapGroup("api/<feature>")` to group routes.
   - Each endpoint is a static method receiving dependencies via parameter injection.
   - Example structure:
     ```csharp
     public static class UserEndpoints
     {
         public static RouteGroupBuilder MapUserEndpoints(this IEndpointRouteBuilder app)
         {
             var group = app.MapGroup("api/users");
             group.MapGet("/", GetAll);
             group.MapGet("/{id:int}", GetById);
             group.MapPost("/", Create);
             return group;
         }

         private static async Task<IResult> GetAll(IGetUsersUseCase useCase) { ... }
         private static async Task<IResult> GetById(int id, IGetUserByIdUseCase useCase) { ... }
         private static async Task<IResult> Create(CreateUserDto dto, ICreateUserUseCase useCase) { ... }
     }
     ```
   - Register in `Program.cs`: `app.MapUserEndpoints();`

   #### Option C: FastEndpoints (recommended for API-heavy projects)
   ```
   Presentation/Features/<Feature>/
   ├── Get<Feature>Endpoint.cs         ← Endpoint class
   ├── Get<Feature>Request.cs          ← Request DTO
   ├── Get<Feature>Response.cs         ← Response DTO
   ├── Get<Feature>Validator.cs        ← FluentValidation validator
   └── Get<Feature>Mapper.cs           ← Entity ↔ DTO mapper (optional)
   ```
   - **Vertical slice structure:** each endpoint gets its own folder with all related files.
   - Endpoint class inherits `Endpoint<TRequest, TResponse>` and overrides `Configure()` + `HandleAsync()`.
   - Endpoints are auto-discovered — no manual registration needed.
   - Validation uses `Validator<TRequest>` (built-in FluentValidation integration).
   - Example:
     ```csharp
     public sealed class GetUserEndpoint : Endpoint<GetUserRequest, GetUserResponse>
     {
         private readonly IGetUserByIdUseCase _useCase;

         public GetUserEndpoint(IGetUserByIdUseCase useCase) => _useCase = useCase;

         public override void Configure()
         {
             Get("api/users/{Id}");
             AllowAnonymous(); // or Roles("Admin")
         }

         public override async Task HandleAsync(GetUserRequest req, CancellationToken ct)
         {
             var result = await _useCase.ExecuteAsync(req.Id, ct);
             await Send.OkAsync(new GetUserResponse { ... });
         }
     }
     ```
   - Docs: https://fast-endpoints.com/docs/get-started

   #### MAUI/WPF:
   ```
   Presentation/ViewModels/<Feature>ViewModel.cs
   Presentation/Views/<Feature>Page.xaml
   ```

   #### Blazor:
   ```
   Presentation/Pages/<Feature>.razor
   ```

   **In all cases:** Presentation depends on use cases only, not on repositories.

### Vertical Slice Architecture Path

When the project uses VSA, create a feature folder that owns its full vertical stack:

1. **Create the VSA feature folder**
   ```
   Features/<Feature>/
   ├── <Feature>Entity.cs                     ← Business entity (plain C#, no ORM)
   ├── I<Feature>Repository.cs                ← Repository contract
   ├── <Feature>Repository.cs                 ← Repository implementation
   ├── <Feature>ServiceExtensions.cs          ← DI registration extension
   ├── Get<Feature>/
   │   ├── Get<Feature>Endpoint.cs            ← FastEndpoints endpoint
   │   ├── Get<Feature>Request.cs             ← Request DTO
   │   ├── Get<Feature>Response.cs            ← Response DTO
   │   └── Get<Feature>Validator.cs           ← FluentValidation validator
   ├── Create<Feature>/
   │   ├── Create<Feature>Endpoint.cs
   │   ├── Create<Feature>Request.cs
   │   ├── Create<Feature>Response.cs
   │   └── Create<Feature>Validator.cs
   └── Update<Feature>/
       └── ...
   ```

2. **Create the entity and repository contract**
   - Entity: plain C# class, no ORM attributes. Lives at the feature root.
   - Repository interface: defines the data access contract within the slice.

3. **Create the repository implementation**
   - Uses DbContext directly, lives in the same feature folder.
   - No separate Infrastructure project — the slice owns its data access.

4. **Create endpoints per operation**
   - One subfolder per operation (Get, Create, Update, Delete).
   - Each endpoint inherits `Endpoint<TRequest, TResponse>` (FastEndpoints).
   - Request/Response DTOs are scoped to the operation, not shared.
   - Validation uses `Validator<TRequest>` per endpoint.

   Example endpoint:
   ```csharp
   public sealed class Get<Feature>Endpoint : Endpoint<Get<Feature>Request, Get<Feature>Response>
   {
       private readonly I<Feature>Repository _repo;

       public Get<Feature>Endpoint(I<Feature>Repository repo) => _repo = repo;

       public override void Configure()
       {
           Get("api/<feature>/{Id}");
           AllowAnonymous();
       }

       public override async Task HandleAsync(Get<Feature>Request req, CancellationToken ct)
       {
           var entity = await _repo.GetByIdAsync(req.Id, ct);
           if (entity is null) { await SendNotFoundAsync(ct); return; }
           await Send.OkAsync(new Get<Feature>Response { ... }, ct);
       }
   }
   ```

5. **Create DI registration extension per slice**
   ```csharp
   // Features/<Feature>/<Feature>ServiceExtensions.cs
   public static class <Feature>ServiceExtensions
   {
       public static IServiceCollection Add<Feature>Feature(this IServiceCollection services)
       {
           services.AddScoped<I<Feature>Repository, <Feature>Repository>();
           return services;
       }
   }
   ```

   Register in `Program.cs`:
   ```csharp
   builder.Services.Add<Feature>Feature();
   ```

6. **Create tests** (VSA testing follows the slice, not the layer)
   ```
   Features/<Feature>/Get<Feature>/Get<Feature>EndpointTests.cs
   Features/<Feature>/Create<Feature>/Create<Feature>ValidatorTests.cs
   Features/<Feature>/<Feature>RepositoryTests.cs
   ```
   - Endpoint tests: integration tests or unit tests against `HandleAsync`.
   - Repository tests: test against a test database (EF Core InMemory or Testcontainers).
   - Validator tests: pure unit tests for request validation rules.

**VSA Key Rules:**
- Each feature folder is self-contained — no cross-slice imports between features.
- Shared kernel (`Shared/`) provides cross-cutting infrastructure (DbConext, logging, auth).
- Contracts (`Contracts/`) define shared event types for cross-slice communication.
- Endpoints auto-discovered — no manual route registration.

6. **Register in DI**
   - Register repository, use case, and services in `Program.cs`.

7. **Create tests**
   ```
   Domain.Tests/Entities/<Feature>EntityTests.cs
   Application.Tests/UseCases/Get<Feature>UseCaseTests.cs
   Infrastructure.Tests/Repositories/<Feature>RepositoryTests.cs

   # Controllers:
   Presentation.Tests/Controllers/<Feature>ControllerTests.cs
   # Minimal API:
   Presentation.Tests/Endpoints/<Feature>EndpointsTests.cs
   # FastEndpoints:
   Presentation.Tests/Features/<Feature>/Get<Feature>EndpointTests.cs
   ```

## Decoupling Checklist

**Clean Architecture:**
- [ ] Domain files have zero framework references.
- [ ] Application files don't import from Infrastructure or Presentation.
- [ ] Infrastructure files don't import from Presentation.
- [ ] Presentation files don't import from Infrastructure directly.
- [ ] Use case can be tested without database or UI framework.
- [ ] Swapping the Controller/ViewModel doesn't break use case tests.

**Vertical Slice Architecture:**
- [ ] Each feature folder is self-contained — no imports from other feature folders.
- [ ] Shared kernel (`Shared/`) contains only cross-cutting infrastructure, no feature-specific logic.
- [ ] Contracts (`Contracts/`) define event types for cross-slice communication.
- [ ] Endpoint can be tested with a mocked repository (no database).
- [ ] Repository can be tested against a test database (InMemory or Testcontainers).
- [ ] Swapping the endpoint doesn't affect other slices.

## Reference
- Refer to `conventions.md` in the project root for .NET conventions.
