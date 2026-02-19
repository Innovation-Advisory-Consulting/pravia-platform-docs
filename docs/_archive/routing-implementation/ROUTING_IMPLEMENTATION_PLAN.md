# Routing Abstraction Implementation Plan

## Phase 1: packages/ui (Shared Library)

### Step 1.1: Update Routing Abstractions

**File: `packages/ui/src/components/navigation/routes/hooks/use-pathname.ts`**
```typescript
'use client';

export function usePathname(): string {
  if (typeof window !== 'undefined' && 'next' in window) {
    const { usePathname: useNextPathname } = require('next/navigation');
    return useNextPathname();
  }
  
  const { useLocation } = require('react-router-dom');
  return useLocation().pathname;
}
```

**File: `packages/ui/src/components/navigation/routes/hooks/use-params.ts`**
```typescript
'use client';

export function useParams<T = any>(): T {
  if (typeof window !== 'undefined' && 'next' in window) {
    const { useParams: useNextParams } = require('next/navigation');
    return useNextParams();
  }
  
  const { useParams: useRouterParams } = require('react-router-dom');
  return useRouterParams();
}
```

**File: `packages/ui/src/components/navigation/routes/hooks/use-search-params.ts`**
```typescript
'use client';

export function useSearchParams() {
  if (typeof window !== 'undefined' && 'next' in window) {
    const { useSearchParams: useNextSearchParams } = require('next/navigation');
    return useNextSearchParams();
  }
  
  const { useSearchParams: useRouterSearchParams } = require('react-router-dom');
  const [searchParams] = useRouterSearchParams();
  return searchParams;
}
```

**File: `packages/ui/src/components/navigation/routes/hooks/use-router.ts`**
```typescript
'use client';

import { useMemo, useCallback } from 'react';

export function useRouter() {
  if (typeof window !== 'undefined' && 'next' in window) {
    const { useRouter: useNextRouter } = require('next/navigation');
    return useNextRouter();
  }
  
  const { useNavigate } = require('react-router-dom');
  const navigate = useNavigate();
  
  return useMemo(
    () => ({
      push: (href: string) => navigate(href),
      replace: (href: string) => navigate(href, { replace: true }),
      back: () => navigate(-1),
      forward: () => navigate(1),
      refresh: () => window.location.reload(),
      prefetch: () => {}, // No-op for non-Next.js
    }),
    [navigate]
  );
}
```

**File: `packages/ui/src/components/navigation/routes/components/router-link.tsx`**
```typescript
'use client';

import type { ComponentType } from 'react';

let RouterLink: ComponentType<any>;

if (typeof window !== 'undefined' && 'next' in window) {
  RouterLink = require('next/link').default;
} else {
  try {
    const { Link } = require('react-router-dom');
    RouterLink = Link;
  } catch {
    // Fallback to anchor tag
    RouterLink = 'a' as any;
  }
}

export { RouterLink };
```

### Step 1.2: Update Components to Use Abstractions

**File: `packages/ui/src/components/navigation/navigation-menu/mini/nav-list.tsx`**
```diff
- import { usePathname } from 'next/navigation';
+ import { usePathname } from '../../routes/hooks';
```

**File: `packages/ui/src/components/navigation/navigation-menu/horizontal/nav-list.tsx`**
```diff
- import { usePathname } from 'next/navigation';
+ import { usePathname } from '../../routes/hooks';
```

**File: `packages/ui/src/components/navigation/navigation-menu/vertical/nav-list.tsx`**
```diff
- import { usePathname } from 'next/navigation';
+ import { usePathname } from '../../routes/hooks';
```

**File: `packages/ui/src/components/data-display/custom-breadcrumbs/back-link.tsx`**
```diff
- import { RouterLink } from '../../navigation/routes/components';
+ import { RouterLink } from '../../../navigation/routes/components';
```
(Verify the path is correct based on file structure)

**File: `packages/ui/src/components/data-display/custom-breadcrumbs/breadcrumb-link.tsx`**
```diff
- import { RouterLink } from '../../navigation/routes/components';
+ import { RouterLink } from '../../../navigation/routes/components';
```

### Step 1.3: Update package.json

**File: `packages/ui/package.json`**
```json
{
  "peerDependencies": {
    "react": "^18.0.0 || ^19.0.0",
    "react-dom": "^18.0.0 || ^19.0.0",
    "next": "^14.0.0 || ^15.0.0",
    "react-router-dom": "^6.0.0"
  },
  "peerDependenciesMeta": {
    "next": {
      "optional": true
    },
    "react-router-dom": {
      "optional": true
    }
  }
}
```

### Step 1.4: Build and Test

```bash
cd packages/ui
pnpm build
pnpm type-check
```

---

## Phase 2: apps/mule-client (Next.js App)

### Step 2.1: Fix Direct Next.js Imports (Optional Cleanup)

**File: `apps/mule-client/src/sections/admin/users/view/users-list-view.tsx`**
```diff
- import { useRouter } from 'next/navigation';
+ import { useRouter } from 'src/routes/hooks';
```

**File: `apps/mule-client/src/sections/admin/users/view/user-profile-view.tsx`**
```diff
- import { useRouter } from 'next/navigation';
+ import { useRouter } from 'src/routes/hooks';
```

**File: `apps/mule-client/src/sections/my-workspace/submissions/view/submissions-list-view.tsx`**
```diff
- import { useRouter } from 'next/navigation';
+ import { useRouter } from 'src/routes/hooks';
```

### Step 2.2: Test Critical Paths

```bash
cd apps/mule-client
pnpm dev
```

**Test Checklist:**
- [ ] Navigate to `/dashboard` - verify navigation menu works
- [ ] Navigate to `/admin/users` - verify navigation menu works
- [ ] Click navigation menu items - verify routing works
- [ ] Check breadcrumbs render correctly
- [ ] Verify progress bar completes on navigation
- [ ] Test back/forward browser buttons
- [ ] Check console for errors

### Step 2.3: Verify DashboardLayout

**Test these pages specifically:**
- `/admin/users`
- `/admin/roles`
- `/admin/permissions`
- `/dashboard`
- `/dashboard/contacts`
- `/my-workspace/organization`
- `/my-workspace/contacts`
- `/my-workspace/submissions`

---

## Phase 3: Validation

### 3.1 Type Checking
```bash
# In packages/ui
pnpm type-check

# In apps/mule-client
pnpm tsc:watch
```

### 3.2 Build Verification
```bash
# Build UI package
cd packages/ui
pnpm build

# Build mule-client
cd ../../apps/mule-client
pnpm build
```

### 3.3 Runtime Testing
```bash
# Start dev server
cd apps/mule-client
pnpm dev

# Run in browser and test all navigation
```

---

## Rollback Plan

If issues occur:

### Quick Rollback (packages/ui)
```bash
cd packages/ui
git checkout src/components/navigation/routes/
git checkout src/components/navigation/navigation-menu/
git checkout src/components/data-display/custom-breadcrumbs/
pnpm build
```

### Quick Rollback (mule-client)
```bash
cd apps/mule-client
git checkout src/sections/admin/users/view/
git checkout src/sections/my-workspace/submissions/view/
```

---

## Success Criteria

- ✅ All TypeScript compilation passes
- ✅ mule-client builds successfully
- ✅ Navigation menus render and work correctly
- ✅ Breadcrumbs render with correct links
- ✅ No console errors during navigation
- ✅ All dashboard pages accessible
- ✅ Browser back/forward buttons work
- ✅ Progress bar completes on route changes

---

## Timeline Estimate

- **Phase 1 (packages/ui)**: 30 minutes
  - Update routing abstractions: 15 min
  - Update component imports: 10 min
  - Build and verify: 5 min

- **Phase 2 (mule-client)**: 20 minutes
  - Fix direct imports: 5 min
  - Test critical paths: 15 min

- **Phase 3 (validation)**: 15 minutes
  - Type checking: 5 min
  - Build verification: 5 min
  - Runtime testing: 5 min

**Total: ~65 minutes**

---

## Notes

1. **No breaking changes for mule-client** - it will continue to work with Next.js
2. **Enables Vite SPA support** - components can now be used in non-Next.js apps
3. **Backward compatible** - existing Next.js apps continue to work
4. **Runtime detection** - automatically uses correct router based on environment
