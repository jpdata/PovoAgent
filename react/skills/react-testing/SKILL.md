---
name: react-testing
description: 'Generate and run tests for a React Clean Architecture project. Use when writing unit tests for domain validators, application use-case hooks, infrastructure repositories, or presentational components. Covers Vitest, React Testing Library, and MSW for API mocking.'
argument-hint: 'Layer or feature to test (domain / application / infrastructure / presentation / all)'
---

# React Testing

## When to Use

- Writing unit tests for domain validators or entities.
- Testing application use-case hooks in isolation.
- Testing infrastructure repositories against a mocked API.
- Testing presentational components and pages with React Testing Library.
- Running decoupling validation checks.

## Test Stack

| Tool                          | Purpose                                             |
|-------------------------------|-----------------------------------------------------|
| Vitest                        | Unit and integration test runner                    |
| React Testing Library (RTL)   | Component and page tests                            |
| MSW (Mock Service Worker)     | HTTP API mocking in tests                           |
| `@testing-library/user-event` | User interaction simulation                         |
| `@testing-library/jest-dom`   | Custom DOM matchers                                 |

## Layer-by-Layer Testing

### Layer 1 — Domain (pure TypeScript, no React)

Test validators and entity logic with pure TypeScript. No rendering, no mocking.

```ts
// src/domain/validators/user-validator.test.ts
import { describe, it, expect } from 'vitest';
import { validateCreateUser } from './user-validator';

describe('validateCreateUser', () => {
  it('should return valid when all required fields are present', () => {
    const result = validateCreateUser({ name: 'Alice', email: 'alice@example.com' });
    expect(result.valid).toBe(true);
    expect(result.errors).toHaveLength(0);
  });

  it('should return invalid when email is missing', () => {
    const result = validateCreateUser({ name: 'Alice' });
    expect(result.valid).toBe(false);
    expect(result.errors).toContain('email is required');
  });
});
```

### Layer 2 — Application (use-case hooks with MSW)

Test hooks with `renderHook` from RTL. Mock the repository via context, or mock the HTTP layer with MSW.

**Option A — Mock repository (preferred for unit isolation):**

```ts
// src/application/use-cases/use-get-users.test.ts
import { describe, it, expect } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { UserRepositoryContext } from '@/application/interfaces/i-user-repository';
import { useGetUsers } from './use-get-users';
import type { UserEntity } from '@/domain/entities/user-entity';

const mockUsers: UserEntity[] = [{ id: '1', name: 'Alice', email: 'alice@test.com', createdAt: new Date() }];

const mockRepo = {
  getAll: vi.fn().mockResolvedValue(mockUsers),
  getById: vi.fn(),
  create: vi.fn(),
};

function wrapper({ children }: { children: React.ReactNode }) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return (
    <QueryClientProvider client={qc}>
      <UserRepositoryContext.Provider value={mockRepo}>
        {children}
      </UserRepositoryContext.Provider>
    </QueryClientProvider>
  );
}

describe('useGetUsers', () => {
  it('should return the user list on success', async () => {
    const { result } = renderHook(() => useGetUsers(), { wrapper });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(mockUsers);
  });
});
```

**Option B — MSW for HTTP layer:**

```ts
// src/test-utils/msw-handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/users', () => HttpResponse.json([{ id: '1', name: 'Alice', email: 'alice@test.com', created_at: '2025-01-01' }])),
];
```

```ts
// src/test-utils/msw-server.ts
import { setupServer } from 'msw/node';
import { handlers } from './msw-handlers';
export const server = setupServer(...handlers);
```

```ts
// src/test-setup.ts
import { server } from './test-utils/msw-server';
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Layer 3 — Infrastructure (repositories with MSW)

Test that the repository calls the correct endpoints and that the adapter transforms responses correctly.

```ts
// src/infrastructure/repositories/user-repository.test.ts
import { describe, it, expect, beforeAll, afterAll, afterEach } from 'vitest';
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { UserRepository } from './user-repository';

const server = setupServer(
  http.get('/users', () =>
    HttpResponse.json([{ id: '1', name: 'Alice', email: 'alice@test.com', created_at: '2025-01-01T00:00:00Z' }])
  )
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('UserRepository.getAll', () => {
  it('should return adapted UserEntity list', async () => {
    const repo = new UserRepository();
    const users = await repo.getAll();
    expect(users[0].id).toBe('1');
    expect(users[0].createdAt).toBeInstanceOf(Date);
  });
});
```

Also test adapters in isolation:

```ts
// src/infrastructure/adapters/user-adapter.test.ts
import { adaptUser } from './user-adapter';

describe('adaptUser', () => {
  it('should map created_at string to Date', () => {
    const dto = { id: '1', name: 'Alice', email: 'a@b.com', created_at: '2025-01-01T00:00:00Z' };
    const entity = adaptUser(dto);
    expect(entity.createdAt).toBeInstanceOf(Date);
  });
});
```

### Layer 4 — Presentation (components and pages with RTL)

Test components and pages by simulating user interactions, not implementation details.

**Component test:**

```tsx
// src/presentation/components/user/UserCard.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserCard } from './UserCard';

describe('UserCard', () => {
  it('should display the user name', () => {
    const user = { id: '1', name: 'Alice', email: 'a@b.com', createdAt: new Date() };
    render(<UserCard item={user} onSelect={vi.fn()} />);
    expect(screen.getByText('Alice')).toBeInTheDocument();
  });

  it('should call onSelect with the user id when clicked', async () => {
    const onSelect = vi.fn();
    const user = { id: '1', name: 'Alice', email: 'a@b.com', createdAt: new Date() };
    render(<UserCard item={user} onSelect={onSelect} />);
    await userEvent.click(screen.getByText('Alice'));
    expect(onSelect).toHaveBeenCalledWith('1');
  });
});
```

**Page integration test (mock repository via context):**

```tsx
// src/presentation/pages/UsersPage.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { MemoryRouter } from 'react-router-dom';
import { UserRepositoryContext } from '@/application/interfaces/i-user-repository';
import { UsersPage } from './UsersPage';
import type { UserEntity } from '@/domain/entities/user-entity';

const mockUsers: UserEntity[] = [{ id: '1', name: 'Alice', email: 'a@b.com', createdAt: new Date() }];
const mockRepo = { getAll: vi.fn().mockResolvedValue(mockUsers), getById: vi.fn(), create: vi.fn() };

function Wrapper({ children }: { children: React.ReactNode }) {
  return (
    <MemoryRouter>
      <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
        <UserRepositoryContext.Provider value={mockRepo}>
          {children}
        </UserRepositoryContext.Provider>
      </QueryClientProvider>
    </MemoryRouter>
  );
}

describe('UsersPage', () => {
  it('should render user list after loading', async () => {
    render(<UsersPage />, { wrapper: Wrapper });
    await waitFor(() => screen.getByText('Alice'));
    expect(screen.getByText('Alice')).toBeInTheDocument();
  });
});
```

## Decoupling Validation

Run these checks to verify layer boundaries are intact:

```bash
# Domain layer: zero React or library imports
grep -r "from 'react\|from \"react\|from 'axios\|from 'zustand" src/domain/
# Expected: no output

# Infrastructure: no presentation imports
grep -r "from '.*presentation\|from \".*presentation" src/infrastructure/
# Expected: no output

# Presentation: no infrastructure imports
grep -r "from '.*infrastructure\|from \".*infrastructure" src/presentation/components/ src/presentation/layouts/
# Expected: no output (pages may import application use-cases only)

# Application use-cases: no presentation imports
grep -r "from '.*presentation" src/application/use-cases/
# Expected: no output
```

## Run Coverage

```bash
npx vitest run --coverage
```

## Test Naming Convention

- File: same name as source file + `.test.ts` / `.test.tsx`
- Test: `should <expected behavior> when <condition>`
- Co-locate tests with the code they validate.

## Reference

Refer to `conventions.md` in the project root for React conventions.