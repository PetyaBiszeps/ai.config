---
category: State
related: createGlobalState
---

# createSharedComposable

Make a composable function usable with multiple Vue instances.

> [!WARNING]
> In versions implementing the server fallback, `createSharedComposable` returns the original composable during SSR rather than sharing its result. Verify the installed implementation before relying on this behavior; older versions may differ.
> This does not isolate mutable refs, caches, or subscriptions captured outside the composable, nor does it transfer state in the Nuxt payload. Do not use it as a request-scoped store or assume it prevents all [cross-request state pollution](https://vuejs.org/guide/scaling-up/ssr.html#cross-request-state-pollution). Prefer Nuxt's `useState` for SSR-safe shared state.

## Usage

```ts
import { createSharedComposable, useMouse } from '@vueuse/core'

const useSharedMouse = createSharedComposable(useMouse)

// CompA.vue
const { x, y } = useSharedMouse()

// CompB.vue - on the client, reuse state without registering new event listeners
const { x, y } = useSharedMouse()
```

## Type Declarations

```ts
export type SharedComposableReturn<T extends AnyFn = AnyFn> = T
/**
 * Make a composable function usable with multiple Vue instances.
 *
 * @see https://vueuse.org/createSharedComposable
 *
 * @__NO_SIDE_EFFECTS__
 */
export declare function createSharedComposable<Fn extends AnyFn>(
  composable: Fn,
): SharedComposableReturn<Fn>
```
