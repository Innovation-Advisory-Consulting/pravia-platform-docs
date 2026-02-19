# RouterLink Integration Changes

## Summary
Updated the UI package to support React Router navigation instead of Next.js Link, preventing hard page refreshes when navigating.

## Changes Made

### 1. Dashboard Layout (`layouts/templates/dashboard-layout/dashboard-layout.tsx`)
- Added `RouterLink` to `slotProps` type definition
- Passes `RouterLink` component to NavVertical, NavHorizontal, and NavMobile components

### 2. Nav Components (`layouts/templates/dashboard-layout/components/`)
- **nav-vertical.tsx**: Accepts `RouterLink` prop and passes to NavSectionVertical and NavSectionMini
- **nav-horizontal.tsx**: Accepts `RouterLink` prop and passes to NavSectionHorizontal  
- **nav-mobile.tsx**: Accepts `RouterLink` prop and passes to NavSectionVertical

### 3. Navigation Menu Types (`components/navigation/navigation-menu/types.ts`)
- Added `RouterLink?: React.ComponentType<any>` to:
  - `NavSectionProps` - Main navigation section props
  - `NavItemProps` - Individual nav item props
  - `NavListProps` - Nav list props (updated Pick to include RouterLink)

### 4. Create Nav Item Utility (`components/navigation/navigation-menu/utils/create-nav-item.ts`)
- Removed hardcoded `import Link from 'next/link'`
- Added `RouterLink` parameter to `CreateNavItemProps`
- Updated link creation logic:
  - External links: Use regular anchor with target="_blank"
  - Internal links with RouterLink: Use `{ component: RouterLink, href: path }`
  - Internal links without RouterLink: Fallback to `{ href: path }`
- Added comments explaining the navigation logic

### 5. Vertical Navigation (`components/navigation/navigation-menu/vertical/`)
- **nav-item.tsx**: Accepts `RouterLink` prop and passes to `createNavItem()`
- **nav-list.tsx**: Accepts `RouterLink` prop and passes to `NavItem` component
- **nav-section-vertical.tsx**: Accepts `RouterLink` prop and passes to `NavList` components

### 6. Horizontal & Mini Navigation
- Same pattern as vertical navigation needs to be applied to:
  - `horizontal/nav-item.tsx`
  - `horizontal/nav-list.tsx`
  - `horizontal/nav-section-horizontal.tsx`
  - `mini/nav-item.tsx`
  - `mini/nav-section-mini.tsx`

## Usage in App

```tsx
import { RouterLink } from 'src/routes/components';

<DashboardLayout
  navData={navData}
  slotProps={{
    RouterLink,  // Pass RouterLink component here
  }}
  // ... other props
>
  {children}
</DashboardLayout>
```

## How It Works

1. App passes `RouterLink` component to `DashboardLayout` via `slotProps`
2. `DashboardLayout` passes it to nav components (NavVertical, NavHorizontal, NavMobile)
3. Nav components pass it to NavSection components
4. NavSection components pass it to NavList components
5. NavList components pass it to NavItem components
6. NavItem components pass it to `createNavItem()` utility
7. `createNavItem()` uses it to create link props: `{ component: RouterLink, href: path }`
8. MUI ButtonBase renders with RouterLink, enabling React Router navigation without page refreshes

## Benefits

- ✅ No hard page refreshes when navigating
- ✅ Preserves React state during navigation
- ✅ Faster navigation (no full page reload)
- ✅ Better user experience
- ✅ Works with React Router's lazy loading
