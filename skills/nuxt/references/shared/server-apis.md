# Server APIs — Nuxt 3/4

Baseline examples use **Nitro v2 / h3 v1**, supported by Nuxt 3 and Nuxt 4's default server runtime. Do not substitute h3 v2 or Nuxt 5 imports. For a project already using the **Nuxt 4.6+ `nuxt/server` surface**, read the v4 overlay first; its event/helper contract is different.

## Handler boundaries

- `server/api/hello.get.ts` handles `GET /api/hello`; `server/routes/health.get.ts` handles `GET /health`. Resolve `serverDir` before placing files.
- Use method suffixes for endpoints with method-specific behavior. Dynamic params use `[id]`; do not assume page routing features all work in server routes.
- Return objects for JSON; return or await async work. Throw intentional HTTP errors rather than returning an error object with status 200.
- App plugins and app composables are not the server request context. Server middleware, Nitro plugins, and build-time modules are separate lifecycles.
- Existing server auto-imports are valid in this baseline. Explicit h3 imports are also valid; follow nearby conventions.

Nuxt 3/4 with h3 v1, `server/api/normalize.post.ts`; validation without adding a dependency:

```ts
import { createError, defineEventHandler, readBody } from 'h3'

export default defineEventHandler(async (event) => {
  const body: unknown = await readBody(event)
  if (
    !body || typeof body !== 'object' ||
    !('name' in body) || typeof body.name !== 'string' ||
    !body.name.trim() || body.name.length > 100
  ) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid name' })
  }
  return { name: body.name.trim() }
})
```

`readBody<T>`, `getQuery<T>`, and TypeScript assertions do **not** validate input. Validate params, query, body, headers, uploads, and size limits. Reuse an existing schema library if present. For h3 v1's `readValidatedBody`/`getValidatedQuery`, pass a supported validation function (e.g. the existing schema's `parse` function), not a newer runtime's schema-object contract.

## Context and runtime

- In baseline h3 handlers, use `useRuntimeConfig(event)` for private configuration. In server-to-server requests, plain `$fetch` does not inherit user credentials. Use `event.$fetch` for trusted internal requests needing forwarded context, if supported by the installed runtime.
- Put trusted per-request identity in `event.context` after verifying the session/token; never trust a submitted user ID as proof of identity.
- Server plugins initialize runtime services/hooks; connection pools can be process-wide, authenticated user state cannot.
- Node APIs, writable files, long-lived connections, and background tasks are deployment-dependent. An edge/serverless deployment is not a persistent Node process. Use the existing target's supported storage and request lifetime APIs.

## Security and errors

- Authenticate and authorize **each protected operation**, including resource ownership/tenant checks. Page middleware does not secure these handlers.
- Reject unsafe external URLs (SSRF), open redirects, oversized uploads, and unbounded queries. Allowlist destinations and query fields; parameterize database operations.
- Cookie-based mutations need appropriate CSRF/origin protections; CORS is not authorization. Use secure, HttpOnly, appropriately SameSite session cookies.
- Use safe public HTTP status text and sanitized error data. Log diagnostic causes server-side without tokens or sensitive request bodies; never return stack traces, raw upstream errors, or database internals.
- Do not blindly cache user-specific endpoints with `swr`/`isr`. A cache key and isolation policy must be correct before enabling caching.
- Do not move code to `nuxt/server` just to modernize it. Availability starts at 4.6, and helper names alone do not guarantee compatible semantics.

Sources: [3.x server](https://nuxt.com/docs/3.x/directory-structure/server), [4.x server](https://nuxt.com/docs/4.x/directory-structure/server), [4.x server import boundary](https://nuxt.com/docs/4.x/guide/going-further/server-imports).
