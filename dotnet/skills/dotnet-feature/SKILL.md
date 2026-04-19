---
name: dotnet-feature
description: 'Create a new feature module in a .NET Clean Architecture project. Use when adding a feature, creating a new endpoint/screen with its use case, repository, DTO, and ViewModel/Controller, or implementing a user story end-to-end across all layers.'
argument-hint: 'Feature name and description'
---

# .NET Feature Implementation

## When to Use
- Adding a new feature (endpoint/screen + logic + data) to an existing .NET project.
- Implementing a user story that spans all layers.
- Creating a new module following Clean Architecture.

## Procedure

1. **Define the feature scope**
   - Identify the entity, use case(s), data source, and UI endpoint/screen.
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
- [ ] Domain files have zero framework references.
- [ ] Application files don't import from Infrastructure or Presentation.
- [ ] Infrastructure files don't import from Presentation.
- [ ] Presentation files don't import from Infrastructure directly.
- [ ] Use case can be tested without database or UI framework.
- [ ] Swapping the Controller/ViewModel doesn't break use case tests.

## Reference
- Refer to `conventions.md` in the project root for .NET conventions.
