---
category: Reactivity
---

# toRef

Normalize a value, ref, or getter to a ref. Getter results are readonly; do not assume computed caching.

## Usage

```ts
import { toRef } from '@vueuse/core'
import { ref } from 'vue'

const foo = ref('hi')

const a = toRef(0) // Ref<number>
const b = toRef(foo) // Ref<string>
const c = toRef(() => 'hi') // Readonly<Ref<string>>
```

## Differences from Vue's `toRef`

Vue's native [`toRef`](https://vuejs.org/api/reactivity-utilities.html#toref) supports value/ref/getter normalization in **Vue 3.3+**, in addition to its object-and-key signature. A getter produces a readonly ref; an existing ref is returned as-is. Prefer the native API when it already meets the requirement.

The VueUse declarations bundled below also include object-and-key overloads, so it is incorrect to treat those as Vue-only. VueUse behavior has changed across releases: check the project's installed exports, types, and implementation before relying on an overload or caching behavior. Do not replace a correct native `toRef` import merely to use VueUse.

## Type Declarations

```ts
/**
 * Normalize value/ref/getter to `ref` or `computed`.
 */
export declare function toRef<T>(r: () => T): Readonly<Ref<T>>
export declare function toRef<T>(r: ComputedRef<T>): ComputedRef<T>
export declare function toRef<T>(r: MaybeRefOrGetter<T>): Ref<T>
export declare function toRef<T>(r: T): Ref<T>
export declare function toRef<T extends object, K extends keyof T>(
  object: T,
  key: K,
): ToRef<T[K]>
export declare function toRef<T extends object, K extends keyof T>(
  object: T,
  key: K,
  defaultValue: T[K],
): ToRef<Exclude<T[K], undefined>>
```
