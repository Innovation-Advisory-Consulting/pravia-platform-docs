# Routing Abstraction Fix

## Problem

Turbopack (Next.js dev mode) was trying to resolve `react-router-dom` even though it's in a try-catch block, causing:
```
Module not found: Can't resolve 'react-router-dom'
```

## Root Cause

- @asyml8/ui components (DashboardLayout, navigation menus) use routing hooks
- These hooks have fallback logic to `react-router-dom`
- Turbopack analyzes all `require()` statements at build time
- Even though the code would never execute the react-router-dom path in Next.js, Turbopack still tries to resolve it

## Solution

### 1. Updated next.config.ts

Added webpack resolve fallback to tell Next.js to ignore `react-router-dom`:

```typescript
webpack(config, { isServer }) {
  config.module.rules.push({
    test: /\.svg$/,
    use: ['@svgr/webpack'],
  });

  // Ignore optional peer dependency react-router-dom
  config.resolve.fallback = {
    ...config.resolve.fallback,
    'react-router-dom': false,
  };

  return config;
},
```

### 2. Enhanced Routing Hooks with Better Fallbacks

Updated all routing hooks to have proper fallbacks that don't require react-router-dom:

**use-pathname.ts**:
```typescript
try {
  const { usePathname: useNextPathname } = require('next/navigation');
  return useNextPathname();
} catch (e) {
  try {
    const { useLocation } = require('react-router-dom');
    return useLocation().pathname;
  } catch {
    // Fallback to window.location
    return window.location.pathname;
  }
}
```

**use-router.ts**:
```typescript
try {
  const { useRouter: useNextRouter } = require('next/navigation');
  return useNextRouter();
} catch (e) {
  try {
    const { useNavigate } = require('react-router-dom');
    // ... React Router implementation
  } catch {
    // Fallback to window.location
    return {
      push: (href: string) => window.location.href = href,
      replace: (href: string) => window.location.replace(href),
      back: () => window.history.back(),
      // ...
    };
  }
}
```

## Why This Works

1. **Next.js apps**: 
   - `require('next/navigation')` succeeds
   - Uses Next.js routing
   - `react-router-dom` is never required
   - webpack fallback prevents resolution errors

2. **Vite SPA apps**:
   - `require('next/navigation')` fails
   - Falls back to `react-router-dom`
   - Works with React Router

3. **Fallback apps**:
   - Both Next.js and React Router fail
   - Uses native browser APIs (window.location, window.history)

## Testing

### Dev Server
```bash
cd apps/mule-client
pnpm dev
# ✅ Server starts successfully on http://localhost:3000
```

### Production Build
```bash
cd apps/mule-client
pnpm build
# ✅ Build completes successfully
```

## Files Changed

1. `apps/mule-client/next.config.ts` - Added resolve.fallback
2. `packages/ui/src/components/navigation/routes/hooks/use-pathname.ts` - Enhanced fallbacks
3. `packages/ui/src/components/navigation/routes/hooks/use-params.ts` - Enhanced fallbacks
4. `packages/ui/src/components/navigation/routes/hooks/use-search-params.ts` - Enhanced fallbacks
5. `packages/ui/src/components/navigation/routes/hooks/use-router.ts` - Enhanced fallbacks

## Status

✅ **FIXED** - mule-client dev server now starts successfully with Turbopack
