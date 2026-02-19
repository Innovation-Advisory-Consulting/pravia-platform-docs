# UI Component Styling Debugging Guide

## Problem Pattern
When a UI component looks different in Storybook vs the actual application (spacing, padding, colors, etc.)

## Root Cause Analysis Process

### 1. Identify Environmental Differences
- **Key Question**: Does the component look correct in one environment but not another?
- **If YES**: The issue is environmental, not component logic

### 2. Compare Theme Configurations

#### Check Storybook Theme
```bash
# Look for Storybook preview configuration
find . -name ".storybook" -type d
# Check preview.tsx for theme setup
```

#### Check Application Theme  
```bash
# Find theme files in the app
find ./apps/[app-name] -name "*theme*" -type f
# Look for component overrides
```

### 3. Component-Specific Investigation

#### For MUI Components
1. **Check component overrides** in theme files:
   ```typescript
   // Look for patterns like:
   const MuiTab: Components<Theme>['MuiTab'] = {
     styleOverrides: {
       root: {
         paddingLeft: 0,  // ← Potential culprit
         paddingRight: 0, // ← Potential culprit
       }
     }
   }
   ```

2. **Compare with MUI defaults**:
   - Storybook often uses vanilla MUI defaults
   - Apps often have custom overrides that remove default spacing

#### Common Culprits
- **Padding/Margin**: `padding: 0` overrides removing MUI's default spacing
- **MinWidth**: Custom `minWidth` values affecting layout
- **Typography**: Font size/weight differences
- **Color schemes**: Different palette configurations

### 4. Debugging Commands

```bash
# Search for specific component styling
grep -r "MuiTab\|MuiButton" ./apps/[app-name]/src/theme

# Find theme component files
find ./apps/[app-name] -path "*/theme/core/components/*" -name "*.tsx"

# Compare Storybook vs app theme usage
grep -r "ThemeProvider" ./packages/ui/.storybook/
grep -r "ThemeProvider" ./apps/[app-name]/src/
```

### 5. Solution Patterns

#### Restore Default Spacing
```typescript
// Instead of:
paddingLeft: 0,
paddingRight: 0,

// Use:
paddingLeft: theme.spacing(1),
paddingRight: theme.spacing(1),
```

#### Conditional Styling
```typescript
// Apply different styles based on context
styleOverrides: {
  root: ({ theme }) => ({
    // Base styles
    minWidth: 48,
    // Conditional padding
    ...(someCondition && {
      paddingLeft: theme.spacing(1),
      paddingRight: theme.spacing(1),
    })
  })
}
```

## Case Study: Tab Spacing Issue

**Problem**: Filter tabs too close together in app, but fine in Storybook

**Investigation**:
1. ✅ Component works in Storybook → Environmental issue
2. ✅ Storybook uses basic MUI theme → Has default padding
3. ✅ App uses custom theme → Found `paddingLeft: 0, paddingRight: 0`
4. ✅ Solution: Changed to `theme.spacing(1)` for both sides

**Files Modified**:
- `apps/pravia-web/src/theme/core/components/tabs.tsx`

## Prevention Tips

1. **Document theme overrides** that deviate significantly from MUI defaults
2. **Test components in both environments** during development
3. **Use theme spacing units** instead of hardcoded values
4. **Consider creating theme variants** instead of removing all default spacing

## Quick Checklist

- [ ] Does it work in Storybook but not the app?
- [ ] Check Storybook theme configuration
- [ ] Check app theme component overrides
- [ ] Look for `padding: 0`, `margin: 0`, or similar resets
- [ ] Compare with MUI default component styles
- [ ] Test fix in both environments
