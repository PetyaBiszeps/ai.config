---
title: Mounted and Unmounted Hooks Do Not Run During SSR
impact: MEDIUM
impactDescription: SSR applications may fail if mounted-only code is essential for functionality
type: capability
tags: [vue3, lifecycle, ssr, server-side-rendering, nuxt, onMounted, mounted, hydration]
---

# Mounted and Unmounted Hooks Do Not Run During SSR

**Impact: MEDIUM** - During server-side rendering (SSR), lifecycle hooks like `mounted`, `onMounted`, `unmounted`, and `onUnmounted` are never called on the server. Critical data fetched only in these hooks will be missing from the server-rendered content.

During SSR, `beforeCreate`, `created`, and `setup()` run, and the renderer awaits `serverPrefetch` / `onServerPrefetch` hooks. Client-specific operations (DOM access, browser APIs, third-party libraries) must be in mounted hooks, but you must handle the SSR case appropriately.

## Task Checklist

- [ ] Place browser-specific code (window, document, localStorage) in mounted/onMounted
- [ ] Use `serverPrefetch` / `onServerPrefetch` or framework data fetching for data the server must await
- [ ] Handle hydration mismatches for content that differs client vs server
- [ ] Use `<ClientOnly>` wrapper (Nuxt) or conditional rendering for client-only components
- [ ] Check for browser environment before using browser APIs

**Incorrect:**
```javascript
// WRONG: Accessing browser APIs in created - breaks SSR
export default {
  created() {
    // These don't exist on the server!
    this.width = window.innerWidth // ReferenceError: window is not defined
    this.savedData = localStorage.getItem('data') // ReferenceError: localStorage is not defined
  }
}
```

```javascript
// WRONG: Critical initialization only in mounted - won't run on server
export default {
  data() {
    return { user: null }
  },
  async mounted() {
    // This won't run on server - page renders without user data
    // Client fetch runs after hydration, so content appears later
    this.user = await fetchCurrentUser()
  }
}
```

**Correct lifecycle placement (state transfer omitted):**
`serverPrefetch()` is awaited on the server, but does not serialize or transfer state to the client. This partial example also requires serializing the fetched state and restoring it before the client's initial render to be hydration-safe.

```javascript
// CORRECT: Await server data in serverPrefetch, access DOM in mounted
export default {
  data() {
    return {
      user: null,
      windowWidth: 0
    }
  },
  async serverPrefetch() {
    // The server renderer awaits this hook (unlike async created)
    this.user = await fetchCurrentUser()
  },
  async mounted() {
    // Browser-specific code safely in mounted
    this.windowWidth = window.innerWidth
    window.addEventListener('resize', this.handleResize)
    if (!this.user) this.user = await fetchCurrentUser()
  },
  unmounted() {
    window.removeEventListener('resize', this.handleResize)
  },
  methods: {
    handleResize() {
      this.windowWidth = window.innerWidth
    }
  }
}
```

```vue
<!-- CORRECT: Nuxt Composition API with SSR awareness -->
<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const windowWidth = ref(0)

// Nuxt useFetch returns a data ref and transfers SSR data to the client
const { data: user } = await useFetch('/api/user')

// These only run on client
onMounted(() => {
  windowWidth.value = window.innerWidth
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
})

function handleResize() {
  windowWidth.value = window.innerWidth
}
</script>
```

## Checking for Browser Environment

```javascript
// CORRECT: Guard browser API access
export default {
  data() {
    return { theme: 'light' }
  },
  created() {
    // Check if we're in browser before accessing browser APIs
    if (typeof window !== 'undefined') {
      this.theme = localStorage.getItem('theme') || 'light'
    }
  },
  mounted() {
    // mounted only runs in browser, so this is always safe
    this.applyTheme()
  }
}
```

## Nuxt.js Specific Patterns

```vue
<!-- CORRECT: Using Nuxt's ClientOnly for client-specific components -->
<template>
  <div>
    <!-- This content renders on both server and client -->
    <h1>Dashboard</h1>

    <!-- This only renders on client - no hydration mismatch -->
    <ClientOnly>
      <ChartComponent :data="chartData" />
      <template #fallback>
        <p>Loading chart...</p>
      </template>
    </ClientOnly>
  </div>
</template>
```

```javascript
// CORRECT: Using Nuxt's process.client/process.server
export default {
  created() {
    if (process.client) {
      // Only runs in browser
      this.initAnalytics()
    }
    if (process.server) {
      // Only runs on server
      this.logServerRequest()
    }
  }
}
```

## Handling Hydration Mismatches

```vue
<script setup>
import { ref, onMounted } from 'vue'

// Start with a value that matches what server renders
const currentTime = ref(null)

onMounted(() => {
  // Update to real value only on client
  // This prevents hydration mismatch
  currentTime.value = new Date().toLocaleTimeString()
})
</script>

<template>
  <!-- Renders null on server, then updates on client -->
  <span v-if="currentTime">{{ currentTime }}</span>
  <span v-else>Loading...</span>
</template>
```

## Reference
- [Vue.js SSR Guide](https://vuejs.org/guide/scaling-up/ssr.html)
- [Nuxt.js Lifecycle](https://nuxt.com/docs/api/composables/use-nuxt-app#lifecycle-hooks)
- [Vue SSR Hydration](https://vuejs.org/guide/scaling-up/ssr.html#client-hydration)
