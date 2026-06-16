---
name: react-scaffold
description: 'Scaffold a new React + TypeScript + Tailwind project with Clean Architecture four-layer structure or Vertical Slice Architecture feature-slice structure. Use when creating a new React app: Vite setup, Tailwind v4, shadcn/ui, TanStack Query, Zustand, React Router v7, Axios, and the chosen folder tree.'
argument-hint: 'Project name and main feature list'
---

# React Project Scaffolding

## When to Use

- Creating a new React application from scratch.
- Setting up the four-layer Clean Architecture folder structure.
- Bootstrapping Tailwind CSS v4, shadcn/ui, TanStack Query, Zustand, and React Router v7.

## Pre-Scaffold Questions

Ask the user **before starting** if any of these are undefined:

- Architecture style: Clean Architecture or Vertical Slice Architecture? If not decided, refer to the kickoff diagnostic questions.
- App type: SPA (Vite) or SSR (Next.js)?
- Back-end API: REST or GraphQL? Base URL known?
- Authentication: JWT / OAuth / session?
- i18n required?

## Procedure

### Step 1 — Create the Vite project

```bash
npm create vite@latest <project-name> -- --template react-ts
cd <project-name>
```

If the project needs SSR, use Next.js instead and adapt the folder structure accordingly.

### Step 2 — Install core dependencies

```bash
# Routing
npm install react-router-dom

# Server state
npm install @tanstack/react-query

# Client state
npm install zustand

# HTTP client
npm install axios

# Forms + validation
npm install react-hook-form @hookform/resolvers zod

# Tailwind v4 (new Vite plugin approach)
npm install -D tailwindcss @tailwindcss/vite

# Class utilities for shadcn/ui components
npm install clsx tailwind-merge class-variance-authority lucide-react
```

### Step 3 — Configure Tailwind CSS v4

Add the Tailwind plugin to `vite.config.ts`:

```ts
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: { alias: { '@': '/src' } },
});
```

Create `src/styles/globals.css`:

```css
@import "tailwindcss";
```

Import in `src/main.tsx`:

```ts
import './styles/globals.css';
```

### Step 4 — Set up shadcn/ui

```bash
npx shadcn@latest init
```

When prompted:
- Style: Default
- Base color: Neutral (or per project design)
- CSS variables: Yes

This creates `src/presentation/components/ui/` with source components and updates `tailwind.config.ts`.

Add initial components as needed:

```bash
npx shadcn@latest add button input card dialog label
```

### Step 5 — Create the folder structure

#### Clean Architecture
```bash
mkdir -p src/presentation/components/ui
mkdir -p src/presentation/layouts
mkdir -p src/presentation/pages
mkdir -p src/application/use-cases
mkdir -p src/application/store
mkdir -p src/application/interfaces
mkdir -p src/application/types
mkdir -p src/domain/entities
mkdir -p src/domain/validators
mkdir -p src/infrastructure/http
mkdir -p src/infrastructure/repositories
mkdir -p src/infrastructure/adapters
```

#### Vertical Slice Architecture
```bash
mkdir -p src/features
mkdir -p src/shared/ui
mkdir -p src/shared/hooks
mkdir -p src/shared/http
mkdir -p src/shared/store
mkdir -p src/shared/layouts
mkdir -p src/shared/types
mkdir -p src/contracts/events
```

### Step 6 — Create the HTTP client

```ts
// src/infrastructure/http/axios-instance.ts
import axios from 'axios';

export const httpClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: { 'Content-Type': 'application/json' },
});

httpClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

httpClient.interceptors.response.use(
  (res) => res,
  (err) => Promise.reject(err)
);
```

### Step 7 — Create the `cn` utility

```ts
// src/presentation/components/ui/cn.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

### Step 8 — Bootstrap `main.tsx`

#### Clean Architecture
```tsx
// src/main.tsx
import './styles/globals.css';
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter } from 'react-router-dom';
import { App } from './app';
import { UserRepository } from './infrastructure/repositories/user-repository';
import { UserRepositoryContext } from './application/interfaces/i-user-repository';

const queryClient = new QueryClient();
const userRepo = new UserRepository();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <UserRepositoryContext.Provider value={userRepo}>
        <BrowserRouter>
          <App />
        </BrowserRouter>
      </UserRepositoryContext.Provider>
    </QueryClientProvider>
  </StrictMode>
);
```

#### Vertical Slice Architecture
```tsx
// src/main.tsx
import './styles/globals.css';
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter } from 'react-router-dom';
import { App } from './app';

const queryClient = new QueryClient();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </QueryClientProvider>
  </StrictMode>
);
```

### Step 9 — Create the app layout shell

```tsx
// src/shared/layouts/AppShell.tsx  (or src/presentation/layouts/AppShell.tsx for Clean Architecture)
import { Outlet } from 'react-router-dom';

export function AppShell() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="border-b px-6 py-4">
        <h1 className="text-lg font-semibold">App</h1>
      </header>
      <main className="p-6">
        <Outlet />
      </main>
    </div>
  );
}
```

### Step 10 — Set up router

#### Clean Architecture
```tsx
// src/app.tsx
import { Routes, Route } from 'react-router-dom';
import { AppShell } from './presentation/layouts/AppShell';

export function App() {
  return (
    <Routes>
      <Route element={<AppShell />}>
        {/* Feature routes are added here */}
      </Route>
    </Routes>
  );
}
```

#### Vertical Slice Architecture
```tsx
// src/app.tsx
import { Routes, Route } from 'react-router-dom';
import { AppShell } from './shared/layouts/AppShell';

export function App() {
  return (
    <Routes>
      <Route element={<AppShell />}>
        {/* Lazy-loaded feature routes are added here */}
      </Route>
    </Routes>
  );
}
```

### Step 11 — Install and configure testing

```bash
npm install -D vitest @testing-library/react @testing-library/user-event @testing-library/jest-dom msw jsdom
```

Add to `vite.config.ts`:

```ts
test: {
  globals: true,
  environment: 'jsdom',
  setupFiles: ['./src/test-setup.ts'],
},
```

Create `src/test-setup.ts`:

```ts
import '@testing-library/jest-dom';
```

### Step 12 — Verify

```bash
npm install
npm run build       # Must pass with zero errors
npx vitest run      # Must pass with zero failures
```

## Decoupling Validation

After scaffold, verify the architecture-specific rules:

**Clean Architecture:**
- `src/domain/` contains no React or library imports.
- `src/infrastructure/` does not import from `src/presentation/`.
- `src/presentation/` does not import from `src/infrastructure/`.
- `src/main.tsx` is the only place where concrete repositories are instantiated.

**Vertical Slice Architecture:**
- Each feature under `src/features/<name>/` contains all its own components, hooks, and API calls.
- `src/shared/` contains only reusable cross-slice code (no feature-specific business logic).
- `src/features/` slices do not import from other `src/features/` slices.
- `src/contracts/` defines shared event types and interface contracts between slices.

## Reference

Refer to `conventions.md` in the project root for React conventions.