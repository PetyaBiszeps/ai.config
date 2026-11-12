# Components, composables, and plugins — Nuxt 3/4

Use for discovery, unavailable-context errors, initialization, and lifecycle boundaries. Generic Vue component design belongs in the Vue skills.

## Discovery and reuse

- Resolve the app source directory before using `components/`, `composables/`, `utils/`, or `plugins/`. Auto-imports can be customized/disabled by config or layers.
- Components are named from their paths by default; check generated names before adding manual registrations. Use `#components` for explicit component imports and `#imports` for app auto-imported composables when needed.
- Custom composables are scanned at the top level by default, not recursively. Re-export selected nested helpers from a top-level file or use explicit imports; do not widen scan globs unnecessarily.
- A generated declaration is not a runtime global. Do not use app auto-imports in arbitrary Node scripts, modules, or server code and assume the same context.
- Reuse existing composables; don't wrap `useFetch` just to rename it. If a wrapper adds real policy, preserve the async-data return contract and installed-version behavior.

## Nuxt context

Call `useNuxtApp`, `useRuntimeConfig`, `useState`, and similar context-dependent composables **inside** setup, a Nuxt plugin, or route middleware—not at module evaluation.

Nuxt 3/4, app-source `composables/useApiBase.ts`:

```ts
export function useApiBase () {
  const config = useRuntimeConfig()
  return config.public.apiBase
}
```

The caller must have Nuxt context. Capture context/config synchronously before arbitrary async callbacks; pass ordinary values or an injected service into those callbacks instead of calling composables there. Nuxt transforms supported setup/plugin/middleware contexts, but does not make every async function context-safe.

For an unavoidable context-sensitive callback, use the captured Nuxt app's supported `runWithContext` only after verifying the installed version. Do not enable experimental async context to conceal an architectural error.

## Plugins and lifecycle

- `defineNuxtPlugin` initializes the **Vue app**. Universal plugins execute during SSR and client startup; `.client.ts` and `.server.ts` restrict the side.
- Keep per-request service instances inside the plugin factory, not module scope. Don't add heavyweight global plugins when a local composable suffices.
- Top-level plugin files are discovered automatically. Preserve ordering where injections depend on earlier plugins; verify minor support before adding object-plugin options.
- Return `{ provide: { service } }` when an app-wide injected service is justified; consumers access `useNuxtApp().$service`. Follow existing injection typing.
- A Nuxt plugin has Nuxt context, not a mounted component instance. Component-dependent hooks/composables may not work there.
- Component setup may run on both sides; `onMounted` is client-only. Dispose timers/subscriptions/listeners on unmount.
- `server/plugins/` contains **Nitro plugins**, not `defineNuxtPlugin`. Nuxt modules configure the build, not each request.
- Never edit `.nuxt/` declarations to fix discovery. Inspect source/config first; when execution is permitted, use the repository's existing prepare/dev workflow to regenerate them.

Sources: [4.x auto-imports](https://nuxt.com/docs/4.x/guide/concepts/auto-imports), [3.x plugins](https://nuxt.com/docs/3.x/directory-structure/plugins), [4.x plugins](https://nuxt.com/docs/4.x/directory-structure/app/plugins), [4.x composables](https://nuxt.com/docs/4.x/directory-structure/app/composables).
