# Mule Vite - Frontend Application

## Overview
Mule Vite is the main frontend application for the Pravia CRM Platform. Built with React, Vite, TypeScript, and Material-UI, it provides a modern, responsive user interface for managing business operations.

## Purpose
- User interface for Pravia CRM
- Authentication and authorization
- Business data management (accounts, contacts, submissions)
- Registration process workflows
- Dashboard and analytics
- Resource management
- Marketing tools

## Technology Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| React | 18+ | UI library |
| Vite | Latest | Build tool and dev server |
| TypeScript | 5+ | Type safety |
| Material-UI (MUI) | 5+ | UI component library |
| Zustand | Latest | State management |
| TanStack Query | Latest | Server state management |
| React Router | 6+ | Routing |
| React Hook Form | Latest | Form management |
| Zod | Latest | Validation |
| i18next | Latest | Internationalization |
| Axios | Latest | HTTP client |
| Supabase | Latest | Authentication |

## Architecture

### Frontend Architecture
```
User Interface (React + MUI)
    ↓
State Management (Zustand + TanStack Query)
    ↓
API Layer (Axios + Generated Services)
    ↓
Backend APIs (Foundry + Flux)
```

### Authentication Flow
```
1. User logs in → Supabase Auth
2. Get Supabase token
3. Validate with Foundry API
4. Receive internal JWT
5. Use JWT for all API calls
```

### State Management
- **Zustand** - Client state (UI, forms, app state)
- **TanStack Query** - Server state (API data, caching)
- **Generated Slices** - Auto-generated from Swagger

## Directory Structure

```
apps/mule-vite/
├── _archive/                # Archived code
│   ├── deploy/             # Old deployment scripts
│   ├── scripts/            # Old utility scripts
│   └── _mock/              # Mock data
├── docs/                    # Documentation
│   ├── FLUX_TYPES_MIGRATION.md
│   ├── HOW_TO_COMMUNICATE_WITH_AI.md
│   ├── INITIALIZATION.md
│   ├── INITIALIZATION-FLOW.md
│   ├── INITIALIZATION-VALIDATION.md
│   ├── migrate-to-generated-api-types.md
│   ├── STATE_MANAGEMENT.md
│   └── STORE_USAGE.md
├── public/                  # Static assets
│   ├── assets/             # Images and assets
│   ├── logo/               # Logo files
│   ├── favicon.ico
│   └── staticwebapp.config.json
├── scripts/                 # Utility scripts
│   ├── create-users.js
│   └── update-build-info.js
├── src/                     # Source code
│   ├── api/                # API integration
│   ├── components/         # Reusable components
│   ├── constants/          # Application constants
│   ├── contexts/           # React contexts
│   ├── guards/             # Route guards
│   ├── hooks/              # Custom hooks
│   ├── layouts/            # Layout components
│   ├── lib/                # Third-party integrations
│   ├── locales/            # Internationalization
│   ├── pages/              # Page components
│   ├── routes/             # Routing configuration
│   ├── sections/           # Feature sections
│   ├── services/           # Business logic services
│   ├── store/              # State management
│   ├── types/              # TypeScript types
│   ├── utils/              # Utility functions
│   ├── app.tsx             # Root component
│   ├── main.tsx            # Application entry
│   ├── global.css          # Global styles
│   ├── global-config.ts    # Global configuration
│   ├── config-version.ts   # Version configuration
│   └── vite-env.d.ts       # Vite type definitions
├── .env                     # Environment variables (default)
├── .env.dev                 # Development environment
├── .env.qa                  # QA environment
├── .env.localhost           # Local environment
├── eslint.config.mjs        # ESLint configuration
├── index.html               # HTML entry point
├── package.json             # Dependencies and scripts
├── prettier.config.mjs      # Prettier configuration
├── tsconfig.json            # TypeScript configuration
├── tsconfig.node.json       # TypeScript Node configuration
├── vite.config.ts           # Vite configuration
├── vitest.config.ts         # Vitest configuration
└── README.md                # Project documentation
```

## Key Features

### 1. Authentication & Authorization
- Supabase authentication integration
- JWT token management
- Role-based access control
- Protected routes
- Session management
- Inactivity timeout

### 2. State Management
- Zustand for client state
- TanStack Query for server state
- Auto-generated API slices
- Optimistic updates
- Cache management

### 3. Internationalization (i18n)
- Multi-language support
- English and Spanish
- Dynamic language switching
- Translation management

### 4. Form Management
- React Hook Form integration
- Zod validation
- Form state management
- Error handling
- Field validation

### 5. Data Tables
- Sortable columns
- Filtering
- Pagination
- Search
- Export functionality

### 6. Responsive Design
- Mobile-first approach
- Responsive layouts
- Adaptive components
- Touch-friendly UI

### 7. Theme System
- Material-UI theming
- Light/dark mode
- Custom color palettes
- Typography system

## Environment Configuration

### Environment Files

| File | Purpose | API Endpoints |
|------|---------|---------------|
| `.env` | Default | Production endpoints |
| `.env.dev` | Development | Dev API endpoints |
| `.env.qa` | QA | QA API endpoints |
| `.env.localhost` | Local | Local API endpoints |

### Key Environment Variables

```bash
# Application
VITE_APP_ENV=development
VITE_APP_NAME=Pravia Mule
VITE_ENABLE_TOOLS=true
VITE_LOG_LEVEL=debug

# Supabase
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=xxxxx

# API Endpoints
VITE_AUTH_API_URL=http://localhost:4000/api
VITE_DATA_API_URL=http://localhost:4001/api

# Features
VITE_INVITE_REDIRECT_URL=http://localhost:5173/auth/invite
```

## Development

### Installation
```bash
# Install dependencies
pnpm install

# Copy environment file
cp .env.localhost .env

# Configure environment variables
```

### Running the Application
```bash
# Development mode
pnpm dev

# Build for production
pnpm build

# Preview production build
pnpm preview

# Type check
pnpm type-check
```

### Code Quality
```bash
# Lint code
pnpm lint

# Fix linting issues
pnpm lint:fix

# Format code
pnpm fm:fix
```

### Testing
```bash
# Run tests
pnpm test

# Run tests in watch mode
pnpm test:watch

# Test coverage
pnpm test:coverage
```

## API Integration

### Generated Services
Services are auto-generated from backend Swagger/OpenAPI specs:

**Location:** `packages/api-types/src/api/`

**Usage:**
```typescript
import { fluxServices } from 'src/api/flux.api';
import { foundryServices } from 'src/api/foundry.api';

// Use generated services
const accounts = await fluxServices.accounts.getAccounts();
const profile = await foundryServices.userProfile.getProfile(userId);
```

### API Configuration
```typescript
// src/api/flux.api.ts
import { createFluxServices } from '@asyml8/api-types';
import { axiosInstance } from 'src/lib/axios';

export const fluxServices = createFluxServices(
  axiosInstance,
  import.meta.env.VITE_DATA_API_URL
);
```

## State Management

### Zustand Stores
**Location:** `src/store/`

**App Store:**
```typescript
import { useAppStore } from 'src/store/app.store';

const { user, setUser, isInitialized } = useAppStore();
```

**Form Stores:**
```typescript
import { useContactFormStore } from 'src/store/forms/contact-form.store';

const { formData, setFormData, resetForm } = useContactFormStore();
```

### TanStack Query
Used for server state management with caching:

```typescript
import { useQuery } from '@tanstack/react-query';
import { fluxServices } from 'src/api/flux.api';

const { data, isLoading, error } = useQuery({
  queryKey: ['accounts'],
  queryFn: () => fluxServices.accounts.getAccounts(),
});
```

## Routing

### Route Structure
```typescript
// src/routes/paths.ts
export const paths = {
  auth: {
    login: '/auth/login',
    register: '/auth/register',
  },
  dashboard: {
    root: '/dashboard',
    accounts: '/dashboard/accounts',
    contacts: '/dashboard/contacts',
  },
  register: {
    root: '/register',
    step1: '/register/step-1',
    step2: '/register/step-2',
  },
};
```

### Protected Routes
```typescript
import { AuthGuard } from 'src/guards/auth.guard';

<Route element={<AuthGuard />}>
  <Route path="/dashboard" element={<Dashboard />} />
</Route>
```

## Components

### Reusable Components
**Location:** `src/components/`

- `app-logo.tsx` - Application logo
- `icon-with-background.tsx` - Icon with background
- `inactivity-dialog.tsx` - Inactivity warning
- `inactivity-monitor.tsx` - Inactivity detection
- `notifications-drawer.tsx` - Notifications panel
- `submission-processing-card.tsx` - Submission status card
- `submission-processing-widget.tsx` - Submission widget
- `data-table/` - Data table components

### UI Package
Shared UI components from `@asyml8/ui` package:
- DataTable
- PageHeader
- DashboardContent
- Form components
- And more...

## Layouts

### Available Layouts
**Location:** `src/layouts/`

- `animated-layout.tsx` - Animated page transitions
- `auth-layout.tsx` - Authentication pages layout
- `default-dashboard-layout.tsx` - Main dashboard layout
- `components/` - Layout components
- `nav-config/` - Navigation configuration

## Pages & Sections

### Page Structure
Pages are organized by feature:

- `auth/` - Authentication pages (login, register)
- `dashboard/` - Dashboard pages
- `error/` - Error pages (404, 500)
- `marketing/` - Marketing pages
- `my-workspace/` - User workspace
- `register/` - Registration flow
- `resources/` - Resource management
- `startup/` - Application startup

### Sections
Feature-specific components:

- `admin/` - Admin functionality
- `blank/` - Blank templates
- `dashboard/` - Dashboard sections
- `marketing/` - Marketing sections
- `my-workspace/` - Workspace sections
- `register/` - Registration sections
- `resources/` - Resource sections

## Deployment

### Azure Static Web Apps
Deployed via GitHub Actions workflow.

**Configuration:** `public/staticwebapp.config.json`

**Deployment Process:**
1. Push to main branch
2. GitHub Action triggers
3. Build packages (api-types → ui → mule-vite)
4. Deploy to Azure Static Web Apps

**See:** `.github/workflows/deploy-mule-vite.yml`

## Documentation

### Available Documentation
- `docs/FLUX_TYPES_MIGRATION.md` - Flux types migration guide
- `docs/HOW_TO_COMMUNICATE_WITH_AI.md` - AI communication guide
- `docs/INITIALIZATION.md` - App initialization
- `docs/INITIALIZATION-FLOW.md` - Initialization flow
- `docs/INITIALIZATION-VALIDATION.md` - Validation guide
- `docs/migrate-to-generated-api-types.md` - API types migration
- `docs/STATE_MANAGEMENT.md` - State management guide
- `docs/STORE_USAGE.md` - Store usage guide

## Best Practices

### Code Organization
1. Use feature-based folder structure
2. Keep components small and focused
3. Extract reusable logic to hooks
4. Use TypeScript for type safety
5. Follow naming conventions

### State Management
1. Use Zustand for client state
2. Use TanStack Query for server state
3. Avoid prop drilling
4. Keep state close to where it's used
5. Use selectors for performance

### Performance
1. Lazy load routes and components
2. Optimize re-renders
3. Use React.memo strategically
4. Implement virtualization for large lists
5. Optimize images and assets

### Security
1. Validate all user inputs
2. Sanitize data before rendering
3. Use environment variables for secrets
4. Implement CSRF protection
5. Follow OWASP guidelines

## Troubleshooting

### Common Issues

**Build Errors**
```bash
# Clean and rebuild
rm -rf node_modules dist
pnpm install
pnpm build
```

**Type Errors**
```bash
# Regenerate types
cd ../../packages/api-types
pnpm build
```

**API Connection Issues**
```bash
# Check environment variables
cat .env

# Verify API endpoints are running
curl $VITE_AUTH_API_URL/health
curl $VITE_DATA_API_URL/health
```

**Authentication Issues**
```bash
# Check Supabase configuration
echo $VITE_SUPABASE_URL
echo $VITE_SUPABASE_ANON_KEY

# Clear browser storage
# Open DevTools → Application → Clear storage
```

## Related Documentation
- Parent: `DOCUMENTACION-COMPLETA.md`
- APIs: `api/API-OVERVIEW.md`
- UI Package: `packages/ui/UI-PACKAGE.md`
- API Types: `packages/api-types/API-TYPES.md`
