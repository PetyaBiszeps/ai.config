---
title: Return All State Properties in Pinia Setup Stores
impact: HIGH
impactDescription: Not returning state properties in setup stores breaks SSR, DevTools, and plugin compatibility
type: gotcha
tags: [vue3, pinia, state-management, setup-stores, ssr, devtools]
---

# Return All State Properties in Pinia Setup Stores

**Impact: HIGH** - When using Pinia's setup store syntax (Composition API style), you MUST return all state properties from the setup function. Private state that isn't returned will break Server-Side Rendering (SSR), Vue DevTools inspection, and Pinia plugins.

This is a critical gotcha that can cause silent failures in production.

**Security:** The state returned by a Setup Store can be sent to the client during SSR hydration. Keep server-only session tokens and secrets out of Pinia state. A client-visible `hasLoggedIn` flag is only UI state, never an authorization check.

## Task Checklist

- [ ] Return ALL reactive state properties from setup stores
- [ ] Do not create "private" state by omitting it from the return
- [ ] If you need private state, use a prefix convention instead (e.g., `_internal`)
- [ ] Test stores with DevTools to verify all state is visible
- [ ] Verify SSR hydration includes all necessary state

## The Problem: Private State in Setup Stores

```javascript
// stores/user.js - WRONG: Private state breaks SSR/DevTools
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // Public state
  const name = ref('')
  const email = ref('')

  // "Private" state - NOT returned
  const lastLoginAt = ref(null)  // Won't be serialized for SSR!
  const lastFetchTime = ref(null)  // Won't appear in DevTools!

  const hasLoggedIn = computed(() => lastLoginAt.value !== null)

  async function login(credentials) {
    const response = await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify(credentials)
    })
    const data = await response.json()

    lastLoginAt.value = Date.now()  // This state won't transfer to client in SSR!
    name.value = data.name
    email.value = data.email
    lastFetchTime.value = Date.now()
  }

  // WRONG: Not returning lastLoginAt and lastFetchTime
  return {
    name,
    email,
    hasLoggedIn,
    login
  }
})
```

**What breaks:**

1. **SSR Hydration**: `lastLoginAt` and `lastFetchTime` won't be serialized and sent to the client
2. **DevTools**: These properties won't appear in the store inspector
3. **Plugins**: Persistence plugins won't save these properties
4. **Time-travel debugging**: Can't track changes to hidden state

## The Solution: Return Everything

```javascript
// stores/user.js - CORRECT: All state returned
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // All state properties
  const name = ref('')
  const email = ref('')
  const lastLoginAt = ref(null)
  const lastFetchTime = ref(null)

  // Getters
  const hasLoggedIn = computed(() => lastLoginAt.value !== null)

  // Actions
  async function login(credentials) {
    const response = await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify(credentials)
    })
    const data = await response.json()

    lastLoginAt.value = Date.now()
    name.value = data.name
    email.value = data.email
    lastFetchTime.value = Date.now()
  }

  function logout() {
    lastLoginAt.value = null
    name.value = ''
    email.value = ''
  }

  // CORRECT: Return ALL state, getters, and actions
  return {
    // State
    name,
    email,
    lastLoginAt,
    lastFetchTime,
    // Getters
    hasLoggedIn,
    // Actions
    login,
    logout
  }
})
```

## If You Need "Private" State

Use naming conventions instead of actually hiding state:

```javascript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // Convention: underscore prefix for "internal" state
  // Still returned, but signals it's not for external use
  const _lastLoginAt = ref(null)
  const _lastFetchTime = ref(null)

  // Public state
  const name = ref('')
  const email = ref('')

  const hasLoggedIn = computed(() => _lastLoginAt.value !== null)

  // Return everything - convention communicates intent
  return {
    // "Private" - use with caution
    _lastLoginAt,
    _lastFetchTime,
    // Public
    name,
    email,
    hasLoggedIn
  }
})
```

## Option Stores Don't Have This Problem

With the Options API syntax, all state is automatically tracked:

```javascript
// stores/user.js - Options syntax: all state is tracked automatically
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    name: '',
    email: '',
    lastLoginAt: null,  // Automatically included
    lastFetchTime: null  // Automatically included
  }),

  getters: {
    hasLoggedIn: (state) => state.lastLoginAt !== null
  },

  actions: {
    async login(credentials) {
      // ...
    }
  }
})
```

## How Setup Stores Map to State

Understanding the mapping helps avoid mistakes:

```javascript
defineStore('example', () => {
  // ref() becomes state
  const count = ref(0)  // → state.count

  // computed() becomes getters
  const double = computed(() => count.value * 2)  // → getters.double

  // Regular functions become actions
  function increment() {  // → actions.increment
    count.value++
  }

  // CRITICAL: Must return all of them
  return { count, double, increment }
})
```

## Debugging: Verify All State is Returned

```javascript
// Test that DevTools can see all state
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// In DevTools console or tests:
console.log(userStore.$state)
// Should include ALL reactive state properties

// Check what's returned
console.log(Object.keys(userStore))
// Should include: name, email, lastLoginAt, lastFetchTime, hasLoggedIn, login, logout
```

## Reference
- [Pinia - Setup Stores](https://pinia.vuejs.org/core-concepts/#setup-stores)
- [Pinia - SSR](https://pinia.vuejs.org/ssr/)
- [Mastering Pinia - Common Mistakes](https://masteringpinia.com/blog/top-5-mistakes-to-avoid-when-using-pinia)
