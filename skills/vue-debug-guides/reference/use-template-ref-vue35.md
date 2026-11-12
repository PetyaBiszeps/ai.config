---
title: Use useTemplateRef for Template Refs in Vue 3.5+
impact: MEDIUM
impactDescription: Legacy ref pattern is error-prone due to name matching requirement
type: best-practice
tags: [vue3, vue35, template-refs, useTemplateRef, composition-api]
---

# Use useTemplateRef for Template Refs in Vue 3.5+

**Impact: MEDIUM** - Before Vue 3.5, template refs required declaring a `ref()` with a name exactly matching the template's ref attribute. This fragile connection breaks silently during refactoring. Vue 3.5's `useTemplateRef()` makes this binding explicit and improves TypeScript support, but its argument must still match the template ref name.

The legacy pattern causes no errors or warnings when names don't match - the ref simply stays null, leading to confusing debugging sessions.

## Task Checklist

- [ ] Use `useTemplateRef('ref-name')` in Vue 3.5+ projects
- [ ] The first argument must exactly match the ref attribute value in the template
- [ ] IDE support provides auto-completion for available ref names
- [ ] Static ref types are inferred with Vue 3.5+ and `@vue/language-tools` 2.1+; otherwise, provide a generic type

**Incorrect (Legacy Pattern):**
```vue
<script setup>
import { ref, onMounted } from 'vue'

// FRAGILE: Variable name MUST match template ref value exactly
const input = ref(null)

// DANGER: After refactoring, names may not match
const inputElement = ref(null) // Renamed variable...

onMounted(() => {
  // NO ERROR - just silently null!
  inputElement.value?.focus() // Does nothing
})
</script>

<template>
  <!-- But template still uses old name -->
  <input ref="input" />
</template>
```

```vue
<script setup>
import { ref } from 'vue'

// TYPO: 'inupt' instead of 'input' - no warning!
const inupt = ref(null)
</script>

<template>
  <input ref="input" />
  <!-- inupt.value will always be null -->
</template>
```

**Correct (Vue 3.5+):**
```vue
<script setup>
import { useTemplateRef, onMounted } from 'vue'

// CORRECT: Explicit binding - argument matches template ref
const inputElement = useTemplateRef('my-input')

onMounted(() => {
  inputElement.value?.focus()
})
</script>

<template>
  <!-- ref name is explicitly connected via useTemplateRef argument -->
  <input ref="my-input" />
</template>
```

```vue
<script setup>
import { useTemplateRef, onMounted } from 'vue'

// BENEFITS:
// 1. Variable name is independent of ref attribute
// 2. IDE auto-completes available ref names
// 3. Updated Vue language tools infer static ref types

const searchInput = useTemplateRef('search-box')
const submitButton = useTemplateRef('submit-btn')

onMounted(() => {
  // TypeScript knows these are HTMLInputElement and HTMLButtonElement
  searchInput.value?.focus()
  if (submitButton.value) submitButton.value.disabled = false
})
</script>

<template>
  <input ref="search-box" type="search" />
  <button ref="submit-btn">Submit</button>
</template>
```

## v-for Refs

In Vue 3.5+, `useTemplateRef()` supports refs inside `v-for`. Its value is initially `null` and is populated with an array of elements after mount.

```vue
<script setup>
import { useTemplateRef, onMounted } from 'vue'

// CORRECT: Collect v-for refs in Vue 3.5+
const itemRefs = useTemplateRef('itemRefs')

const items = [
  { id: 1, text: 'First' },
  { id: 2, text: 'Second' },
]

onMounted(() => {
  // itemRefs.value is an array of DOM elements
  itemRefs.value?.forEach(el => {
    console.log(el.textContent)
  })
})
</script>

<template>
  <ul>
    <li v-for="item in items" ref="itemRefs" :key="item.id">
      {{ item.text }}
    </li>
  </ul>
</template>
```

Before Vue 3.5, use `ref([])` with a variable name matching the template ref. In either pattern, the ref array's order is not guaranteed to match the source array.

## Migration Guide

```vue
<!-- BEFORE (Vue < 3.5) -->
<script setup>
import { ref } from 'vue'
const myElement = ref(null) // Name must match template
</script>
<template>
  <div ref="myElement"></div>
</template>

<!-- AFTER (Vue 3.5+) -->
<script setup>
import { useTemplateRef } from 'vue'
const element = useTemplateRef('my-element') // Any variable name
</script>
<template>
  <div ref="my-element"></div>
</template>
```

## Reference
- [Vue.js Template Refs - Composition API](https://vuejs.org/guide/essentials/template-refs.html#accessing-the-refs)
- [Vue 3.5 Release Notes](https://blog.vuejs.org/posts/vue-3-5)
