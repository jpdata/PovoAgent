---
name: react-feature
description: 'Create a new feature in a React Clean Architecture project end-to-end: domain entity, application interface + use-case hook, infrastructure repository + adapter, presentational components, and page composition. Use when implementing a user story or adding a new routed screen.'
argument-hint: 'Feature name and description'
---

# React Feature Implementation

## When to Use

- Adding a new feature (routed page + use case + API calls + UI) to an existing React project.
- Implementing a user story end-to-end across all four layers.
- Creating a new module that must remain decoupled from the rest of the app.

## Pre-Implementation Questions

Ask the user **before starting** if any of these are unclear:

- What is the primary entity or resource this feature manages?
- What API endpoints does it call? (HTTP method + path)
- What UI states are needed? (loading, empty, error, success)
- Does the feature require a form (create/edit)? If so, what fields and validation rules?
- Does it have access control (auth guard)?

## Procedure

### Step 1 — Define the domain entity

```ts
// src/domain/entities/xxx-entity.ts
export interface XxxEntity {
  id: string;
  // ... domain fields only, no API-specific shapes
}
```

Add a validator if the feature has business rules:

```ts
// src/domain/validators/xxx-validator.ts
export function validateCreateXxx(
  input: unknown
): { valid: boolean; errors: string[] } {
  const errors: string[] = [];
  // pure validation logic
  return { valid: errors.length === 0, errors };
}
```

### Step 2 — Define the application interface

```ts
// src/application/interfaces/i-xxx-repository.ts
import { XxxEntity } from '@/domain/entities/xxx-entity';
import { CreateXxxDto } from '@/application/types/create-xxx-dto';

export interface IXxxRepository {
  getAll(): Promise<XxxEntity[]>;
  getById(id: string): Promise<XxxEntity>;
  create(data: CreateXxxDto): Promise<XxxEntity>;
}

// React Context for DI injection
import { createContext, useContext } from 'react';

export const XxxRepositoryContext = createContext<IXxxRepository | null>(null);

export function useXxxRepository(): IXxxRepository {
  const repo = useContext(XxxRepositoryContext);
  if (!repo) throw new Error('XxxRepository not provided');
  return repo;
}
```

Define the DTOs:

```ts
// src/application/types/create-xxx-dto.ts
export interface CreateXxxDto {
  // fields required to create the entity
}
```

### Step 3 — Create the use-case hook

```ts
// src/application/use-cases/use-get-xxx-list.ts
import { useQuery } from '@tanstack/react-query';
import { useXxxRepository } from '@/application/interfaces/i-xxx-repository';

export function useGetXxxList() {
  const repo = useXxxRepository();
  return useQuery({
    queryKey: ['xxx'],
    queryFn: () => repo.getAll(),
  });
}

// src/application/use-cases/use-create-xxx.ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useXxxRepository } from '@/application/interfaces/i-xxx-repository';
import { CreateXxxDto } from '@/application/types/create-xxx-dto';

export function useCreateXxx() {
  const repo = useXxxRepository();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateXxxDto) => repo.create(data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['xxx'] }),
  });
}
```

### Step 4 — Create the infrastructure adapter

```ts
// src/infrastructure/adapters/xxx-adapter.ts
import { XxxEntity } from '@/domain/entities/xxx-entity';

export interface ApiXxxDto {
  id: string;
  // snake_case API response fields
}

export function adaptXxx(dto: ApiXxxDto): XxxEntity {
  return {
    id: dto.id,
    // map API fields to domain entity fields
  };
}
```

### Step 5 — Create the infrastructure repository

```ts
// src/infrastructure/repositories/xxx-repository.ts
import { IXxxRepository } from '@/application/interfaces/i-xxx-repository';
import { XxxEntity } from '@/domain/entities/xxx-entity';
import { CreateXxxDto } from '@/application/types/create-xxx-dto';
import { httpClient } from '@/infrastructure/http/axios-instance';
import { adaptXxx, ApiXxxDto } from '@/infrastructure/adapters/xxx-adapter';

export class XxxRepository implements IXxxRepository {
  async getAll(): Promise<XxxEntity[]> {
    const { data } = await httpClient.get<ApiXxxDto[]>('/xxx');
    return data.map(adaptXxx);
  }

  async getById(id: string): Promise<XxxEntity> {
    const { data } = await httpClient.get<ApiXxxDto>(`/xxx/${id}`);
    return adaptXxx(data);
  }

  async create(dto: CreateXxxDto): Promise<XxxEntity> {
    const { data } = await httpClient.post<ApiXxxDto>('/xxx', dto);
    return adaptXxx(data);
  }
}
```

### Step 6 — Create the presentational components

```tsx
// src/presentation/components/xxx/XxxCard.tsx
import { XxxEntity } from '@/domain/entities/xxx-entity';
import { cn } from '@/presentation/components/ui/cn';

interface XxxCardProps {
  item: XxxEntity;
  onSelect: (id: string) => void;
}

export function XxxCard({ item, onSelect }: XxxCardProps) {
  return (
    <div
      className={cn('rounded-lg border bg-card p-4 cursor-pointer', 'hover:bg-accent transition-colors')}
      onClick={() => onSelect(item.id)}
    >
      <p className="font-medium text-card-foreground">{item.id}</p>
    </div>
  );
}
```

For lists with loading and empty states:

```tsx
// src/presentation/components/xxx/XxxList.tsx
import { XxxEntity } from '@/domain/entities/xxx-entity';
import { XxxCard } from './XxxCard';

interface XxxListProps {
  items: XxxEntity[];
  isLoading: boolean;
  onSelect: (id: string) => void;
}

export function XxxList({ items, isLoading, onSelect }: XxxListProps) {
  if (isLoading) return <p className="text-muted-foreground">Loading…</p>;
  if (items.length === 0) return <p className="text-muted-foreground">No items found.</p>;
  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {items.map((item) => (
        <XxxCard key={item.id} item={item} onSelect={onSelect} />
      ))}
    </div>
  );
}
```

If the feature has a form, use React Hook Form + Zod:

```tsx
// src/presentation/components/xxx/CreateXxxForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { CreateXxxDto } from '@/application/types/create-xxx-dto';
import { Button } from '@/presentation/components/ui/button';
import { Input } from '@/presentation/components/ui/input';

const schema = z.object({
  // Zod schema matching CreateXxxDto fields
});

interface CreateXxxFormProps {
  onSubmit: (data: CreateXxxDto) => void;
  isLoading: boolean;
}

export function CreateXxxForm({ onSubmit, isLoading }: CreateXxxFormProps) {
  const { register, handleSubmit, formState: { errors } } = useForm<CreateXxxDto>({
    resolver: zodResolver(schema),
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <Input {...register('fieldName')} placeholder="Field" aria-invalid={!!errors.fieldName} />
      {errors.fieldName && <p className="text-sm text-destructive">{errors.fieldName.message}</p>}
      <Button type="submit" disabled={isLoading}>
        {isLoading ? 'Saving…' : 'Create'}
      </Button>
    </form>
  );
}
```

### Step 7 — Create the page (view-model wiring)

```tsx
// src/presentation/pages/XxxPage.tsx
import { useNavigate } from 'react-router-dom';
import { useGetXxxList } from '@/application/use-cases/use-get-xxx-list';
import { useCreateXxx } from '@/application/use-cases/use-create-xxx';
import { XxxList } from '@/presentation/components/xxx/XxxList';
import { CreateXxxForm } from '@/presentation/components/xxx/CreateXxxForm';

export function XxxPage() {
  const navigate = useNavigate();
  const { data: items = [], isLoading } = useGetXxxList();
  const { mutate: create, isPending } = useCreateXxx();

  return (
    <div className="flex flex-col gap-8">
      <div>
        <h2 className="text-2xl font-semibold tracking-tight">Xxx</h2>
        <p className="text-muted-foreground">Manage your xxx items.</p>
      </div>
      <CreateXxxForm onSubmit={create} isLoading={isPending} />
      <XxxList items={items} isLoading={isLoading} onSelect={(id) => navigate(`/xxx/${id}`)} />
    </div>
  );
}
```

### Step 8 — Register the route and provide the repository

In `src/app.tsx`, add the route:

```tsx
import { lazy } from 'react';
const XxxPage = lazy(() => import('./presentation/pages/XxxPage').then(m => ({ default: m.XxxPage })));

<Route path="/xxx" element={<XxxPage />} />
```

In `src/main.tsx`, add the repository context provider:

```tsx
import { XxxRepository } from './infrastructure/repositories/xxx-repository';
import { XxxRepositoryContext } from './application/interfaces/i-xxx-repository';

const xxxRepo = new XxxRepository();

// Wrap inside existing providers:
<XxxRepositoryContext.Provider value={xxxRepo}>
  ...
</XxxRepositoryContext.Provider>
```

## Decoupling Checklist

- [ ] `domain/entities/xxx-entity.ts` has zero React or library imports.
- [ ] `domain/validators/xxx-validator.ts` has zero React or library imports.
- [ ] `application/use-cases/` hooks do not import from `presentation/` or `infrastructure/`.
- [ ] `infrastructure/repositories/` implements the interface from `application/interfaces/`.
- [ ] `presentation/components/` receive all data via props — no direct use-case hook calls.
- [ ] `presentation/pages/XxxPage.tsx` is the only file that wires the use-case hook to components.
- [ ] Swapping the `XxxCard` and `XxxList` components requires zero changes in `application/` or `infrastructure/`.

## Reference

Refer to `conventions.md` in the project root for React conventions.

## Reference
- Refer to `conventions.md` in the project root for React conventions.