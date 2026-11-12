---
name: nuxt
description: Version-aware Nuxt development guidance for Nuxt 3, 4, and 5 prereleases. Use when working with Nuxt applications, SSR, server routes, data fetching, routing, middleware, modules, or configuration.
---

# Nuxt

Nuxt 4 is the primary stable reference, **not** an instruction to upgrade. Shared references target Nuxt 3/4; the version overlays qualify defaults and newer APIs.

## Resolve the project before editing

1. Find the actual app/workspace package, not just the monorepo root. Read its `package.json`: Nuxt dependency range, package manager, scripts, overrides/resolutions, and aliases such as `npm:nuxt-nightly@...`.
2. Read the matching lockfile (`pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, or Bun lockfile). Follow the app's importer/resolved package; a range or dist-tag is not an installed version.
3. If dependencies exist, read the Nuxt package resolved **from that app** (normally `node_modules/nuxt/package.json`, following symlinks; account for PnP). Record the exact major/minor/prerelease and relevant Nitro/h3/module versions. Installed dependencies describe the current runtime; a conflicting lockfile describes a different intended install—report the discrepancy rather than silently choosing.
4. Inspect `nuxt.config.*` and extended layers for `future.compatibilityVersion`, `compatibilityDate`, explicit experimental/default overrides, `srcDir`, `rootDir`, `serverDir`, `dir`, and aliases. A compatibility flag changes selected defaults, **not** the installed major or available exports. `compatibilityDate` is not the Nuxt version.
5. Inspect the actual directories and nearby code. Nuxt 3 may opt into v4 conventions; Nuxt 4 may retain the old layout. Keep existing structure, imports, scripts, modules, and rendering choices unless migration is requested.
6. If version evidence is missing or conflicting, state what is known, use only the verified common subset, and ask before a version-dependent change. Do not install or upgrade merely to detect a version.

## Load only what the task needs

Load the detected major's overlay plus the relevant shared topic(s). For an explicit future-compatibility opt-in, also read only the affected overlay; never treat the flag as a full upgrade. Check the installed minor's types/release notes when an API is newer than the baseline.

| Task | Reference |
| --- | --- |
| Fetching, payloads, cache, refresh, request headers | [Data fetching](references/shared/data-fetching.md) |
| SSR safety, hydration mismatches, request isolation | [SSR and hydration](references/shared/ssr-hydration.md) |
| Pages, layouts, navigation, middleware | [Routing and middleware](references/shared/routing-middleware.md) |
| Local/shared state, Pinia boundary | [State management](references/shared/state-management.md) |
| API handlers, validation, errors, security | [Server APIs](references/shared/server-apis.md) |
| Auto-imports, plugins, context, lifecycle | [Components and composables](references/shared/components-composables.md) |
| Nuxt config, runtime/app config, environment, SEO | [Configuration](references/shared/configuration.md) |
| Install/configure modules, layers, reuse | [Modules and layers](references/shared/modules-layers.md) |
| SSR/CSR/hybrid, route rules, prerender, hosting | [Rendering and deployment](references/shared/rendering-deployment.md) |
| Nuxt-aware tests, SSR/navigation verification | [Testing](references/shared/testing.md) |
| Nuxt 3 project | [v3 compatibility](references/v3/compatibility.md) |
| Nuxt 4 project | [v4 defaults and differences](references/v4/compatibility.md) |
| Nuxt 5 prerelease or explicit v5 compatibility investigation | [v5 prerelease boundary](references/v5/prerelease.md) |
| Source provenance, verification limits, upstream MIT notice | [Sources and attribution](references/shared/sources.md) |

Never backport a future API by copying an example. Prefer official [3.x](https://nuxt.com/docs/3.x) or [4.x](https://nuxt.com/docs/4.x) docs matching the installed minor, then installed types/source. Do not assume a 5.x documentation URL exists or a prerelease API is stable.

## Delegate adjacent concerns

- `nuxt-ui`: Nuxt UI components, theming, forms, and layouts.
- `vue-best-practices`: Vue reactivity, SFCs, props/events, and component design; preserve Options API projects with `vue-options-api-best-practices`.
- `vue-pinia-best-practices`: store implementation; keep Nuxt SSR integration here.
- `vue-debug-guides` and `vue-testing-best-practices`: Vue diagnostics and test patterns; use the Nuxt references for context and hydration boundaries.

Topic selection was informed by Anthony Fu's Nuxt skill, not adopted as Nuxt 3/4 API documentation. See the linked source and license notice.
