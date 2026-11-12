# SSR and hydration — Nuxt 3/4

Use for server crashes, cross-user leakage, or different server/client markup.

## Request isolation and secrets

- Universal setup/plugins run on the server for each rendered request, then in the browser. Imported module scope can survive across requests.
- Never keep user data, mutable refs, cookies, auth clients, or request headers in module-level singletons. Create them in setup, a Nuxt plugin, `useState`, or the request handler. Server-wide connection pools may be reused, but must not hold per-user state.
- `useState` and async-data results are serialized to the client. Include only data the current user is authorized to receive; never include secrets or server-only credentials. App config is public, and client-side plugin injections are accessible in the browser. Keep private runtime config server-side. SSR does not make serialized data private.
- Prerendering and shared response caches must never capture a logged-in user's HTML or payload.

## Make the first render deterministic

Server HTML must match the client's **initial** render:

1. Compare the server response and initial hydrated tree; inspect browser hydration warnings and payload, not just the final DOM.
2. Check invalid HTML nesting, random/time-based output, locale/timezone differences, stale payloads, and auth/cookie differences.
3. Serialize a stable initial value with `useState` or async data; use explicit locale/timezone when formatting.
4. Delay browser-derived changes until mount. Prefer CSS for viewport-dependent presentation.

Nuxt 3/4, component setup:

```vue
<script setup lang="ts">
const theme = ref('light') // same initial value on server and client
onMounted(() => {
  theme.value = localStorage.getItem('theme') || 'light'
})
</script>

<template>
  <p>Theme: {{ theme }}</p>
</template>
```

If the server must know a preference initially, use an SSR-readable cookie rather than localStorage.

## Browser-only code

- Access `window`, `document`, localStorage, DOM libraries, and observers only on the client, normally in `onMounted` or a `.client.ts` plugin. Clean up listeners/timers on unmount.
- An environment guard inside setup does not prevent a browser-only **top-level import** from executing on the server. Dynamically import it after mount or isolate it in a client-only plugin/component.
- Use `<ClientOnly>` for a genuinely client-only subtree with a stable fallback, not as a blanket hydration-warning fix. CSS used only by that subtree may not be inlined in server HTML.
- Client/server branches that render different initial markup still mismatch. A client guard alone does not synchronize rendering.
- Do not globally set `ssr: false` to hide a localized issue.

Sources: [4.x hydration](https://nuxt.com/docs/4.x/guide/best-practices/hydration), [3.x hydration](https://nuxt.com/docs/3.x/guide/best-practices/hydration), [4.x state](https://nuxt.com/docs/4.x/getting-started/state-management).
