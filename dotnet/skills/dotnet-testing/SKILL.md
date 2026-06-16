---
name: dotnet-testing
description: 'Generate and run tests for a .NET project (Clean Architecture or Vertical Slice Architecture). Use when writing unit tests, integration tests, validating decoupling between layers/slices, or checking test coverage.'
argument-hint: 'Feature or layer to test'
---

# .NET Testing

## When to Use
- Writing or generating tests for a feature, layer (CA), or slice (VSA).
- Validating that architectural decoupling is maintained.
- Checking test coverage.

## Pre-Testing Questions
- **Architecture style:** Clean Architecture or Vertical Slice Architecture? If not decided, refer to the kickoff diagnostic questions.

## Procedure

### Unit Tests (Domain)
1. Test entities and value objects in isolation (pure C#, no mocking needed).
2. File: `Domain.Tests/Entities/<Entity>Tests.cs`
3. Verify business rules, validation, and edge cases.

### Unit Tests (Application)
1. Mock repositories and services using `Moq` or `NSubstitute`.
2. Test use cases and application services.
3. File: `Application.Tests/UseCases/<UseCase>Tests.cs`
4. Verify correct orchestration and DTO mapping.

### Integration Tests (Infrastructure)
1. Use in-memory database (`UseInMemoryDatabase`) or `TestContainers`.
2. Test repository implementations against real DbContext.
3. File: `Infrastructure.Tests/Repositories/<Repo>Tests.cs`
4. Verify correct data persistence and retrieval.

### Presentation Tests
1. Mock Application layer services — never use real repositories.
2. For Web API: use `WebApplicationFactory<Program>` for integration tests.
3. For MAUI/WPF: test ViewModels with mocked use cases.
4. File: `Presentation.Tests/Controllers/<Controller>Tests.cs`

## Decoupling Validation

**Clean Architecture:**
1. **Domain isolation**: Verify `Domain` project has zero framework package references.
   ```bash
   dotnet list Domain/Domain.csproj package
   ```
   Expected: only base .NET SDK, no EF Core, ASP.NET, or MAUI packages.

2. **Application isolation**: Verify `Application` project references only `Domain`.
   ```bash
   dotnet list Application/Application.csproj reference
   ```

3. **Infrastructure isolation**: Verify no imports from `Presentation` namespace.
   ```bash
   grep -r "using.*Presentation" src/Infrastructure/
   ```
   Expected: no matches.

4. **Presentation isolation**: Verify no imports from `Infrastructure` namespace.
   ```bash
   grep -r "using.*Infrastructure" src/Presentation/
   ```
   Expected: no matches.

**Vertical Slice Architecture:**
1. **Slice isolation**: Verify no cross-slice imports between feature folders.
   ```bash
   grep -r "using.*Features/" src/Features/<other-feature>/
   ```
   Expected: no matches.

2. **Shared kernel purity**: Verify `Shared/` contains no feature-specific business logic.
   ```bash
   grep -r "Feature" src/Shared/
   ```
   Expected: no feature names referenced.

3. **Contract stability**: Verify contract/event types are not modified without versioning.
   ```bash
   dotnet test Contracts.Tests/Contracts.Tests.csproj
   ```
   Expected: all contract tests pass.

4. **Endpoint isolation**: Verify endpoints don't import from other slices' repositories.
   ```bash
   grep -r "I.*Repository" src/Features/<feature>/  | grep -v "I<feature>"
   ```
   Expected: each slice references only its own repository.

### Coverage
```bash
dotnet test --collect:"XPlat Code Coverage"
reportgenerator -reports:**/coverage.cobertura.xml -targetdir:coverage/html
```

### Vertical Slice Architecture Testing

When the project uses VSA, tests follow the slice, not the layer:

#### Unit Tests (per endpoint)
- Test endpoint `HandleAsync` with a mocked repository.
- File: `Features/<Feature>/Get<Feature>/Get<Feature>EndpointTests.cs`
- Mock `I<Feature>Repository` using `Moq` or `NSubstitute`.
- Verify correct response status, DTO mapping, and error handling.

#### Unit Tests (per validator)
- Test FluentValidation validators in isolation.
- File: `Features/<Feature>/Create<Feature>/Create<Feature>ValidatorTests.cs`
- Verify validation rules for valid and invalid requests.

#### Integration Tests (per slice)
- Test the full vertical slice end-to-end with `WebApplicationFactory<Program>`.
- Use in-memory database or Testcontainers for real persistence.
- File: `Features/<Feature>/<Feature>SliceTests.cs`
- Verify the endpoint works from HTTP request through to database.

#### Unit Tests (repository)
- Test repository against a test database (EF Core InMemory or Testcontainers).
- File: `Features/<Feature>/<Feature>RepositoryTests.cs`

#### Contract Tests (cross-slice)
- Test that shared contracts/events between slices remain compatible.
- File: `Contracts.Tests/<Event>ContractTests.cs`

**VSA Testing Rules:**
- Test folders mirror the feature folder structure — not by technical layer.
- Endpoints tested with mocked repository = fast unit tests.
- Slice integration tests = full vertical verification.
- No cross-slice imports in test projects — each slice is testable independently.

## Test Naming Convention
- Class: `<ClassUnderTest>Tests.cs`
- Method: `<Method>_Should<ExpectedResult>_When<Condition>`
- Example: `GetUserUseCase_ShouldReturnUser_WhenUserExists`

## Reference
- Refer to `conventions.md` in the project root for .NET conventions.
