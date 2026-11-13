---
category: State
---

# useSessionStorage

Reactive [SessionStorage](https://developer.mozilla.org/en-US/docs/Web/API/Window/sessionStorage).

## Usage

Please refer to [useStorage](useStorage.md), especially its [SSR and Nuxt guidance](useStorage.md#ssr-and-nuxt). This is browser-only, per-tab persistence, not SSR request state. If supported by the installed version, use `{ initOnMounted: true }` as the third argument when the stored value affects server-rendered HTML.

## Type Declarations

```ts
export declare function useSessionStorage(
  key: MaybeRefOrGetter<string>,
  initialValue: MaybeRefOrGetter<string>,
  options?: UseStorageOptions<string>,
): RemovableRef<string>
export declare function useSessionStorage(
  key: MaybeRefOrGetter<string>,
  initialValue: MaybeRefOrGetter<boolean>,
  options?: UseStorageOptions<boolean>,
): RemovableRef<boolean>
export declare function useSessionStorage(
  key: MaybeRefOrGetter<string>,
  initialValue: MaybeRefOrGetter<number>,
  options?: UseStorageOptions<number>,
): RemovableRef<number>
export declare function useSessionStorage<T>(
  key: MaybeRefOrGetter<string>,
  initialValue: MaybeRefOrGetter<T>,
  options?: UseStorageOptions<T>,
): RemovableRef<T>
export declare function useSessionStorage<T = unknown>(
  key: MaybeRefOrGetter<string>,
  initialValue: MaybeRefOrGetter<null>,
  options?: UseStorageOptions<T>,
): RemovableRef<T>
```
