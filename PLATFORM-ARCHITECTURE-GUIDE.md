# 📚 Complete Documentation - Pravia Mule Platform

> **Created:** February 19, 2026  
> **Version:** 1.0.0  
> **Status:** ✅ Completed

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Project Structure](#project-structure)
3. [APIs - Backend Microservices](#apis---backend-microservices)
4. [Kiro CLI Configuration](#kiro-cli-configuration)
5. [Husky - Git Hooks Manager](#husky---git-hooks-manager)
6. [GitHub Configuration](#github-configuration)
7. [Frontend Applications](#frontend-applications)
8. [Deployment](#deployment)
9. [Shared Packages](#shared-packages)
10. [Infrastructure](#infrastructure)
11. [Tools and Scripts](#tools-and-scripts)
12. [Development Tools](#development-tools)
13. [Documentation](#documentation)
14. [External Services](#external-services)
15. [Change Log](#change-log)
16. [Documentation Files Index](#documentation-files-index)

---

## 🎯 Project Overview

Pravia Mule Platform is a modern CRM platform built with microservices architecture using pnpm workspaces, featuring self-hosted Supabase and AWS deployment.

### Core Technologies
- **Monorepo:** pnpm workspaces
- **Backend:** NestJS
- **Frontend:** React + Vite
- **Database:** PostgreSQL (Supabase)
- **Infrastructure:** AWS CDK, Azure
- **Testing:** Jest, Playwright (roadmap)

---

## 📁 Project Structure

Total folders: **207**

```
pravia-mule-platform/
├── api/                    # Backend microservices
├── apps/                   # Frontend applications
├── packages/               # Shared packages
├── infra/                  # Infrastructure as code
├── docs/                   # Documentation
├── scripts/                # Generation scripts
├── tools/                  # Development tools
├── external/               # External services
└── deploy/                 # Deployment scripts
```

---

## 🔧 APIs - Backend Microservices

### Overview
Two main microservices built with NestJS and Fastify, each serving distinct purposes in the Pravia ecosystem.

### Architecture

**Microservices:**
- **Foundry** - Authentication & Authorization API
- **Flux** - Dataverse Data API

**Why Separated?**
- Independent scaling (auth vs data)
- Enhanced security (credentials isolated)
- Independent deployment
- Team separation
- Reusability
- Compliance (separate audit trails)

### Shared Technology Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| NestJS | Latest | Framework with DI |
| Fastify | Latest | High-performance HTTP |
| TypeORM | Latest | Database ORM |
| PostgreSQL | 14+ | Database (Supabase) |
| Swagger/OpenAPI | Latest | API documentation |
| Jest | Latest | Testing |
| ESLint + Prettier | Latest | Code quality |

### 1. Foundry API - Authentication & Authorization

**Purpose:** User authentication, authorization, and management

**Database Schema:** `external_authentication`

**Key Features:**
- JWT authentication (access + refresh tokens)
- Supabase Admin API integration (15 methods)
- User profile management
- Role-based access control (RBAC)
- Government compliance & audit trails
- User lifecycle management

**Core Modules:**
- `auth-admin` - Authentication & Supabase integration
- `user-profile` - User profiles & admin operations
- `auth-audit` - Compliance & audit trails
- `role` - Role management
- `contacts` - User contacts
- `health` - System monitoring
- `dev` - Development utilities
- `validators` - Custom validators

**Key Endpoints:**
- `POST /api/auth/validate` - Validate Supabase token
- `POST /api/auth/refresh` - Refresh session
- `GET /api/auth/me` - Get current user
- `POST /api/user-management/admin/users` - Create user
- `GET /api/user-management/admin/users` - List users
- `PUT /api/user-management/admin/users/:id` - Update user
- `DELETE /api/user-management/admin/users/:id` - Delete user
- `POST /api/user-management/admin/users/:id/reset-password` - Reset password
- `GET /api/health` - Health check

**Supabase Admin API (15 Methods):**
- User management (create, update, delete, list)
- Password management (reset, generate links)
- Session management (refresh, revoke)
- User status (ban, unban, invite)
- Audit & activity tracking

**Port:** 4000

**Documentation:** `api/foundry/FOUNDRY-API.md`

### 2. Flux API - Dataverse Data API

**Purpose:** Business data management and Dataverse integration

**Database Schema:** `external_dataverse`

**Key Features:**
- Dataverse integration & synchronization
- Business data management
- Document & attachment handling
- Organization member management
- Form submission processing

**Core Modules:**
- `accounts` - Account management
- `contacts` - Contact management
- `submissions` - Form submissions
- `attachments` - File attachments
- `register` - Registration processes
- `document-types` - Document classifications
- `document-urls` - Document URL management
- `organization-members` - Member management
- `designees` - Designee management
- `admin` - Admin operations
- `health` - System monitoring
- `test-only` - Testing utilities
- `validators` - Custom validators

**Key Endpoints:**
- `GET /api/accounts` - List accounts
- `POST /api/accounts` - Create account
- `GET /api/contacts` - List contacts
- `POST /api/contacts` - Create contact
- `GET /api/submissions` - List submissions
- `POST /api/submissions` - Create submission
- `GET /api/attachments` - List attachments
- `POST /api/attachments` - Upload attachment
- `GET /api/health` - Health check

**Port:** 4001

**Documentation:** `api/flux/FLUX-API.md`

### Communication Flow

```
Frontend (mule-vite)
    ↓
1. Login → Foundry → JWT Token
    ↓
2. Request Data → Flux (with JWT)
    ↓
3. Flux validates JWT with Foundry
    ↓
4. Flux returns data if authorized
```

### Environment Configuration

Both APIs support multiple environments:

| Environment | .env File | Supabase Project |
|-------------|-----------|------------------|
| Local | `.env.local` | localhost:54321 |
| Development | `.env.development` | ahanrwalkdrbbhlhjxzr |
| Test | `.env.test` | gurgyegmjqbisdhbvoww |
| QA | `.env.qa` | Per environment |
| UAT | `.env.uat` | laorysvmqjaxatyzsgkj |

### Common Features

**Health Monitoring:**
- System health status
- Database connectivity
- Memory usage
- Performance metrics

**API Documentation:**
- Swagger/OpenAPI UI
- Interactive API explorer
- Request/response schemas
- Authentication testing

**Testing:**
- Unit tests (Jest)
- Integration tests
- E2E tests
- Load tests (Artillery)

**Deployment:**
- Docker containerization
- Azure Container Apps
- Environment-specific configs
- Automated deployment scripts

**Code Quality:**
- ESLint linting
- Prettier formatting
- TypeScript strict mode
- Pre-commit hooks (Husky)

### Development Workflow

**Installation:**
```bash
pnpm install
cp .env.example .env
```

**Development:**
```bash
pnpm dev              # Start dev server
pnpm test             # Run tests
pnpm lint:fix         # Fix linting
pnpm format-lint      # Format and lint
```

**Database:**
```bash
pnpm migration:generate  # Generate migration
pnpm migration:run       # Run migrations
pnpm migration:revert    # Revert migration
```

**Deployment:**
```bash
pnpm build                      # Build for production
pnpm start:prod                 # Start production
./deploy/deploy-azure-dev.sh    # Deploy to Azure
```

### Security

**Authentication:**
- JWT-based authentication
- Refresh token support
- Token expiration
- Secure token storage

**Authorization:**
- Role-based access control (RBAC)
- Permission-based access
- Resource-level permissions
- Audit logging

**Data Protection:**
- Environment variable encryption
- Secure database connections
- HTTPS enforcement
- Input validation
- SQL injection prevention

### Performance

**Optimization:**
- Database query optimization
- Caching strategies (Redis)
- Connection pooling
- Lazy loading
- Materialized views

**Monitoring:**
- Request/response logging
- Error tracking
- Performance metrics
- Health checks

### Documentation Files

**Foundry:**
- `api/foundry/FOUNDRY-API.md` - Complete documentation
- `api/foundry/docs/API_ENDPOINTS.md` - Endpoint reference
- `api/foundry/docs/ARCHITECTURE.md` - Architecture details
- `api/foundry/docs/TESTING.md` - Testing guide
- `api/foundry/docs/ERD.md` - Database schema

**Flux:**
- `api/flux/FLUX-API.md` - Complete documentation
- `api/flux/docs/DATAVERSE_FLOWS.md` - Dataverse integration
- `api/flux/docs/TESTING.md` - Testing guide
- `api/flux/docs/architecture-diagram.md` - Architecture

**General:**
- `api/API-OVERVIEW.md` - API overview and comparison

---

## 🤖 Kiro CLI Configuration

### Overview
Configuration and context for Kiro CLI (AWS AI-assisted development tool). Provides AI with project-specific knowledge, verification procedures, and development guidelines.

### Directory Structure
```
.kiro/
├── instructions.md                    # Mandatory AI instructions
├── project-context.md                 # Environment mapping
├── verification-checklist.md          # Operation verification
├── scripts/                           # Utility scripts
├── context/frontend/                  # Frontend development guides
└── specs/ai-accelerator-platform/     # AI platform specifications
```

### Core Configuration

#### Mandatory AI Instructions
**File:** `instructions.md`

**Critical Rules:**
- ALWAYS verify environment before database operations
- NEVER claim success without proof
- Show query results and verification
- Confirm before destructive operations
- Don't assume environment variable loading

**Environment Mapping:**
- `.env.development` → Dev (ahanrwalkdrbbhlhjxzr)
- `.env.test` → Test (gurgyegmjqbisdhbvoww)
- `.env.uat` → UAT (laorysvmqjaxatyzsgkj)

#### Project Context
**File:** `project-context.md`

**Environment Mapping:**

| API | Environment | Supabase Project | Schema |
|-----|-------------|------------------|--------|
| Foundry | dev/test/uat | Per environment | external_authentication |
| Flux | dev/test/uat | Per environment | external_dataverse |
| Incidents | TBD | TBD | TBD |

#### Verification Checklist
**File:** `verification-checklist.md`

**Pre-Operation Steps:**
1. Verify environment and .env file
2. Verify database connection
3. Preview destructive operations
4. Confirm with user
5. Verify after execution

### Utility Scripts

#### verify-db-connection.sh
Verifies database connection and environment configuration.

**Usage:**
```bash
./.kiro/scripts/verify-db-connection.sh <environment> <api-name>
```

**Output:**
- .env file path
- Connection parameters
- Supabase project reference
- Connection test results

#### run-db-query.sh
Executes database queries with proper environment.

**Usage:**
```bash
./.kiro/scripts/run-db-query.sh <environment> <api-name> "<query>"
```

### Development Context

#### Frontend Guides
**Location:** `context/frontend/`

**GENERATED_CODE_GUIDE.md:**
- Auto-generated API services from Swagger
- Zustand slices generation
- Shared TypeScript types
- Integration patterns

**ZUSTAND_SLICE_WIRING.md:**
- Store creation patterns
- Slice composition
- Selector optimization
- Testing strategies

### Project Specifications

#### AI Accelerator Platform
**Location:** `specs/ai-accelerator-platform/`

**Overview:** Multi-agent workflow orchestration system powered by CrewAI.

**Files:**
- `requirements.md` (16KB) - System requirements and user stories
- `design.md` (111KB) - Technical design and architecture
- `tasks.md` (12KB) - Implementation task breakdown

**Key Features:**
- Workflow definition and management
- Agent configuration and orchestration
- Tool integration framework
- Knowledge base with vector search
- Job execution and monitoring
- Multi-tenant architecture
- Event-driven design
- Full observability

**Technology Stack:**
- CrewAI (orchestration)
- NestJS (backend)
- PostgreSQL/Supabase (database)
- pgvector (vector search)

**Status:** Specification phase

### Best Practices

**Environment Safety:**
- Always verify before operations
- Show proof of operations
- Confirm destructive actions
- Never assume environment loading

**Documentation:**
- Keep instructions current
- Document environment changes
- Update mappings immediately
- Include examples

**Script Usage:**
- Test scripts regularly
- Handle errors gracefully
- Provide clear output
- Document parameters

---

## 🪝 Husky - Git Hooks Manager

### Overview
Husky manages Git Hooks to automate code quality checks before commits are finalized. Ensures consistent code formatting and linting across the entire codebase.

### Directory Structure
```
.husky/
├── _/                      # Husky internal files
│   ├── husky.sh           # Base script (deprecated in v10)
│   └── [hook templates]   # Available but unconfigured hooks
└── pre-commit             # Active pre-commit hook
```

### Active Hooks

#### pre-commit Hook

**Purpose:** Automatically lint and format code before allowing commits.

**Execution Flow:**
```
git commit → Husky intercepts → Detects changes → Runs linters → Auto-fixes → Adds fixes → Commit completes
```

**Monitored Paths:**

| Path | Commands | Tools |
|------|----------|-------|
| `apps/mule-vite/` | `pnpm lint:fix`<br>`pnpm fm:fix` | ESLint<br>Prettier |
| `apps/mule-incidents/` | `pnpm lint:fix`<br>`pnpm fm:fix` | ESLint<br>Prettier |
| `api/flux/` | `pnpm format-lint` | Prettier + ESLint |
| `api/foundry/` | `pnpm format-lint` | Prettier + ESLint |
| `api/incidents/` | `pnpm format-lint` | Prettier + ESLint |

**Benefits:**
- ✅ Prevents commits with linting errors
- ✅ Automatic code formatting
- ✅ Consistent code style across team
- ✅ Only processes changed files (performance optimized)

**Example Usage:**
```bash
# Developer makes changes
$ git add apps/mule-vite/src/app.tsx
$ git commit -m "feat: update app"

# Husky automatically:
Running lint and format for mule-vite...
✓ ESLint fixes applied
✓ Prettier formatting applied

[main abc1234] feat: update app component
```

**Bypass Hook (Emergency Only):**
```bash
git commit --no-verify -m "message"
```

**Available But Unconfigured Hooks:**
- commit-msg (validate commit messages)
- pre-push (run tests before push)
- post-merge (update dependencies)
- And 10+ more Git hooks

---

## 🔄 GitHub Configuration

### Overview
GitHub-specific configuration for repository automation and CI/CD workflows.

### Directory Structure
```
.github/
└── workflows/          # GitHub Actions workflows
    └── deploy-mule-vite.yml
```

### 1. GitHub Actions Workflows

#### 1.1 Deploy Mule Vite Workflow
**File:** `workflows/deploy-mule-vite.yml`

**Purpose:** Automated deployment pipeline for the mule-vite frontend application to Azure Static Web Apps.

**Trigger Conditions:**
- Automatic: Push to `main` branch with changes in:
  - `apps/mule-vite/**`
  - `packages/ui/**`
- Manual: Workflow dispatch with environment selection

**Supported Environments:**
- Development (dev)
- Quality Assurance (qa)
- User Acceptance Testing (uat)
- Testing (test)

**Pipeline Stages:**

| Stage | Description | Tools |
|-------|-------------|-------|
| 1. Checkout | Clone repository | actions/checkout@v4 |
| 2. Setup | Install pnpm v9 & Node.js v20 | pnpm/action-setup@v2, actions/setup-node@v4 |
| 3. Dependencies | Install with frozen lockfile | pnpm install |
| 4. Clean | Remove previous build artifacts | rm -rf dist folders |
| 5. Build Packages | Build api-types → ui → mule-vite | pnpm build |
| 6. Deploy | Upload to Azure Static Web Apps | Azure/static-web-apps-deploy@v1 |

**Required Environment Variables:**
- `VITE_APP_ENV` - Application environment identifier
- `VITE_SUPABASE_URL` - Supabase instance URL
- `VITE_SUPABASE_ANON_KEY` - Supabase anonymous key
- `VITE_AUTH_API_URL` - Authentication API endpoint
- `VITE_DATA_API_URL` - Data API endpoint
- `VITE_INVITE_REDIRECT_URL` - User invitation redirect URL
- `VITE_ENABLE_TOOLS` - Development tools toggle
- `VITE_LOG_LEVEL` - Application logging level

**Required Secrets:**
- `AZURE_STATIC_WEB_APPS_API_TOKEN_MULE_VITE` - Azure deployment token
- `GITHUB_TOKEN` - Auto-provided by GitHub

**Build Order (Critical):**
1. packages/api-types
2. packages/ui
3. apps/mule-vite

**Deployment Target:** Azure Static Web Apps

**Usage:**
- **Automatic:** Push changes to main branch
- **Manual:** 
  1. Navigate to Actions tab
  2. Select "Deploy Mule Vite to Azure SWA"
  3. Click "Run workflow"
  4. Choose environment
  5. Execute

**Key Features:**
- Monorepo-aware build process
- Clean build strategy (no stale artifacts)
- Multi-environment support
- Dependency-ordered builds

---

## 🎨 Frontend Applications

### Overview
React-based frontend application built with Vite, TypeScript, and Material-UI.

### Mule Vite - Main Frontend Application

**Purpose:** User interface for Pravia CRM Platform

**Technology Stack:**
- React 18+ with TypeScript
- Vite (build tool)
- Material-UI 5+ (UI components)
- Zustand (client state)
- TanStack Query (server state)
- React Router 6+ (routing)
- React Hook Form + Zod (forms)
- i18next (internationalization)
- Supabase (authentication)

**Key Features:**
- Authentication & authorization
- Business data management
- Registration workflows
- Dashboard and analytics
- Resource management
- Marketing tools
- Multi-language support (EN/ES)
- Responsive design
- Theme system (light/dark)

**Architecture:**
```
UI (React + MUI)
    ↓
State (Zustand + TanStack Query)
    ↓
API Layer (Axios + Generated Services)
    ↓
Backend APIs (Foundry + Flux)
```

**Directory Structure:**
- `src/api/` - API integration
- `src/components/` - Reusable components
- `src/pages/` - Page components
- `src/sections/` - Feature sections
- `src/store/` - State management
- `src/layouts/` - Layout components
- `src/guards/` - Route protection
- `src/hooks/` - Custom hooks
- `src/services/` - Business logic
- `src/locales/` - i18n translations
- `src/lib/` - Third-party integrations
- `src/utils/` - Utility functions

**State Management:**
- **Zustand** - Client state (UI, forms, app state)
- **TanStack Query** - Server state (API data, caching)
- **Auto-generated slices** - From Swagger specs

**API Integration:**
- Generated services from Swagger/OpenAPI
- Axios HTTP client
- JWT authentication
- Request/response interceptors

**Routing:**
- React Router 6+
- Protected routes (AuthGuard)
- Guest routes (GuestGuard)
- Lazy loading
- Route-based code splitting

**Forms:**
- React Hook Form
- Zod validation
- Form state management
- Error handling
- Field-level validation

**Internationalization:**
- i18next integration
- English and Spanish
- Dynamic language switching
- Translation management

**Development:**
```bash
pnpm install      # Install dependencies
pnpm dev          # Start dev server
pnpm build        # Build for production
pnpm lint:fix     # Fix linting
pnpm fm:fix       # Format code
```

**Environment Variables:**
- `VITE_SUPABASE_URL` - Supabase instance
- `VITE_SUPABASE_ANON_KEY` - Supabase key
- `VITE_AUTH_API_URL` - Foundry API endpoint
- `VITE_DATA_API_URL` - Flux API endpoint
- `VITE_APP_ENV` - Environment name
- `VITE_LOG_LEVEL` - Logging level

**Deployment:**
- Azure Static Web Apps
- GitHub Actions CI/CD
- Automatic deployment on push to main
- Environment-specific builds

**Documentation:**
- `apps/mule-vite/MULE-VITE-APP.md` - Complete documentation
- `apps/mule-vite/docs/` - Technical guides
  - STATE_MANAGEMENT.md
  - INITIALIZATION.md
  - FLUX_TYPES_MIGRATION.md
  - HOW_TO_COMMUNICATE_WITH_AI.md

**Port:** 5173 (dev), deployed to Azure

---

## 🚀 Deployment

### Overview
Unified container deployment system for all API services with configuration-driven approach.

### API Deployment System

**Location:** `deploy/api/`

**Purpose:** Centralized deployment for Flux, Foundry, and other APIs to Azure Container Apps.

**Key Components:**
- `deploy-container.sh` - Unified deployment script
- Service-specific `config.json` files
- Wrapper scripts for backward compatibility

**Features:**
- Single parameterized script for all containers
- Environment-specific configurations (dev, qa, test, uat)
- Multi-stack support (Foundry: compliance/incidents)
- Docker build and push to Azure Container Registry
- Azure Container Apps update
- Health check verification

**Usage:**
```bash
# Direct usage
./deploy/api/deploy-container.sh <service> <environment> [--stack <stack>]

# Examples
./deploy/api/deploy-container.sh flux dev
./deploy/api/deploy-container.sh foundry dev --stack compliance

# Via wrapper scripts
cd api/flux/deploy && ./deploy-azure-dev-new.sh
```

**Configuration Structure:**
```json
{
  "dev": {
    "registry": "acrpraviamuledevereh4t.azurecr.io",
    "registryName": "acrpraviamuledevereh4t",
    "imageName": "pravia-mule/pravia-data-api-dev",
    "containerApp": "ca-pravia-data-api-dev",
    "resourceGroup": "rg-pravia-mule-dev-eastus",
    "subscriptionId": "...",
    "apiUrl": "...",
    "setNodeEnv": true
  }
}
```

**Deployment Process:**
1. Read configuration from config.json
2. Build Docker image (linux/amd64)
3. Login to Azure Container Registry
4. Push image to ACR
5. Update Azure Container App
6. Verify health endpoint

**Supported Services:**
- **Flux API** - Data API (dev, qa, test, uat)
- **Foundry API** - Auth API with 2 stacks:
  - `compliance` - Main authentication
  - `incidents` - Incidents management

**Benefits:**
- 95% code reduction (1 script vs 12+ scripts)
- Single source of truth
- Easy to extend (add services via config)
- Backward compatible
- Type-safe configuration

**Migration Status:**
- ✅ Unified script created
- ✅ Config files for Flux and Foundry
- ✅ Wrapper scripts created
- ✅ Original scripts preserved as backup
- ⏳ Testing in all environments
- ⏳ Migration of incidents service

**Rollback Strategy:**
Original scripts preserved for rollback:
```bash
cd api/flux/deploy
./deploy-azure-dev.sh  # Original script
```

**Documentation:** `deploy/api/API-DEPLOYMENT.md`

---

## 📦 Shared Packages

### Overview
Shared packages used across all APIs and frontend applications, promoting code reuse, consistency, and maintainability across the monorepo.

### Directory Structure
```
packages/
├── api-core/       # Shared NestJS backend functionality
├── api-types/      # Shared TypeScript types and API contracts
└── ui/             # Shared React UI component library
```

### 1. api-core - Backend Core Library

**Purpose:** Shared NestJS functionality for all backend APIs (Foundry, Flux, Incidents)

**Key Features:**
- Health monitoring with database connectivity checks
- Response standardization (consistent API format)
- Database validators (`IsExist`, `IsNotExist`)
- Base entity with common fields
- Enhanced Swagger UI with custom theming
- Automatic CORS management

**Technology Stack:**
- NestJS
- TypeORM
- Fastify
- Swagger/OpenAPI

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

**Documentation:**
- `packages/api-core/README.md` - Complete documentation
- `packages/api-core/DOCUMENTATION_PROVIDERS.md` - Provider setup guide

### 2. api-types - Shared Types & API Contracts

**Purpose:** Centralized TypeScript types, interfaces, and auto-generated API services for frontend-backend communication

**Key Features:**
- Auto-generated API services from Swagger/OpenAPI specs
- Auto-generated Zustand state slices
- Shared TypeScript types and interfaces
- Service factory pattern for API creation
- End-to-end type safety

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
- `packages/api-types/COMMON_INTERFACES.md` - Common interfaces
- `packages/api-types/FACTORY_PATTERN.md` - Factory pattern details
- `packages/api-types/SERVICE_SLICE_GENERATION.md` - Slice generation

### 3. ui - React Component Library

**Purpose:** Shared React UI components, layouts, and utilities for all frontend applications

**Key Features:**
- 40+ UI components organized by category
- Layout templates (Dashboard, Form, Marketing)
- Pre-built auth views (SignIn, SignUp, Reset Password)
- MUI v7 theme system with 47 component overrides
- Storybook integration for component documentation
- Code generation CLI tool
- Tree-shakeable exports

**Component Categories:**

| Category | Components |
|----------|------------|
| Data Display | DataTable, Label, Logo, Iconify, CustomCard, StatCard, CustomBreadcrumbs, FileThumbnail, FlagIcon |
| Feedback | CustomSnackbar, ProgressBar, ConfirmationDialog, LoadingScreen, EnhancedFormDialog, SearchNotFound |
| Inputs | FormBuilder, HookForm components, PhoneInput, NumberInput, Upload |
| Layout | DashboardContent, MenuButton, NavToggleButton |
| Navigation | NavigationMenu, HorizontalStepper, Fab, Routes, Scrollbar |
| Surfaces | AnimatedBackground, PageHeader, Drawers |
| Utils | FiltersResult, PerformanceMonitor, SvgColor, Animations |

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

**Development Tools:**
- Storybook - `npm run storybook` (http://localhost:6006)
- Code Generator - `npm run codegen`
- Testing - Vitest with coverage

**Consumers:**
- apps/mule-vite
- apps/mule-incidents
- All frontend applications

**Documentation:**
- `packages/ui/README.md` - Main documentation
- `packages/ui/THEME.md` - Theme system guide (18KB)
- `packages/ui/ROUTERLINK_CHANGES.md` - Router link changes
- `packages/ui/docs/` - Implementation guides
  - `AI_WORKFLOW_VISUALIZATION.md` - AI workflow visualization
  - `CRUD_PATTERNS.md` - CRUD patterns guide
  - `JOB_MONITOR_IMPLEMENTATION.md` - Job monitor implementation
  - `KB_IMPLEMENTATION_SUMMARY.md` - Knowledge base implementation
  - `WORKFLOW_BUILDER_IMPLEMENTATION.md` - Workflow builder guide
  - `NOTIFICATION_REFACTORING.md` - Notification refactoring

**Version:** 1.0.643 (auto-incremented on build)

### Package Dependencies

**Dependency Graph:**
```
apps/mule-vite
    ↓
packages/ui → packages/api-types
    ↓              ↓
packages/api-core (backend only)
    ↓
api/foundry, api/flux, api/incidents
```

**Build Order:**
1. api-core - Backend shared functionality
2. api-types - Types and API services
3. ui - UI components
4. apps/ - Frontend applications
5. api/ - Backend APIs

**Build Command:**
```bash
# From root
pnpm build

# Individual package
cd packages/api-core && pnpm build
```

### Development Workflow

**Adding Shared Backend Code (api-core):**
1. Create component in appropriate directory
2. Export from `src/index.ts`
3. Rebuild: `pnpm build`
4. Test in consuming API

**Updating Types (api-types):**
1. Update backend Swagger spec
2. Run generation: `pnpm generate`
3. Verify generated files
4. Test in frontend

**Adding UI Component (ui):**
1. Generate: `npm run codegen`
2. Implement component
3. Add Storybook story
4. Rebuild: `npm run build`
5. Test in consuming app

### Best Practices

**✅ Create shared code when:**
- Used by 2+ applications/APIs
- Core functionality (auth, validation, responses)
- UI components used across apps
- Common types and interfaces

**❌ Don't create shared code when:**
- Feature-specific to one app
- Experimental or unstable
- Tightly coupled to specific implementation

**Documentation File:** `packages/README.md`

---

## 🏗️ Infrastructure

### Overview
Infrastructure as Code (IaC) definitions for deploying Pravia CRM Platform across AWS, Azure, Docker, and Kubernetes.

### Directory Structure
```
infra/
├── aws/            # AWS infrastructure (CDK)
├── azure/          # Azure infrastructure (Bicep)
├── compose/        # Docker Compose configurations
├── docker/         # Dockerfiles
└── k8s/            # Kubernetes manifests
```

### 1. AWS Infrastructure (CDK)

**Purpose:** AWS Cloud Development Kit stacks for AWS deployment.

**Location:** `infra/aws/cdk/`

#### Foundation Stack (`foundation-infra/`)

**Purpose:** Long-lived, shared infrastructure resources.

**What's Included:**
- **DNS & SSL** - Route53 Hosted Zone, SSL Certificate
- **Email** - SES Domain Identity, DKIM signing
- **Storage** - S3 Bucket with versioning

**Deployment:**
```bash
cd infra/aws/cdk/foundation-infra
cdk deploy --context environment=development
```

**Why Separate?**
Foundation resources remain stable across application deployments. Safe to redeploy apps without risking DNS/SSL/email issues.

**Current Status:** ⚠️ Resources exist but not CDK-managed yet.

**Documentation:** `infra/aws/cdk/foundation-infra/README.md` (10KB)

#### Supabase Stack (`supabase-infra/`)

**Purpose:** Self-hosted Supabase on AWS EC2.

**What's Included:**
- EC2 instance with Supabase Docker containers
- VPC with public/private subnets
- Security groups and networking
- EBS volumes for persistence
- Optional Application Load Balancer
- CloudWatch monitoring
- Automated backups (optional)

**Deployment:**
```bash
# Interactive mode
cdk deploy --profile AdministratorAccess-042428207581

# Non-interactive mode
cdk deploy \
  -c stackPrefix=mycompany \
  -c environment=production \
  -c instanceType=t3.large \
  --profile AdministratorAccess-042428207581
```

**Parameters:**
- `stackPrefix` - Company/project prefix
- `environment` - development/production
- `instanceType` - t3.small/t3.medium/t3.large
- `enableLoadBalancer` - Enable ALB (saves ~$40/month if disabled)
- `enableBackups` - Enable automated backups
- `enableCloudWatch` - Enable monitoring

**Cost Optimization:**
- Disable ALB in development (saves $16/month)
- Use t3.small for dev, t3.large for prod

**Documentation:**
- `infra/aws/cdk/supabase-infra/README.md` (9KB)
- `infra/aws/cdk/supabase-infra/README-MODULAR.md` (9KB)

#### Legacy API Stacks

**Deprecated:** auth-api-infra, compliance-api-infra, data-api-infra, platform-api-infra

**Note:** Current deployment uses Azure Container Apps (see `deploy/api/`).

### 2. Azure Infrastructure (Bicep)

**Purpose:** Azure infrastructure using Bicep templates.

**Location:** `infra/azure/`

#### Pravia Mule (`pravia-mule/`)

**Purpose:** Main Pravia CRM platform on Azure.

**What's Included:**
- Azure Container Apps for APIs
- Azure Container Registry
- Virtual Network and subnets
- Application Insights
- Log Analytics Workspace
- Managed Identity
- Key Vault (optional)

**Deployment:**
```bash
cd infra/azure/pravia-mule
az deployment group create \
  --resource-group rg-pravia-mule-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json
```

**Configuration:**
- `infra/main.bicep` - Main template (14KB)
- `infra/main.parameters.json` - Parameters
- `infra/modules/` - Reusable modules
- `scripts/configure-environment.sh` - Setup script (24KB)

**Documentation:**
- `infra/azure/pravia-mule/README.md` (16KB)
- `infra/azure/pravia-mule/QUICKSTART.md` (8KB)
- `infra/azure/pravia-mule/BICEP_UPDATES.md`

#### Pravia Incidents (`pravia-incidents/`)

**Purpose:** Incidents management system on Azure.

**What's Included:**
- Azure Container Apps for Incidents API
- Azure Container Registry
- Virtual Network
- Application Insights
- Managed Identity

**Deployment:**
```bash
cd infra/azure/pravia-incidents
az deployment group create \
  --resource-group rg-pravia-incidents-dev \
  --template-file infra/main.bicep
```

**Documentation:** `infra/azure/pravia-incidents/README.md` (16KB)

### 3. Docker Compose

**Purpose:** Local development with Docker Compose.

**Location:** `infra/compose/`

#### Development Compose

**File:** `docker-compose.dev.yml`

**Services:**
- APIs (Foundry, Flux, Incidents)
- PostgreSQL database
- Supabase (optional)
- n8n (optional)

**Usage:**
```bash
docker compose -f infra/compose/docker-compose.dev.yml up -d
```

#### Supabase Compose (`compose/supabase/`)

**Purpose:** Self-hosted Supabase for local development.

**Services:**
- Supabase Studio
- PostgreSQL database
- PostgREST API
- GoTrue (auth)
- Realtime server
- Storage API
- Kong API Gateway

**Usage:**
```bash
cd infra/compose/supabase
./start-local.sh
```

**Access:**
- Studio: http://localhost:54323
- API: http://localhost:54321
- DB: postgresql://postgres:postgres@localhost:54322/postgres

**Documentation:** `infra/compose/supabase/README.md` (15KB)

### 4. Docker

**Purpose:** Dockerfiles for container images.

**Location:** `infra/docker/`

**Files:**
- `auth-api.Dockerfile` - Foundry API
- `data-api.Dockerfile` - Flux API
- `platform-api.Dockerfile` - Platform API (legacy)
- `gateway-api.Dockerfile` - Gateway API (legacy)
- `docker-compose.minimal.yml` - Minimal setup
- `docker-compose.pgadmin.yml` - PostgreSQL admin
- `docker-compose.supabase.yml` - Supabase reference

**Note:** Individual API Dockerfiles now in each API directory.

### 5. Kubernetes

**Purpose:** Kubernetes manifests.

**Location:** `infra/k8s/`

**Current Status:** Minimal configuration

**Files:**
- `namespace.yaml` - Namespace definition

**Note:** K8s not actively used. Current targets: Azure Container Apps, AWS ECS.

### Multi-Cloud Architecture

**AWS:**
- Foundation (DNS, SSL, Email, Storage)
- Self-hosted Supabase on EC2
- CloudWatch monitoring

**Azure:**
- Container Apps for APIs
- Container Registry
- Application Insights
- Static Web Apps for frontend

**Why Multi-Cloud?**
- Leverage best services from each provider
- Avoid vendor lock-in
- Cost optimization
- Regional availability

### Deployment Targets

| Component | Platform | Tool |
|-----------|----------|------|
| Foundation (DNS, SSL, Email) | AWS | CDK |
| Supabase | AWS EC2 | CDK |
| APIs (Foundry, Flux, Incidents) | Azure Container Apps | Bicep |
| Frontend (mule-vite) | Azure Static Web Apps | GitHub Actions |
| Local Development | Docker Compose | Docker |

### Cost Estimation (Monthly)

**AWS:**
- Development: ~$21 (without ALB) / ~$37 (with ALB)
- Production: ~$66 (without ALB) / ~$82 (with ALB)

**Azure:**
- Development: ~$37
- Production: ~$115

**Total Platform:**
- Development: ~$58/month
- Production: ~$181/month

**Cost Optimization:**
- Disable ALB in development (saves $16/month)
- Use t3.small for Supabase in dev
- Scale down Container Apps when not in use

### Security Best Practices

- Use VPCs/VNets with private subnets
- Restrict security groups to necessary ports
- Use AWS Secrets Manager / Azure Key Vault
- Enable CloudWatch / Application Insights
- Automated backups for databases
- Rotate credentials regularly

**Documentation File:** `infra/README.md`

---

## 🛠️ Tools and Scripts

### Overview
CLI tools and templates for scaffolding new applications, APIs, and deploying packages in the monorepo.

### Directory Structure
```
scripts/
├── api/            # API generator (NestJS + Fastify)
├── app/            # Frontend app generator (Vite + React)
└── packages/       # Package deployment scripts
```

### 1. API Generator

**Purpose:** Scaffold new NestJS + Fastify backend APIs from a standardized template.

**Usage:**
```bash
node scripts/api/generate-api.js
```

**Interactive Prompts:**
- API name (lowercase)
- Display name
- Description
- Port number (default: 4007)
- Package scope (default: @asyml8)

**What Gets Generated:**
Creates `/api/{api-name}` with:
- Complete NestJS + Fastify setup
- TypeORM + PostgreSQL integration (optional)
- Swagger/OpenAPI documentation
- Health check endpoints
- Docker configuration
- Azure deployment scripts
- ESLint + Prettier
- Jest testing

**Template Tokens:**
- `{{API_NAME}}` - API name
- `{{API_DISPLAY_NAME}}` - Display name
- `{{PORT}}` - Dev server port
- `{{PACKAGE_NAME}}` - Full package name
- `{{SWAGGER_TITLE}}` - Swagger title

**Next Steps:**
```bash
cd api/{api-name}
pnpm install
cp .env.example .env.local
pnpm dev
```

**Template Location:** `scripts/api/base-api/`

**Documentation:** `scripts/api/README.md`

### 2. App Generator

**Purpose:** Scaffold new Vite + React frontend applications from the `mule-vite` template.

**Usage:**
```bash
node scripts/app/generate-app.js
```

**Interactive Prompts:**
- App name (kebab-case)
- Display name
- Description
- Port number (default: 8081)
- Package scope (default: @asyml8)
- Author

**What Gets Generated:**
Creates `/apps/{app-name}` with:
- React 18+ with TypeScript
- Vite build tool
- Material-UI 5+ components
- Zustand + TanStack Query (state management)
- React Router 6+ (routing)
- React Hook Form + Zod (forms)
- i18next (internationalization)
- Supabase authentication
- Complete dashboard layout
- Theme system

**Template Tokens:**
- `{{APP_NAME}}` - Package name
- `{{APP_DISPLAY_NAME}}` - Display name
- `{{PORT}}` - Dev server port
- `{{APP_TITLE}}` - HTML title
- `{{AUTHOR}}` - Author name

**Next Steps:**
```bash
cd apps/{app-name}
pnpm install
pnpm dev
```

**Template Location:** `scripts/app/base-app/`

**Documentation:** `scripts/app/README.md`

### 3. Package Deployment Scripts

**Purpose:** Deploy monorepo packages to private git repositories for distribution.

**Prerequisites:**
SSH key setup required for private repositories.

**Configuration:**
`scripts/packages/deploy-config.env` maps packages to git repos:
```bash
packages/api-types=git@github.com:yourorg/api-types.git
packages/ui=git@github.com:yourorg/ui-components.git
packages/api-core=git@github.com:yourorg/api-core.git
```

**Usage:**
```bash
# Deploy a package
pnpm deploy:api-types

# Or directly
bash scripts/packages/deploy.sh packages/api-types

# Or with custom repo
bash scripts/packages/deploy-to-git.sh packages/api-types git@github.com:org/repo.git
```

**Deployment Process:**
1. Validates package exists
2. Reads package name and version
3. Runs `pnpm build`
4. Copies deployment files (dist/, package.json, README, LICENSE)
5. Initializes git repo
6. Commits with version message
7. Force pushes to remote
8. Creates version tag
9. Cleans up and logs

**Logging:**
Creates timestamped log files with color-coded output:
- [INFO] - General information (blue)
- [SUCCESS] - Successful operations (green)
- [WARN] - Warnings (yellow)
- [ERROR] - Errors (red)

**Environment Variables:**
- `GIT_USER_NAME` - Git commit author (default: "CI Deploy")
- `GIT_USER_EMAIL` - Git commit email (default: "deploy@pravia.local")

**CI/CD Integration:**
Supports GitHub Actions and GitLab CI with SSH key setup.

**Package Requirements:**
- `package.json` with `name` and `version`
- `build` script in `package.json`
- Recommended: README.md, LICENSE, .npmignore

**Documentation:** `scripts/packages/README.md`

### Base Templates

**API Base Template (`scripts/api/base-api/`):**
- Complete NestJS + Fastify API
- Health monitoring
- Swagger documentation
- TypeORM integration
- Docker + Azure deployment
- Testing setup

**App Base Template (`scripts/app/base-app/`):**
- Complete Vite + React application
- Authentication flow
- Dashboard layout
- State management
- API integration
- i18n support
- Theme system

### Customization

**Modifying Templates:**
1. Edit files in `scripts/api/base-api/` or `scripts/app/base-app/`
2. Use `{{TOKEN}}` syntax for parameterized values
3. Update `replacements` object in generator scripts for new tokens

### Best Practices

**API Generation:**
- Use descriptive, lowercase names
- Choose unique port numbers
- Configure database settings before first run
- Review generated README

**App Generation:**
- Use kebab-case for app names
- Choose unique port numbers
- Configure environment variables
- Review generated README

**Package Deployment:**
- Test build locally before deploying
- Bump version before each deploy
- Use semantic versioning
- Review deployment logs
- Test deployed package

**Documentation File:** `scripts/README.md`

---

## 🔧 Development Tools

### Overview
Specialized development tools that enhance productivity, code quality, and monitoring capabilities.

### Directory Structure
```
tools/
├── mcp/            # Model Context Protocol servers for AI-assisted development
├── monitoring/     # Application monitoring and observability tools
└── quickstart/     # Quick start templates and examples
```

### 1. MCP (Model Context Protocol) Servers

**Purpose:** AI-powered development tools that integrate with Claude Code and other AI assistants.

**Location:** `tools/mcp/`

**What is MCP?**
Model Context Protocol connects AI assistants to external tools and data sources, enabling them to understand and work with your codebase more effectively.

#### Component Analyzer MCP

**Path:** `tools/mcp/component-analyzer-mcp/`

**Purpose:** Analyze React components and identify opportunities to extract reusable components to the shared UI package.

**Features:**
- Component scanning and analysis
- Extraction candidates (reusability scores 0-100)
- Duplicate detection
- Usage analysis
- Existence checking in UI package
- Migration tracking
- Extraction planning

**Reusability Scoring:**
- Props Interface (+20)
- Default Props (+10)
- Documentation (+15)
- Generic Nature (+25)
- Minimal Dependencies (+20)
- Low Complexity (+10)

**Available Tools:**
- `scan_components` - Analyze React components
- `find_extraction_candidates` - Find high-score components
- `check_if_exists_in_ui` - Check UI package
- `analyze_component_usage` - Show usage
- `generate_extraction_plan` - Step-by-step guide
- `track_migration_status` - Track progress
- `find_duplicate_patterns` - Find duplicates

**Installation:**
```bash
cd tools/mcp/component-analyzer-mcp
npm install && npm run build
```

**Configuration (Claude Code):**
Add to `~/Library/Application Support/Claude/config.json`:
```json
{
  "mcpServers": {
    "component-analyzer": {
      "command": "node",
      "args": ["/path/to/dist/index.js"],
      "env": {"MONOREPO_ROOT": "/path/to/project"}
    }
  }
}
```

**Documentation:**
- `tools/mcp/component-analyzer-mcp/README.md` (7KB)
- `tools/mcp/component-analyzer-mcp/SETUP.md` (4KB)

#### Other MCP Servers

**AWS Docs MCP** - Access AWS documentation and best practices
**AWS Resources MCP** - Query and manage AWS resources
**Frontend Templates MCP** - Generate React components from templates
**Monorepo Compliance MCP** - Ensure monorepo conventions
**NPM Packages MCP** - Search and analyze NPM packages
**Context Manager MCP** - Manage AI conversation context
**Component Converter MCP** - Convert components between frameworks

**Bulk Installation:**
```bash
cd tools/mcp
./install-mcps.sh
```

### 2. Monitoring Tools

**Purpose:** Application monitoring and observability.

**Location:** `tools/monitoring/`

#### Faro Agent

**Path:** `tools/monitoring/faro-agent/`

**Purpose:** Desktop app for monitoring SaaS application health.

**Technology Stack:**
- Electron + Vite + React 19 + TypeScript
- Zustand (state) + TanStack Query (data)
- Fastify (embedded server) + Better-SQLite3 (database)
- @asyml8/ui (components and theme)

**Architecture:**
```
Electron Main Process
├── Fastify Server (localhost:3000)
│   └── REST API with CRUD
├── Better-SQLite3 Database
└── Window Management

React Renderer
├── TanStack Query → HTTP
├── Zustand Stores
└── @asyml8/ui Components
```

**Features:**
- ✅ Full CRUD for services
- ✅ Embedded Fastify REST API
- ✅ SQLite persistence
- ✅ TanStack Query caching
- ✅ Zustand state management
- ✅ Cross-platform (macOS, Windows, Linux)

**Setup:**
```bash
cd tools/monitoring/faro-agent
pnpm install
pnpm dev

# Build for production
pnpm build:mac      # macOS DMG
pnpm build:win      # Windows installer
pnpm build:linux    # Linux AppImage
```

**API Endpoints:**
```
GET    /api/health              # Health check
GET    /api/services            # Get all services
POST   /api/services            # Create service
PUT    /api/services/:id        # Update service
DELETE /api/services/:id        # Delete service
POST   /api/check-health        # Check URL health
```

**Database:**
SQLite at `~/Library/Application Support/faro-agent/faro.db` (macOS)

**Documentation:**
- `tools/monitoring/faro-agent/README.md` (3.5KB)
- `tools/monitoring/faro-agent/QUICKSTART.md` (1.8KB)

### 3. Quickstart Templates

**Purpose:** Quick start templates for rapid prototyping.

**Location:** `tools/quickstart/`

#### Base API Template

**Path:** `tools/quickstart/base-api/`

**Purpose:** Minimal NestJS API template for quick prototyping.

**Features:**
- NestJS + Fastify
- Docker support
- Basic health check
- Swagger documentation
- TypeScript configuration

**Usage:**
```bash
cd tools/quickstart/base-api
npm install
npm run start:dev
```

**Access:**
- API: http://localhost:3000
- Swagger: http://localhost:3000/docs

**Note:** Simpler alternative to full API generator in `scripts/api/`. Use for quick prototypes only.

### Development Workflows

**Component Extraction:**
1. Scan components → 2. Check duplicates → 3. Analyze usage → 4. Generate plan → 5. Track progress

**Monitoring:**
1. Start Faro Agent → 2. Add services → 3. View health status

**Quick Prototyping:**
1. Use base API → 2. Develop feature → 3. Migrate to full API

### Best Practices

**MCP Servers:**
- Install only needed servers
- Keep servers updated
- Configure environment variables
- Test before relying on them

**Monitoring:**
- Monitor critical services only
- Set appropriate intervals
- Configure alerts
- Review data regularly

**Quick Start Templates:**
- Use for prototyping only
- Don't use in production
- Migrate to full templates when ready

**Documentation File:** `tools/README.md`

---

## 📖 Documentation

### Overview
Comprehensive documentation organized into specialized sections covering development, deployment, architecture, and tooling. Serves as the knowledge base for developers, DevOps, and AI-assisted development tools.

### Directory Structure
```
docs/
├── development/        # Development guidelines and best practices
├── getting-started/    # Quick start guides for new developers
├── infrastructure/     # Production deployment and infrastructure
├── reference/          # Technical reference materials
├── tools/              # AI-assisted development and automation
└── _archive/           # Historical documentation and implementation records
```

### Development Documentation
**Location:** `docs/development/`

**Purpose:** Guidelines and best practices for building and maintaining the platform.

**Key Files:**

| File | Description |
|------|-------------|
| `README.md` | Development workflow overview |
| `API_BEST_PRACTICES.md` | Standards for API design, error handling, endpoint structure |
| `ENVIRONMENT_STANDARDS.md` | Configuration management and environment variable conventions |
| `testing.md` | Jest testing strategies and Playwright roadmap |
| `ui-components.md` | Reusable component library documentation |
| `standards.md` | Code quality, linting, and formatting rules |
| `SWAGGER_EXCLUSIONS.md` | API documentation configuration |
| `REGISTER_API_FRONTEND.md` | Guide for connecting new APIs to frontend applications |

**Target Audience:** Backend and frontend developers

### Getting Started Documentation
**Location:** `docs/getting-started/`

**Purpose:** Quick start guides for new developers to get the platform running quickly.

**Key Files:**

| File | Description |
|------|-------------|
| `README.md` | Get the platform running in 2 minutes |
| `architecture.md` | System design, microservices structure, component relationships |
| `commands.md` | Key pnpm commands for development workflow |

**Target Audience:** New developers, onboarding

### Infrastructure Documentation
**Location:** `docs/infrastructure/`

**Purpose:** Production deployment and infrastructure management guides.

**Key Files:**

| File | Description |
|------|-------------|
| `README.md` | Step-by-step AWS deployment using CDK |
| `monitoring.md` | CloudWatch setup, metrics, and alerting |
| `cost-estimation.md` | Monthly AWS cost breakdown and optimization strategies |

**Target Audience:** DevOps, infrastructure engineers

### Reference Documentation
**Location:** `docs/reference/`

**Purpose:** Technical reference materials and troubleshooting guides.

**Key Files:**

| File | Description |
|------|-------------|
| `project-structure.md` | Directory organization and workspace layout |
| `api-docs.md` | Links to Swagger/OpenAPI endpoints for each service |
| `troubleshooting.md` | Common issues, error messages, and solutions |

**Target Audience:** All developers

### Tools Documentation
**Location:** `docs/tools/`

**Purpose:** AI-assisted development and automation tools.

**Key Files:**

| File | Description |
|------|-------------|
| `README.md` | Model Context Protocol servers for enhanced AI capabilities |
| `CODING_STANDARDS.md` | AI-specific coding guidelines and patterns |
| `COMPONENT-EXTRACTION-SUMMARY.md` | Automated component refactoring summaries |
| `CONTRIBUTING.md` | How to contribute to the project |

**Target Audience:** AI tools (Kiro, Cursor, etc.), developers using AI assistants

### Archive Documentation
**Location:** `docs/_archive/`

**Purpose:** Historical documentation and implementation records for reference.

**Subdirectories:**

| Directory | Description |
|-----------|-------------|
| `app-migrations/` | Legacy deduplication and migration guides |
| `cortex-sessions/` | N8N workflow integration session logs |
| `cortex-ui-plans/` | Workflow builder UI implementation plans |
| `forge-tus-implementation/` | TUS resumable upload implementation logs |
| `foundry-prompts/` | Historical AI prompts and boilerplate templates |
| `kiro-sessions/` | Forge-Cortex integration session records |
| `mule-client-prompts/` | Frontend integration guides (DataTable, Navigation) |
| `nexus-implementation/` | Architecture specs and stored procedure migrations |
| `old-prompts/` | Legacy AI prompts for various features |
| `routing-implementation/` | Routing abstraction implementation logs |
| `ui-implementations/` | UI feature implementation records (Dashboard, KB, Workflow Builder) |
| `ui-tus-implementation/` | Frontend TUS upload integration guides |

**Target Audience:** Historical reference, learning from past implementations

### Documentation Philosophy

**Principles:**
- **Living Documentation** - Updated alongside code changes
- **Practical Examples** - Real-world code snippets and CLI commands
- **Progressive Disclosure** - Quick starts for beginners, deep dives for experts
- **AI-Friendly** - Structured for consumption by AI development tools via MCP

### Key Documentation Flows

**For New Developers:**
1. Start with `getting-started/README.md`
2. Review `getting-started/architecture.md`
3. Follow `development/README.md` for local setup
4. Reference `getting-started/commands.md` for daily workflow

**For DevOps/Infrastructure:**
1. Review `infrastructure/README.md` for deployment overview
2. Check `infrastructure/cost-estimation.md` for budget planning
3. Follow `infrastructure/monitoring.md` for observability setup
4. Reference CDK stack READMEs in `infra/aws/cdk/`

**For API Development:**
1. Read `development/API_BEST_PRACTICES.md`
2. Follow `development/ENVIRONMENT_STANDARDS.md`
3. Use `development/REGISTER_API_FRONTEND.md` for frontend integration
4. Reference `development/SWAGGER_EXCLUSIONS.md` for documentation

**For Frontend Development:**
1. Review `development/ui-components.md`
2. Check `development/standards.md` for code quality
3. Reference archived UI implementation guides in `_archive/ui-implementations/`

### Maintenance Guidelines

**Best Practices:**
- Archive outdated documentation to `_archive/` with timestamp
- Keep main sections focused on current implementation
- Update links when file structure changes
- Add new sections as platform evolves
- Document decisions and rationale
- Include examples and code snippets
- Keep documentation close to code

**Documentation File:** `docs/README.md`

---

## 🌐 External Services

### Overview
Third-party services that integrate with the Pravia CRM Platform. These services are self-hosted or managed separately from the main application stack.

### Directory Structure
```
external/
├── n8n/            # Workflow automation platform
└── supabase/       # Backend-as-a-Service (Database, Auth, Storage)
```

### 1. n8n - Workflow Automation Platform

**Purpose:** Self-hosted workflow automation tool for orchestrating tasks and integrating services.

**Version:**
- n8n: v1.21.1
- PostgreSQL: 15-alpine

**What is n8n?**
Workflow automation platform that connects services, automates tasks, and creates complex workflows with a visual editor.

**Use Cases in Pravia:**
- Data synchronization between Dataverse and Supabase
- Notification workflows (email, SMS, push)
- API orchestration (chain multiple API calls)
- Scheduled tasks (periodic data processing)
- Webhook handlers (process incoming webhooks)

**Configuration:**
- Docker Compose setup (port 5678)
- PostgreSQL database for persistence
- Shared network with other services

**Database:**
- Type: PostgreSQL 16
- Schema: external_n8n
- Host: host.docker.internal:5432

**Quick Start:**
```bash
# Start n8n
pnpm n8n:start

# Stop n8n
pnpm n8n:stop

# Access
http://localhost:5678
```

**Integration with APIs:**
- n8n triggers Helix API endpoints via HTTP
- Helix calls n8n webhooks for automation
- Orchestrates multi-service workflows

**Example Webhook:**
```
http://localhost:5678/webhook/helix-trigger
```

**Data Persistence:**
- n8n_data volume - Workflow definitions, credentials
- external_n8n schema - Database tables

**Security (Production):**
- Use strong passwords
- Enable HTTPS
- Configure OAuth/SAML authentication
- Restrict network access
- Enable 2FA

**Documentation:**
- `external/n8n/README.md` - Complete documentation
- `external/n8n/SETUP.md` - Installation summary
- `external/n8n/WORKFLOW_SETUP.md` - Workflow setup guide
- `external/n8n/docker-compose.yml` - Docker configuration
- `external/n8n/.env.example` - Environment template

**Resources:**
- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)

### 2. Supabase - Backend-as-a-Service

**Purpose:** Self-hosted Supabase providing PostgreSQL database, authentication, storage, and real-time subscriptions.

**What is Supabase?**
Open-source Firebase alternative providing:
- PostgreSQL database with full SQL support
- User authentication with JWT tokens
- File storage with CDN
- Real-time WebSocket subscriptions
- Auto-generated REST and GraphQL APIs
- Row Level Security (RLS)

**Use Cases in Pravia:**
- User authentication (JWT-based auth)
- Primary data store for application data
- File storage (documents, attachments, media)
- Real-time data synchronization
- Admin API for user management

**Database Schemas:**

| Schema | Purpose | Used By |
|--------|---------|---------|
| `external_authentication` | User auth and profiles | Foundry API |
| `external_dataverse` | Business data | Flux API |
| `external_n8n` | Workflow automation | n8n |
| `public` | Supabase system tables | Supabase |

**Deployment Environments:**

| Environment | Project ID | URL |
|-------------|-----------|-----|
| Local | localhost | http://localhost:54321 |
| Development | ahanrwalkdrbbhlhjxzr | https://ahanrwalkdrbbhlhjxzr.supabase.co |
| Test | gurgyegmjqbisdhbvoww | https://gurgyegmjqbisdhbvoww.supabase.co |
| UAT | laorysvmqjaxatyzsgkj | https://laorysvmqjaxatyzsgkj.supabase.co |

**Quick Start:**
```bash
# Start Supabase locally
supabase start

# Access:
# - Studio: http://localhost:54323
# - API: http://localhost:54321
# - DB: postgresql://postgres:postgres@localhost:54322/postgres
```

**Integration with APIs:**

**Foundry API (Authentication):**
- Uses Supabase Admin SDK for user management
- Validates JWT tokens from Supabase Auth
- Manages user profiles in `external_authentication` schema

**Flux API (Data):**
- Connects to `external_dataverse` schema
- Manages business data (accounts, contacts, submissions)
- Uses Supabase connection pooling

**Frontend Applications:**
- Use Supabase Client SDK for authentication
- Direct database access via Supabase APIs
- Real-time subscriptions for live updates

**Email Configuration:**
- Uses AWS SES for email delivery
- Custom HTML templates in `templates/` directory
- Supports confirmation, invites, password recovery

**Email Templates:**
- `confirm.html` - Email confirmation
- `invite.html` - User invitation
- `magic_link.html` - Magic link login
- `email_change.html` - Email change confirmation
- `recovery.html` - Password recovery

**Security:**
- JWT-based authentication
- Refresh token rotation
- Row Level Security (RLS) policies
- API keys: `anon` (public) and `service_role` (private)

**Configuration Files:**
- `external/supabase/config.toml` - Main configuration (13KB)
- `external/supabase/.env` - Environment variables
- `external/supabase/templates/` - Email templates (5 files)

**Resources:**
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Self-Hosting Guide](https://supabase.com/docs/guides/self-hosting)

### Service Dependencies

**Dependency Graph:**
```
Frontend Apps (mule-vite)
    ↓
Supabase (Auth + Database)
    ↓
Backend APIs (Foundry, Flux)
    ↓
n8n (Workflow Automation)
```

**Network Communication:**
- Frontend → Supabase - Direct connection for auth and data
- APIs → Supabase - Database connections
- APIs → n8n - HTTP webhooks for workflow triggers
- n8n → APIs - HTTP requests for service orchestration

### Development Workflow

**Starting All External Services:**
```bash
# Start Supabase
supabase start

# Start n8n
pnpm n8n:start

# Verify services
curl http://localhost:54321/health  # Supabase
curl http://localhost:5678          # n8n
```

**Stopping Services:**
```bash
pnpm n8n:stop
supabase stop
```

### Best Practices

**n8n:**
- Export workflows regularly for version control
- Use environment variables for credentials
- Add error handling workflows
- Test in development before production
- Set up alerts for failed workflows

**Supabase:**
- Always use migrations for schema changes
- Enable RLS on tables with sensitive data
- Regular database backups
- Never expose `service_role` key to clients
- Use connection pooling for high traffic

**Documentation File:** `external/README.md`

---

## 📝 Change Log

| Date | Section | Description |
|------|---------|-------------|
| 2026-02-19 | Initial | Master document creation |
| 2026-02-19 | GitHub Configuration | Added CI/CD workflows documentation |
| 2026-02-19 | Husky | Added Git hooks manager documentation |
| 2026-02-19 | Kiro CLI | Added AI assistant configuration documentation |
| 2026-02-19 | APIs | Added Foundry and Flux API documentation |
| 2026-02-19 | Documentation | Added comprehensive docs/ folder documentation |
| 2026-02-19 | Packages | Added shared packages documentation (api-core, api-types, ui) |
| 2026-02-19 | External Services | Added n8n and Supabase documentation |
| 2026-02-19 | Scripts | Added generation and deployment scripts documentation |
| 2026-02-19 | Infrastructure | Added AWS, Azure, Docker, and K8s infrastructure documentation |
| 2026-02-19 | Development Tools | Added MCP servers, monitoring tools, and quickstart templates documentation |

---

## 📂 Documentation Files Index

### Root Level
- `DOCUMENTACION-COMPLETA.md` - This master document

### .github/
- `GITHUB-CONFIGURATION.md` - GitHub configuration overview
- `workflows/WORKFLOWS-OVERVIEW.md` - CI/CD workflows reference

### .husky/
- `HUSKY-CONFIGURATION.md` - Git hooks manager configuration
- `_/INTERNAL-FILES.md` - Husky internal files reference

### .kiro/
- `KIRO-CONFIGURATION.md` - Kiro CLI configuration and context
- `scripts/UTILITY-SCRIPTS.md` - Database utility scripts
- `context/frontend/FRONTEND-CONTEXT.md` - Frontend development guides
- `specs/ai-accelerator-platform/AI-PLATFORM-SPECS.md` - AI platform specifications

### api/
- `API-OVERVIEW.md` - API overview and architecture
- `flux/FLUX-API.md` - Flux API complete documentation
- `foundry/FOUNDRY-API.md` - Foundry API complete documentation

### apps/
- `mule-vite/MULE-VITE-APP.md` - Mule Vite application documentation
- `mule-vite/docs/DOCUMENTATION.md` - Technical guides
- `mule-vite/src/` - Source code documentation

### deploy/
- `api/API-DEPLOYMENT.md` - Unified API deployment system

### docs/
- `README.md` - Documentation overview and navigation guide
- `development/` - Development guidelines and best practices
- `getting-started/` - Quick start guides
- `infrastructure/` - Deployment and infrastructure management
- `reference/` - Technical reference materials
- `tools/` - AI-assisted development tools
- `_archive/` - Historical documentation

### packages/
- `README.md` - Shared packages overview
- `api-core/` - Backend core library documentation
  - `README.md` - Complete documentation
  - `DOCUMENTATION_PROVIDERS.md` - Provider setup guide
- `api-types/` - Shared types and API contracts
  - `CODEGEN.md` - Code generation guide
  - `SERVICE_FACTORY.md` - Service factory pattern
  - `MIGRATION.md` - Migration guide
  - `COMMON_INTERFACES.md` - Common interfaces
  - `FACTORY_PATTERN.md` - Factory pattern details
  - `SERVICE_SLICE_GENERATION.md` - Slice generation
- `ui/` - React component library
  - `README.md` - Main documentation
  - `THEME.md` - Theme system guide
  - `ROUTERLINK_CHANGES.md` - Router link changes
  - `docs/` - Implementation guides

### external/
- `README.md` - External services overview
- `n8n/` - Workflow automation platform
  - `README.md` - Complete documentation
  - `SETUP.md` - Installation summary
  - `WORKFLOW_SETUP.md` - Workflow setup guide
  - `docker-compose.yml` - Docker configuration
  - `.env.example` - Environment template
- `supabase/` - Backend-as-a-Service
  - `config.toml` - Main configuration (13KB)
  - `templates/` - Email templates (5 HTML files)

### scripts/
- `README.md` - Generation and deployment scripts overview
- `api/` - API generator (NestJS + Fastify)
  - `README.md` - API generator documentation
  - `base-api/` - API template
- `app/` - Frontend app generator (Vite + React)
  - `README.md` - App generator documentation
  - `base-app/` - App template
- `packages/` - Package deployment scripts
  - `README.md` - Deployment documentation
  - `deploy-config.env` - Deployment configuration
  - `deploy.sh` - Deployment wrapper
  - `deploy-to-git.sh` - Core deployment script

### infra/
- `README.md` - Infrastructure as Code overview
- `aws/cdk/` - AWS CDK stacks
  - `foundation-infra/README.md` - Foundation stack (DNS, SSL, Email, Storage)
  - `supabase-infra/README.md` - Supabase stack (EC2, VPC, monitoring)
  - `supabase-infra/README-MODULAR.md` - Modular architecture
- `azure/` - Azure Bicep templates
  - `README.md` - Azure infrastructure overview
  - `pravia-mule/README.md` - Main platform infrastructure
  - `pravia-mule/QUICKSTART.md` - Quick start guide
  - `pravia-mule/BICEP_UPDATES.md` - Bicep updates
  - `pravia-incidents/README.md` - Incidents infrastructure
- `compose/` - Docker Compose configurations
  - `docker-compose.dev.yml` - Development environment
  - `supabase/README.md` - Local Supabase setup
- `docker/` - Dockerfiles and compose files
- `k8s/` - Kubernetes manifests

### tools/
- `README.md` - Development tools overview
- `mcp/` - Model Context Protocol servers
  - `component-analyzer-mcp/README.md` - Component analysis and extraction
  - `component-analyzer-mcp/SETUP.md` - Setup guide
  - `install-mcps.sh` - Bulk installation script
- `monitoring/` - Monitoring and observability
  - `faro-agent/README.md` - Desktop monitoring app
  - `faro-agent/QUICKSTART.md` - Quick start guide
- `quickstart/` - Quick start templates
  - `base-api/` - Minimal NestJS API template

---

**Last updated:** 2026-02-19
