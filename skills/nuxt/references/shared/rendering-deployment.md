# Rendering and deployment — Nuxt 3/4

Choose per-route behavior from product requirements and the existing host, not from a general preference for static or client rendering.

| Mode | Use when | Constraint |
| --- | --- | --- |
| SSR (default) | Initial HTML needs fresh/request-specific data | Requires a server/runtime; isolate requests |
| CSR (`ssr: false`) | App truly does not need server-rendered HTML | Weaker initial content/SEO; not an auth boundary |
| Prerender | Public content is known at build time | No per-user request; updates require regeneration |
| Hybrid route rules | Public/static, dynamic, and client sections coexist | Requires suitable server/platform support |

Nuxt 3/4 root `nuxt.config.ts` example (public news only):

```ts
export default defineNuxtConfig({
  routeRules: {
    '/': { prerender: true },
    '/news/**': { swr: 300 },
    '/dashboard/**': { ssr: false },
  },
  nitro: {
    prerender: {
      routes: ['/about'],
    },
  },
})
```

The dashboard's APIs still require server-side authorization. Never put personal pages behind a shared response-cache rule.

## Route rules and prerendering

- `swr` caches/revalidates responses; `isr` depends on host support. Neither is equivalent to async-data payload reuse.
- `prerender: true` emits build-time content, not runtime SSR. Dynamic/catch-all URLs must be discoverable via links or listed/generated explicitly; inspect crawler coverage rather than assuming every database record gets a page.
- Prerender execution has no real logged-in request/cookies. Do not access user data or serialize private runtime config into generated output.
- Route rules are rendering/caching/redirect policies, not authorization controls. Broad globs can unintentionally affect API routes or private content.
- A fully static deployment cannot provide Nitro endpoints, runtime redirects, server sessions, or on-demand rendering just because they exist in source.
- Keep route rules in `nuxt.config` unless an existing, supported project feature intentionally defines them elsewhere. Do not introduce experimental per-page macros unnecessarily.
- Hybrid rendering requires a server-capable deployment; `nuxt generate` produces static output and does not support runtime SWR/ISR behavior.

## Deployment checklist

- Use repository scripts for dev/build/generate/preview. Preserve the package manager and installed CLI; do not run a latest-version CLI to operate an older app.
- Confirm Node/edge requirements from installed Nuxt/Nitro and the provider, not Nuxt 5's engine requirements.
- SSR/hybrid builds deploy the generated `.output` server and public assets with the matching Nitro preset. For the Node server preset, the entry is `node .output/server/index.mjs`; other presets have different deployment artifacts.
- Static generation deploys `.output/public`. With CSR-only/static hosting, configure deep-link fallback correctly.
- Provide private environment variables to the deployed server and public build-time values where required. Do not expect production to read the development `.env` file.
- Verify the chosen host supports required APIs, persistence, streaming, response caching, and background task lifetime. Local preview is not proof of provider behavior.
- When checks are permitted, verify a hard reload and client navigation for representative routes, redirects/404 status, hydration warnings, cache headers, and absence of private data in HTML/payloads. Follow the user's execution constraints.

Sources: [3.x rendering](https://nuxt.com/docs/3.x/guide/concepts/rendering), [4.x rendering](https://nuxt.com/docs/4.x/guide/concepts/rendering), [4.x prerendering](https://nuxt.com/docs/4.x/getting-started/prerendering), [4.x deployment](https://nuxt.com/docs/4.x/getting-started/deployment).
