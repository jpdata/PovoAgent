---
name: angular-spec
description: 'Translates the Angular Design Document into formal Specification Documents for components, services, facades, and domain entities. Maps each spec scenario to Jasmine/Jest test patterns and Angular TestBed setup. Use after Design and before Implementation in Angular projects.'
argument-hint: 'Feature or module name to specify'
---

# Angular Specification

## When to Use

- After the Angular architecture Design Document is approved.
- Before writing any component, service, or feature module.
- When adding a new feature to an existing Angular project.

## Angular-Specific Specification Units

| Unit Type | Layer | Spec Focus |
|---|---|---|
| Domain entity / validator | Domain | Pure logic, business rules, validation |
| Use-case service / facade | Application | Command/query orchestration, state transitions |
| HTTP adapter / repository | Infrastructure | HTTP call shape, error mapping, interceptors |
| Smart component (page) | Presentation | Input binding, output events, loading/error UI |
| Dumb / presentational component | Presentation | `@Input()` rendering, `@Output()` event emission |

## Workflow

1. Read the Angular Design Document (feature boundaries, facades, HTTP strategy, state).
2. Identify all components, services, facades, and adapters that need a spec.
3. Apply the base `specification` skill workflow — one `SPEC_<Name>.md` per unit.
4. Enrich each spec with the Angular-specific fields below.
5. Map each scenario to an Angular TestBed or Jest test pattern.
6. Verify every facade/service spec covers command and query flows, including error paths.
7. Verify every smart component spec covers its `@Input()` and `@Output()` contracts.

## Angular-Specific Spec Fields

Add the following section to each spec in an Angular project:

````markdown
## Angular Implementation Hints

### Unit Type
- [ ] Smart component (wires facade to template)
- [ ] Dumb/presentational component (pure `@Input()` / `@Output()`)
- [ ] Facade / use-case service
- [ ] HTTP adapter (implements domain port)
- [ ] Domain service / validator

### Component Input / Output Contract
```typescript
// @Input() and @Output() interfaces or signal types go here
```

### Service / Facade Method Contract
```typescript
// Method signatures, return types (Observable<T> / Signal<T>), error types go here
```

### State Scenarios to Cover
| State | Description | Expected Behavior |
|---|---|---|
| `loading` | Async operation in flight | Loading indicator visible |
| `success` | Operation completed | Data bound to template |
| `error` | Operation failed | Error message displayed |
| `empty` | No data returned | Empty state shown |

### TestBed / Jest Pattern Reference
| Scenario | Angular Test Approach |
|---|---|
| Component render | `TestBed.createComponent(...)`, `fixture.detectChanges()`, query DOM |
| Input binding | Set `component.inputProp = value`, `detectChanges()`, assert template |
| Output event | `component.outputEvent.subscribe(...)`, trigger action, assert emitted |
| Service method | `TestBed.inject(MyService)`, call method, assert Observable with `firstValueFrom` |
| HTTP adapter | `HttpClientTestingModule` + `HttpTestingController`, flush mock responses |
````

## Acceptance Criteria (Angular-specific additions)

- [ ] Every facade/service spec documents `Observable` or `Signal` return types per scenario.
- [ ] Every smart component spec covers all `@Input()` bindings and `@Output()` emissions.
- [ ] HTTP adapter specs include error mapping scenarios (4xx, 5xx, network failure).
- [ ] TestBed configuration (providers, imports) is noted for each component spec.
- [ ] No spec couples a dumb component scenario to HTTP or business logic directly.

## Tool References

- **Testing:** Jest (or Jasmine) + Angular TestBed
- **HTTP mocking:** `HttpClientTestingModule` + `HttpTestingController`
- **Async testing:** `fakeAsync`, `tick`, `firstValueFrom`
- **Component harnesses:** Angular CDK component harnesses where applicable

## Pattern Reference

Follow the feature-first structure and conventions defined in `angular/conventions.md`.
All HTTP adapter contracts must match the Design Document's port/adapter definitions.
