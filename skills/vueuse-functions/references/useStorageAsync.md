---
category: State
---

# useStorageAsync

Reactive Storage with async support.

## Usage

For basic usage and browser-storage hydration boundaries, see [useStorage](useStorage.md#ssr-and-nuxt). Do not share user-specific storage adapters or refs across SSR requests.

The thenable return shown below is version-dependent; verify installed types before awaiting it. The `onReady` callback is an alternative when supported. The manual mounting examples are for standalone client-side Vue apps with Vue Router 4, not Nuxt; do not replace Nuxt's bootstrap or SSR data primitives. `Promise.withResolvers` also requires runtime support.

## Wait First Loaded

When user entering your app, `useStorageAsync()` will start loading value from an async storage,
sometimes you may get the default initial value, not the real value stored in storage at the very
beginning.

```ts
import { useStorageAsync } from '@vueuse/core'

const themePreference = useStorageAsync('theme.preference', '', SomeAsyncStorage)

// themePreference.value may be empty before the async storage is ready
console.log(themePreference.value) // ""

setTimeout(() => {
  // After some time, the async storage is ready
  console.log(themePreference.value) // "dark"
}, 500)
```

In this case, you can wait the storage prepared, the returned value is also a `Promise`,
so you can wait it resolved in your template or script.

```ts
// Use top-level await if your environment supports it
const themePreference = await useStorageAsync('theme.preference', '', SomeAsyncStorage)

console.log(themePreference.value) // "dark"
```

If you must wait multiple storages, put them into a `Promise.allSettled()`

```ts
router.isReady().then(async () => {
  await Promise.allSettled([
    themePreference,
    localePreference,
    sidebarPreference,
  ])

  app.mount('app')
})
```

There is a callback named `onReady` in options:

```ts
import { useStorageAsync } from '@vueuse/core'

// Use ES2024 Promise.withResolvers, you may use any Deferred object or EventBus to do same thing.
const { promise, resolve } = Promise.withResolvers()

const themePreference = useStorageAsync('theme.preference', '', SomeAsyncStorage, {
  onReady(value) {
    resolve(value)
  }
})

// At main.ts
router.isReady().then(async () => {
  // Let's wait for the theme preference to load
  await promise

  // Now the theme preference has loaded, we can safely mount our app

  app.mount('app')
})
```

Simply use `resolve` as callback:

```ts
const themePreference = useStorageAsync('theme.preference', '', SomeAsyncStorage, {
  onReady: resolve
})
```

## Type Declarations

```ts
export interface UseStorageAsyncOptions<T> extends Omit<
  UseStorageOptions<T>,
  "serializer"
> {
  /**
   * Custom data serialization
   */
  serializer?: SerializerAsync<T>
  /**
   * On first value loaded hook.
   */
  onReady?: (value: T) => void
}
export declare function useStorageAsync(
  key: string,
  initialValue: MaybeRefOrGetter<string>,
  storage?: StorageLikeAsync,
  options?: UseStorageAsyncOptions<string>,
): RemovableRef<string> & Promise<RemovableRef<string>>
export declare function useStorageAsync(
  key: string,
  initialValue: MaybeRefOrGetter<boolean>,
  storage?: StorageLikeAsync,
  options?: UseStorageAsyncOptions<boolean>,
): RemovableRef<boolean> & Promise<RemovableRef<boolean>>
export declare function useStorageAsync(
  key: string,
  initialValue: MaybeRefOrGetter<number>,
  storage?: StorageLikeAsync,
  options?: UseStorageAsyncOptions<number>,
): RemovableRef<number> & Promise<RemovableRef<number>>
export declare function useStorageAsync<T>(
  key: string,
  initialValue: MaybeRefOrGetter<T>,
  storage?: StorageLikeAsync,
  options?: UseStorageAsyncOptions<T>,
): RemovableRef<T> & Promise<RemovableRef<T>>
export declare function useStorageAsync<T = unknown>(
  key: string,
  initialValue: MaybeRefOrGetter<null>,
  storage?: StorageLikeAsync,
  options?: UseStorageAsyncOptions<T>,
): RemovableRef<T> & Promise<RemovableRef<T>>
```
