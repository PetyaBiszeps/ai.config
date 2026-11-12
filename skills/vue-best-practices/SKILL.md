---
name: vue-best-practices
description: Vue 3 best practices for reactivity, SFCs, component data flow, composables, SSR, and modern Vue APIs. Use for Vue components or Vue-related code; follow the repository stack and preserve existing architectural conventions.
license: MIT
metadata:
  author: github.com/vuejs-ai
  version: "18.0.0"
---

# Vue Best Practices Workflow

Use this skill as an instruction set. Follow the workflow in order unless the user explicitly asks for a different order.

## Core Principles
- **Keep state predictable:** one source of truth, derive everything else.
- **Make data flow explicit:** Props down, Events up for most cases.
- **Choose useful component boundaries:** split by responsibility, reuse, or testability; avoid needless component extraction.
- **Avoid unnecessary re-renders:** use computed properties and watchers wisely.
- **Readability counts:** write clear, self-documenting code.

## 1) Confirm the project's architecture and Vue version

- Inspect the repository's Vue version, conventions, framework (including Nuxt), and existing tooling before suggesting an API.
- For new Vue 3 SFCs, prefer Composition API with `<script setup lang="ts">` when TypeScript is in use. Respect JavaScript-only projects and established conventions.
- Preserve existing Options API components in legacy code unless migration is requested or clearly justified. Use `vue-options-api-best-practices` when available and relevant.
- Treat JSX as an explicit project choice; do not introduce it just for consistency.

### 1.1 Read references selectively

- Start with `references/reactivity.md`, `references/sfc.md`, `references/component-data-flow.md`, or `references/composables.md` **only when the task touches that topic**.
- Load additional references for specific APIs or problems. Do not load all four core references for every small Vue edit.
- Prioritize verified project conventions and official documentation over an example that targets another Vue version.

### 1.2 Plan component boundaries proportionately

- For a non-trivial feature, outline components and their state/data ownership when that improves implementation clarity.
- Keep route components straightforward, but do not force them to be empty wrappers.
- Extract a component when it has a genuinely independent responsibility, meaningful reuse, complex lifecycle, or a separately testable UI contract.
- Extract composables for reused or meaningfully complex stateful logic, not merely to reduce line counts.
- Avoid numeric split thresholds, obligatory feature-folder structures, and mandatory multi-component CRUD templates.

## 2) Apply relevant Vue foundations

### Reactivity — [reactivity](references/reactivity.md)

- Prefer `ref()` for ordinary local state, including primitives; use `reactive()` when object-style mutation makes sense.
- Reserve `shallowRef()` / `shallowReactive()` for explicit shallow-reactivity needs, large immutable structures, or external/opaque objects.
- Derive values with `computed()` and use `watch()` / `watchEffect()` for reactive side effects. Handle stale async operations when relevant.

### SFCs and modern Vue APIs — [sfc](references/sfc.md)

- Match the project's SFC structure and styling conventions; keep templates readable and safe.
- In Vue 3.5+, destructured `defineProps()` bindings are reactive inside the same `<script setup>` block. Pass `() => propName` to watchers or composables when a reactive source is needed.
- In Vue 3.5+, prefer `useTemplateRef()` for DOM/component template refs, including refs inside `v-for` where an array is produced.
- In Vue 3.5+, use `useId()` when stable SSR-safe IDs are needed for form labels or accessibility attributes.
- `defineModel()` is available in Vue 3.4+ for two-way component contracts; beware of child defaults desynchronizing from an undefined parent model.

### Component data flow — [component-data-flow](references/component-data-flow.md)

- Prefer explicit props and emits for parent-child communication; use `v-model` only when two-way binding is the desired contract.
- Use provide/inject for appropriate cross-tree context, with typed keys when useful.

### Composables — [composables](references/composables.md)

- Prefer small, predictable APIs and extract reused or complex stateful behavior when helpful.
- For genuinely reusable inputs, consider `MaybeRefOrGetter<T>` and normalize with `toValue()` **inside a tracked reactive getter/effect** when the input must remain reactive.
- Do not make every composable library-grade by default. For writable inputs, require a writable `Ref<T>` when changes must propagate to the caller; a plain value cannot be mutated by reference.
- Account for SSR: browser globals and DOM effects must run only in a client-safe context, with cleanup where needed.

## 3) Consider optional features only when requirements call for them

### 3.1 Standard optional features

Do not add these by default. Load the matching reference only when the requirement exists.

- Slots: parent needs to control child content/layout -> [component-slots](references/component-slots.md)
- Fallthrough attributes: wrapper/base components must forward attrs/events safely -> [component-fallthrough-attrs](references/component-fallthrough-attrs.md)
- Built-in component `<KeepAlive>` for stateful view caching -> [component-keep-alive](references/component-keep-alive.md)
- Built-in component `<Teleport>` for overlays/portals -> [component-teleport](references/component-teleport.md)
- Built-in component `<Suspense>` for async subtree fallback boundaries -> [component-suspense](references/component-suspense.md)
- Animation-related features: pick the simplest approach that matches the required motion behavior.
  - Built-in component `<Transition>` for enter/leave effects -> [transition](references/component-transition.md)
  - Built-in component `<TransitionGroup>` for animated list mutations -> [transition-group](references/component-transition-group.md)
  - Class-based animation for non-enter/leave effects -> [animation-class-based-technique](references/animation-class-based-technique.md)
  - State-driven animation for user-input-driven animation -> [animation-state-driven-technique](references/animation-state-driven-technique.md)

### 3.2 Less-common optional features

Use these only when there is explicit product or technical need.

- Directives: behavior is DOM-specific and not a good composable/component fit -> [directives](references/directives.md)
- Async components: heavy/rarely-used UI should be lazy loaded -> [component-async](references/component-async.md)
- Render functions only when templates cannot express the requirement -> [render-functions](references/render-functions.md)
- Plugins when behavior must be installed app-wide -> [plugins](references/plugins.md)
- State management patterns: app-wide shared state crosses feature boundaries -> [state-management](references/state-management.md)

## 4) Run performance optimization after behavior is correct

Performance work is a post-functionality pass. Do not optimize before core behavior is implemented and verified.

- Large list rendering bottlenecks -> [perf-virtualize-large-lists](references/perf-virtualize-large-lists.md)
- Static subtrees re-rendering unnecessarily -> [perf-v-once-v-memo-directives](references/perf-v-once-v-memo-directives.md)
- Over-abstraction in hot list paths -> [perf-avoid-component-abstraction-in-lists](references/perf-avoid-component-abstraction-in-lists.md)
- Expensive updates triggered too often -> [updated-hook-performance](references/updated-hook-performance.md)

## 5) Final self-check before finishing

- Behavior matches the request and existing project conventions.
- Reactive state and derived values are used appropriately; shallow state is intentional.
- Component boundaries and composable extraction solve real problems rather than satisfy arbitrary size rules.
- Vue version-specific APIs match the installed version.
- Watchers clean up stale side effects, and browser-only code is SSR-safe when needed.
- Relevant references were consulted; irrelevant documentation was not loaded by default.
- Test, type-check, and visually verify the affected behavior when tooling is available.
