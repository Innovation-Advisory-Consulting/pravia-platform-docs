# Mule-SPA Deduplication Analysis

## Executive Summary

This analysis identifies duplicate code in `mule-spa` that already exists in `packages/ui`. The goal is to remove local duplicates and import from the shared package, following the pattern established in `mule-client` (Next.js).

**Key Difference**: `mule-client` uses Next.js, `mule-spa` uses Vite + React Router.

---

## 1. Components to Remove & Import from @asyml8/ui

### 1.1 Hook Form Components ✅ HIGH PRIORITY
**Location**: `src/components/hook-form/`

**Duplicates in packages/ui**: `packages/ui/src/components/inputs/hook-form/`

**Files to Remove**:
- `rhf-select.tsx`
- `rhf-rating.tsx`
- `rhf-switch.tsx`
- `rhf-slider.tsx`
- `rhf-checkbox.tsx`
- `rhf-text-field.tsx`
- `rhf-date-picker.tsx`
- `rhf-radio-group.tsx`
- `rhf-autocomplete.tsx`
- `schema-utils.ts`
- `form-provider.tsx`
- `fields.tsx`
- `help-text.tsx`

**Action**:
```typescript
// Replace local imports with:
import {
  RHFSelect,
  RHFRating,
  RHFSwitch,
  RHFSlider,
  RHFCheckbox,
  RHFTextField,
  RHFDatePicker,
  RHFRadioGroup,
  RHFAutocomplete,
  FormProvider,
  Field,
  schemaHelper
} from '@asyml8/ui/components/inputs/hook-form';
```

**Note**: packages/ui has additional components not in mule-spa:
- `rhf-phone-input.tsx`
- `rhf-number-input.tsx`

---

### 1.2 Logo Component ✅ HIGH PRIORITY
**Location**: `src/components/logo/`

**Duplicates in packages/ui**: `packages/ui/src/components/data-display/logo/`

**Files to Remove**:
- `logo.tsx`
- `classes.ts`

**Action**:
```typescript
// Replace with:
import { Logo } from '@asyml8/ui/components/data-display/logo';
```

**Important Difference**:
- mule-spa: Uses `RouterLink` from `react-router`
- mule-client: Uses `Link` from `next/link`
- packages/ui: Supports both via props

---

### 1.3 Custom Popover ✅ HIGH PRIORITY
**Location**: `src/components/custom-popover/`

**Duplicates in packages/ui**: `packages/ui/src/components` (location TBD)

**Files to Remove**:
- `custom-popover.tsx`
- `hooks.ts`
- `styles.tsx`
- `types.ts`
- `utils.ts`

**Action**:
```typescript
// Replace with:
import { CustomPopover, usePopover } from '@asyml8/ui/components';
```

---

### 1.4 Loading Screen Components ✅ MEDIUM PRIORITY
**Location**: `src/components/loading-screen/`

**Duplicates in packages/ui**: `packages/ui/src/components/feedback/loading-screen/`

**Files to Remove**:
- `loading-screen.tsx`
- `splash-screen.tsx`

**Action**:
```typescript
// Replace with:
import { LoadingScreen, SplashScreen } from '@asyml8/ui/components/feedback/loading-screen';
```

---

### 1.5 Progress Bar ✅ MEDIUM PRIORITY
**Location**: `src/components/progress-bar/`

**Duplicates in packages/ui**: `packages/ui/src/components/feedback/progress-bar/`

**Files to Remove**:
- `progress-bar.tsx`
- `styles.css`

**Action**:
```typescript
// Replace with:
import { ProgressBar } from '@asyml8/ui/components/feedback/progress-bar';
```

---

### 1.6 Search Not Found ✅ LOW PRIORITY
**Location**: `src/components/search-not-found/`

**Duplicates in packages/ui**: `packages/ui/src/components/feedback/search-not-found/`

**Files to Remove**:
- `search-not-found.tsx`

**Action**:
```typescript
// Replace with:
import { SearchNotFound } from '@asyml8/ui/components/feedback/search-not-found';
```

---

### 1.7 Nav Section Components ✅ HIGH PRIORITY
**Location**: `src/components/nav-section/`

**Duplicates in packages/ui**: `packages/ui/src/components/navigation/navigation-menu/`

**Files to Remove** (entire directory):
- `mini/` - nav-section-mini.tsx, nav-list.tsx, nav-item.tsx
- `horizontal/` - nav-section-horizontal.tsx, nav-list.tsx, nav-item.tsx
- `vertical/` - nav-section-vertical.tsx, nav-list.tsx, nav-item.tsx
- `components/` - nav-elements.tsx, nav-dropdown.tsx, nav-collapse.tsx, nav-subheader.tsx
- `styles/` - classes.ts, nav-item-styles.tsx, css-vars.ts
- `utils/` - create-nav-item.ts
- `types.ts`

**Action**:
```typescript
// Replace with:
import {
  NavSectionMini,
  NavSectionHorizontal,
  NavSectionVertical
} from '@asyml8/ui/components/navigation/navigation-menu';
```

---

## 2. Layout Components to Remove & Import

### 2.1 Core Layout Components ✅ HIGH PRIORITY
**Location**: `src/layouts/core/`

**Duplicates in packages/ui**: `packages/ui/src/layouts/core/`

**Files to Remove**:
- `header-section.tsx`
- `main-section.tsx`
- `layout-section.tsx`
- `css-vars.ts`
- `classes.ts`

**Action**:
```typescript
// Replace with:
import {
  HeaderSection,
  MainSection,
  LayoutSection
} from '@asyml8/ui/layouts/core';
```

---

### 2.2 Layout Components (Shared) ✅ MEDIUM PRIORITY
**Location**: `src/layouts/components/`

**Duplicates in packages/ui**: `packages/ui/src/layouts/templates/dashboard-layout/components/`

**Files to Remove**:
- `menu-button.tsx`
- `nav-toggle-button.tsx`
- `account-button.tsx`
- `account-drawer.tsx`
- `account-popover.tsx`
- `contacts-popover.tsx`
- `language-popover.tsx`
- `notifications-drawer/`
- `searchbar/`
- `settings-button.tsx`
- `sign-in-button.tsx`
- `sign-out-button.tsx`
- `workspaces-popover.tsx`
- `nav-upgrade.tsx`

**Action**:
```typescript
// Replace with imports from:
import {
  MenuButton,
  NavToggleButton,
  AccountButton,
  AccountDrawer,
  AccountPopover,
  // ... etc
} from '@asyml8/ui/layouts/templates/dashboard-layout/components';
```

---

### 2.3 Auth Split Layout ✅ MEDIUM PRIORITY
**Location**: `src/layouts/auth-split/`

**Duplicates in packages/ui**: Similar pattern exists in `packages/ui/src/layouts/templates/`

**Files to Review**:
- `layout.tsx`
- `content.tsx`
- `section.tsx`

**Action**: Check if packages/ui has equivalent auth layout template

---

### 2.4 Simple Layout ✅ LOW PRIORITY
**Location**: `src/layouts/simple/`

**Files to Review**:
- `layout.tsx`
- `content.tsx`

**Action**: Check if packages/ui has equivalent simple layout template

---

### 2.5 Dashboard Layout ✅ HIGH PRIORITY
**Location**: `src/layouts/dashboard/`

**Duplicates in packages/ui**: `packages/ui/src/layouts/templates/dashboard-layout/`

**Files to Remove**:
- `layout.tsx`
- `content.tsx`
- `nav-mobile.tsx`
- `nav-horizontal.tsx`
- `nav-vertical.tsx`
- `css-vars.ts`

**Action**:
```typescript
// Replace with:
import { DashboardLayout } from '@asyml8/ui/layouts/templates/dashboard-layout';
```

---

## 3. Utilities to Remove & Import

### 3.1 Format Time ✅ MEDIUM PRIORITY
**Location**: `src/utils/format-time.ts`

**Note**: packages/ui doesn't have format-time, but has format-number. Check if format-time should be moved to packages/ui or if it's app-specific.

**Action**: 
- If generic: Move to packages/ui
- If app-specific: Keep in mule-spa

---

## 4. Assets to Remove & Import

### 4.1 Illustrations ✅ LOW PRIORITY
**Location**: `src/assets/illustrations/`

**Duplicates in packages/ui**: `packages/ui/src/assets/` (location TBD)

**Files** (all identical):
- `avatar-shape.tsx`
- `background-shape.tsx`
- `booking-illustration.tsx`
- `check-in-illustration.tsx`
- `check-out-illustration.tsx`
- `coming-soon-illustration.tsx`
- `forbidden-illustration.tsx`
- `maintenance-illustration.tsx`
- `motivation-illustration.tsx`
- `order-complete-illustration.tsx`
- `page-not-found-illustration.tsx`
- `seo-illustration.tsx`
- `server-error-illustration.tsx`
- `upload-illustration.tsx`

**Action**: Import from packages/ui if available

---

### 4.2 Icons ✅ LOW PRIORITY
**Location**: `src/assets/icons/`

**Duplicates in packages/ui**: `packages/ui/src/assets/` (location TBD)

**Files**:
- `email-inbox-icon.tsx`
- `new-password-icon.tsx`
- `password-icon.tsx`
- `plan-free-icon.tsx`
- `plan-premium-icon.tsx`
- `plan-starter-icon.tsx`
- `sent-icon.tsx`

**Action**: Import from packages/ui if available

---

### 4.3 Data ✅ LOW PRIORITY
**Location**: `src/assets/data/`

**Duplicates in packages/ui**: `packages/ui/src/assets/data/`

**Files**:
- `countries.ts` (identical)

**Action**:
```typescript
// Replace with:
import { countries } from '@asyml8/ui/assets/data';
```

---

## 5. Auth Components to Remove & Import

### 5.1 Auth Context ✅ HIGH PRIORITY
**Location**: `src/auth/context/`

**Duplicates in packages/ui**: Check if auth context should be shared

**Files**:
- `jwt/` - auth-provider.tsx, action.ts, utils.ts, constant.ts
- `auth-context.tsx`

**Action**: Determine if auth should be app-specific or shared

---

### 5.2 Auth Components ✅ MEDIUM PRIORITY
**Location**: `src/auth/components/`

**Duplicates in packages/ui**: `packages/ui/src/views/auth/`

**Files to Remove**:
- `form-head.tsx`
- `form-divider.tsx`
- `form-resend-code.tsx`
- `form-return-link.tsx`
- `form-socials.tsx`
- `sign-up-terms.tsx`

**Action**:
```typescript
// Replace with:
import {
  FormHead,
  SignUpTerms
} from '@asyml8/ui/views/auth';
```

---

### 5.3 Auth Guards ✅ HIGH PRIORITY
**Location**: `src/auth/guard/`

**Files**:
- `auth-guard.tsx`
- `guest-guard.tsx`
- `role-based-guard.tsx`

**Action**: Check if these should be shared or app-specific (likely app-specific due to routing differences)

---

### 5.4 Auth Views ✅ MEDIUM PRIORITY
**Location**: `src/auth/view/jwt/`

**Duplicates in packages/ui**: `packages/ui/src/views/auth/`

**Files**:
- `jwt-sign-in-view.tsx`
- `jwt-sign-up-view.tsx`

**Action**: Check if packages/ui has equivalent views

---

## 6. Routes to Review

### 6.1 Route Hooks ✅ HIGH PRIORITY
**Location**: `src/routes/hooks/`

**Duplicates in packages/ui**: `packages/ui/src/components/navigation/routes/hooks/`

**Files**:
- `use-params.ts`
- `use-pathname.ts`
- `use-router.ts`
- `use-search-params.ts`

**Important**: These are router-specific
- mule-spa: Uses `react-router` v7
- mule-client: Uses Next.js App Router
- packages/ui: Provides abstractions for both

**Action**:
```typescript
// Replace with:
import {
  useParams,
  usePathname,
  useRouter,
  useSearchParams
} from '@asyml8/ui/components/navigation/routes/hooks';
```

---

### 6.2 Route Components ✅ MEDIUM PRIORITY
**Location**: `src/routes/components/`

**Files**:
- `router-link.tsx`
- `error-boundary.tsx`

**Action**: Check if packages/ui has router-agnostic versions

---

## 7. Mock Data to Remove & Import

### 7.1 Mock Files ✅ LOW PRIORITY
**Location**: `src/_mock/`

**Duplicates in packages/ui**: Not applicable (mock data is typically app-specific)

**Files** (identical to mule-client):
- `_user.ts`
- `_invoice.ts`
- `_overview.ts`
- `_calendar.ts`
- `_product.ts`
- `_job.ts`
- `_files.ts`
- `_tour.ts`
- `_others.ts`
- `_order.ts`
- `_blog.ts`
- `_mock.ts`
- `assets.ts`

**Action**: Consider moving to shared package or keeping app-specific

---

## 8. Implementation Plan

### Phase 1: High Priority (Week 1)
1. ✅ Hook Form Components
2. ✅ Logo Component
3. ✅ Custom Popover
4. ✅ Nav Section Components
5. ✅ Core Layout Components
6. ✅ Dashboard Layout
7. ✅ Route Hooks

### Phase 2: Medium Priority (Week 2)
1. ✅ Loading Screen & Progress Bar
2. ✅ Layout Components (Shared)
3. ✅ Auth Components
4. ✅ Auth Views
5. ✅ Route Components

### Phase 3: Low Priority (Week 3)
1. ✅ Search Not Found
2. ✅ Assets (Illustrations, Icons, Data)
3. ✅ Simple & Auth Split Layouts
4. ✅ Mock Data (if applicable)

---

## 9. Key Differences: Vite vs Next.js

### 9.1 Routing
**mule-spa (Vite)**:
```typescript
import { useNavigate, useLocation } from 'react-router';
```

**mule-client (Next.js)**:
```typescript
import { useRouter, usePathname } from 'next/navigation';
```

**packages/ui Solution**:
```typescript
// Provides abstraction layer
import { useRouter, usePathname } from '@asyml8/ui/components/navigation/routes/hooks';
```

---

### 9.2 Links
**mule-spa (Vite)**:
```typescript
import { Link } from 'react-router';
```

**mule-client (Next.js)**:
```typescript
import Link from 'next/link';
```

**packages/ui Solution**:
```typescript
// RouterLink component handles both
import { RouterLink } from '@asyml8/ui/components/navigation/routes/components';
```

---

### 9.3 Image Optimization
**mule-spa (Vite)**:
```typescript
<img src="/assets/image.png" alt="..." />
```

**mule-client (Next.js)**:
```typescript
import Image from 'next/image';
<Image src="/assets/image.png" alt="..." width={100} height={100} />
```

**Action**: Keep image handling app-specific

---

### 9.4 Metadata
**mule-spa (Vite)**:
```typescript
// Use react-helmet or similar
import { Helmet } from 'react-helmet-async';
```

**mule-client (Next.js)**:
```typescript
// Built-in metadata
export const metadata = { title: '...' };
```

**Action**: Keep metadata handling app-specific

---

## 10. Package.json Updates Required

### Current Dependencies to Review
```json
{
  "dependencies": {
    "@asyml8/ui": "workspace:*",  // ✅ Already present
    // ... other deps
  }
}
```

### Ensure packages/ui Exports
Check `packages/ui/src/index.ts` exports all needed components:
```typescript
// Should include:
export * from './components';
export * from './layouts';
export * from './theme';
export * from './hooks';
export * from './utils';
export * from './views';
```

---

## 11. Testing Strategy

### 11.1 Component Testing
For each migrated component:
1. ✅ Verify import works
2. ✅ Check TypeScript types
3. ✅ Test functionality
4. ✅ Verify styling
5. ✅ Check responsive behavior

### 11.2 Integration Testing
1. ✅ Test routing still works
2. ✅ Test auth flow
3. ✅ Test layouts render correctly
4. ✅ Test forms submit properly

### 11.3 Build Testing
```bash
# Test build after each phase
pnpm build

# Verify no errors
pnpm tsc --noEmit
```

---

## 12. Rollback Plan

If issues arise:
1. Keep original files in `_backup/` folder temporarily
2. Revert imports one component at a time
3. Document any incompatibilities
4. Fix in packages/ui if needed

---

## 13. Success Metrics

### Code Reduction
- **Target**: Remove ~50-60% of duplicate code
- **Estimated**: ~100+ files to remove
- **Bundle Size**: Should decrease by ~15-20%

### Maintainability
- **Single Source of Truth**: All shared components in packages/ui
- **Consistency**: Same components across mule-spa and mule-client
- **Updates**: Fix once, benefit everywhere

---

## 14. Next Steps

1. ✅ Review this analysis with team
2. ✅ Verify packages/ui exports all needed components
3. ✅ Create feature branch: `feat/deduplicate-mule-spa`
4. ✅ Start with Phase 1 (High Priority)
5. ✅ Test thoroughly after each component migration
6. ✅ Update documentation
7. ✅ Create PR for review

---

## 15. Questions to Resolve

1. ❓ Should auth context be shared or app-specific?
2. ❓ Should mock data be shared or app-specific?
3. ❓ Should format-time utility be moved to packages/ui?
4. ❓ Are there any mule-spa specific customizations we need to preserve?
5. ❓ Should we create a migration guide for future apps?

---

## 16. Reference: mule-client Usage

Check how mule-client imports from packages/ui:
```typescript
// Example from mule-client
import { Logo } from '@asyml8/ui/components/data-display/logo';
import { DashboardLayout } from '@asyml8/ui/layouts/templates/dashboard-layout';
import { useRouter } from '@asyml8/ui/components/navigation/routes/hooks';
```

Follow the same pattern for mule-spa.

---

**Last Updated**: 2025-11-20
**Status**: Ready for Implementation
**Priority**: High
