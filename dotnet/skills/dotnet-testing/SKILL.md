---
name: dotnet-testing
description: 'Generate and run tests for a .NET Clean Architecture project. Use when writing unit tests, integration tests, validating decoupling between layers, or checking test coverage for a C# application.'
argument-hint: 'Feature or layer to test'
---

# .NET Testing

## When to Use
- Writing or generating tests for a feature or layer.
- Validating that architectural decoupling is maintained.
- Checking test coverage.

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

### Decoupling Validation
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

### Coverage
```bash
dotnet test --collect:"XPlat Code Coverage"
reportgenerator -reports:**/coverage.cobertura.xml -targetdir:coverage/html
```

## Test Naming Convention
- Class: `<ClassUnderTest>Tests.cs`
- Method: `<Method>_Should<ExpectedResult>_When<Condition>`
- Example: `GetUserUseCase_ShouldReturnUser_WhenUserExists`

## Reference
- [.NET Conventions](../conventions.md)
