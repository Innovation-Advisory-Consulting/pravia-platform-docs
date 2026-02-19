# Routing Abstraction Impact Analysis

## Executive Summary

**Impact Level: HIGH** ⚠️ **BREAKING CHANGES**

While mule-client has its own routing abstractions, it **DOES use @asyml8/ui components** that internally depend on Next.js routing. These components will break when you implement runtime detection.

### Components That Will Break:
1. **DashboardLayout** - uses navigation menu internally
2. **Navigation menus** (mini, horizontal, vertical) - use `usePathname()` from `next/navigation`
3. **CustomBreadcrumbs** - uses `RouterLink` from `next/link`
4. **ProgressBar** - accepts `usePathname` as prop (already handled correctly)

## Current Architecture

### @asyml8/ui Package (Shared Library)
```
packages/ui/src/components/navigation/routes/
├── hooks/
│   ├── use-router.ts          → exports from next/navigation
│   ├── use-pathname.ts        → exports from next/navigation
│   ├── use-params.ts          → exports from next/navigation
│   └── use-search-params.ts   → exports from next/navigation
└── components/
    ├── router-link.tsx        → exports from next/link
    └── universal-link.tsx     → runtime detection (Next.js vs React Router)
```

### mule-client App (Next.js Consumer)
```
apps/mule-client/src/routes/
├── hooks/
│   ├── use-router.ts          → imports from next/navigation (with NProgress)
│   ├── use-pathname.ts        → exports from next/navigation
│   ├── use-params.ts          → exports from next/navigation
│   └── use-search-params.ts   → exports from next/navigation
└── components/
    └── router-link.tsx        → exports from next/link
```

## Key Finding

**mule-client does NOT import routing utilities from @asyml8/ui**

All routing imports in mule-client use local paths:
```typescript
// ✅ Current usage in mule-client
import { useRouter } from 'src/routes/hooks';
import { usePathname } from 'src/routes/hooks';
import { RouterLink } from 'src/routes/components';

// ❌ NOT used
import { useRouter } from '@asyml8/ui';
```

## ⚠️ BREAKING: Components Using Routing Internally

### Critical Issue
mule-client imports these @asyml8/ui components that have **hardcoded Next.js routing**:

1. **DashboardLayout** (used in 3 files)
   - `src/app/admin/layout.tsx`
   - `src/app/dashboard/layout.tsx`
   - `src/layouts/dashboard-layout-wrapper.tsx`

2. **Navigation Menu Components** (internal to DashboardLayout)
   - `NavList` components use `usePathname()` from `next/navigation`
   - Located in: `packages/ui/src/components/navigation/navigation-menu/`

3. **CustomBreadcrumbs** (if used)
   - Uses `RouterLink` from `next/link`
   - Located in: `packages/ui/src/components/data-display/custom-breadcrumbs/`

### Why This Breaks

When you change @asyml8/ui routing to use runtime detection:
```typescript
// packages/ui/src/components/navigation/routes/hooks/use-pathname.ts
export function usePathname() {
  if (typeof window !== 'undefined' && 'next' in window) {
    return require('next/navigation').usePathname();
  }
  return require('react-router-dom').useLocation().pathname;
}
```

The navigation menu components still import directly:
```typescript
// packages/ui/src/components/navigation/navigation-menu/mini/nav-list.tsx
import { usePathname } from 'next/navigation'; // ❌ HARDCODED
```

This creates a mismatch where:
- Your abstraction layer tries to support both Next.js and Vite
- But the components bypass the abstraction and call Next.js directly
- mule-client (Next.js app) will still work
- **Any Vite SPA using these components will crash**

## Usage Analysis

### Files Using Routing in mule-client (30+ files)

**Direct Next.js imports (3 files):**
- `src/sections/admin/users/view/users-list-view.tsx`
- `src/sections/admin/users/view/user-profile-view.tsx`
- `src/sections/my-workspace/submissions/view/submissions-list-view.tsx`

**Local routing hooks (20+ files):**
- All auth pages (`src/app/auth/**`)
- Layout files (`src/app/admin/layout.tsx`, `src/app/dashboard/layout.tsx`)
- Auth views (`src/auth/view/**`)
- Main page (`src/app/page.tsx`)

## Impact Assessment

### ✅ Zero Breaking Changes
Since mule-client uses its own routing abstractions, changes to @asyml8/ui routing will **not break** mule-client.

### 🔄 Optional Migration Path
If you want mule-client to use @asyml8/ui routing in the future:

1. **Update imports** (30+ files):
   ```typescript
   // Before
   import { useRouter } from 'src/routes/hooks';
   
   // After
   import { useRouter } from '@asyml8/ui';
   ```

2. **Remove local routing files**:
   - Delete `src/routes/hooks/`
   - Delete `src/routes/components/`

3. **Preserve NProgress integration**:
   The mule-client `useRouter` has NProgress integration that would need to be preserved or moved to a wrapper.

## Recommendations

### REQUIRED: Fix @asyml8/ui Components

**All navigation components must use the abstraction layer:**

```typescript
// ❌ BEFORE (hardcoded)
// packages/ui/src/components/navigation/navigation-menu/mini/nav-list.tsx
import { usePathname } from 'next/navigation';

// ✅ AFTER (use abstraction)
import { usePathname } from '../../routes/hooks';
```

**Files that need updating:**
1. `src/components/navigation/navigation-menu/mini/nav-list.tsx`
2. `src/components/navigation/navigation-menu/horizontal/nav-list.tsx`
3. `src/components/navigation/navigation-menu/vertical/nav-list.tsx`
4. `src/components/data-display/custom-breadcrumbs/back-link.tsx`
5. `src/components/data-display/custom-breadcrumbs/breadcrumb-link.tsx`

### Implementation Steps

1. **Update @asyml8/ui routing abstractions** (as planned)
   ```typescript
   // use-pathname.ts
   export function usePathname() {
     if (typeof window !== 'undefined' && 'next' in window) {
       return require('next/navigation').usePathname();
     }
     return require('react-router-dom').useLocation().pathname;
   }
   ```

2. **Update all component imports** (5 files)
   ```typescript
   // Change all direct Next.js imports to use abstraction
   import { usePathname } from '../../routes/hooks';
   import { RouterLink } from '../../routes/components';
   ```

3. **Test in mule-client**
   - Run `pnpm dev` in mule-client
   - Navigate to dashboard pages
   - Verify navigation menus work
   - Check breadcrumbs render correctly

4. **Add peer dependency**
   ```json
   {
     "peerDependencies": {
       "react-router-dom": "^6.0.0"
     },
     "peerDependenciesMeta": {
       "react-router-dom": {
         "optional": true
       }
     }
   }
   ```

### For mule-client App

**Option A: Keep current approach** (Recommended)
- No changes needed
- Maintains full control over routing
- Preserves NProgress integration

**Option B: Migrate to @asyml8/ui routing**
- Only if you want centralized routing logic
- Requires updating 30+ import statements
- Need to handle NProgress separately

## Files Requiring Direct Next.js Import Updates

Only 3 files import directly from `next/navigation` instead of local abstractions:

1. `src/sections/admin/users/view/users-list-view.tsx`
2. `src/sections/admin/users/view/user-profile-view.tsx`
3. `src/sections/my-workspace/submissions/view/submissions-list-view.tsx`

**Fix:**
```typescript
// Before
import { useRouter } from 'next/navigation';

// After
import { useRouter } from 'src/routes/hooks';
```

## Conclusion

**⚠️ IMMEDIATE ACTION REQUIRED**

The routing abstraction changes will NOT break mule-client directly, BUT:

1. **5 component files** in @asyml8/ui have hardcoded Next.js imports
2. These components are used by mule-client (DashboardLayout, navigation menus)
3. **Must update component imports** to use the abstraction layer
4. Without this fix, Vite SPA apps cannot use these components

### Action Items:
- [ ] Update 5 component files to use routing abstractions
- [ ] Test DashboardLayout in mule-client
- [ ] Add react-router-dom as optional peer dependency
- [ ] Document which components require routing context

The architecture is sound, but the implementation needs to be completed across all components that use routing.
