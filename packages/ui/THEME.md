# Theme System Documentation

Complete guide for integrating and using the Asyml8 UI theme system in your applications.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Basic Setup](#basic-setup)
- [Theme Configuration](#theme-configuration)
- [Advanced Usage](#advanced-usage)
- [API Reference](#api-reference)
- [Customization](#customization)
- [Migration Guide](#migration-guide)
- [Troubleshooting](#troubleshooting)

## Overview

The Asyml8 UI theme system is a comprehensive theming solution built on top of Material-UI v7. It provides:

- **47 MUI component overrides** with consistent styling
- **Dark/Light mode support** with CSS variables
- **Multiple color presets** (default, cyan, purple, blue, orange, red)
- **High contrast mode** for accessibility
- **RTL (Right-to-Left) support**
- **Dynamic theme updates** based on settings
- **TypeScript support** with full type safety

### Architecture

```
packages/ui/src/theme/
├── core/                      # Core theme system
│   ├── components/           # 47 MUI component overrides
│   ├── mixins/              # Reusable theme mixins
│   ├── palette.ts           # Color palette definitions
│   ├── shadows.ts           # Shadow definitions
│   ├── custom-shadows.ts    # Custom shadow system
│   └── typography.ts        # Typography system
├── with-settings/           # Dynamic theme updates
│   ├── color-presets.ts    # Color preset definitions
│   ├── update-core.ts      # Dynamic palette updates
│   └── update-components.ts # Dynamic component updates
├── theme-config.ts          # Theme configuration
├── theme-provider.tsx       # Theme provider component
├── create-theme.ts          # Theme factory
├── create-classes.ts        # CSS class name generator
└── types.ts                 # TypeScript type definitions
```

## Installation

The theme is part of the `@asyml8/ui` package. No additional installation is required if you already have the UI package.

### Dependencies

The theme requires these peer dependencies:

```json
{
  "@mui/material": "^7.3.1",
  "@emotion/react": "^11.14.0",
  "@emotion/styled": "^11.14.1",
  "react": "^19.1.1",
  "minimal-shared": "^1.0.0"
}
```

## Basic Setup

### 1. Simple Setup (No Settings)

For basic usage without dynamic settings:

```tsx
// app/layout.tsx
import { ThemeProvider } from '@asyml8/ui/theme';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <ThemeProvider>
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
```

### 2. Setup with Settings

For apps that need dynamic theme settings (color presets, dark mode, etc.):

```tsx
// app/layout.tsx
import { ThemeProvider } from '@asyml8/ui/theme';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const settingsState = {
    mode: 'light',
    primaryColor: 'default',
    contrast: 'default',
    direction: 'ltr',
    navColor: 'integrate',
    navLayout: 'vertical',
    compactLayout: true,
    fontSize: 16,
    fontFamily: 'Public Sans Variable',
  };

  return (
    <html lang="en">
      <body>
        <ThemeProvider settingsState={settingsState}>
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
```

### 3. Setup with App-Specific Settings Context

For apps with existing settings context:

```tsx
// src/theme/theme-provider.tsx
'use client';

import type { ThemeProviderProps as MuiThemeProviderProps } from '@mui/material/styles';
import type { ThemeOptions } from '@asyml8/ui';
import { ThemeProvider as UIThemeProvider } from '@asyml8/ui/theme';
import { useSettingsContext } from 'src/components/settings';

export type AppThemeProviderProps = Partial<MuiThemeProviderProps> & {
  themeOverrides?: ThemeOptions;
};

export function AppThemeProvider({ themeOverrides, children, ...other }: AppThemeProviderProps) {
  const settings = useSettingsContext();

  return (
    <UIThemeProvider
      settingsState={settings.state}
      themeOverrides={themeOverrides}
      {...other}
    >
      {children}
    </UIThemeProvider>
  );
}
```

## Theme Configuration

### Default Configuration

The theme comes with sensible defaults defined in `theme-config.ts`:

```typescript
{
  defaultMode: 'light',              // Initial color mode
  modeStorageKey: 'theme-mode',     // localStorage key for mode
  direction: 'ltr',                  // Text direction
  classesPrefix: 'asyml8',          // CSS class prefix
  fontFamily: {
    primary: 'Public Sans Variable',
    secondary: 'Barlow',
  },
  palette: {
    primary: { main: '#00A76F', ... },
    secondary: { main: '#8E33FF', ... },
    // ... full palette configuration
  }
}
```

### Customizing Configuration

You can override theme configuration by providing `themeOverrides`:

```tsx
import { ThemeProvider } from '@asyml8/ui/theme';

const customTheme = {
  palette: {
    primary: {
      main: '#FF5630',
      light: '#FFAC82',
      dark: '#B71D18',
    },
  },
  typography: {
    fontFamily: 'Inter Variable',
  },
};

function App() {
  return (
    <ThemeProvider themeOverrides={customTheme}>
      {/* your app */}
    </ThemeProvider>
  );
}
```

## Advanced Usage

### Using Theme Hooks

Access theme values in your components:

```tsx
import { useTheme } from '@mui/material/styles';

function MyComponent() {
  const theme = useTheme();

  return (
    <div style={{ color: theme.palette.primary.main }}>
      Primary color text
    </div>
  );
}
```

### Using Color Scheme Hook

Control dark/light mode:

```tsx
import { useColorScheme } from '@mui/material/styles';

function ThemeToggle() {
  const { mode, setMode } = useColorScheme();

  return (
    <button onClick={() => setMode(mode === 'light' ? 'dark' : 'light')}>
      Toggle {mode} mode
    </button>
  );
}
```

### Creating CSS Classes

Use the `createClasses` utility for consistent class naming:

```tsx
import { createClasses } from '@asyml8/ui/theme';

const myComponentClasses = {
  root: createClasses('my__component__root'),
  header: createClasses('my__component__header'),
  body: createClasses('my__component__body'),
};

// Generates: 'asyml8__my__component__root', 'asyml8__my__component__header', etc.
```

### Accessing Theme Utilities

The theme provides various utilities through mixins:

```tsx
import { styled } from '@mui/material/styles';

const StyledBox = styled('div')(({ theme }) => ({
  // Border gradient
  ...theme.mixins.borderGradient({ padding: '2px' }),

  // Background blur
  ...theme.mixins.bgBlur({
    color: theme.palette.background.paper,
    blur: 20,
  }),

  // Filled button styles
  ...theme.mixins.filledStyles(theme, 'primary'),

  // Soft background styles
  ...theme.mixins.softStyles(theme, 'info'),

  // Text gradient
  ...theme.mixins.textGradient(
    `linear-gradient(135deg, ${theme.palette.primary.main}, ${theme.palette.secondary.main})`
  ),
}));
```

### Using Color Presets

Switch between different color schemes:

```tsx
import { primaryColorPresets } from '@asyml8/ui/theme';

// Available presets: 'default', 'cyan', 'purple', 'blue', 'orange', 'red'
const cyanPreset = primaryColorPresets.cyan;
// { main: '#00B8D9', light: '#61F3F3', dark: '#006C9C', ... }
```

### Custom Shadows

Access the custom shadow system:

```tsx
import { useTheme } from '@mui/material/styles';

function MyCard() {
  const theme = useTheme();

  return (
    <div style={{ boxShadow: theme.customShadows.card }}>
      Card with custom shadow
    </div>
  );
}
```

Available custom shadows:
- `z1`, `z4`, `z8`, `z12`, `z16`, `z20`, `z24` - Elevation shadows
- `card` - Card shadow
- `dropdown` - Dropdown shadow
- `dialog` - Dialog shadow
- `primary`, `secondary`, `info`, `success`, `warning`, `error` - Colored shadows

## API Reference

### ThemeProvider Props

```typescript
interface ThemeProviderProps {
  children: React.ReactNode;
  settingsState?: SettingsState;     // Optional settings
  themeOverrides?: ThemeOptions;     // Custom theme overrides
  theme?: Theme;                     // Pre-created theme
  // ... other MUI ThemeProvider props
}
```

### SettingsState Type

```typescript
interface SettingsState {
  mode?: 'light' | 'dark';                    // Color mode
  primaryColor?: ThemeColorPreset;            // Color preset
  contrast?: 'default' | 'high';              // Contrast mode
  direction?: 'ltr' | 'rtl';                  // Text direction
  navColor?: 'integrate' | 'apparent';        // Nav color style
  navLayout?: 'vertical' | 'horizontal' | 'mini'; // Nav layout
  compactLayout?: boolean;                    // Compact layout
  fontSize?: number;                          // Base font size
  fontFamily?: string;                        // Font family
}
```

### Theme Configuration Type

```typescript
interface ThemeConfig {
  defaultMode: 'light' | 'dark';
  modeStorageKey: string;
  direction: 'ltr' | 'rtl';
  classesPrefix: string;
  cssVariables: {
    cssVarPrefix: string;
    colorSchemeSelector: string;
  };
  fontFamily: {
    primary: string;
    secondary: string;
  };
  palette: {
    primary: ColorRange;
    secondary: ColorRange;
    info: ColorRange;
    success: ColorRange;
    warning: ColorRange;
    error: ColorRange;
  };
}
```

### Available Exports

From `@asyml8/ui/theme`:

**Components:**
- `ThemeProvider` - Main theme provider component
- `Rtl` - RTL wrapper component

**Utilities:**
- `createTheme` - Theme factory function
- `createClasses` - Class name generator

**Configuration:**
- `themeConfig` - Default theme configuration
- `primaryColorPresets` - Available color presets

**Palette:**
- `primary`, `secondary`, `info`, `success`, `warning`, `error` - Palette objects
- `grey`, `common` - Additional palettes
- `colorKeys` - Available color keys

**Types:**
- `ThemeConfig`, `ThemeOptions`, `ThemeColorPreset`
- `SettingsState`, `ColorRange`, `PaletteColorKey`

## Customization

### Override Component Styles

Use `themeOverrides` to customize component styles:

```tsx
const customTheme = {
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          textTransform: 'none',
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 16,
        },
      },
    },
  },
};

<ThemeProvider themeOverrides={customTheme}>
  {/* your app */}
</ThemeProvider>
```

### Add Custom Colors

Extend the palette with custom colors:

```tsx
const customTheme = {
  palette: {
    tertiary: {
      main: '#FF5722',
      light: '#FF8A65',
      dark: '#E64A19',
      contrastText: '#FFFFFF',
    },
  },
};

// TypeScript: Extend theme types
declare module '@mui/material/styles' {
  interface Palette {
    tertiary: Palette['primary'];
  }
  interface PaletteOptions {
    tertiary?: PaletteOptions['primary'];
  }
}
```

### Custom CSS Variables

The theme uses CSS variables for dynamic styling. Access them in your styles:

```tsx
import { styled } from '@mui/material/styles';

const StyledDiv = styled('div')({
  color: 'var(--palette-primary-main)',
  backgroundColor: 'var(--palette-background-paper)',
  padding: 'var(--spacing)',
  borderRadius: 'var(--shape-borderRadius)',
});
```

### Custom Typography

Override typography settings:

```tsx
const customTheme = {
  typography: {
    fontFamily: 'Inter Variable, sans-serif',
    h1: {
      fontSize: '3rem',
      fontWeight: 700,
    },
    button: {
      textTransform: 'none',
      fontWeight: 600,
    },
  },
};
```

## Migration Guide

### From Local Theme to UI Package Theme

If you're migrating from a local theme implementation:

1. **Install/Update dependencies:**
   ```bash
   pnpm install @asyml8/ui@latest
   ```

2. **Update imports:**
   ```tsx
   // Before
   import { ThemeProvider } from 'src/theme';
   import { createClasses } from 'src/theme/create-classes';
   import { primary, secondary } from 'src/theme/core';

   // After
   import { ThemeProvider, createClasses, primary, secondary } from '@asyml8/ui/theme';
   ```

3. **Update theme provider:**
   ```tsx
   // Before
   import { ThemeProvider } from 'src/theme';

   // After
   import { ThemeProvider } from '@asyml8/ui/theme';
   import { useSettingsContext } from 'src/components/settings';

   function App() {
     const settings = useSettingsContext();
     return (
       <ThemeProvider settingsState={settings.state}>
         {children}
       </ThemeProvider>
     );
   }
   ```

4. **Remove old theme files:**
   - Delete `src/theme/core/`, `src/theme/with-settings/`, etc.
   - Keep only app-specific theme wrapper if needed

5. **Update TypeScript paths:**
   If you have path aliases, update `tsconfig.json`:
   ```json
   {
     "compilerOptions": {
       "paths": {
         "@theme/*": ["@asyml8/ui/theme"]
       }
     }
   }
   ```

### Breaking Changes

- **Class prefix:** Changed from `minimal` to `asyml8`
  - Update any CSS selectors that reference class names

- **Settings structure:** `SettingsState` is now optional
  - If you don't need dynamic settings, you can omit it entirely

## Troubleshooting

### Common Issues

#### Issue: "Module not found: Can't resolve '@asyml8/ui/theme'"

**Solution:** Ensure the UI package has the theme export in `package.json`:

```json
{
  "exports": {
    "./theme": {
      "types": "./dist/theme/index.d.ts",
      "default": "./dist/theme/index.js"
    }
  }
}
```

Then rebuild: `pnpm run build`

#### Issue: Theme not applying / CSS variables missing

**Solution:** Make sure `ThemeProvider` wraps your entire app:

```tsx
// ✅ Correct
<ThemeProvider>
  <App />
</ThemeProvider>

// ❌ Wrong - Provider inside components won't have global styles
<App>
  <ThemeProvider>
    <Content />
  </ThemeProvider>
</App>
```

#### Issue: TypeScript errors with theme types

**Solution:** Import types from the theme package:

```tsx
import type { Theme } from '@mui/material/styles';
import type { ThemeConfig, SettingsState } from '@asyml8/ui/theme';
```

#### Issue: Settings not updating theme

**Solution:** Ensure `settingsState` is reactive:

```tsx
// ✅ Correct - state updates trigger re-render
const [settings, setSettings] = useState(defaultSettings);
<ThemeProvider settingsState={settings}>

// ❌ Wrong - static object won't update
const settings = { mode: 'light' };
<ThemeProvider settingsState={settings}>
```

#### Issue: Custom components not styled correctly

**Solution:** Use `styled` or `sx` prop for custom styling:

```tsx
import { styled } from '@mui/material/styles';
import Box from '@mui/material/Box';

// Using styled
const StyledDiv = styled('div')(({ theme }) => ({
  color: theme.palette.primary.main,
}));

// Using sx prop
<Box sx={{ color: 'primary.main' }} />
```

### Performance Tips

1. **Memoize theme overrides:**
   ```tsx
   const themeOverrides = useMemo(() => ({
     palette: { primary: { main: customColor } }
   }), [customColor]);
   ```

2. **Use CSS variables for dynamic values:**
   ```tsx
   // ✅ Fast - uses CSS variables
   <div style={{ color: 'var(--palette-primary-main)' }} />

   // ❌ Slower - requires theme context
   const theme = useTheme();
   <div style={{ color: theme.palette.primary.main }} />
   ```

3. **Avoid creating themes in render:**
   ```tsx
   // ❌ Bad - creates new theme on every render
   function App() {
     const theme = createTheme({ ... });
     return <ThemeProvider theme={theme}>...</ThemeProvider>
   }

   // ✅ Good - use themeOverrides prop
   function App() {
     return <ThemeProvider themeOverrides={{ ... }}>...</ThemeProvider>
   }
   ```

## Examples

### Complete Next.js App Setup

```tsx
// app/layout.tsx
import type { Metadata } from 'next';
import { ThemeProvider } from '@asyml8/ui/theme';
import { SettingsProvider } from '@/components/settings';

export const metadata: Metadata = {
  title: 'My App',
  description: 'Built with Asyml8 UI',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <SettingsProvider>
          <ThemeProvider>
            {children}
          </ThemeProvider>
        </SettingsProvider>
      </body>
    </html>
  );
}
```

### Creating a Custom Themed Component

```tsx
import { styled } from '@mui/material/styles';
import { createClasses } from '@asyml8/ui/theme';

const classes = {
  root: createClasses('custom__card__root'),
  header: createClasses('custom__card__header'),
  content: createClasses('custom__card__content'),
};

const StyledCard = styled('div')(({ theme }) => ({
  [`&.${classes.root}`]: {
    borderRadius: theme.shape.borderRadius * 2,
    boxShadow: theme.customShadows.card,
    backgroundColor: theme.palette.background.paper,
    overflow: 'hidden',
  },
  [`& .${classes.header}`]: {
    padding: theme.spacing(3),
    background: `linear-gradient(135deg, ${theme.palette.primary.main}, ${theme.palette.primary.dark})`,
    color: theme.palette.primary.contrastText,
  },
  [`& .${classes.content}`]: {
    padding: theme.spacing(3),
  },
}));

export function CustomCard({ title, children }) {
  return (
    <StyledCard className={classes.root}>
      <div className={classes.header}>{title}</div>
      <div className={classes.content}>{children}</div>
    </StyledCard>
  );
}
```

## Support

For issues, questions, or contributions:
- GitHub: [pravia-monorepo](https://github.com/asyml8/pravia-monorepo)
- Documentation: See package README
- MUI Documentation: https://mui.com/material-ui/

## License

This theme system is part of the Asyml8 UI package and follows the same license.
