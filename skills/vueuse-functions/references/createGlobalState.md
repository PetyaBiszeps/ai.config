---
category: State
related: createSharedComposable
---

# createGlobalState

Keep states in the global scope to be reusable across Vue instances.

> [!WARNING]
> The module-level examples below are for client-only sharing. On an SSR server, a module-level `createGlobalState` can retain mutable state across requests, including user-specific data. Do not use it as a Nuxt SSR store: prefer Nuxt's `useState` or existing SSR-configured Pinia stores. If a custom factory is necessary, create it and all captured mutable state separately for each app/request.
> Adding `useStorage` does not make a global store request-isolated or hydrate it through Nuxt; see [browser storage and hydration](useStorage.md#ssr-and-nuxt).

## Usage

### Without Persistence (Store in Memory)

```ts
// store.ts
import { createGlobalState } from '@vueuse/core'
import { shallowRef } from 'vue'

export const useGlobalState = createGlobalState(
  () => {
    const count = shallowRef(0)
    return { count }
  }
)
```

A bigger example:

```ts
// store.ts
import { createGlobalState } from '@vueuse/core'
import { computed, shallowRef } from 'vue'

export const useGlobalState = createGlobalState(
  () => {
    // state
    const count = shallowRef(0)

    // getters
    const doubleCount = computed(() => count.value * 2)

    // actions
    function increment() {
      count.value++
    }

    return { count, doubleCount, increment }
  }
)
```

### With Persistence

Store in `localStorage` with `useStorage`:

```ts twoslash include store
// store.ts
import { createGlobalState, useStorage } from '@vueuse/core'

export const useGlobalState = createGlobalState(
  () => useStorage('vueuse-local-storage', 'initialValue'),
)
```

```ts
// @filename: store.ts
// @include: store
// ---cut---
// component.ts
import { useGlobalState } from './store'

export default defineComponent({
  setup() {
    const state = useGlobalState()
    return { state }
  },
})
```

## Type Declarations

```ts
export type CreateGlobalStateReturn<Fn extends AnyFn = AnyFn> = Fn
/**
 * Keep states in the global scope to be reusable across Vue instances.
 *
 * @see https://vueuse.org/createGlobalState
 * @param stateFactory A factory function to create the state
 *
 * @__NO_SIDE_EFFECTS__
 */
export declare function createGlobalState<Fn extends AnyFn>(
  stateFactory: Fn,
): CreateGlobalStateReturn<Fn>
```
