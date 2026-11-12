# Nuxt 5 — prerelease boundary, not stable guidance

Load only for a verified Nuxt 5 prerelease checkout/dependency, explicit migration investigation, or an existing v5 compatibility opt-in. **Never apply this file's changes to ordinary Nuxt 3/4 work.**

## Verified status and limits

At source review, the official stable release was **v4.6.4** (`prerelease: false`), while the official development source identifies Nuxt as **`5.0.0-0`**. The official 4.x upgrade guide says Nuxt 5 is **in development**. A development package version is not evidence of a published stable release.

The checked `/docs/5.x/getting-started/introduction.md` and `/docs/5.x/getting-started/upgrade.md` endpoints returned **404**, even though the 4.x guide links to 5.x pages. Do not treat those links or the upstream skill as verified standalone Nuxt 5 documentation. See the source snapshot in the attribution reference; recheck official sources against the exact installed prerelease before editing.

## Confirmed preview differences

The official **4.x upgrade guide** documents `future.compatibilityVersion: 5`, available from **Nuxt 4.2+**. It changes supported defaults without installing Nuxt 5. The set of preview behaviors depends on the installed 4.x minor and explicit overrides.

These differences are documented preview behavior, **not shared stable defaults**:

| Area | Documented v5-compatibility direction | Editing rule |
| --- | --- | --- |
| Routing | Case-sensitive page matching; typed pages enabled | Audit route casing/types only if this preview is actually enabled |
| Vite integration | Vite Environment API enabled | Verify plugin/config compatibility; don't rewrite an older Vite config from a future example |
| State clearing | `clearNuxtState` resets to the `useState` initializer instead of unsetting | Check installed support/overrides before relying on reset semantics |
| Server imports | Nitro helper auto-import compatibility disabled by default in the preview | Verify generated imports and installed server surface; prefer explicit supported imports |

The official 4.x guide separately confirms that **actual Nuxt 5 moves to Nitro v3/h3 v2**, while enabling the flag on Nuxt 4 does **not** perform that runtime upgrade. Do not replace server events/plugins or h3 versions based solely on the flag.

## Safe working policy

1. Record the exact prerelease identifier, installed dependencies, effective flags, and matching official source revision. Reuse v4/shared guidance only where that prerelease still supports it.
2. Inspect the existing server builder and event/helper surface. `nuxt/server` is also available on Nuxt 4.6+; its presence alone does not identify Nuxt 5.
3. Confirm every requested API in official docs/source and installed exports/types. Validate handler and helper imports together. Avoid mixing h3 v1, h3 v2, and runtime-independent event contracts.
4. Keep experimental/prerelease choices explicit and local. Do not enable preview flags, change the lockfile, or upgrade dependencies without authorization.
5. Omit unverified factories, addon/middleware APIs, exact engine requirements, bundler versions, and migration switches. Upstream examples are topic leads, not compatibility evidence.

No Nuxt 5-only implementation example is supplied because the standalone documentation endpoints could not be verified.

Sources: [Official 4.x upgrade/preview guidance](https://nuxt.com/docs/4.x/getting-started/upgrade), [official stable release snapshot](https://github.com/nuxt/nuxt/releases/tag/v4.6.4), [official development package snapshot](https://github.com/nuxt/nuxt/blob/58bef806df04e2b3855ed60e6f80ab65e5aaddd9/packages/nuxt/package.json).
