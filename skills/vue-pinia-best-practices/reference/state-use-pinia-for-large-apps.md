---
title: Use Pinia for Large-Scale Vue Applications
impact: MEDIUM
impactDescription: Hand-rolled reactive stores lack DevTools integration, TypeScript support, and debugging capabilities needed for production apps
type: best-practice
tags: [vue3, pinia, state-management, devtools, architecture, scalability]
---

# Use Pinia for Large-Scale Vue Applications

**Impact: MEDIUM** - Choose state management based on actual application needs. Vue's reactivity APIs and composables work well for simple state, while Pinia adds structured stores, actions, DevTools integration, and a plugin ecosystem when those capabilities are needed.

## Task Checklist

- [ ] Choose Pinia when shared state and domain actions warrant dedicated stores
- [ ] Use Pinia when team collaboration requires consistent patterns
- [ ] Use Pinia when you need Vue DevTools state debugging
- [ ] Consider local state, composables, or Nuxt `useState()` before adding a store
- [ ] Migrate from Vuex to Pinia (Vuex is in maintenance mode)

## When Hand-Rolled State is Acceptable

Simple reactive state and composables are fine when they meet the requirements, regardless of team size. In Nuxt, `useState()` offers request-isolated, serializable shared state. Do not use module-level reactive singletons for request-specific SSR state.

```javascript
// Simple hand-rolled store - OK for small apps
import { reactive, readonly } from 'vue'

export const store = reactive({
  count: 0,
  increment() {
    this.count++
  }
})
```

## When to Use Pinia

Use Pinia when you have any of these requirements:

### 1. DevTools Integration

Pinia provides rich Vue DevTools support:
- Timeline of state changes
- State inspection and editing
- Time-travel debugging
- Action tracking

```javascript
// Pinia store - fully visible in DevTools
import { defineStore } from 'pinia'

export const useCounterStore = defineStore('counter', {
  state: () => ({ count: 0 }),
  actions: {
    increment() {
      this.count++  // Tracked in DevTools timeline
    }
  }
})
```

### 2. TypeScript Support

Pinia has excellent TypeScript inference:

```typescript
// Full type inference without extra configuration
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    name: '',
    age: 0,
    preferences: {
      theme: 'light' as 'light' | 'dark'
    }
  }),

  getters: {
    // Return type is inferred
    displayName: (state) => state.name || 'Anonymous'
  },

  actions: {
    // Full parameter type checking
    setUser(name: string, age: number) {
      this.name = name
      this.age = age
    }
  }
})

// Usage is fully typed
const userStore = useUserStore()
userStore.name  // string
userStore.displayName  // string
userStore.setUser('John', 30)  // Type-checked
```

### 3. Team Collaboration

Pinia enforces conventions that help teams:

```javascript
// Consistent structure across all stores
// stores/products.js
export const useProductsStore = defineStore('products', {
  state: () => ({ /* ... */ }),
  getters: { /* ... */ },
  actions: { /* ... */ }
})

// stores/cart.js - Same structure
export const useCartStore = defineStore('cart', {
  state: () => ({ /* ... */ }),
  getters: { /* ... */ },
  actions: { /* ... */ }
})
```

### 4. Hot Module Replacement (HMR)

Pinia supports HMR out of the box - state persists during development:

```javascript
// State survives code changes during development
// No need to re-login or re-create state after every edit
```

### 5. Server-Side Rendering (SSR)

Pinia handles SSR state correctly:

```javascript
// SSR requires a Pinia instance per application/request
// Set up state serialization and hydration through the framework integration
// Never put server-only secrets in hydrated state
```

### 6. Plugin Ecosystem

Pinia supports plugins for common needs:

```javascript
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

// Now stores can persist to localStorage
export const useSettingsStore = defineStore('settings', {
  state: () => ({
    theme: 'light',
    language: 'en'
  }),
  persist: true  // Automatically saved/restored
})
```

## Pinia vs Hand-Rolled Comparison

| Feature | Hand-Rolled `reactive()` | Pinia |
|---------|-------------------------|-------|
| DevTools integration | No | Yes |
| TypeScript inference | Manual | Automatic |
| HMR support | No | Yes |
| SSR support | Manual | Built-in |
| Plugins | No | Yes |
| Time-travel debugging | No | Yes |
| Learning curve | Lower | Slightly higher |
| Bundle size | Smaller | ~1KB |
| Team conventions | None | Enforced |

## Migration from Vuex

Vuex is now in maintenance mode. Migrate to Pinia for new features:

```javascript
// Vuex (legacy)
export default createStore({
  state: { count: 0 },
  mutations: {
    INCREMENT(state) { state.count++ }
  },
  actions: {
    increment({ commit }) { commit('INCREMENT') }
  }
})

// Pinia (recommended)
export const useCounterStore = defineStore('counter', {
  state: () => ({ count: 0 }),
  actions: {
    increment() { this.count++ }  // No mutations needed!
  }
})
```

**Pinia advantages over Vuex:**
- No mutations (simpler mental model)
- Better TypeScript support
- No nested modules complexity
- Smaller bundle size
- Composition API style available

## Pinia Store Styles

Choose the style that fits your team:

### Options Style (Similar to Options API)

```javascript
export const useCounterStore = defineStore('counter', {
  state: () => ({ count: 0 }),
  getters: {
    double: (state) => state.count * 2
  },
  actions: {
    increment() { this.count++ }
  }
})
```

### Setup Style (Composition API)

```javascript
export const useCounterStore = defineStore('counter', () => {
  const count = ref(0)
  const double = computed(() => count.value * 2)
  function increment() { count.value++ }

  return { count, double, increment }
})
```

## Quick Start

```bash
npm install pinia
```

```javascript
// main.js
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

const app = createApp(App)
app.use(createPinia())
app.mount('#app')
```

## Reference
- [Vue.js - State Management](https://vuejs.org/guide/scaling-up/state-management.html)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Pinia vs Vuex](https://pinia.vuejs.org/introduction.html#comparison-with-vuex)
