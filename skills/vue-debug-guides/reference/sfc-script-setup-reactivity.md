---
title: Variables in Script Setup Are Not Reactive by Default
impact: HIGH
impactDescription: Forgetting to wrap variables with ref() or reactive() causes silent reactivity failures in script setup
type: gotcha
tags: [vue3, sfc, script-setup, reactivity, ref, composition-api]
---

# Variables in Script Setup Are Not Reactive by Default

**Impact: HIGH** - Unlike Options API's `data()` which automatically makes properties reactive, variables declared in `<script setup>` are plain JavaScript values. You must explicitly use `ref()` or `reactive()` to make them reactive. Forgetting this causes the UI to not update when values change.

## Task Checklist

- [ ] Always wrap primitive values (strings, numbers, booleans) with `ref()`
- [ ] Use `reactive()` for objects when you don't need to reassign the whole object
- [ ] Remember to access `.value` on refs in script (not needed in templates)
- [ ] Use `computed()` from Vue, not a plain function, for derived reactive state

**Problematic Code:**
```vue
<script setup>
// BAD: These are NOT reactive!
let count = 0
let message = 'Hello'
let user = { name: 'John', age: 30 }

function increment() {
  count++  // This change won't update the UI!
}

function updateMessage() {
  message = 'World'  // UI won't reflect this change!
}
</script>

<template>
  <div>
    <!-- Will always show initial values -->
    <p>Count: {{ count }}</p>
    <p>Message: {{ message }}</p>
    <button @click="increment">Increment</button>
    <button @click="updateMessage">Update</button>
  </div>
</template>
```

**Correct Code:**
```vue
<script setup>
import { ref, reactive, computed } from 'vue'

// GOOD: Primitives wrapped with ref()
const count = ref(0)
const message = ref('Hello')

// GOOD: Object with reactive()
const user = reactive({ name: 'John', age: 30 })

// GOOD: Computed for derived state
const doubleCount = computed(() => count.value * 2)

function increment() {
  count.value++  // Use .value for refs in script
}

function updateMessage() {
  message.value = 'World'
}

function updateUser() {
  user.name = 'Jane'  // No .value needed for reactive objects
}
</script>

<template>
  <div>
    <!-- No .value needed in templates - Vue unwraps automatically -->
    <p>Count: {{ count }}</p>
    <p>Double: {{ doubleCount }}</p>
    <p>Message: {{ message }}</p>
    <p>User: {{ user.name }}</p>
    <button @click="increment">Increment</button>
  </div>
</template>
```

## Common Mistake: Plain Computed

```vue
<script setup>
import { ref } from 'vue'

const items = ref([1, 2, 3, 4, 5])

// BAD: Computed once; this value won't update when items change
const total = items.value.reduce((sum, n) => sum + n, 0)

// A function called during render tracks dependencies, but isn't cached
const getTotal = () => items.value.reduce((sum, n) => sum + n, 0)
</script>

<template>
  <!-- total never updates, getTotal works but isn't optimal -->
  <p>Total: {{ total }}</p>
</template>
```

```vue
<script setup>
import { ref, computed } from 'vue'

const items = ref([1, 2, 3, 4, 5])

// GOOD: computed() tracks dependencies and caches result
const total = computed(() => items.value.reduce((sum, n) => sum + n, 0))
</script>

<template>
  <p>Total: {{ total }}</p>  <!-- Updates when items change -->
</template>
```

## When to Use ref() vs reactive()

```vue
<script setup lang="ts">
import { ref, reactive } from 'vue'

// Use ref() for:
// - Primitives (string, number, boolean)
// - Values you might reassign entirely
const count = ref(0)
const isLoading = ref(false)
const selectedId = ref<number | null>(null)

// Use reactive() for:
// - Objects/arrays you'll mutate but not reassign
// - When you want to avoid .value
const form = reactive({
  name: '',
  email: '',
  errors: []
})

// Gotcha: Replacing a reactive variable loses the tracked connection
let user = reactive({ name: 'John' })
// user = reactive({ name: 'Jane' })  // Existing consumers still track the old proxy
// user.name = 'Jane'       // This works

// Use ref() if you need to reassign objects
const userData = ref({ name: 'John' })
userData.value = { name: 'Jane' }  // This works
</script>
```

## Template Automatic Unwrapping

Vue automatically unwraps refs in templates:

```vue
<script setup>
import { ref } from 'vue'

const count = ref(0)
const user = ref({ name: 'John' })
</script>

<template>
  <!-- All of these work - no .value needed -->
  <p>{{ count }}</p>
  <p>{{ user.name }}</p>
  <input v-model="count" type="number">
  <button @click="count++">Increment</button>
</template>
```

Top-level refs are also unwrapped in inline event handlers:

```vue
<template>
  <!-- This works (Vue handles it) -->
  <button @click="count++">+1</button>

  <!-- Complex inline logic also uses the unwrapped value -->
  <button @click="() => { count = Math.max(0, count - 1) }">
    -1 (min 0)
  </button>
</template>
```

## Reference
- [Vue.js Reactivity Fundamentals](https://vuejs.org/guide/essentials/reactivity-fundamentals.html)
- [Vue.js ref()](https://vuejs.org/api/reactivity-core.html#ref)
- [Vue.js reactive()](https://vuejs.org/api/reactivity-core.html#reactive)
