---
category: Browser
---

# useSSRWidth

Read the app/component-provided SSR viewport width used by functions such as [`useMediaQuery`](useMediaQuery.md) or [`useBreakpoints`](useBreakpoints.md). Set it with `provideSSRWidth`.

Verify these exports and the `ssrWidth` option exist in the installed VueUse version. Provide a consistent value for the server render and initial client hydration, within the current app/request's context. In Nuxt, use the existing root setup or a Nuxt app plugin rather than creating another Vue app or mutable server-global width.

## Usage

```ts
import { provideSSRWidth } from '@vueuse/core'

const app = createApp(App)

provideSSRWidth(500, app)
```

Or in the root component

```vue
<script setup lang="ts">
import { provideSSRWidth } from '@vueuse/core'

provideSSRWidth(500)
</script>
```

To retrieve the provided value if you need it in a subcomponent

```vue
<script setup lang="ts">
import { useSSRWidth } from '@vueuse/core'

const width = useSSRWidth()
</script>
```

## Type Declarations

```ts
export declare function useSSRWidth(): number | undefined
export declare function provideSSRWidth(
  width: number | null,
  app?: App<unknown>,
): void
```
