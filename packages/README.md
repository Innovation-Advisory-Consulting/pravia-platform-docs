# Shared Packages

This directory contains shared packages used across all APIs and frontend applications in the Pravia CRM Platform. These packages promote code reuse, consistency, and maintainability across the monorepo.

## Directory Structure

```
packages/
├── api-core/       # Shared NestJS backend functionality
├── api-types/      # Shared TypeScript types and API contracts
└── ui/             # Shared React UI component library
```

## Package Overview

### 1. `api-core` - Backend Core Library

**Purpose:** Shared NestJS functionality for all backend APIs (Foundry, Flux, Incidents)

**Key Features:**
- **Health Monitoring** - Standardized health check endpoints with database connectivity
- **Response Standardization** - Consistent API response format across all services
- **Database Validators** - Custom validation decorators (`IsExist`, `IsNotExist`)
- **Base Entity** - Common database entity fields (id, timestamps, audit fields)
- **Swagger UI** - Enhanced Swagger documentation with custom theming
- **CORS Management** - Automatic CORS header handling

**Technology Stack:**
- NestJS
- TypeORM
- Fastify
- Swagger/OpenAPI

**Usage Example:**
```typescript
import { 
  HealthModule, 
  ResponseTransformInterceptor,
  ValidatorsModule,
  BaseEntity,
  ResponseMessage,
  ApiOkBaseResponse 
} from '@asyml8/api-core';

@Module({
  imports: [HealthModule, ValidatorsModule],
  providers: [{
    provide: APP_INTERCEPTOR,
    useClass: ResponseTransformInterceptor
  }]
})
export class AppModule {}
```

**Response Format:**
```json
{
  "statusCode": 200,
  "body": [...],
  "message": "Operation successful"
}
```

**Consumers:**
- api/foundry
- api/flux
- api/incidents

**Documentation:** `packages/api-core/README.md`

---

### 2. `api-types` - Shared Types & API Contracts

**Purpose:** Centralized TypeScript types, interfaces, and API service generation for frontend-backend communication

**Key Features:**
- **Auto-generated API Services** - Generated from Swagger/OpenAPI specs
- **Auto-generated Zustand Slices** - State management slices for each API
- **Shared TypeScript Types** - Common interfaces and types
- **Service Factory Pattern** - Centralized API service creation
- **Type Safety** - End-to-end type safety between frontend and backend

**Code Generation Scripts:**
- `generate-api-services.js` - Generate API services from Swagger
- `generate-api-slices.js` - Generate Zustand state slices
- `generate-api-contracts.js` - Extract API contracts
- `extract-common-types.js` - Extract shared types
- `generate-root-index.js` - Generate barrel exports

**Generated Structure:**
```
src/
├── api/
│   ├── foundry/          # Foundry API services & types
│   ├── flux/             # Flux API services & types
│   └── incidents/        # Incidents API services & types
├── core/                 # Core types and interfaces
└── index.ts              # Barrel exports
```

**Usage Example:**
```typescript
import { 
  FoundryApiService,
  FluxApiService,
  UserDto,
  AccountDto 
} from '@asyml8/api-types';

// Use generated services
const authService = FoundryApiService.create(httpClient);
const users = await authService.getUsers();
```

**Workflow:**
1. Backend API exposes Swagger/OpenAPI spec
2. Run generation scripts
3. Frontend imports generated services and types
4. Full type safety across stack

**Consumers:**
- apps/mule-vite
- apps/mule-incidents
- All frontend applications

**Documentation:**
- `packages/api-types/CODEGEN.md` - Code generation guide
- `packages/api-types/SERVICE_FACTORY.md` - Service factory pattern
- `packages/api-types/MIGRATION.md` - Migration guide

---

### 3. `ui` - React Component Library

**Purpose:** Shared React UI components, layouts, and utilities for all frontend applications

**Key Features:**
- **40+ UI Components** - Organized by category (data-display, feedback, inputs, layout, navigation, surfaces)
- **Layout Templates** - Dashboard, Form, Marketing layouts
- **Pre-built Views** - Auth forms (SignIn, SignUp, Reset Password, etc.)
- **MUI v7 Theme System** - 47 component overrides, dark/light mode, color presets
- **Storybook Integration** - Interactive component documentation
- **Code Generation** - CLI tool for generating new components
- **Tree-shakeable** - Optimized bundle size

**Component Categories:**

| Category | Components |
|----------|------------|
| **Data Display** | DataTable, Label, Logo, Iconify, CustomCard, StatCard, CustomBreadcrumbs, FileThumbnail, FlagIcon |
| **Feedback** | CustomSnackbar, ProgressBar, ConfirmationDialog, LoadingScreen, EnhancedFormDialog, SearchNotFound |
| **Inputs** | FormBuilder, HookForm components, PhoneInput, NumberInput, Upload |
| **Layout** | DashboardContent, MenuButton, NavToggleButton |
| **Navigation** | NavigationMenu, HorizontalStepper, Fab, Routes, Scrollbar |
| **Surfaces** | AnimatedBackground, PageHeader, Drawers |
| **Utils** | FiltersResult, PerformanceMonitor, SvgColor, Animations |

**Layouts:**
- DashboardLayout - Full dashboard with sidebar and header
- FormLayout - Centered form layout
- AnimatedFormLayout - Form with animations
- MarketingLayout - Marketing/landing page layout

**Theme System:**
- Dark/Light mode support
- Multiple color presets
- High contrast mode
- RTL support
- 47 MUI component overrides

**Usage Example:**
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
          <DataTable data={data} columns={columns} />
        </Card>
      </DashboardLayout>
    </ThemeProvider>
  );
}
```

**Development Tools:**
- **Storybook** - `npm run storybook` (http://localhost:6006)
- **Code Generator** - `npm run codegen` (generate components/services/stores)
- **Testing** - Vitest with coverage

**Consumers:**
- apps/mule-vite
- apps/mule-incidents
- All frontend applications

**Documentation:**
- `packages/ui/README.md` - Main documentation
- `packages/ui/THEME.md` - Theme system guide
- `packages/ui/IMPORT_GUIDE.md` - Import patterns and tree-shaking
- `packages/ui/docs/` - Implementation guides

**Version:** 1.0.643 (auto-incremented on build)

---

## Package Dependencies

### Dependency Graph

```
apps/mule-vite
    ↓
packages/ui → packages/api-types
    ↓              ↓
packages/api-core (backend only)
    ↓
api/foundry, api/flux, api/incidents
```

### Build Order

When building the monorepo, packages must be built in this order:

1. **api-core** - Backend shared functionality
2. **api-types** - Types and API services (depends on api-core types)
3. **ui** - UI components (depends on api-types)
4. **apps/** - Frontend applications (depend on ui and api-types)
5. **api/** - Backend APIs (depend on api-core)

**Build Command:**
```bash
# From root
pnpm build

# Individual package
cd packages/api-core && pnpm build
```

---

## Development Workflow

### Adding a New Shared Component

**For Backend (api-core):**
1. Create component in appropriate directory
2. Export from `src/index.ts`
3. Rebuild: `pnpm build`
4. Test in consuming API

**For Types (api-types):**
1. Update backend Swagger spec
2. Run generation scripts: `pnpm generate`
3. Verify generated files
4. Test in frontend

**For UI (ui):**
1. Generate component: `npm run codegen`
2. Implement component
3. Add Storybook story
4. Rebuild: `npm run build`
5. Test in consuming app

### Testing Changes Locally

```bash
# Build package
cd packages/ui
pnpm build

# Test in app
cd ../../apps/mule-vite
pnpm dev
```

### Versioning

- **api-core**: Manual versioning
- **api-types**: Manual versioning
- **ui**: Auto-incremented on build (prebuild script)

---

## Best Practices

### When to Create Shared Code

**✅ Create shared code when:**
- Used by 2+ applications/APIs
- Core functionality (auth, validation, responses)
- UI components used across apps
- Common types and interfaces

**❌ Don't create shared code when:**
- Feature-specific to one app
- Experimental or unstable
- Tightly coupled to specific implementation

### Package Guidelines

**api-core:**
- Keep backend-only (no frontend dependencies)
- Maintain backward compatibility
- Document breaking changes
- Test with all consuming APIs

**api-types:**
- Auto-generate from Swagger (don't hand-write)
- Keep types pure (no logic)
- Version with backend APIs
- Regenerate after API changes

**ui:**
- Keep components generic and reusable
- Document with Storybook
- Support theming
- Maintain accessibility
- Tree-shakeable exports

---

## Troubleshooting

### Build Errors

**Issue:** `Cannot find module '@asyml8/api-core'`

**Solution:**
```bash
cd packages/api-core
pnpm build
```

### Type Errors

**Issue:** Types out of sync with backend

**Solution:**
```bash
cd packages/api-types
pnpm generate
```

### UI Component Not Found

**Issue:** Component not exported

**Solution:** Check `packages/ui/src/index.ts` for proper export

---

## Related Documentation

- [Monorepo Best Practices](../docs/development/standards.md)
- [API Development Guide](../docs/development/API_BEST_PRACTICES.md)
- [UI Component Guide](../docs/development/ui-components.md)
- [Code Generation](../docs/tools/COMPONENT-EXTRACTION-SUMMARY.md)

---

## Package Maintenance

### Regular Tasks

- **Weekly:** Review and update dependencies
- **After API Changes:** Regenerate api-types
- **Before Release:** Test all consuming applications
- **Monthly:** Review and remove unused exports

### Health Checks

```bash
# Check for circular dependencies
pnpm list --depth=0

# Verify builds
pnpm -r build

# Run tests
pnpm -r test
```
