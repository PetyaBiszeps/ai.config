# Routing and middleware — Nuxt 3/4

App pages, layouts, and route middleware are relative to the resolved app source directory (`srcDir`): typically the project root in Nuxt 3 and `app/` in Nuxt 4. Server middleware lives under the separately resolved `serverDir`, usually root-level `server/` in Nuxt 4.

## Pages and layouts

- `pages/index.vue` → `/`; `pages/posts/[id].vue` → `/posts/:id`; `[[slug]].vue` is optional; `[...slug].vue` is catch-all. Catch-all/optional params are not always a single defined string.
- Render pages with `<NuxtPage />`; a parent nested page also needs `<NuxtPage />` for its children.
- Layouts wrap a `<slot />`. Use `<NuxtLayout><NuxtPage /></NuxtLayout>` in the app shell when layouts are needed. Select with `definePageMeta({ layout: 'account' })`; `layout: false` disables the wrapper.
- Use Nuxt's `useRoute` (auto-import or `#app`), not a direct `vue-router` import: Nuxt coordinates route updates with page navigation.
- Use `<NuxtLink>` for internal links. Return/await `navigateTo` for programmatic navigation. Never pass unvalidated user input as an external redirect target.
- Validate route params before using them. Returning `false` from `definePageMeta({ validate })` gives a 404, not API authorization.

## Route middleware is not server middleware

| | App route middleware | Server middleware |
| --- | --- | --- |
| Location | app-source `middleware/` | resolved `server/middleware/` |
| API | `defineNuxtRouteMiddleware((to, from) => ...)` | Nitro/h3 event handler |
| Runs | initial SSR, initial client hydration, later client navigation | incoming server requests reaching Nitro |
| Purpose | navigation guards, redirects, page prerequisites | request logging, headers, request context, server checks |

Neither a hidden page nor a client navigation guard secures an API. Authorize protected data at its server boundary.

App middleware can be inline, named (page `middleware: 'auth'`), or global (`auth.global.ts`). Global middleware runs before page middleware; keep ordering explicit when guards depend on each other.

Nuxt 3/4 app-source `middleware/account.ts` (illustrates navigation only, **not authentication**):

```ts
export default defineNuxtRouteMiddleware((to) => {
  if (to.path === '/account') {
    return navigateTo('/account/profile')
  }
})
```

- Return `navigateTo(...)` or `abortNavigation(...)`; don't continue after a redirect. Avoid redirect loops by checking the destination.
- In middleware, use `to`/`from`, not `useRoute()`; there is no settled current route yet.
- Initial route middleware may run on server and client even with SSR payload reuse. Make effects idempotent; do not blindly skip client execution if it is needed on later navigation.
- Server middleware should inspect/extend `event.context` or throw, not act as the final response handler. See the server reference for runtime conventions.
- Do not introduce typed/case-sensitive routing defaults from v5 into an older project's router.

Sources: [3.x routing](https://nuxt.com/docs/3.x/getting-started/routing), [4.x routing](https://nuxt.com/docs/4.x/getting-started/routing), [4.x middleware](https://nuxt.com/docs/4.x/directory-structure/app/middleware).
