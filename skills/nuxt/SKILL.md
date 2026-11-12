---
name: nuxt
description: Version-aware Nuxt development guidance for Nuxt 3, 4, and 5. Use when working with Nuxt applications, SSR, server routes, data fetching, routing, middleware, modules, or configuration.
---

# Nuxt

## Version Detection

Before applying version-specific guidance:

1. Inspect `package.json` and the project's lockfile.
2. Determine the installed Nuxt version when dependencies are available.
3. Inspect `nuxt.config.ts` for compatibility settings.
4. Follow the conventions of the detected version.

Never assume the project uses the latest Nuxt version.

## Documentation

Use the official documentation matching the project's major version:

- Nuxt 3: https://nuxt.com/docs/3.x
- Nuxt 4: https://nuxt.com/docs/4.x
- Nuxt 5: https://nuxt.com/docs/5.x (when available)

Consult relevant documentation when APIs, behavior, or compatibility are uncertain.

Prefer documentation matching the installed version over newer examples.

## Architecture

- Respect the project's existing directory structure.
- Do not assume `app/` is the source directory.
- Follow existing conventions for pages, layouts, components, composables, plugins, and server routes.
- Preserve established module and configuration patterns.
- Avoid unnecessary architectural changes.

## Data Fetching

- Prefer Nuxt's built-in data-fetching utilities.
- Use `useFetch` and `useAsyncData` for SSR-aware data fetching.
- Use `$fetch` for imperative requests when appropriate.
- Account for hydration, caching, and navigation behavior.
- Verify version-specific options and return types before using them.

## Server

- Follow the Nitro and h3 APIs supported by the installed Nuxt version.
- Do not introduce imports or APIs from newer major versions.
- Keep server-only logic within server boundaries.
- Validate external input and handle errors appropriately.
- Avoid exposing secrets or server-only code to the client.

## Components and Composables

- Prefer Vue Composition API and `<script setup>` when consistent with the project.
- Reuse existing components and composables.
- Respect Nuxt auto-import conventions.
- Avoid unnecessary wrappers around built-in composables.

## Compatibility

- Never introduce breaking changes from another Nuxt major version.
- Do not migrate project structure or APIs unless explicitly requested.
- Check compatibility of Nuxt modules and related dependencies.
- When documentation conflicts with existing project behavior, investigate before changing code.

## Related Skills

- Use `nuxt-ui` for Nuxt UI components, theming, and layouts when applicable.
- Use Vue-specific skills for Vue patterns and component behavior.
