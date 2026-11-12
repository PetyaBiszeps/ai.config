# Nuxt 4 defaults and differences

Primary stable overlay. Apply only the behavior supported by the installed **minor** and effective config; don't migrate a working v3-layout project merely because it runs Nuxt 4.

## App source versus root

Default layout:

```text
app/
  app.vue  app.config.ts  error.vue  router.options.ts
  pages/  layouts/  middleware/  components/  composables/  plugins/  utils/
server/  shared/  public/  modules/  layers/
nuxt.config.ts
```

- Default `srcDir` is `app/`; `~`/`@` point there. `~~`/`@@` point to the root: `~/components/Button.vue` versus `~~/shared/types/item`.
- `serverDir` defaults to root `server/`, even with a custom `srcDir`. `public/`, `modules/`, `layers/`, and `shared/` are root-side conventions; explicit config can override paths.
- App config, plugins, pages, route middleware, and app assets belong under resolved `srcDir`. `nuxt.config.ts` does not move into `app/`.
- `dir.app` defaults to `srcDir` for `router.options.ts` and `spa-loading-template.html`, unlike the v3 support directory.
- Nuxt retains backward-compatible old-layout detection. Honor explicit `srcDir: '.'` and directory settings. Inspect actual source/config/generated aliases rather than moving files automatically.
- `shared/` contains runtime-neutral code/types for app and server. It cannot rely on Vue/Nitro context or contain secrets. Do not import server implementations into the app via a shared barrel.

## Async data changes that affect edits

| v4 default/change | Practical consequence |
| --- | --- |
| `data` is shallow (`deep: false`) | Replace the object when updating; use local `deep: true` only if nested mutation reactivity is required |
| Initial `data` and `error` are `undefined` | Don't use strict `=== null` checks for loading/success |
| Same-key consumers share data/error/status refs | Keep handlers/options consistent; check other consumers before altering a query |
| `pending` tracks active fetching, not idle | Check `status`; initiate `immediate: false` queries explicitly |
| Non-immediate reactive-key changes wait until first execution | Call `execute`/`refresh` once; don't rely on an option/key change to start |
| Clearing async data respects its `default` factory | Reset does not necessarily make data nullish |
| Boolean refresh `dedupe` aliases removed | Use `'cancel'` or `'defer'` |

Reactive async-data keys are supported. `getCachedData` can participate in watcher/manual/hook refreshes and receive the request cause; custom cache policies must allow deliberate refresh to bypass stale entries. Cached data can be purged when the final consumer unmounts; it is not durable app storage. Relevant flags/config can override these behaviors.

Shared prerender data can reuse keyed results across pages. Include the page/resource identity in keys; the same key cannot represent different content on two prerendered routes.

## Server conventions: distinguish two supported surfaces

**Default Nitro v2/h3 v1:** Existing auto-imported `defineEventHandler`, h3 helpers, `defineNitroPlugin`, `event.context`, and `useRuntimeConfig(event)` remain valid. Shared server examples use this baseline. Nuxt 4 is **not** inherently Nitro v3/h3 v2.

**Nuxt 4.6+ optional `nuxt/server` surface:** Official docs introduce runtime-independent helpers with a different event contract. Use only when the installed minor exports them and the task/project calls for this surface.

Nuxt **4.6+ only**, `server/api/hello.get.ts`:

```ts
import { defineEventHandler, getQuery } from 'nuxt/server'

export default defineEventHandler((event) => {
  const query = getQuery(event)
  return { message: typeof query.name === 'string' ? query.name : 'world' }
})
```

- Import the handler and its helpers from the **same** surface. Mixing h3's auto-imported handler with `nuxt/server` helpers can produce `NUXT_E8012`.
- This surface uses `createError({ status, statusText })`, `useRuntimeConfig()` without an event, and Web-style event access. Do not mechanically apply those semantics to h3 v1 handlers.
- For a helper outside that surface, keep the handler/helpers together on the supported h3/Nitro runtime instead of mixing event models.
- Do not introduce `#server` into earlier minors: that server-only alias is documented from **4.3**. Relative/existing aliases remain valid.
- No server-import migration is required for ordinary Nuxt 4 maintenance.

## Other meaningful boundaries

- Generated TypeScript configurations split app/server/shared/tooling contexts. Preserve the existing root project's references; do not collapse them or import app-only auto-imports into server code.
- Layer module execution now runs extended-layer modules before project modules. Check order-sensitive hooks rather than reordering layers indiscriminately.
- Nuxt 4 uses Unhead v2. Prefer Nuxt's `useHead`/`useSeoMeta`; do not copy older Unhead internals into a v4 app.
- `future.compatibilityVersion: 5` is an explicit preview opt-in supported from 4.2, not the normal v4 baseline. Read the v5 reference only for relevant opted-in behavior; do not enable it as a routine fix.

Sources: [4.x upgrade guide](https://nuxt.com/docs/4.x/getting-started/upgrade), [4.x app directory](https://nuxt.com/docs/4.x/directory-structure/app), [4.x async data](https://nuxt.com/docs/4.x/api/composables/use-async-data), [4.x server](https://nuxt.com/docs/4.x/directory-structure/server), [4.6+ server imports](https://nuxt.com/docs/4.x/guide/going-further/server-imports).
