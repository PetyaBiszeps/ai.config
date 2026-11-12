# Data fetching — Nuxt 3/4

Use in setup/composables for initial data, refresh behavior, or missing cookies. Read the major overlay for defaults; newer 3.x/4.x docs can include APIs absent from older minors.

## Choose the boundary

| Need | Use |
| --- | --- |
| Initial HTTP data rendered by a page/component | `useFetch` |
| SDK, aggregation, or other async read with payload transfer | `useAsyncData` |
| Click/submit mutation, server-to-server request, imperative action | `$fetch` |

`$fetch` alone in universal setup runs on both server and client without transferring its result. `useFetch`/`useAsyncData` serialize data into the Nuxt payload so hydration can reuse it. Do not put mutations or store-initialization side effects inside an async-data handler.

Nuxt 3.6+/4, in an existing page's `<script setup>` (endpoint returns an array; `status` was added in 3.6):

```ts
const page = ref(1)
const { data: posts, status, error, refresh } = await useFetch('/api/posts', {
  query: { page },
  default: () => [],
})
// In the template: distinguish idle/pending, error, success-with-empty-data.
// In script, refs require .value; await refresh() after a successful mutation.
```

Keep URLs/options reactive (a getter URL or refs in `query`). Avoid destructuring a route parameter into a stale constant. `watch: false` disables option watching; trigger `refresh` deliberately instead.

For aggregation or another async read, use an explicit key and return the result:

```ts
const { data: summary } = await useAsyncData('public-summary', async () => {
  const [posts, categories] = await Promise.all([
    $fetch('/api/posts'),
    $fetch('/api/categories'),
  ])
  return { posts, categories }
})
```

That example is for public data. Plain `$fetch` does not forward the incoming user's cookies on SSR. Return a serializable, defined result; `undefined`/`null` can cause a client refetch. Represent an empty result explicitly, e.g. `[]` or `{ item: null }`.

## Payload, keys, and cache

- A key identifies a result. Include relevant resource/filter/locale identity; never embed secrets or raw auth tokens in keys.
- Calls sharing a key must agree on handler, shape, `deep`, `pick`, `transform`, `default`, and `getCachedData`. Do not reuse one key for unrelated queries. Auto-generated `useFetch` key behavior varies by version; use an explicit shared key when sharing is intentional.
- Hydration reuse is **not** a persistent HTTP cache or a freshness guarantee. Default cached-data lookup uses hydration payload/static data; extraction settings affect reuse. A custom `getCachedData` needs expiry/invalidation and must return `undefined` for a miss. Invocation on refresh/watch differs by version.
- Use returned `refresh`/`execute` for this query; `refreshNuxtData(key)` for keyed consumers. Use `clearNuxtData(key)` to invalidate/reset Nuxt async data, not a CDN or database cache. Clear private results on logout/account changes.
- `pick`/`transform` reduce serialized payload size, not authorization requirements or necessarily upstream bandwidth. Filter secret fields **on the server** before returning them.
- `dedupe: 'cancel'` supersedes a pending request; `'defer'` reuses an in-flight request. Actual network abortion depends on version and handler support—do not assume every Nuxt 3 minor supplies a handler abort signal.

## Timing and errors

- Default SSR fetching waits for initial data. `lazy: true` allows non-blocking client navigation; show loading/error/empty states. Awaiting a lazy call does not guarantee data is ready on the client.
- With `server: false`, initial fetching waits until hydration completes; even `await useFetch(...)` does not make data available during initial setup.
- With `immediate: false`, explicitly initiate using `execute`/`refresh`; do not rely on `pending` to distinguish an unstarted request from a running one.
- Inspect `error`/`status` (`status` requires 3.6+; older v3 uses `pending` plus error/data checks); fetch failures are exposed as state. Keep recoverable failures inline with retry; promote a genuinely missing required resource to a page error. A success with no items is not a network error.
- A custom fetch composable should return the built-in result, not internally await it; await at the call site. Preserve project wrappers and verify their installed-version recipe before changing them.

## Request context

By default, `useFetch` uses Nuxt's request-aware fetch for relative internal URLs during SSR, forwarding appropriate incoming headers and cookies. Custom `$fetch` implementations may require explicit handling. For custom async-data handlers needing authentication, capture `useRequestFetch()` synchronously in setup if supported by the installed minor, or explicitly forward an allowlist using `useRequestHeaders(['cookie'])`.

Never forward all incoming headers to an external host. SSR API responses' `Set-Cookie` headers are not automatically copied to the browser response; propagate required cookies deliberately with the supported server helpers.

Sources: [3.x fetching](https://nuxt.com/docs/3.x/getting-started/data-fetching), [4.x fetching](https://nuxt.com/docs/4.x/getting-started/data-fetching), [4.x async data](https://nuxt.com/docs/4.x/api/composables/use-async-data), [3.6 async-data status source](https://github.com/nuxt/nuxt/blob/v3.6.0/packages/nuxt/src/app/composables/asyncData.ts).
