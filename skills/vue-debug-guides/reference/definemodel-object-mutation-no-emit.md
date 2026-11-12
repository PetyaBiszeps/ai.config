---
title: defineModel Object Mutations Do Not Emit Updates
impact: HIGH
impactDescription: Mutating object properties via defineModel changes shared state without emitting update events
type: gotcha
tags: [vue3, v-model, defineModel, objects, reactivity, two-way-binding]
---

# defineModel Object Mutations Do Not Emit Updates

**Impact: HIGH** - When using `defineModel()` with objects or arrays, directly mutating nested properties like `model.value.prop = x` does NOT emit the `update:modelValue` event. The shared reactive object can still update in the parent, but listeners relying on the update event will not run.

The model ref's setter emits the update event when its value changes. Nested mutations bypass that setter, even though Vue still tracks mutations to a shared reactive object.

## Task Checklist

- [ ] Don't expect nested mutations to emit `update:modelValue`
- [ ] Create a new object reference when an update event is needed: `model.value = {...model.value, prop: x}`
- [ ] For arrays, use spread or slice: `model.value = [...model.value, newItem]`
- [ ] For nested updates, copy each object along the changed path

**Incorrect - Mutation without event emission:**
```vue
<script setup lang="ts">
// Child component with object v-model
const model = defineModel<{ name: string; age: number; items: string[] }>({ required: true })

function updateName(newName: string) {
  // WRONG: This mutates the object in place
  // Parent receives NO update:modelValue event!
  model.value.name = newName
}

function addToList() {
  // WRONG: Push mutates the array
  model.value.items.push('new item')  // No update event; shared data still changes
}
</script>
```

**Correct - Replace object reference to trigger event:**
```vue
<script setup lang="ts">
const model = defineModel<{ name: string; age: number; items: string[] }>({ required: true })

function updateName(newName: string) {
  // CORRECT: Create new object reference
  // This triggers update:modelValue event to parent
  model.value = {
    ...model.value,
    name: newName
  }
}

function addToList() {
  // CORRECT: Create new array reference
  model.value = {
    ...model.value,
    items: [...model.value.items, 'new item']
  }
}
</script>
```

## Deep Updates with Event Emission

```vue
<script setup lang="ts">
const model = defineModel<{
  user: {
    address: {
      city: string
    }
  }
}>({ required: true })

// WRONG: Deep mutation does not emit an update event
model.value.user.address.city = 'New York'

// CORRECT: Replace entire chain
model.value = {
  ...model.value,
  user: {
    ...model.value.user,
    address: {
      ...model.value.user.address,
      city: 'New York'
    }
  }
}
</script>
```

## Race Condition Warning with Spread Operator

When multiple updates occur rapidly, earlier changes can be lost:

```vue
<script setup lang="ts">
const model = defineModel<{ a: string; b: string }>({ required: true })

// CAUTION: Race condition if called in same tick
function updateBothWrong() {
  model.value = { ...model.value, a: 'new-a' }  // First update
  model.value = { ...model.value, b: 'new-b' }  // May use stale model.value!
}

// CORRECT: Batch updates into single assignment
function updateBothCorrect() {
  model.value = {
    ...model.value,
    a: 'new-a',
    b: 'new-b'
  }
}
</script>
```

## Alternative: VueUse's useVModel with Deep Option

For complex objects, consider VueUse:

```vue
<script setup lang="ts">
import { useVModel } from '@vueuse/core'

const props = defineProps<{ modelValue: { name: string } }>()
const emit = defineEmits(['update:modelValue'])

// Deep tracking with passive updates
const model = useVModel(props, 'modelValue', emit, { deep: true, passive: true })

// Now direct mutations work
model.value.name = 'New Name'  // Properly syncs with parent
</script>
```

## Reference
- [Vue.js Component v-model](https://vuejs.org/guide/components/v-model.html)
- [GitHub Discussion: defineModel with objects](https://github.com/orgs/vuejs/discussions/10538)
- [SIMPL Engineering: Vue defineModel Pitfalls](https://engineering.simpl.de/post/vue_definemodel/)
