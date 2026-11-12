# Sources, verification limits, and attribution

Use to audit provenance or resolve uncertain/version-dependent claims. Task references link directly to their relevant official documentation; no need to load this file for routine development.

## Source hierarchy

1. The target app's installed version, effective config, exports/types, and project conventions.
2. Matching official [Nuxt 3 docs](https://nuxt.com/docs/3.x) or [Nuxt 4 docs](https://nuxt.com/docs/4.x), qualified by installed minor and flags.
3. Official release/tagged source for a behavior not covered by those docs.
4. Upstream skills as a topic inventory only, never as proof of Nuxt 3/4 compatibility.

Versioned documentation is maintained over time, not frozen to every minor. The 3.x upgrade page still contains historical Nuxt 4 release-planning text; don't infer current release status from it. Current 4.x pages include 4.3/4.6 additions and explicit v5-compatibility previews; don't treat every example there as a Nuxt 4.0 API.

## Reviewed snapshots (2026-11-13)

- Anthony Fu's [Nuxt skill and references](https://github.com/antfu/skills/tree/d524ed287eef22757297827ce42e3cad88abd20c/skills/nuxt), including its entry point, generation metadata, data-fetching and server references. It identifies its baseline as Nuxt **5.0.0-0**. Its topic organization informed these newly written references; its future APIs were not copied into Nuxt 3/4 guidance.
- Official [Nuxt v4.6.4 release](https://github.com/nuxt/nuxt/releases/tag/v4.6.4) was the stable release reported by GitHub during review.
- Official [Nuxt development package](https://github.com/nuxt/nuxt/blob/58bef806df04e2b3855ed60e6f80ab65e5aaddd9/packages/nuxt/package.json) identifies **5.0.0-0**; the [4.x upgrade guide](https://nuxt.com/docs/4.x/getting-started/upgrade) explicitly describes in-development v5 compatibility and the 4.6 server-import boundary.
- Standalone 5.x introduction/upgrade markdown endpoints returned 404 during review. The v5 reference therefore cites only confirmed official 4.x preview guidance and official source, not assumed 5.x documentation.
- No claim is carried forward for unverified upstream factory/addon APIs, precise Nuxt 5 engine/bundler versions, or runtime migration switches. Their compatibility must be independently established before use.

All examples here are independently written for their labeled boundary. Shared server examples deliberately retain Nitro v2/h3 v1 semantics; the optional 4.6+ surface is isolated in the v4 overlay. No project build/runtime validation was performed for this documentation-only work.

## Upstream license notice

The upstream skill repository is MIT-licensed. Preserve this attribution and notice with adaptations or redistributed substantial upstream material.

Source: [Anthony Fu's LICENSE.md](https://github.com/antfu/skills/blob/d524ed287eef22757297827ce42e3cad88abd20c/LICENSE.md).

```text
MIT License

Copyright (c) 2025-PRESENT Anthony Fu <https://github.com/antfu>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
