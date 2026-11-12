---
title: Call Composables Only in Setup Context Synchronously
impact: HIGH
impactDescription: Composables called outside setup context or asynchronously fail to register lifecycle hooks and may cause memory leaks
type: gotcha
tags: [vue3, composables, composition-api, setup, async, lifecycle]
---

# Call Composables Only in Setup Context Synchronously

**Impact: HIGH** - Composables that depend on component context should be called synchronously within `<script setup>` or `setup()`, or in supported lifecycle hooks. Calls in asynchronous callbacks or after `await` in ordinary async functions lose that context. Top-level `await` in `<script setup>` is an exception: Vue restores the component context.

This is critical because composables often register `onMounted` and `onUnmounted` hooks internally. If called in the wrong context, these hooks are never registered, leading to uninitialized state or memory leaks.

## Task Checklist

- [ ] Call component-dependent composables synchronously in a supported context
- [ ] Never call composables inside async callbacks, setTimeout, or Promise.then
- [ ] Conditional calls and loops are valid when they run synchronously in a supported context
- [ ] Exception: Composables CAN be called in lifecycle hooks like `onMounted`

**Incorrect:**
```vue
<script setup>
import { useFetch } from './composables/useFetch'

// WRONG: Composable called after await in a nested async function
async function initialize() {
  const config = await loadConfig()
  const { data } = useFetch(config.apiUrl)  // Lifecycle hooks won't register!
}
initialize()

// WRONG: Composable called in callback
setTimeout(() => {
  const { data } = useFetch('/api/delayed')  // No component context!
}, 1000)
</script>
```

**Correct:**
```vue
<script setup>
import { ref, computed, onMounted } from 'vue'
import { useFetch } from './composables/useFetch'
import { useAuth } from './composables/useAuth'

// CORRECT: Call composables synchronously at top level
const { user, isAuthenticated } = useAuth()
const apiUrl = ref('/api/default')
const { data, execute } = useFetch(apiUrl)

// Handle async config loading differently
onMounted(async () => {
  const config = await loadConfig()
  apiUrl.value = config.apiUrl  // Update the ref, composable reacts
})

// CORRECT: React to condition changes through reactive state
const showUserData = computed(() => isAuthenticated.value && someCondition)

// CORRECT: For multiple URLs, use a different pattern
const urls = ref(['/api/a', '/api/b', '/api/c'])
const results = ref([])

// Either fetch in onMounted or use a composable designed for arrays
onMounted(async () => {
  results.value = await Promise.all(urls.value.map(url => fetch(url)))
})
</script>
```

## Exception: Calling in Lifecycle Hooks

Some composables can be called synchronously inside lifecycle hooks because Vue maintains the component context. This does not make setup-only operations or already-passed hooks valid there:

```vue
<script setup>
import { onMounted } from 'vue'
import { useEventListener } from '@vueuse/core'

// CORRECT: Called in lifecycle hook - component context is available
onMounted(() => {
  // This works because we're still in the component's execution context
  useEventListener(document, 'visibilitychange', handleVisibility)
})
</script>
```

## Special Case: Async Setup in `<script setup>`

Top-level await in `<script setup>` is special - Vue's compiler automatically preserves context:

```vue
<script setup>
import { useFetch } from './composables/useFetch'

// CORRECT: Top-level await in <script setup> preserves context
// Vue compiler handles this specially
const config = await loadConfig()
const { data } = useFetch(config.apiUrl)  // This works!

// But nested awaits still break context:
async function initLater() {
  await delay(1000)
  const { data } = useFetch('/api/late')  // WRONG: This won't work!
}
</script>
```

## Why This Matters

When you call a composable, Vue needs to know which component instance to associate it with. This association uses an internal "current instance" available during setup, synchronous lifecycle callbacks, and compiler-restored top-level awaits in `<script setup>`.

```javascript
// Inside a composable
export function useFetch(url) {
  const data = ref(null)

  // These need the current component instance!
  onMounted(() => { /* ... */ })
  onUnmounted(() => { /* cleanup */ })

  // If called outside setup context, Vue can't find the instance
  // and these hooks are silently ignored
  return { data }
}
```

## Reference
- [Vue.js Composables - Usage Restrictions](https://vuejs.org/guide/reusability/composables.html#usage-restrictions)
- [Vue.js Composition API - Setup Context](https://vuejs.org/api/composition-api-setup.html)
