---
name: react-spec
description: 'Translates the React Design Document into formal Specification Documents for components, hooks, and domain entities. Maps each spec scenario to React Testing Library test patterns and TanStack Query contract shapes. Use after Design and before Implementation in React projects.'
argument-hint: 'Feature or component name to specify'
---

# React Specification

## When to Use

- After the React architecture Design Document is approved.
- Before writing any component, hook, or service implementation.
- When adding a new feature to an existing React project.

## React-Specific Specification Units

In a React Clean Architecture project, specs are written at these boundaries:

| Unit Type | Layer | Spec Focus |
|---|---|---|
| Domain entity / validator | Domain | Pure function behavior, input→output, validation rules |
| Use-case hook (`useXxxUseCase`) | Application | Data flow: loading, success, error states; side effects |
| Repository / service | Infrastructure | API call shape, response mapping, error handling |
| Page / feature component | Presentation | Rendered output per state, user interactions, accessibility |

## Workflow

1. Read the React Design Document (four-layer architecture, API contracts, data models).
2. Identify all components, hooks, repositories, and domain validators that need a spec.
3. Apply the base `specification` skill workflow — one `SPEC_<Name>.md` per unit.
4. Enrich each spec with the React-specific fields below.
5. Map each scenario explicitly to a React Testing Library (RTL) test pattern.
6. Verify every hook spec covers `loading`, `success`, and `error` states.
7. Verify every component spec covers at least one render state and one interaction.

## React-Specific Spec Fields

Add the following section to each spec in a React project:

````markdown
## React Implementation Hints

### Component / Hook Type
- [ ] Presentational component (no hooks except `useState` for local UI state)
- [ ] Page-level wiring component (connects use-case hook to presentational tree)
- [ ] Use-case hook (`useXxxUseCase`)
- [ ] Repository implementation
- [ ] Domain validator (pure function)

### State Scenarios to Cover
| State | Description | Expected UI / Return Value |
|---|---|---|
| `loading` | Data fetch in flight | Skeleton / spinner rendered |
| `success` | Data resolved | Data displayed correctly |
| `error` | Fetch failed or validation failed | Error message rendered |
| `empty` | Success but no data | Empty state rendered |

### RTL Test Pattern Reference
| Scenario | RTL Approach |
|---|---|
| Render with data | `render(<Component data={mockData} />)`, assert with `screen.getByText` |
| Loading state | Mock query as pending, assert spinner is visible |
| Error state | Mock query rejection, assert error message |
| User interaction | `userEvent.click(...)`, assert callback or state change |
| Hook behavior | `renderHook(() => useXxxUseCase(...))`, assert return values per state |

### Props / Return Value Contract
Document the exact TypeScript interface for props or hook return:
```typescript
// Component props or hook return type goes here
```
````

## Acceptance Criteria (React-specific additions)

- [ ] Every use-case hook spec covers `loading`, `success`, and `error` states.
- [ ] Every component spec has at least one render scenario and one interaction scenario.
- [ ] All prop interfaces and hook return types are defined in the spec (not assumed).
- [ ] RTL test patterns are specified for every scenario.
- [ ] No spec references internal Zustand store shape directly in presentation specs (state flows through props).

## Tool References

- **Testing:** Vitest + React Testing Library + `@testing-library/user-event`
- **Mocking:** `vi.mock`, `msw` (Mock Service Worker) for API layer
- **Hook testing:** `renderHook` from `@testing-library/react`
- **Contract testing:** TanStack Query `QueryClient` with mocked responses

## Pattern Reference

Follow the four-layer architecture defined in `react/conventions.md`.
All API contract shapes must match the Design Document's `application/interfaces/` definitions.
