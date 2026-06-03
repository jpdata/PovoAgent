# Guía para Principiantes: PovoAgent con SDD

> **Proyecto de ejemplo:** Aplicación de gestión de tareas — `TaskFlow`
> **Patrón:** React + TypeScript + Clean Architecture
> **Plataforma:** GitHub Copilot
> **Audiencia:** Desarrollador que usa PovoAgent con SDD por primera vez

---

## ¿Qué es SDD en PovoAgent?

**Specification-Driven Development (SDD)** significa que antes de escribir una sola línea de código, cada feature tiene un **documento de especificación formal** que define:

- Qué debe hacer (comportamiento esperado)
- Cuándo y bajo qué condiciones (escenarios concretos)
- Cómo saber que está terminado (criterios de aceptación verificables)

Los archivos de especificación (`SPEC_<Feature>.md`) son la **fuente de verdad** para el agente durante la implementación, las pruebas y la revisión. Si no hay spec aprobada, no hay código.

---

## Ciclo de vida completo con SDD

```mermaid
flowchart LR
    KO([1\nKickoff]) --> PL([2\nPlanning])
    PL --> AN([3\nAnalysis])
    AN --> DE([4\nDesign])
    DE --> SP([5\nSpecification])
    SP --> SC([6\nScaffold])
    SC --> IM([7\nImplementation])
    IM --> TE([8\nTesting])
    TE --> RE([9\nReview])

    style KO fill:#4a90d9,color:#fff
    style PL fill:#4a90d9,color:#fff
    style AN fill:#7b68ee,color:#fff
    style DE fill:#7b68ee,color:#fff
    style SP fill:#e87722,color:#fff
    style SC fill:#50c878,color:#fff
    style IM fill:#50c878,color:#fff
    style TE fill:#f4a460,color:#fff
    style RE fill:#f4a460,color:#fff
```

**Leyenda de colores:**
- Azul — Inicio de proyecto
- Morado — Arquitectura
- Naranja — **Especificación (nuevo con SDD)**
- Verde — Construcción
- Naranja claro — Validación

La diferencia clave respecto al ciclo sin SDD: la fase de **Specification** se inserta entre Design e Implementation y produce los documentos `SPEC_<Feature>.md` que guían todo el trabajo posterior.

---

## El proyecto de ejemplo: TaskFlow

A lo largo de esta guía construiremos **TaskFlow**: una aplicación web en React para que equipos pequeños gestionen sus tareas diarias. Tiene tres features:

1. **Tablero de tareas** — ver todas las tareas del equipo en lista
2. **Crear/editar tarea** — formulario con título, descripción, responsable y prioridad
3. **Filtrar tareas** — filtrar por responsable y prioridad

Es un ejemplo deliberadamente simple para que puedas ver el ciclo SDD completo sin perder el hilo en complejidad tecnológica.

---

## Fase 1 — Kickoff

**Skill:** `kickoff`
**Output:** `PROJECT_INTAKE.md`
**Gate:** Confirmas que el documento refleja tu proyecto correctamente

### Cómo iniciar

Abre el chat de Copilot y escribe:

> "Quiero empezar un proyecto nuevo. Es una app para gestionar tareas de equipo."

El agente carga el skill `kickoff` y comienza la entrevista. Solo hace una pregunta a la vez:

---

**Agente:** ¿Cómo se llama este proyecto?
**Tú:** TaskFlow

**Agente:** En una o dos frases, ¿qué hace?
**Tú:** Una app web donde equipos pequeños pueden ver, crear y filtrar sus tareas diarias.

**Agente:** ¿Cuál es el objetivo más importante de la primera versión?
**Tú:** Que el equipo tenga visibilidad de todas las tareas y pueda asignarlas a personas.

**Agente:** ¿Quiénes son los usuarios?
**Tú:** Miembros de un equipo pequeño (2–8 personas), sin roles diferenciados en esta versión.

**Agente:** ¿Qué patrón tecnológico aplica?
**Tú:** react

**Agente:** ¿Qué plataforma AI usarás?
**Tú:** copilot

*(La entrevista continúa hasta completar todos los bloques del intake)*

---

Al final el agente presenta un resumen y genera:

```markdown
# Project Intake Document

## Project Identity
- **Name:** TaskFlow
- **Description:** App web para que equipos pequeños gestionen tareas diarias.
- **Main Goal:** Dar visibilidad de tareas y facilitar su asignación.

## Scope
- **Core Features:**
  1. Tablero de tareas (lista con estado)
  2. Crear y editar tarea (título, descripción, responsable, prioridad)
  3. Filtrar tareas por responsable y prioridad
- **Out of Scope:** Notificaciones, autenticación, roles
- **Non-Functional Requirements:** Carga inicial < 2s, accesible con teclado

## Technology Stack
- **Pattern:** react
- **AI Platform:** copilot

## Approval
- [x] Kickoff confirmed by user
```

> **Nota para principiantes:** No avances a la siguiente fase hasta que confirmes este documento. Si algo está mal, díselo al agente y lo corrige antes de continuar.

---

## Fase 2 — Planning

**Skill:** `planning`
**Output:** `PROJECT_PLAN.md`
**Gate:** Apruebas el plan antes de que comience el análisis

El agente lee el intake y genera un plan estructurado con el ciclo de vida completo, incluyendo la fase de Specification:

```markdown
## Phase Table

| # | Phase         | Skill / Agent                   | Outputs                          | Gate                    |
|---|---------------|---------------------------------|----------------------------------|-------------------------|
| 1 | Kickoff       | `kickoff`                       | `PROJECT_INTAKE.md`              | Intake confirmado       |
| 2 | Planning      | `planning`                      | `PROJECT_PLAN.md`                | Plan aprobado           |
| 3 | Analysis      | `analysis`                      | Analysis Plan                    | Plan revisado           |
| 4 | Design        | `design` + `react-architect`    | Design Document                  | Diseño aprobado         |
| 5 | Specification | `specification` + `react-spec`  | `SPEC_TaskBoard.md`, etc.        | Specs aprobadas         |
| 6 | Scaffold      | `react-scaffold`                | Estructura de proyecto           | Compila sin errores     |
| 7 | Implementation| `implementation`                | Código funcional                 | Todas las specs cubiertas |
| 8 | Testing       | `testing` + `react-testing`     | Suite de tests + reporte         | Cobertura alcanzada     |
| 9 | Review        | `review` + `react-reviewer`     | Review Report                    | Sin violations bloqueantes |
```

> **Nota SDD:** Observa que la fase 5 (Specification) aparece ahora en el plan con su propio gate: *"Specs aprobadas"*. Esto garantiza que nadie empieza a codificar sin tener la spec aprobada primero.

---

## Fase 3 — Analysis

**Skill:** `analysis`
**Output:** Analysis Plan
**Gate:** Revisas y apruebas el análisis antes del diseño

El agente identifica los casos de uso, flujos de usuario y los límites entre capas:

```markdown
## Main Use Cases

| ID   | Use Case              | Actor   | Trigger                         |
|------|-----------------------|---------|---------------------------------|
| UC-1 | Ver tablero de tareas | Usuario | Carga la aplicación             |
| UC-2 | Crear tarea           | Usuario | Hace clic en "Nueva tarea"      |
| UC-3 | Editar tarea          | Usuario | Hace clic en una tarea existente|
| UC-4 | Filtrar tareas        | Usuario | Selecciona filtros en el tablero|

## Layer Boundaries

- **Presentation:** Tablero, formulario de tarea, controles de filtro
- **Application:** `useTaskBoard`, `useCreateTask`, `useEditTask`, `useTaskFilters`
- **Domain:** Entidad `Task`, validador de prioridad, reglas de asignación
- **Infrastructure:** `TaskRepository` (API REST o local storage)
```

---

## Fase 4 — Design

**Agente:** `react-architect`
**Output:** Design Document
**Gate:** El agente de arquitectura aprueba el diseño antes de autorizar la fase de Specification

El arquitecto de React produce el documento de diseño con la arquitectura de 4 capas, los contratos de API, y los modelos de datos:

```markdown
## Architecture Diagram

Presentation → Application → Domain
Infrastructure → Application → Domain
(Presentation ✗→ Infrastructure — forbidden)

## API Contracts

### TaskRepository interface (Application layer)
- `getTasks(filters?: TaskFilters): Promise<Task[]>`
- `createTask(data: CreateTaskInput): Promise<Task>`
- `updateTask(id: string, data: UpdateTaskInput): Promise<Task>`

## Domain Entity: Task

| Field       | Type                                  | Required |
|-------------|---------------------------------------|----------|
| id          | string (UUID)                         | Yes      |
| title       | string (1–100 chars)                  | Yes      |
| description | string (0–500 chars)                  | No       |
| assignee    | string                                | No       |
| priority    | 'low' \| 'medium' \| 'high'           | Yes      |
| status      | 'todo' \| 'in-progress' \| 'done'     | Yes      |
| createdAt   | Date                                  | Yes      |
```

> **Importante:** El arquitecto **no permite** que la fase de Specification comience hasta que este documento esté aprobado. Esto es un gate automático definido en el agente.

---

## Fase 5 — Specification ⬅ La fase nueva de SDD

**Skills:** `specification` + `react-spec`
**Output:** Un archivo `SPEC_<Feature>.md` por cada feature
**Gate:** Apruebas cada spec antes de que comience el scaffold o la implementación

Esta es la fase central de SDD. El agente lee el Design Document e identifica todas las unidades que necesitan spec. Para TaskFlow produce tres documentos.

### Ejemplo completo: `SPEC_TaskBoard.md`

```markdown
# Specification: Task Board

## Metadata
| Field   | Value                        |
|---------|------------------------------|
| ID      | SPEC-001                     |
| Feature | Task Board                   |
| Layer   | Presentation + Application   |
| Status  | Draft                        |
| Date    | 2026-06-03                   |

## Description
El tablero muestra todas las tareas disponibles en una lista. Obtiene los datos
a través del hook `useTaskBoard` y pasa los resultados como props al componente
presentacional `TaskList`. Los filtros activos se pasan como parámetros al hook.

## Preconditions
- El repositorio de tareas está disponible (real o en memoria).
- El usuario ha navegado a la ruta raíz `/`.

## Postconditions
- La lista de tareas visible en pantalla refleja el estado actual del repositorio
  con los filtros aplicados.

## Scenarios

### Scenario 1 — Carga inicial con tareas existentes
**Given:** El repositorio contiene 3 tareas con prioridades: alta, media, baja.
**When:** El usuario carga la aplicación (ruta `/`).
**Then:** Se muestran las 3 tareas con su título, responsable y prioridad.
**And:** No se muestra ningún mensaje de lista vacía.

### Scenario 2 — Carga inicial sin tareas
**Given:** El repositorio no contiene ninguna tarea.
**When:** El usuario carga la aplicación.
**Then:** Se muestra el mensaje "No hay tareas todavía."
**And:** El botón "Nueva tarea" es visible y habilitado.

### Scenario 3 — Estado de carga
**Given:** La petición al repositorio está en curso.
**When:** El componente está montado y el fetch no ha completado.
**Then:** Se muestra un indicador de carga (skeleton o spinner).
**And:** No se muestra ninguna tarea ni el mensaje de lista vacía.

### Scenario 4 — Error al cargar tareas
**Given:** El repositorio lanza un error de red.
**When:** El usuario carga la aplicación.
**Then:** Se muestra el mensaje "No se pudieron cargar las tareas. Intenta de nuevo."
**And:** Se muestra un botón "Reintentar" que vuelve a ejecutar el fetch.

### Scenario 5 — Filtro activo por responsable
**Given:** El repositorio contiene tareas asignadas a "Ana" y a "Luis".
**When:** El usuario selecciona el filtro "Responsable: Ana".
**Then:** Solo se muestran las tareas asignadas a "Ana".
**And:** Las tareas de "Luis" no son visibles.

## Acceptance Criteria
- [ ] AC-01: La lista renderiza una fila por cada tarea devuelta por el hook.
- [ ] AC-02: El estado `loading` muestra un indicador visual y oculta la lista.
- [ ] AC-03: El estado `empty` muestra el mensaje "No hay tareas todavía."
- [ ] AC-04: El estado `error` muestra el mensaje de error y el botón "Reintentar".
- [ ] AC-05: Al aplicar un filtro de responsable, solo se muestran las tareas del responsable seleccionado.

## API / Contract Reference
| Contract         | Method                              | Return           |
|------------------|-------------------------------------|------------------|
| TaskRepository   | `getTasks(filters?: TaskFilters)`   | `Promise<Task[]>`|

## Exclusions
- Esta spec no cubre la navegación al formulario de edición al hacer clic en una tarea.
  Eso está en SPEC-002.
- Esta spec no cubre la creación de tareas nuevas. Eso está en SPEC-002.

## Open Questions
- *(Ninguna — todos los escenarios están confirmados por el diseño)*
```

### Por qué cada criterio es así

Observa que cada criterio de aceptación (AC-NN) es **binario y verificable sin ambigüedad**:

| Criterio | ¿Por qué es bueno? |
|---|---|
| AC-01: "renderiza una fila por cada tarea" | Se puede verificar con `screen.getAllByRole('listitem').length` |
| AC-03: "muestra el mensaje 'No hay tareas todavía.'" | Texto exacto → `screen.getByText('No hay tareas todavía.')` |
| AC-04: "muestra el botón 'Reintentar'" | Texto exacto → `screen.getByRole('button', { name: 'Reintentar' })` |

Evita criterios vagos como "la lista se ve bien" o "funciona correctamente" — no son verificables.

### Los tres archivos de spec de TaskFlow

| Archivo | Feature | ACs |
|---|---|---|
| `SPEC_TaskBoard.md` | Tablero y filtros | AC-01 a AC-05 |
| `SPEC_TaskForm.md` | Crear y editar tarea | AC-01 a AC-07 |
| `SPEC_TaskDomain.md` | Entidad Task y validaciones | AC-01 a AC-04 |

> **Gate de esta fase:** No puedes pasar al Scaffold hasta que hayas revisado y aprobado los tres archivos. Si tienes dudas o quieres cambiar un escenario, díselo al agente ahora — cambiar una spec antes de codificar cuesta minutos; cambiarla después cuesta horas.

---

## Fase 6 — Scaffold

**Skill:** `react-scaffold`
**Output:** Estructura de proyecto compilable con las 4 capas
**Gate:** El proyecto compila sin errores

El agente crea la estructura de carpetas siguiendo el Design Document. Las specs ya existen, así que el scaffold genera los archivos vacíos/stub en las ubicaciones correctas:

```
src/
├── domain/
│   ├── entities/
│   │   └── Task.ts          ← interface Task (de SPEC_TaskDomain.md)
│   └── validators/
│       └── taskValidator.ts ← stub, cubrirá AC-01 a AC-04 de SPEC_TaskDomain
├── application/
│   ├── interfaces/
│   │   └── ITaskRepository.ts
│   ├── use-cases/
│   │   ├── useTaskBoard.ts  ← stub para SPEC-001
│   │   └── useCreateTask.ts ← stub para SPEC-002
│   └── types/
│       └── taskTypes.ts
├── infrastructure/
│   └── repositories/
│       └── TaskRepository.ts
└── presentation/
    ├── pages/
    │   └── TaskBoardPage.tsx
    └── components/
        ├── task/
        │   ├── TaskList.tsx     ← cubrirá Scenario 1 y 2 de SPEC-001
        │   └── TaskListItem.tsx
        └── ui/
            └── LoadingSpinner.tsx
```

---

## Fase 7 — Implementation

**Skill:** `implementation`
**Input primario:** Archivos `SPEC_*.md` (NO el Design Document directamente)
**Gate:** Cada criterio de aceptación de cada spec tiene un camino de implementación trazable

El agente implementa **spec por spec**, en orden de dependencia (Domain primero, luego Application, luego Infrastructure, luego Presentation):

### Ejemplo: implementando AC-03 de SPEC-001

El agente lee el criterio:
> AC-03: El estado `empty` muestra el mensaje "No hay tareas todavía."

Y genera el código correspondiente en `TaskList.tsx`:

```tsx
// TaskList.tsx
interface TaskListProps {
  tasks: Task[];
  isLoading: boolean;
  error: Error | null;
  onRetry: () => void;
}

export function TaskList({ tasks, isLoading, error, onRetry }: TaskListProps) {
  if (isLoading) return <LoadingSpinner />;

  if (error) {
    return (
      <div>
        <p>No se pudieron cargar las tareas. Intenta de nuevo.</p>
        <button onClick={onRetry}>Reintentar</button>
      </div>
    );
  }

  if (tasks.length === 0) {
    return <p>No hay tareas todavía.</p>; // AC-03
  }

  return (
    <ul>
      {tasks.map(task => (
        <li key={task.id}>
          <TaskListItem task={task} />
        </li>
      ))}
    </ul>
  );
}
```

> **Nota para principiantes:** Fíjate que el mensaje de texto en el código es **exactamente igual** al texto en la spec (`"No hay tareas todavía."`). Esto es intencional: el agente copia el texto de la spec para que el test pueda buscarlo directamente.

---

## Fase 8 — Testing

**Skill:** `testing` + `react-testing`
**Input primario:** Archivos `SPEC_*.md` + código implementado
**Gate:** Cada AC de cada spec tiene al menos un test que pasa

El agente mapea **cada escenario de la spec a un test case nombrado con el ID del escenario**. Esto hace que cuando un test falla, sepas exactamente qué escenario está roto.

### Tests generados desde `SPEC_TaskBoard.md`

```typescript
// TaskList.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { TaskList } from './TaskList';

const mockTasks = [
  { id: '1', title: 'Diseñar mockups', assignee: 'Ana', priority: 'high', status: 'todo', createdAt: new Date() },
  { id: '2', title: 'Revisar PR',     assignee: 'Luis', priority: 'medium', status: 'in-progress', createdAt: new Date() },
];

// SPEC-001 Scenario 1 — Carga inicial con tareas existentes
test('SPEC-001-S1: muestra todas las tareas cuando el repositorio tiene datos', () => {
  render(<TaskList tasks={mockTasks} isLoading={false} error={null} onRetry={() => {}} />);
  expect(screen.getAllByRole('listitem')).toHaveLength(2); // AC-01
  expect(screen.getByText('Diseñar mockups')).toBeInTheDocument();
  expect(screen.getByText('Revisar PR')).toBeInTheDocument();
});

// SPEC-001 Scenario 2 — Carga inicial sin tareas — cubre AC-03
test('SPEC-001-S2: muestra mensaje de lista vacía cuando no hay tareas', () => {
  render(<TaskList tasks={[]} isLoading={false} error={null} onRetry={() => {}} />);
  expect(screen.getByText('No hay tareas todavía.')).toBeInTheDocument(); // AC-03
});

// SPEC-001 Scenario 3 — Estado de carga — cubre AC-02
test('SPEC-001-S3: muestra spinner durante la carga', () => {
  render(<TaskList tasks={[]} isLoading={true} error={null} onRetry={() => {}} />);
  expect(screen.getByRole('status')).toBeInTheDocument(); // AC-02: spinner con role="status"
  expect(screen.queryByText('No hay tareas todavía.')).not.toBeInTheDocument();
});

// SPEC-001 Scenario 4 — Error al cargar — cubre AC-04
test('SPEC-001-S4: muestra error y botón reintentar cuando falla la carga', async () => {
  const onRetry = vi.fn();
  render(<TaskList tasks={[]} isLoading={false} error={new Error('Network error')} onRetry={onRetry} />);
  expect(screen.getByText('No se pudieron cargar las tareas. Intenta de nuevo.')).toBeInTheDocument(); // AC-04
  await userEvent.click(screen.getByRole('button', { name: 'Reintentar' }));
  expect(onRetry).toHaveBeenCalledOnce();
});
```

> **Nota para principiantes:** Los nombres de los tests empiezan con `SPEC-001-S1`, `SPEC-001-S2`, etc. Cuando ejecutas los tests y uno falla, sabes inmediatamente que el Scenario 1 de SPEC-001 está roto — sin necesidad de leer el código.

---

## Fase 9 — Review

**Skill:** `review` + `react-reviewer`
**Input primario:** Specs + código + tests + `conventions.md`
**Gate:** Sin violations bloqueantes, incluyendo conformidad con specs

El agente de revisión valida tres cosas nuevas que no existían antes de SDD:

### Informe de conformidad con specs (extracto)

```markdown
## Spec Conformance Summary

| Spec ID  | Feature       | ACs Total | ACs Covered | ACs Missing |
|----------|---------------|-----------|-------------|-------------|
| SPEC-001 | Task Board    | 5         | 5           | 0           |
| SPEC-002 | Task Form     | 7         | 6           | 1 ← bloqueante |
| SPEC-003 | Task Domain   | 4         | 4           | 0           |

### Blocking — SPEC-002 AC-06 sin cobertura
- **Criterion:** "AC-06: Al guardar una tarea con título vacío, el campo se marca en rojo y no se envía el formulario."
- **Status:** No existe test que valide esta condición. No existe código de validación visual en `TaskForm.tsx`.
- **Action required:** Implementar validación visual en el campo título y añadir el test correspondiente.
```

Cuando el agente detecta un AC sin cobertura, lo clasifica automáticamente como `blocking`. No puedes dar el trabajo por terminado hasta que ese AC esté cubierto.

---

## Flujo resumido: lo que haces tú vs. lo que hace el agente

| Fase | Tú haces | El agente hace |
|---|---|---|
| Kickoff | Respondes las preguntas | Produce `PROJECT_INTAKE.md` |
| Planning | Apruebas el plan | Genera el `PROJECT_PLAN.md` con 9 fases |
| Analysis | Corriges si algo no refleja tu proyecto | Identifica casos de uso y límites de capas |
| Design | Apruebas la arquitectura | Produce el Design Document con contratos y modelos |
| **Specification** | **Revisas y apruebas cada SPEC file** | **Genera `SPEC_<Feature>.md` con escenarios y ACs** |
| Scaffold | Verificas que el proyecto compila | Crea la estructura de carpetas y stubs |
| Implementation | Revisas el código generado | Implementa spec por spec, AC por AC |
| Testing | Verificas los resultados | Genera tests nombrados por escenario y spec ID |
| Review | Resuelves los bloqueantes encontrados | Valida conformidad spec + SOLID + convenciones |

---

## Los 5 errores más comunes al empezar con SDD

### 1. Pasar de Design directamente a Scaffold (saltarse Specification)
**Problema:** El agente empieza a codificar sin saber qué comportamiento exacto se espera.
**Solución:** Si el agente intenta generar código antes de que hayas visto los archivos `SPEC_*.md`, escríbele:
> "Para. Primero necesito revisar las especificaciones. Usa el skill `specification` con el Design Document."

### 2. Aprobar una spec con Open Questions sin resolver
**Problema:** El agente asume comportamientos no definidos y genera código inconsistente.
**Solución:** Si un `SPEC_*.md` tiene la sección `## Open Questions` con items sin tachar, no lo apruebes. Responde las preguntas primero.

### 3. Usar criterios de aceptación vagos
**Problema:** "La lista funciona correctamente" no tiene test posible.
**Solución:** Pide al agente que reformule criterios vagos. Un buen criterio siempre tiene un sujeto concreto, una condición observable y un valor exacto.

### 4. Modificar el código sin actualizar la spec
**Problema:** La spec y el código divergen. Los tests empiezan a fallar por razones confusas.
**Solución:** Si necesitas cambiar el comportamiento, actualiza la spec primero. El agente detectará la inconsistencia en la fase de Review si no lo haces.

### 5. Crear una spec que mezcla capas
**Problema:** Una spec de componente que describe comportamiento de base de datos, o viceversa.
**Solución:** Cada spec cubre exactamente una capa. Si descubres que necesitas describir comportamiento de dos capas, divídela en dos archivos.

---

## Comandos de referencia rápida

| Momento | Qué escribirle al agente |
|---|---|
| Empezar un proyecto | "Tengo un proyecto nuevo. \<descripción breve\>" |
| Iniciar las specs | "El diseño está aprobado. Genera las especificaciones con el skill `specification`." |
| Revisar una spec | "Muéstrame el SPEC de \<feature\>. Quiero revisar los escenarios antes de aprobarlo." |
| Corregir un escenario | "En SPEC-001, el Scenario 3 no es correcto. Cuando hay error debería mostrar \<comportamiento correcto\>." |
| Aprobar y avanzar | "Las specs están aprobadas. Procede con el scaffold." |
| Verificar cobertura | "¿Qué ACs de las specs están sin implementar?" |
| Solicitar el reporte final | "Genera el Review Report validando conformidad con todas las specs." |

---

## Lectura adicional

- [Ciclo de vida completo (sin SDD)](project-lifecycle-guide.md) — guía de referencia con el ciclo de 8 fases original
- [Descripción del framework](new-project-lifecycle.md) — documento técnico del ciclo de vida
- [Patrón React](react-pattern.md) — convenciones y decisiones del patrón React
- [Framework AI Enhancement Phase](framework-ai-enhancement-phase.md) — contexto de evolución del framework
