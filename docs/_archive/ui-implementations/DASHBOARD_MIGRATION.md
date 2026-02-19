# Dashboard Layout Migration Guide

## Overview

The dashboard layout has been extracted from `mule-client` into the `@asyml8/ui` package as a reusable template. This allows other apps in the monorepo to use the same dashboard structure.

## What Was Migrated (Phase 1 - Complete)

### Core Components
- ✅ `DashboardLayout` - Main layout component with slot-based architecture
- ✅ `NavVertical` - Vertical navigation sidebar (supports mini mode)
- ✅ `NavHorizontal` - Horizontal navigation bar
- ✅ `NavMobile` - Mobile drawer navigation
- ✅ `dashboardLayoutVars` - CSS variables for layout dimensions
- ✅ `dashboardNavColorVars` - CSS variables for navigation theming

### Location
```
packages/ui/src/layouts/templates/dashboard-layout/
├── dashboard-layout.tsx
├── css-vars.ts
├── components/
│   ├── nav-vertical.tsx
│   ├── nav-horizontal.tsx
│   └── nav-mobile.tsx
└── index.ts
```

## Key Changes from Original

### 1. Slot-Based Architecture
The new layout uses a flexible slot system instead of hardcoded components:

```tsx
<DashboardLayout
  navData={navData}
  slots={{
    header: {
      leftArea: <YourHeaderLeft />,
      rightArea: <YourHeaderRight />,
    },
    nav: {
      topArea: <YourNavTop />,
      toggleButton: <YourToggleButton />,
    },
  }}
/>
```

### 2. Pathname as Prop
Mobile nav now accepts `pathname` as a prop instead of using `usePathname()` hook internally:

```tsx
<DashboardLayout
  pathname={pathname}  // Pass from your app
  navOpen={navOpen}
  onNavClose={onNavClose}
/>
```

### 3. State Management Externalized
Layout state (nav open/close, layout mode) is managed by the consuming app:

```tsx
const { value: navOpen, onFalse: onNavClose } = useBoolean();
const settings = useSettingsContext();

<DashboardLayout
  navOpen={navOpen}
  onNavClose={onNavClose}
  onNavToggle={handleNavToggle}
  navLayout={settings.state.navLayout}
  navColor={settings.state.navColor}
/>
```

## Migration Steps for Apps

### Step 1: Install Updated UI Package
```bash
npm install @asyml8/ui@latest
```

### Step 2: Create App-Specific Wrapper
See `apps/mule-client/src/layouts/dashboard-layout-wrapper.tsx` for a complete example.

Key responsibilities of the wrapper:
- Fetch navigation data
- Manage nav open/close state
- Handle settings/preferences
- Provide app-specific components (searchbar, account menu, etc.)
- Handle permissions/role checks

### Step 3: Replace Old Layout
```tsx
// Before
import { DashboardLayout } from 'src/layouts/dashboard';

// After
import { DashboardLayoutWrapper } from 'src/layouts/dashboard-layout-wrapper';

// Usage stays the same
<DashboardLayoutWrapper>
  {children}
</DashboardLayoutWrapper>
```

## What Stays in Your App

These components remain app-specific and should NOT be migrated to UI package:

- `nav-config-dashboard.tsx` - Navigation menu structure
- `nav-config-account.tsx` - Account menu items
- `nav-config-workspace.tsx` - Workspace menu items
- `components/searchbar/` - Search functionality
- `components/account-drawer.tsx` - Account menu
- `components/account-popover.tsx` - Account popover
- `components/notifications-drawer/` - Notifications
- `components/settings-button.tsx` - Settings
- `components/language-popover.tsx` - Language selector
- `components/workspaces-popover.tsx` - Workspace switcher
- `components/nav-toggle-button.tsx` - Nav toggle button
- `components/menu-button.tsx` - Mobile menu button
- `components/footer.tsx` - Footer content

## API Reference

### DashboardLayout Props

```tsx
type DashboardLayoutProps = {
  // Required
  navData: NavSectionProps['data'];
  children: React.ReactNode;
  
  // Navigation state
  navOpen?: boolean;
  onNavClose?: () => void;
  onNavToggle?: () => void;
  pathname?: string;
  
  // Layout configuration
  navLayout?: 'vertical' | 'horizontal' | 'mini';
  navColor?: 'integrate' | 'apparent';
  layoutQuery?: Breakpoint;
  
  // Permissions
  checkPermissions?: (allowedRoles?: string[]) => boolean;
  
  // Customization
  slots?: {
    header?: {
      topArea?: React.ReactNode;
      leftArea?: React.ReactNode;
      rightArea?: React.ReactNode;
      bottomArea?: React.ReactNode;
    };
    nav?: {
      topArea?: React.ReactNode;
      bottomArea?: React.ReactNode;
      toggleButton?: React.ReactNode;
    };
  };
  
  slotProps?: {
    header?: HeaderSectionProps;
    main?: MainSectionProps;
  };
  
  // Styling
  sx?: SxProps<Theme>;
  cssVars?: Record<string, any>;
};
```

## Next Steps (Future Phases)

### Phase 2: Extract Reusable Components
Consider moving these to UI package if needed by multiple apps:
- Generic searchbar component
- Generic notifications drawer
- Generic settings button

### Phase 3: Storybook Documentation
- Create stories for all dashboard variants
- Document all slot combinations
- Show responsive behavior

### Phase 4: Additional Apps
- Migrate other apps to use new dashboard layout
- Gather feedback and iterate

## Benefits

1. **Consistency** - All apps use the same layout structure
2. **Maintainability** - Fix bugs once, benefit everywhere
3. **Flexibility** - Slot-based architecture allows customization
4. **Type Safety** - Full TypeScript support
5. **Documentation** - Centralized in UI package

## Support

For questions or issues, contact the UI team or create an issue in the monorepo.
