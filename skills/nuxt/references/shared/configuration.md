# Configuration and head metadata — Nuxt 3/4

Use for configuration placement, environment overrides, public/private values, and SEO. Preserve existing config file style and module conventions.

## Choose a configuration surface

| Surface | Purpose | Boundary |
| --- | --- | --- |
| Root `nuxt.config.ts` / `defineNuxtConfig` | Build/framework/modules/rendering | Evaluated by Nuxt tooling, not a per-request hook |
| `runtimeConfig` / `useRuntimeConfig` | Deployment-time private or public values | Only server reads private keys; `public` and reserved `app` values reach clients |
| App-source `app.config.ts` / `defineAppConfig` | Public app metadata/theme defaults | Bundled/public; not a secret store or automatic runtime env override |
| `useHead` / `useSeoMeta` | Page/app document metadata | Reactive rendering context; no secrets |

Nuxt 3/4 root `nuxt.config.ts`:

```ts
export default defineNuxtConfig({
  runtimeConfig: {
    apiSecret: '',
    public: {
      apiBase: '/api',
    },
  },
})
```

Provide `NUXT_API_SECRET` and `NUXT_PUBLIC_API_BASE` at deployment. Read `config.public.apiBase` in the app; use `useRuntimeConfig(event).apiSecret` only in baseline Nitro v2/h3 v1 server handlers. The optional 4.6+ `nuxt/server` surface uses a different form—see v4.

## Environment pitfalls

- Declare custom runtime keys so Nuxt knows their shape. Use matching `NUXT_` names; `runtimeConfig.apiSecret: process.env.OTHER_SECRET` is a build-time default, not an automatic production override from `OTHER_SECRET`.
- The CLI reads `.env` for dev/build/generate; the built server does **not** automatically load that file. Configure environment variables in the actual host/runtime; never commit secrets.
- Client bundles and prerendered HTML/payloads are fixed build outputs. Changing a static host's environment does not rewrite them.
- Keep runtime defaults serializable. Services/functions belong in runtime plugins. Reserve `runtimeConfig.app` for Nuxt; avoid overwriting it with application-specific settings.
- Do not import private server utilities into app code or expose secrets through app config, `public`, payloads, error messages, or logs.
- `compatibilityDate` controls compatibility behavior of supporting tooling/providers; it does not install a Nuxt major. `future.compatibilityVersion` changes supported defaults only; inspect explicit overrides and layers.
- Configure Vite, Nitro, and PostCSS through Nuxt's corresponding config keys, not a standalone config file Nuxt does not read. Do not copy newer Vite environment/bundler options into older minors.

## SEO and app errors

- Keep static site-wide defaults in `app.head`; use `useSeoMeta` for typed page SEO fields and `useHead` for links/body attrs and other head entries. Use getters/computed inputs for changing route data.
- Ensure SEO-critical data is fetched during SSR/prerendering rather than only after mount. Use a trusted configured site origin for canonical/OG URLs, not unchecked request headers.
- Never interpolate untrusted HTML into head scripts. Prefer `useHeadSafe` where its supported safe fields fit.
- Keep fetch errors inline when recoverable. For a required missing page, throw Nuxt `createError`; on baseline Nuxt 3/4 the compatible fields are `statusCode`/`statusMessage`. Verify newer error forms against the installed minor before using them.
- Throwing Nuxt `createError` during SSR triggers page error handling; on the client it is non-fatal by default. Use `fatal: true` only when a full-page client error is intended.
- A top-level `error.vue` (under the resolved app source) handles full-page errors; `<NuxtErrorBoundary>` handles localized client errors. Use `clearError({ redirect: '/' })` for deliberate recovery; guard against errors caused by unavailable plugin injections. Server API errors follow the server reference, not the page-error lifecycle.

Sources: [3.x configuration](https://nuxt.com/docs/3.x/getting-started/configuration), [4.x configuration](https://nuxt.com/docs/4.x/getting-started/configuration), [4.x runtime config](https://nuxt.com/docs/4.x/guide/going-further/runtime-config), [4.x SEO](https://nuxt.com/docs/4.x/getting-started/seo-meta), [4.x errors](https://nuxt.com/docs/4.x/getting-started/error-handling).
