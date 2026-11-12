# State management — Nuxt 3/4

Keep existing store conventions. Delegate store internals to `vue-pinia-best-practices`.

| State | Preferred home |
| --- | --- |
| Component-only interaction | Local `ref`/`reactive` |
| Shareable/bookmarkable filters | Route params/query |
| Server-owned fetched results | `useFetch`/`useAsyncData`, not a duplicate store |
| Small app-wide SSR-aware state | Keyed `useState` composable |
| Existing or complex domain stores/actions | Pinia with compatible Nuxt integration |
| Server request identity/authorization | Server request context, never client state as authority |

Nuxt 3/4, `composables/useCartCount.ts` under the existing app source:

```ts
export function useCartCount () {
  return useState<number>('cart:count', () => 0)
}
```

Call it inside setup or another valid Nuxt context. Calls with this key share state within the Nuxt app; SSR initializes it per request and serializes it for hydration.

## Rules

- Export a **function**, not a module-level `ref` or eagerly invoked `useState`. A server module singleton can leak state between users.
- Use stable, unique keys and compatible initializers. Do not generate a new random key every render.
- Use serializable data, not functions, symbols, service clients, or class instances. Treat serialized state as client-visible: include only data the current user is authorized to receive. Keep credentials and session secrets on the server.
- `useState` is not durable persistence or a cross-user server cache. Use cookies/storage only when persistence is required and safe, with an SSR-consistent initial value.
- Clear user-specific state and async-data caches on logout/account switch. Do not assume `clearNuxtState` resets to its initializer: v5 compatibility changes that behavior.
- Use `@pinia/nuxt` only if already present or stores are warranted; verify its version against Nuxt. Never create a global server store instance shared across requests.
- For Pinia initialization, use the integration's SSR pattern. Where supported, `callOnce` avoids repeating an initialization side effect during hydration; it was introduced in Nuxt 3.9. Verify navigation-mode support separately. Do not put a void-returning store action inside `useAsyncData`.

Sources: [3.x state](https://nuxt.com/docs/3.x/getting-started/state-management), [4.x state](https://nuxt.com/docs/4.x/getting-started/state-management), [3.x callOnce version notes](https://nuxt.com/docs/3.x/api/utils/call-once).
