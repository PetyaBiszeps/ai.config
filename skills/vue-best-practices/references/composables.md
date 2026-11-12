---
title: Composable Organization Patterns
impact: MEDIUM
impactDescription: Well-structured composables improve maintainability, reusability, and update performance
type: best-practice
tags: [vue3, composables, composition-api, code-organization, api-design, readonly, utilities]
---

# Composable Organization Patterns

**Impact: MEDIUM** - Treat composables as reusable, stateful building blocks and keep their code organized by feature concern. This keeps large components maintainable and prevents hard-to-debug mutation and API design issues.

## Task List

- Compose behavior from small, focused composables when doing so reduces real complexity
- Use options objects for composables with multiple optional parameters
- Return readonly state when updates must flow through explicit actions
- Keep pure utility functions as plain utilities, not composables
- Organize code by feature concern where helpful; extract composables for reuse or meaningful complexity, not just size

## Compose Composables from Smaller Primitives

**BAD:**
```vue
<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const x = ref(0)
const y = ref(0)
const inside = ref(false)
const el = ref(null)

function onMove(e) {
  x.value = e.pageX
  y.value = e.pageY
  if (!el.value) return
  const r = el.value.getBoundingClientRect()
  inside.value = x.value >= r.left && x.value <= r.right &&
    y.value >= r.top && y.value <= r.bottom
}

onMounted(() => window.addEventListener('mousemove', onMove))
onUnmounted(() => window.removeEventListener('mousemove', onMove))
</script>
```

**GOOD:**
```javascript
// composables/useEventListener.js
import { onMounted, onUnmounted, toValue } from 'vue'

export function useEventListener(target, event, callback) {
  let attachedTo
  onMounted(() => {
    attachedTo = toValue(target)
    attachedTo?.addEventListener(event, callback)
  })
  onUnmounted(() => attachedTo?.removeEventListener(event, callback))
}
```

```javascript
// composables/useMouse.js
import { ref } from 'vue'
import { useEventListener } from './useEventListener'

export function useMouse() {
  const x = ref(0)
  const y = ref(0)

  // Resolve window only after mount so SSR can safely evaluate setup.
  useEventListener(() => window, 'mousemove', (e) => {
    x.value = e.pageX
    y.value = e.pageY
  })

  return { x, y }
}
```

```javascript
// composables/useMouseInElement.js
import { computed } from 'vue'
import { useMouse } from './useMouse'

export function useMouseInElement(elementRef) {
  const { x, y } = useMouse()

  const isOutside = computed(() => {
    if (!elementRef.value) return true
    const rect = elementRef.value.getBoundingClientRect()
    return x.value < rect.left || x.value > rect.right ||
      y.value < rect.top || y.value > rect.bottom
  })

  return { x, y, isOutside }
}
```

## Accept maybe-reactive inputs when adaptability is useful

For a public or genuinely reusable read-only input, Vue 3.3+ provides `MaybeRefOrGetter<T>`: a raw value, a `Ref`, a computed ref, or a zero-argument getter. For a private project-specific composable, a simple `string` or `Ref<string>` may be clearer.

```ts
import { computed, toValue } from 'vue'
import type { MaybeRefOrGetter } from 'vue'

export function useNormalizedQuery(query: MaybeRefOrGetter<string>) {
  const normalizedQuery = computed(() => toValue(query).trim().toLowerCase())
  return { normalizedQuery }
}
```

This supports `useNormalizedQuery('Hello')`, `useNormalizedQuery(ref('Hello'))`, and `useNormalizedQuery(() => props.query)`. **Resolve `toValue(query)` inside `computed`, `watch` source, or `watchEffect`** when subsequent changes must be tracked. Normalizing once in setup loses reactive updates from getters/refs.

### Distinguish readable from writable inputs

If the composable needs to update the caller's reactive value, require a writable `Ref<T>` rather than `MaybeRef<T>` with a raw-value fallback:

```ts
import type { Ref } from 'vue'

export function useIncrement(count: Ref<number>) {
  return { increment: () => { count.value += 1 } }
}
```

A plain `number` cannot be modified in the caller by turning it into a new local `ref`. For callbacks or predicates whose **value is a function**, avoid `MaybeRefOrGetter<Function>` with `toValue()` because it would call that function as a getter. Use an explicit function signature (or a well-defined `Ref<Function>`) instead.

### SSR and lifecycle

For DOM side effects, use `onMounted()` (or a browser guard) and clean up listeners/timers in `onUnmounted()`. Avoid reading `window` or `document` while executing server-side setup. Consider async cancellation and avoid cross-request module-level reactive singletons in SSR.

## Use Options Object Pattern for Composable Parameters

**BAD:**
```javascript
export function useFetch(url, method, headers, timeout, retries, immediate) {
  // hard to read and easy to misorder
}

useFetch('/api/users', 'GET', null, 5000, 3, true)
```

**GOOD:**
```javascript
export function useFetch(url, options = {}) {
  const {
    method = 'GET',
    headers = {},
    timeout = 30000,
    retries = 0,
    immediate = true
  } = options

  // implementation
  return { method, headers, timeout, retries, immediate }
}

useFetch('/api/users', {
  method: 'POST',
  timeout: 5000,
  retries: 3
})
```

```typescript
interface UseCounterOptions {
  initial?: number
  min?: number
  max?: number
  step?: number
}

export function useCounter(options: UseCounterOptions = {}) {
  const { initial = 0, min = -Infinity, max = Infinity, step = 1 } = options
  // implementation
}
```

## Return Readonly State with Explicit Actions

**BAD:**
```javascript
export function useCart() {
  const items = ref([])
  const total = computed(() => items.value.reduce((sum, item) => sum + item.price, 0))
  return { items, total } // any consumer can mutate directly
}

const { items } = useCart()
items.value.push({ id: 1, price: 10 })
```

**GOOD:**
```javascript
import { ref, computed, readonly } from 'vue'

export function useCart() {
  const _items = ref([])

  const total = computed(() =>
    _items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  )

  function addItem(product, quantity = 1) {
    const existing = _items.value.find(item => item.id === product.id)
    if (existing) {
      existing.quantity += quantity
      return
    }
    _items.value.push({ ...product, quantity })
  }

  function removeItem(productId) {
    _items.value = _items.value.filter(item => item.id !== productId)
  }

  return {
    items: readonly(_items),
    total,
    addItem,
    removeItem
  }
}
```

## Keep Utilities as Utilities

**BAD:**
```javascript
export function useFormatters() {
  const formatDate = (date) => new Intl.DateTimeFormat('en-US').format(date)
  const formatCurrency = (amount) =>
    new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
  return { formatDate, formatCurrency }
}

const { formatDate } = useFormatters()
```

**GOOD:**
```javascript
// utils/formatters.js
export function formatDate(date) {
  return new Intl.DateTimeFormat('en-US').format(date)
}

export function formatCurrency(amount) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD'
  }).format(amount)
}
```

```javascript
// composables/useInvoiceSummary.js
import { computed } from 'vue'
import { formatCurrency } from '@/utils/formatters'

export function useInvoiceSummary(invoiceRef) {
  const totalLabel = computed(() => formatCurrency(invoiceRef.value.total))
  return { totalLabel }
}
```

## Organize Composable and Component Code by Feature Concern

**BAD:**
```vue
<script setup>
import { ref, computed, watch, onMounted } from 'vue'

const searchQuery = ref('')
const items = ref([])
const selected = ref(null)
const showModal = ref(false)
const sortBy = ref('name')
const filter = ref('all')
const loading = ref(false)

const filtered = computed(() => items.value.filter(i => i.category === filter.value))
function openModal() { showModal.value = true }
const sorted = computed(() => [...filtered.value].sort(/* ... */))
watch(searchQuery, () => { /* ... */ })
onMounted(() => { /* ... */ })
</script>
```

**GOOD:**
```vue
<script setup>
import { useItems } from '@/composables/useItems'
import { useSearch } from '@/composables/useSearch'
import { useSelectionModal } from '@/composables/useSelectionModal'

// Data
const { items, loading, fetchItems } = useItems()

// Search/filter/sort
const { query, visibleItems } = useSearch(items)

// Selection + modal
const { selectedItem, isModalOpen, selectItem, closeModal } = useSelectionModal()
</script>
```

```javascript
// composables/useItems.js
import { ref, onMounted } from 'vue'

export function useItems() {
  const items = ref([])
  const loading = ref(false)

  async function fetchItems() {
    loading.value = true
    try {
      items.value = await api.getItems()
    } finally {
      loading.value = false
    }
  }

  onMounted(fetchItems)
  return { items, loading, fetchItems }
}
```
