---
title: State Management Strategy
impact: HIGH
impactDescription: Choosing the wrong store pattern can cause SSR request leaks, brittle mutation flows, and poor scaling
type: best-practice
tags: [vue3, state-management, pinia, composables, ssr, vueuse]
---

# State Management Strategy

**Impact: HIGH** - Use the lightest state solution that fits your architecture. SSR needs request-isolated state: Nuxt `useState()` can be appropriate for simple serializable shared state, while Pinia supports more structured shared state and tooling.

## Task List

- Keep state local first, then promote to shared/global only when needed
- Use singleton composables only in non-SSR applications
- Expose global state as readonly and mutate through explicit actions
- In Nuxt, consider `useState()` for small SSR-safe state; use Pinia when stores/actions/plugins/devtools justify it
- Avoid exporting mutable module-level reactive state directly

## Choose the Lightest Store Approach

- **Feature composable:** Default for reusable logic with local/feature-level state.
- **Singleton composable or VueUse `createGlobalState`:** Small non-SSR apps needing shared app state.
- **Nuxt `useState()`:** Simple serializable shared state scoped per SSR request; avoid secrets in client-hydrated state.
- **Pinia:** Complex shared domains, stores/actions/plugins/DevTools, or teams already using Pinia. Use framework integration (`@pinia/nuxt`) in Nuxt.

## Avoid Exporting Mutable Module State

**BAD:**
```ts
// store/cart.ts
import { reactive } from 'vue'

export const cart = reactive({
  items: [] as Array<{ id: string; qty: number }>
})
```

**GOOD:**
```ts
// composables/useCartStore.ts
import { reactive, readonly } from 'vue'

let _store: ReturnType<typeof createCartStore> | null = null

function createCartStore() {
  const state = reactive({
    items: [] as Array<{ id: string; qty: number }>
  })

  function addItem(id: string, qty = 1) {
    const existing = state.items.find((item) => item.id === id)
    if (existing) {
      existing.qty += qty
      return
    }
    state.items.push({ id, qty })
  }

  return {
    state: readonly(state),
    addItem
  }
}

export function useCartStore() {
  if (!_store) _store = createCartStore()
  return _store
}
```

## Do Not Use Runtime Singletons in SSR

Module singletons live for the runtime lifetime. In SSR this can leak state between requests.

**BAD:**
```ts
// shared singleton reused across requests
const cartStore = useCartStore()

export function useServerCart() {
  return cartStore
}
```

**GOOD:**

> `pinia` dependency required.

```ts
// stores/cart.ts
import { defineStore } from 'pinia'

export const useCartStore = defineStore('cart', {
  state: () => ({
    items: [] as Array<{ id: string; qty: number }>
  }),
  actions: {
    addItem(id: string, qty = 1) {
      const existing = this.items.find((item) => item.id === id)
      if (existing) {
        existing.qty += qty
        return
      }
      this.items.push({ id, qty })
    }
  }
})
```

## Use `createGlobalState` for Small SPA Global State

> `@vueuse/core` dependency required.

If the app is non-SSR and already uses VueUse, `createGlobalState` removes singleton boilerplate.

```ts
import { createGlobalState } from '@vueuse/core'
import { computed, ref } from 'vue'

export const useAuthState = createGlobalState(() => {
  const token = ref<string | null>(null)
  const isAuthenticated = computed(() => token.value !== null)

  function setToken(next: string | null) {
    token.value = next
  }

  return {
    token,
    isAuthenticated,
    setToken
  }
})
```
