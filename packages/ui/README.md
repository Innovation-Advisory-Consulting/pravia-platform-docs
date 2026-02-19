# @asyml8/ui

Shared UI component library for Pravia applications.

## Documentation

- **[Import Guide](./IMPORT_GUIDE.md)** - How to import components, tree-shaking, and bundle optimization
- **[Theme System](./THEME.md)** - Complete theme system documentation
- **[Storybook](http://localhost:6006)** - Interactive component documentation (run `npm run storybook`)

## Quick Start

### Installation

```bash
# Already installed in monorepo
pnpm install
```

### Basic Usage

```tsx
import { 
  ThemeProvider,
  Button, 
  Card, 
  DataTable,
  DashboardLayout 
} from '@asyml8/ui';

function App() {
  return (
    <ThemeProvider>
      <DashboardLayout>
        <Card>
          <Button>Click me</Button>
        </Card>
      </DashboardLayout>
    </ThemeProvider>
  );
}
```

### Import Patterns

```tsx
// ✅ Recommended - Import from main entry (tree-shakeable)
import { Button, Card, DataTable } from '@asyml8/ui';

// ✅ Also supported - Subpath imports
import { Button } from '@asyml8/ui/components';
import { ThemeProvider } from '@asyml8/ui/theme';
import { DashboardLayout } from '@asyml8/ui/layouts';

// ✅ CSS imports
import '@asyml8/ui/scrollbar.css';
import '@asyml8/ui/progress-bar.css';
```

See [IMPORT_GUIDE.md](./IMPORT_GUIDE.md) for detailed import documentation.

## Package Structure

```
src/
├── components/     # 40+ UI components organized by category
│   ├── data-display/
│   ├── feedback/
│   ├── inputs/
│   ├── layout/
│   ├── navigation/
│   ├── surfaces/
│   └── utils/
├── layouts/        # Layout templates (Dashboard, Form, Marketing)
├── views/          # Pre-built views (Auth forms, etc.)
├── theme/          # MUI v7 theme system with 47 component overrides
├── lib/            # Base classes (BaseService, BaseStore, HttpClient)
├── utils/          # Utility functions (formatNumber, notifications, etc.)
└── hooks/          # Custom React hooks
```

## Available Exports

### Components (40+)
- **Data Display**: DataTable, Label, Logo, Iconify, CustomCard, StatCard, CustomBreadcrumbs, FileThumbnail, FlagIcon
- **Feedback**: CustomSnackbar, ProgressBar, ConfirmationDialog, LoadingScreen, EnhancedFormDialog, SearchNotFound, CustomDialog
- **Inputs**: FormBuilder, HookForm components, PhoneInput, NumberInput, Upload
- **Layout**: DashboardContent, MenuButton, NavToggleButton
- **Navigation**: NavigationMenu, HorizontalStepper, Fab, Routes, Scrollbar
- **Surfaces**: AnimatedBackground, PageHeader, Drawers
- **Utils**: FiltersResult, PerformanceMonitor, SvgColor, Animations

### Layouts
- **DashboardLayout** - Full dashboard with sidebar and header
- **FormLayout** - Centered form layout
- **AnimatedFormLayout** - Form with animations
- **MarketingLayout** - Marketing/landing page layout
- **AnimatedLayout** - Generic animated layout

### Views
- **Auth Forms**: SignInForm, SignUpForm, ResetPasswordForm, UpdatePasswordForm, VerifyEmailForm, CheckEmailForm

### Theme
- **ThemeProvider** - Main theme provider
- **SettingsProvider** - Theme settings management
- **themeConfig** - Theme configuration
- **defaultSettings** - Default theme settings
- 47 MUI component overrides
- Dark/Light mode support
- Multiple color presets
- High contrast mode
- RTL support

### Utils
- **formatNumber** - Number formatting utilities
- **mergeClasses** - Class name merging
- **notifications** - Toast notification helpers
- **formStore** - Form state management
- **queryStore** - Query state management
- **mutationStore** - Mutation state management

### Hooks
- **useBoolean** - Boolean state management
- **usePopoverHover** - Popover hover interactions

### Lib
- **BaseService** - Base class for API services
- **BaseStore** - Base class for Zustand stores
- **HttpClient** - Axios HTTP client wrapper
- **ApiManager** - API request manager
- **fetcher** - Data fetching utilities

## Development

### Running Storybook

To view and develop components in isolation:

```bash
# From the ui package directory
npm run storybook
```

This will start Storybook on `http://localhost:6006`

### Building Storybook

To build a static version of Storybook:

```bash
npm run build-storybook
```

### Code Generation

Generate new components, services, or stores:

```bash
npm run codegen
```

See [codegen/README.md](./codegen/README.md) for details.

## Scripts

- `npm run build` - Build the package (auto-increments version)
- `npm run dev` - Watch mode for development
- `npm run storybook` - Start Storybook development server
- `npm run build-storybook` - Build static Storybook
- `npm run lint` - Lint the code
- `npm run type-check` - Type check without emitting files
- `npm run test` - Run tests in watch mode
- `npm run test:run` - Run tests once
- `npm run test:coverage` - Run tests with coverage
- `npm run codegen` - Generate components/services/stores

## Version

Current version: **1.0.643**

Version is auto-incremented on each build via `npm run prebuild`.

## Requirements

- **MUI v7+** - DO NOT DOWNGRADE (see apps/pravia-web/CRITICAL-VERSION-NOTES.md)
- React 19+
- TypeScript 5.4+

## Peer Dependencies

Required in consuming applications:
- `@hookform/resolvers` ^5.2.2
- `@tanstack/react-query` ^5.0.0
- `es-toolkit` ^1.0.0
- `minimal-shared` ^1.0.0
- `react-hook-form` ^7.62.0
- `zod` ^4.1.11

Optional:
- `next` ^15.5.4 (for Next.js apps)
- `react-router-dom` ^6.0.0 (for React Router apps)
