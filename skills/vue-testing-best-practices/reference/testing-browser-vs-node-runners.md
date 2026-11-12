---
title: Choose Browser-Based Runner for Style and DOM Event Testing
impact: MEDIUM
impactDescription: Node-based runners cannot test real CSS behavior, native DOM events, cookies, or computed styles
type: capability
tags: [vue3, testing, component-testing, vitest, browser, jsdom]
---

# Choose Browser-Based Runner for Style and DOM Event Testing

**Impact: MEDIUM** - Simulated DOM environments such as jsdom and happy-dom support many DOM APIs, but cannot fully reproduce browser layout, CSS rendering, and native interaction behavior. Use Browser Mode when real browser behavior matters.

Use Vitest for most component tests (fast), but use Vitest Browser Mode when testing visual/DOM-dependent features.

## Task Checklist

- [ ] Use Vitest (node) for logic-focused component tests
- [ ] Use Vitest Browser Mode for style-dependent tests
- [ ] Use Vitest Browser Mode for native events (focus, drag, resize)
- [ ] Use Vitest Browser Mode for real CSS rendering and computed styles
- [ ] Accept slower speed tradeoff for browser accuracy

## When to Use Each Approach

### Node-Based Runner (Vitest + happy-dom/jsdom)
Best for:
- Pure logic testing
- State management
- Event emission
- Props/slots behavior
- Most component interactions
- Fast CI/CD pipelines

```javascript
// vitest.config.js
export default defineConfig({
  test: {
    environment: 'happy-dom',  // or 'jsdom'
  }
})
```

```javascript
// Fast but limited - fine for most tests
test('button emits click event', async () => {
  const wrapper = mount(Button)
  await wrapper.trigger('click')
  expect(wrapper.emitted('click')).toBeTruthy()
})
```

### Vitest Browser Mode
Required for:
- CSS computed styles verification
- CSS transitions/animations
- Real focus/blur behavior
- Drag and drop
- Viewport-dependent behavior
- Cross-browser validation

## Vitest Browser Mode Setup

This setup targets Vitest 4. For older projects, use documentation matching the installed version.

```bash
npm install -D vitest @vitest/browser-playwright playwright vitest-browser-vue @vitejs/plugin-vue
npx playwright install chromium
```

```javascript
// vitest.browser.config.js
import { defineConfig } from 'vitest/config'
import { playwright } from '@vitest/browser-playwright'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    include: ['**/*.browser.test.{js,ts}'],
    browser: {
      enabled: true,
      provider: playwright(),
      instances: [{ browser: 'chromium' }],
    },
  },
})
```

```javascript
// Button.browser.test.js
import { test, expect } from 'vitest'
import { render } from 'vitest-browser-vue'
import Button from './Button.vue'

test('has correct hover styling', async () => {
  const { getByRole } = await render(Button, { props: { label: 'Click me' } })

  const button = getByRole('button')

  // Check initial style
  await expect.element(button).toHaveStyle({
    backgroundColor: 'rgb(59, 130, 246)'  // blue
  })
})

test('maintains focus after click', async () => {
  const { getByRole } = await render(Button)

  const button = getByRole('button')
  await button.click()

  await expect.element(button).toHaveFocus()
})
```

## Examples: What Each Runner Can/Cannot Test

### Styles - Browser Required
```javascript
// Node runner: CANNOT verify actual CSS
test('danger button has red background', () => {
  const wrapper = mount(Button, { props: { variant: 'danger' } })
  // This only checks class exists, not actual color
  expect(wrapper.classes()).toContain('bg-red-500')
})

// Vitest Browser Mode: CAN verify computed styles
test('danger button renders red', async () => {
  const { getByRole } = await render(Button, { props: { variant: 'danger' } })
  await expect.element(getByRole('button')).toHaveStyle({
    backgroundColor: 'rgb(239, 68, 68)'
  })
})
```

### Computed CSS Styles - Browser Required
```javascript
// Node runner: CANNOT get real computed styles
test('button has correct padding', () => {
  const wrapper = mount(Button)
  // getComputedStyle returns empty/default values in jsdom
  const style = window.getComputedStyle(wrapper.element)
  // style.padding will be empty string, not actual computed value
})

// Vitest Browser Mode: Real computed styles
test('button has correct padding', async () => {
  const { getByRole } = await render(Button)
  const button = getByRole('button')

  await expect.element(button).toHaveStyle({
    padding: '12px 24px'
  })
})
```

### Native Events - Browser Required
```javascript
// Node runner: Synthetic events only
test('handles drag and drop', async () => {
  const wrapper = mount(DraggableList)
  // trigger('dragstart') is synthetic - may not work as expected
  await wrapper.find('.item').trigger('dragstart')
})

// Vitest Browser Mode: Real native events via userEvent
import { userEvent } from 'vitest/browser'

test('reorders items on drag', async () => {
  const { getByTestId } = await render(DraggableList)

  const item = getByTestId('item-1')
  const target = getByTestId('item-3')

  await userEvent.dragAndDrop(item, target)

  // Assert reordering
})
```

## Recommended Testing Strategy

```javascript
// vitest.config.js - Separate test configurations
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    // Default: Node environment for speed
    environment: 'happy-dom',

    // Browser tests in separate directory
    include: ['tests/unit/**/*.test.{js,ts}'],
  },
})

// Run browser tests separately
// npx vitest --config vitest.browser.config.js
```

### Directory Structure
```
tests/
├── unit/              # Fast node-based tests
│   ├── Button.test.js
│   └── useCounter.test.js
├── component/         # Slower browser-based tests
│   ├── Button.browser.test.js
│   └── DragDrop.browser.test.js
└── e2e/               # Full E2E tests (Playwright)
    └── user-flow.spec.ts
```

## Reference
- [Vue.js Testing - Component Testing](https://vuejs.org/guide/scaling-up/testing#component-testing)
- [Vitest Browser Mode](https://vitest.dev/guide/browser.html)
