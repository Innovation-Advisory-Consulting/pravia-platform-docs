# Import Guide

Guide for importing from `@asyml8/ui` with optimal bundle size and tree-shaking.

## Table of Contents

- [Quick Start](#quick-start)
- [Import Patterns](#import-patterns)
- [Subpath Exports](#subpath-exports)
- [Tree-Shaking](#tree-shaking)
- [Best Practices](#best-practices)

## Quick Start

### Default Import (Recommended for Most Cases)

```tsx
import { Button, DataTable, DashboardLayout } from '@asyml8/ui';
```

This works for all exports and supports tree-shaking when using modern bundlers (Vite, Next.js, etc.).

## Import Patterns

### Components

```tsx
// ✅ Recommended - Tree-shakeable
import { Button, Card, DataTable } from '@asyml8/ui';

// ✅ Also works - Explicit subpath
import { Button } from '@asyml8/ui/components';

// ❌ Avoid - Not supported
import Button from '@asyml8/ui/components/Button';
```

### Theme

```tsx
// ✅ Main theme exports
import { 
  ThemeProvider, 
  themeConfig, 
  defaultSettings,
  SettingsProvider 
} from '@asyml8/ui';

// ✅ Theme-only subpath
import { ThemeProvider, themeConfig } from '@asyml8/ui/theme';
```

### Layouts

```tsx
// ✅ From main entry
import { DashboardLayout, FormLayout } from '@asyml8/ui';

// ✅ From subpath
import { DashboardLayout } from '@asyml8/ui/layouts';
```

### Views

```tsx
// ✅ Auth views
import { SignInForm, SignUpForm } from '@asyml8/ui';

// ✅ From subpath
import { SignInForm } from '@asyml8/ui/views';
```

### Utils

```tsx
// ✅ Utility functions
import { formatNumber, mergeClasses } from '@asyml8/ui';

// ✅ From subpath
import { formatNumber } from '@asyml8/ui/utils';
```

### Hooks

```tsx
// ✅ Custom hooks
import { useBoolean, usePopoverHover } from '@asyml8/ui';

// ✅ From subpath
import { useBoolean } from '@asyml8/ui/hooks';
```

### Lib (Base Classes)

```tsx
// ✅ Base classes for services/stores
import { BaseService, BaseStore, HttpClient } from '@asyml8/ui';

// ✅ From subpath
import { BaseService } from '@asyml8/ui/lib';
```

### CSS Files

```tsx
// ✅ Import CSS directly
import '@asyml8/ui/scrollbar.css';
import '@asyml8/ui/progress-bar.css';
```

## Subpath Exports

The package provides the following subpath exports:

| Subpath | Contents | Use Case |
|---------|----------|----------|
| `@asyml8/ui` | Everything | Default - use for most imports |
| `@asyml8/ui/theme` | Theme system only | When you only need theme |
| `@asyml8/ui/components` | All components | Explicit component imports |
| `@asyml8/ui/layouts` | Layout templates | Layout-specific imports |
| `@asyml8/ui/views` | Pre-built views | View-specific imports |
| `@asyml8/ui/utils` | Utility functions | Utility-specific imports |
| `@asyml8/ui/hooks` | Custom hooks | Hook-specific imports |
| `@asyml8/ui/lib` | Base classes | Service/store base classes |
| `@asyml8/ui/scrollbar.css` | Scrollbar styles | CSS import |
| `@asyml8/ui/progress-bar.css` | Progress bar styles | CSS import |

## Tree-Shaking

### How It Works

Modern bundlers (Vite, Next.js 13+, Webpack 5+) automatically tree-shake unused exports when:

1. Using ES modules (`import`/`export`)
2. Package uses `"sideEffects": false` or specifies side effects
3. Production build with minification enabled

### Verification

To verify tree-shaking is working:

```bash
# Build your app
npm run build

# Analyze bundle (if using Vite)
npx vite-bundle-visualizer

# Check bundle size
ls -lh dist/assets/*.js
```

### What Gets Included

Only the code you import gets bundled:

```tsx
// This import...
import { Button, DataTable } from '@asyml8/ui';

// ...only bundles Button and DataTable code
// Theme, layouts, views, etc. are NOT included
```

## Best Practices

### ✅ Do

```tsx
// Import what you need from main entry
import { Button, Card, formatNumber } from '@asyml8/ui';

// Use subpaths for clarity when importing many items from one category
import { 
  SignInForm, 
  SignUpForm, 
  ResetPasswordForm 
} from '@asyml8/ui/views';

// Import CSS files explicitly
import '@asyml8/ui/scrollbar.css';
```

### ❌ Don't

```tsx
// Don't import everything
import * as UI from '@asyml8/ui'; // ❌ Prevents tree-shaking

// Don't use deep imports (not supported)
import Button from '@asyml8/ui/dist/components/Button'; // ❌ Not supported

// Don't mix default and named imports
import UI, { Button } from '@asyml8/ui'; // ❌ No default export
```

## Bundle Size Optimization

### Minimal Setup (~50KB gzipped)

```tsx
// Just theme provider
import { ThemeProvider, themeConfig } from '@asyml8/ui/theme';
```

### Typical App (~200-300KB gzipped)

```tsx
// Theme + common components + layouts
import { 
  ThemeProvider,
  Button,
  Card,
  DataTable,
  DashboardLayout 
} from '@asyml8/ui';
```

### Full Featured (~500KB+ gzipped)

```tsx
// Everything including views, all components, etc.
import { 
  ThemeProvider,
  // ... all components
  // ... all layouts
  // ... all views
} from '@asyml8/ui';
```

## TypeScript Support

All imports are fully typed:

```tsx
import type { Column, ActionItem } from '@asyml8/ui';
import { DataTable } from '@asyml8/ui';

const columns: Column[] = [
  // TypeScript autocomplete works
];
```

## Migration from Old Imports

If you were using deep imports (not officially supported):

```tsx
// Old (if you were doing this)
import Button from '@asyml8/ui/components/Button';

// New
import { Button } from '@asyml8/ui';
// or
import { Button } from '@asyml8/ui/components';
```

## Questions?

- Check the main [README.md](./README.md) for component documentation
- See [THEME.md](./THEME.md) for theme system details
- Review [package.json](./package.json) exports field for all available subpaths
