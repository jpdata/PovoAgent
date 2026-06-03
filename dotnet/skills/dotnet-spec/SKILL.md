---
name: dotnet-spec
description: 'Translates the .NET Design Document into formal Specification Documents for use cases, domain entities, repositories, and API endpoints. Maps each spec scenario to xUnit test patterns and Clean Architecture contract shapes. Use after Design and before Implementation in .NET projects.'
argument-hint: 'Use case, entity, or endpoint name to specify'
---

# .NET Specification

## When to Use

- After the .NET architecture Design Document is approved.
- Before writing any use case, domain entity, or controller.
- When adding a new feature to an existing .NET project.

## .NET-Specific Specification Units

| Unit Type | Layer | Spec Focus |
|---|---|---|
| Domain entity / value object | Domain | Business rule enforcement, invariants, equality |
| Domain service | Domain | Pure business logic, no infrastructure dependencies |
| Use-case / command handler | Application | Input validation, orchestration, output shape |
| Query handler | Application | Data retrieval, mapping, pagination |
| Repository implementation | Infrastructure | Persistence behavior, EF Core queries, error handling |
| API controller / minimal API endpoint | Presentation | HTTP contract: status codes, request/response shape |

## Workflow

1. Read the .NET Design Document (Clean Architecture layers, CQRS commands/queries, API contracts).
2. Identify all use cases, domain entities, repositories, and endpoints that need a spec.
3. Apply the base `specification` skill workflow — one `SPEC_<Name>.md` per unit.
4. Enrich each spec with the .NET-specific fields below.
5. Map each scenario to an xUnit test pattern (Arrange / Act / Assert).
6. Verify every command spec covers validation failure, success, and domain error paths.
7. Verify every API endpoint spec covers all HTTP status codes the endpoint can return.

## .NET-Specific Spec Fields

Add the following section to each spec in a .NET project:

````markdown
## .NET Implementation Hints

### Unit Type
- [ ] Domain entity / value object
- [ ] Domain service (pure logic)
- [ ] Command + handler (write operation)
- [ ] Query + handler (read operation)
- [ ] Repository implementation
- [ ] API controller / minimal API endpoint

### Command / Query Shape
```csharp
// Command or Query record/class definition goes here
// Include FluentValidation rules if applicable
```

### Handler Return Type
```csharp
// Result<T>, OneOf<Success, Error>, or plain T — document the exact type
```

### HTTP Contract (for endpoint specs)
| Field | Value |
|---|---|
| Method | GET / POST / PUT / DELETE / PATCH |
| Route | `/api/v1/resource/{id}` |
| Auth | Anonymous / Bearer JWT / Policy name |
| Request body | `{ field: type }` |
| 200 response | `{ field: type }` |
| 400 response | Validation error shape |
| 401 / 403 response | Auth error shape |
| 404 response | Not found shape |
| 500 response | Internal error shape |

### xUnit Test Pattern Reference
| Scenario | xUnit Approach |
|---|---|
| Domain rule validation | Arrange entity, Act on method, Assert exception or state |
| Command success | Arrange mocked repo, Act `Handle(command, ct)`, Assert result and repo call |
| Command validation failure | Arrange invalid input, Act validator, Assert `ValidationException` |
| Query result | Arrange mocked repo returns list, Act `Handle(query, ct)`, Assert mapped DTOs |
| API endpoint | `WebApplicationFactory<Program>`, `HttpClient.PostAsJsonAsync`, assert status + body |
````

## Acceptance Criteria (.NET-specific additions)

- [ ] Every command spec covers: invalid input (400), domain rule violation, and success path.
- [ ] Every query spec covers: empty result, paginated result, and not-found case.
- [ ] Every API endpoint spec lists all HTTP status codes explicitly.
- [ ] Domain entity specs verify invariant enforcement (constructor or factory method throws on invalid state).
- [ ] Repository specs specify EF Core behavior (tracked vs. no-tracking, transaction boundaries).

## Tool References

- **Testing:** xUnit + FluentAssertions
- **Mocking:** Moq or NSubstitute
- **Integration testing:** `WebApplicationFactory<Program>` + `TestContainers` for DB
- **Validation:** FluentValidation
- **Result pattern:** `OneOf`, `ErrorOr`, or custom `Result<T>`

## Pattern Reference

Follow the Clean Architecture conventions defined in `dotnet/conventions.md`.
All command/query shapes must match the CQRS contracts defined in the Design Document.
