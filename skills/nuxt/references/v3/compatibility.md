# Nuxt 3 compatibility overlay

Load with the relevant shared topic. This preserves existing Nuxt 3 projects; it is **not** a migration checklist to execute automatically.

## Resolve paths, not appearances

Typical v3 layout uses the project root as `srcDir`:

```text
app.vue
app.config.ts
pages/  layouts/  middleware/  components/  composables/  plugins/
server/  public/
nuxt.config.ts
```

- `~`/`@` point to `srcDir`; `~~`/`@@` point to `rootDir`. They coincide only when source and root coincide. Keep existing aliases.
- With a custom `srcDir`, app files live there; v3 normally resolves `serverDir` from `srcDir/server`. Check explicit settings and compatibility flags before creating a root-level `server/`.
- Do not confuse v3's `app/` support directory (e.g. `app/router.options.ts`) with v4's entire app source directory.
- Nuxt config remains at root. Root/source-relative handling of `public/`, local modules, and layers can change under v4 compatibility; inspect existing configuration.

## Compatibility and data fetching

- Nuxt 3.12+ can opt into selected v4 defaults with `future.compatibilityVersion: 4`. This does not supply all later Nuxt 4 APIs. Check the installed minor, flags, and each layer before using the v4 overlay for an opted-in behavior.
- Without relevant overrides, v3 async data is deeply reactive by default (`deep: true`); initial `data`/`error` commonly use `null`, unlike v4's `undefined`. Prefer explicit loading/success checks over assumptions about nullish sentinels.
- The async-data `status` ref requires 3.6+. Earlier projects use their existing `pending`/error/data checks. Older v3 `pending` behavior can be true before any request starts. `immediate: false` and reactive-key changes also differ from v4; explicitly initiate a request when required.
- Modern 3.x releases backport some keyed data/refresh behavior. Do not declare reactive keys, shared refs, cached-data context, or abort signals universally unavailable in v3—or universally present across every 3.x minor. Read installed types before adding them.
- Keep stable explicit string keys and supported `watch` patterns when editing an older query. Do not change cache defaults or `deep` project-wide to match newer examples.
- `callOnce` requires Nuxt 3.9+; navigation mode and later composable options require their own version check.
- Local `layers/` auto-registration starts in 3.12. Earlier projects can still compose explicitly configured layers.

## Server/runtime and migration boundaries

- The supported baseline is Nitro v2/h3 v1: `defineEventHandler`, h3 helpers, `createError({ statusCode, statusMessage })`, server auto-imports, `defineNitroPlugin`, and `useRuntimeConfig(event)` in handlers.
- Do not import `nuxt/server`, `nitro/h3`, or Nitro v3 plugin/handler APIs into a Nuxt 3 app. Installing a new h3 major to make an example compile is not a compatibility fix.
- Keep the existing generated TypeScript config extension and app/server boundary. Do not copy v4 split-project configuration or edit generated `.nuxt` files without a requested migration.
- Do not replace `pages/` with `app/pages/`, change aliases, or run codemods to solve an unrelated feature.
- Nuxt 2's `asyncData`/`fetch` component options, `serverMiddleware`, and `buildModules` examples are not the Nuxt 3 baseline. Investigate existing legacy usage before changing it. Existing `process.server`/`process.client` guards are supported in Nuxt 3; do not replace them with newer `import.meta` guards without checking the minor and local conventions.
- The 3.x upgrade page contains historical release-planning wording. Use it for documented compatibility behavior, not as evidence that Nuxt 4 is still unreleased.

Sources: [3.x configuration](https://nuxt.com/docs/3.x/getting-started/configuration), [3.x upgrade/compatibility](https://nuxt.com/docs/3.x/getting-started/upgrade), [3.x app support directory](https://nuxt.com/docs/3.x/directory-structure/app), [3.x async data](https://nuxt.com/docs/3.x/api/composables/use-async-data), [3.x server](https://nuxt.com/docs/3.x/directory-structure/server).
