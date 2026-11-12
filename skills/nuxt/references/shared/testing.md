# Nuxt-aware testing — Nuxt 3/4

Use only when implementing or reviewing tests/verification. Generic Vue test patterns belong in `vue-testing-best-practices`. Preserve the project's runner and installed tool versions; do not install dependencies or execute commands without permission.

## Match the test to its runtime

- Pure functions and plain Vue components can use existing unit/component tests.
- Components depending on Nuxt auto-imports, plugins, routing, or async setup need a Nuxt-aware environment. If the project already uses compatible `@nuxt/test-utils`, use its supported runtime helpers such as `mountSuspended` rather than mocking all Nuxt behavior away.
- `@nuxt/test-utils/runtime` helpers need the Nuxt/Vitest environment; `@nuxt/test-utils/e2e` tests run externally from a Node environment. Do not mix both lifecycles in the same file.
- DOM-only tests cannot prove SSR isolation, status codes, real cookies, deployment behavior, or hydration correctness. Use existing HTTP/browser/e2e coverage for these.
- Test-utils and Vitest configuration evolves independently of Nuxt's major. Check installed APIs before adopting the newest docs' project configuration.
- Nuxt runtime tests initialize a shared app environment. Reset mutated state, mocks, and side effects between tests to prevent cross-test leakage.

## High-value Nuxt checks

| Change | Verify |
| --- | --- |
| SSR data fetching | Initial HTML contains expected content; hydration reuses payload; errors/empty/retry states work |
| Reactive params/query | Navigate between IDs/filters without a reload; no stale result or unintended duplicate request |
| Auth/state | Separate sessions cannot see each other's data; logout/account switch clears private state |
| Middleware | Hard load and client navigation both work; redirects terminate; APIs authorize independently |
| Server API | Methods, invalid input, missing identity, forbidden resource, safe status/error response |
| Rendering/cache | Public cache only; prerender coverage; private data absent from generated payloads |
| Runtime config | Production override names work; private keys absent from client output |

Run only repository-provided, task-relevant checks when allowed. Report exactly what was inspected or run and what remains unverified; do not claim a browser check from a DOM unit test or a production deployment from a successful local build.

Sources: [3.x testing](https://nuxt.com/docs/3.x/getting-started/testing), [4.x testing](https://nuxt.com/docs/4.x/getting-started/testing).
