# Modules and layers — Nuxt 3/4

Use when integrating packages or sharing Nuxt-specific functionality. Do not add a module/layer when existing code/config already solves the task.

## Install and configure deliberately

1. Inspect the module's installed version, Nuxt compatibility metadata/peer dependencies, and its matching docs. Compatibility with Nuxt 3 does not automatically prove every Nuxt 4 minor or Nuxt 5 prerelease works.
2. Check `modules`, auto-discovered local `modules/`, and extended layers before registering anything twice.
3. If adding is authorized, use the project's package manager and a compatible version; preserve its lockfile workflow. Avoid unpinned latest/nightly installs for an old project.
4. Register external modules in `nuxt.config`'s `modules` array and configure the documented key or tuple options. Local modules discovered from `modules/` do not require manual registration. Do not revive Nuxt 2's `buildModules`.
5. Keep private runtime settings in runtime config, not public module options/templates bundled into the client.

A module runs during Nuxt initialization/build. It can register runtime plugins/handlers, but its setup function is not itself a request handler.

## Reuse boundary

| Need | Prefer |
| --- | --- |
| Runtime logic for one app | Composable, plugin, or server utility |
| Shared files/conventions/config across related apps | Layer |
| Reusable integration that modifies Nuxt setup | Nuxt module with compatible `@nuxt/kit` |

For local modules, preserve existing authoring style. If authoring is required, use `defineNuxtModule`, compatibility metadata, and a module-relative resolver from the supported Nuxt Kit version; do not depend on the consumer's current working directory or internal Nuxt paths.

## Layers

- `extends` composes layers containing `nuxt.config` and conventional app/server files. Resolve source/root paths **per layer**, especially with v3/v4 layouts.
- Project overrides have higher priority than extended layers; among explicit `extends` entries, earlier entries win conflicts. Preserve existing ordering.
- Auto-discovery of local `layers/` requires Nuxt 3.12+; earlier Nuxt 3 projects need explicit `extends`. Do not assume every minor has generated layer aliases or identical scan behavior.
- In v4, module execution order is corrected to extended-layer modules first, project modules last. This is separate from file override priority; inspect hooks that depend on order.
- Reuse the project's own components/composables/config overrides rather than copying layer files locally. Check merge semantics for arrays/options before assuming one value replaces another.
- Build/runtime dependencies used by a distributed layer/module must be declared by its package; do not rely on incidental dependency hoisting.
- Treat remote layers/modules as executable trusted code, pin versions/revisions, and review their compatibility. Do not migrate a project into layers without a reuse requirement.

Sources: [4.x modules](https://nuxt.com/docs/4.x/guide/concepts/modules), [4.x local modules](https://nuxt.com/docs/4.x/directory-structure/modules), [3.x layer registration/version notes](https://nuxt.com/docs/3.x/getting-started/layers), [3.x layers](https://nuxt.com/docs/3.x/guide/going-further/layers), [4.x layers](https://nuxt.com/docs/4.x/guide/going-further/layers).
