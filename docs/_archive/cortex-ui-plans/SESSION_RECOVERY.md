# Session Recovery - Cortex UI Implementation

**Date:** 2025-11-24  
**Last Updated:** 12:53 PM PST

---

## Current State

### ✅ Completed Work

#### Phase 1: Foundation (API & Data Layer) - PARTIALLY COMPLETE

**What's Built:**
1. **Cortex API Client Foundation** (`packages/ui/src/`)
   - `lib/cortex-api-setup.ts` - Factory for creating API instances
   - `lib/cortex-endpoints.ts` - Endpoint definitions
   - `lib/cortex-base-service.ts` - Base service for Cortex API (handles direct responses, not wrapped in `{body: T}`)
   - `types/cortex.ts` - Cortex-namespaced types (CortexWorkflow, CortexAgent, etc.)
   - `services/workflow.service.ts` - Complete CRUD for workflows and steps
   - `services/workflow.service.stories.tsx` - Storybook story with DataTable integration

2. **Cortex API Backend Configuration**
   - Added `DISABLE_AUTHENTICATION=true` setting for development
   - Added `http://localhost:6006` to CORS allowed origins for Storybook
   - Mock user with valid UUIDs for testing

3. **Architecture Decisions Made:**
   - **Pure library pattern** - No instances created in ui package
   - **Factory pattern** - Apps create their own API instances
   - **Service classes** - Extend CortexBaseService
   - **Stores in apps** - Apps use `createAppQueryStore` factory
   - **Namespaced types** - Avoid conflicts with existing ai-workflow types

**Key Files:**
```
packages/ui/src/
├── lib/
│   ├── cortex-api-setup.ts
│   ├── cortex-endpoints.ts
│   └── cortex-base-service.ts
├── services/
│   ├── workflow.service.ts
│   └── workflow.service.stories.tsx
└── types/
    └── cortex.ts

services/cortex/
├── app/
│   ├── config/settings.py (DISABLE_AUTHENTICATION added)
│   └── api/deps.py (conditional auth)
└── .env (DISABLE_AUTHENTICATION=true)
```

---

## What's Working

### Storybook Story
- **URL:** http://localhost:6006 → Services/Cortex/WorkflowService
- **Features:**
  - DataTable showing workflows
  - Create test workflow button
  - Delete selected workflows (external button workaround)
  - Search and filter tabs
  - Row selection and click handlers

### Cortex API
- **URL:** http://localhost:4005/api/v1/docs
- **Status:** Running with auth disabled
- **Command:** `cd services/cortex && poetry run uvicorn app.main:app --reload`

---

## Known Issues

### DataTable Delete Button
- **Issue:** DataTable has hardcoded delete button that only logs to console
- **Workaround:** Added external delete button that actually calls API
- **TODO:** Update DataTable component to use `actions` prop properly

---

## ✅ Completed: Agent (Service + Views)

**Files Created:**
- `services/agent.service.ts` - CRUD operations
- `services/agent.service.stories.tsx` - Service testing
- `views/cortex/agents/agent-list-view.tsx` - List view with DataTable
- `views/cortex/agents/agent-form-view.tsx` - Create/Edit form
- `views/cortex/agents/agent-list-view.stories.tsx` - List view story
- `views/cortex/agents/agent-form-view.stories.tsx` - Form view story
- `types/cortex.ts` - Added Agent types
- `lib/cortex-endpoints.ts` - Added Agent endpoints

**Storybook URLs:**
- Services/Cortex/AgentService
- Views/Cortex/Agents/AgentListView
- Views/Cortex/Agents/AgentFormView

---

## What's Missing

### Services to Create (8 remaining)

Based on Cortex API OpenAPI spec at http://localhost:4005/api/v1/openapi.json:

1. **AgentService** - `/agents`
   - List, Create, Get, Update, Delete

2. **ToolService** - `/tools`
   - List, Create, Get, Update, Delete

3. **PromptService** - `/prompts`
   - List, Create, Get, Update, Delete

4. **StepTemplateService** - `/step-templates`
   - List, Create, Get, Update, Delete

5. **KnowledgeBaseService** - `/knowledge-bases`
   - List, Create, Get, Update, Delete

6. **DocumentService** - `/knowledge-bases/{kb_id}/documents`
   - List, Upload, Get, Delete
   - Search endpoint

7. **JobService** - `/jobs`
   - List, Create, Get, Get Steps
   - Cancel, Resume actions

8. **EventService** - `/events`
   - List definitions, Create, Get, Update, Delete
   - Ingest events

9. **AgentExecutionService** - `/agent-execution`
   - Execute agent

### For Each Service Need:
- Service class extending CortexBaseService
- Types in `types/cortex.ts`
- Endpoints in `lib/cortex-endpoints.ts`
- Storybook story with DataTable
- Export from `index.ts`

---

## Next Steps (In Order)

### Option A: Complete All Services (Recommended)
1. Create remaining 9 services (~4-6 hours)
2. Add Storybook stories for each
3. Test all CRUD operations
4. Set up Cortex API in consuming app (mule-client)

### Option B: Start Workflow Builder UI
1. Extend WorkflowFlow for edit mode
2. Create step configuration flyout
3. Build workflow builder container

---

## Important Patterns to Follow

### Service Pattern
```typescript
// packages/ui/src/services/example.service.ts
import { CortexBaseService } from '../lib/cortex-base-service';
import { cortexEndpoints } from '../lib/cortex-endpoints';

export class ExampleService extends CortexBaseService {
  async list(params?: any): Promise<CortexPaginatedResponse<CortexExample>> {
    return this.get(cortexEndpoints.examples.list, params);
  }
  
  async get(id: string): Promise<CortexExample> {
    return this.get(cortexEndpoints.examples.details(id));
  }
  
  async create(data: CreateCortexExampleRequest): Promise<CortexExample> {
    return this.post(cortexEndpoints.examples.create, data);
  }
  
  async update(id: string, data: UpdateCortexExampleRequest): Promise<CortexExample> {
    return this.put(cortexEndpoints.examples.update(id), data);
  }
  
  async delete(id: string): Promise<void> {
    return this.delete(cortexEndpoints.examples.delete(id));
  }
}
```

### Storybook Story Pattern
```typescript
// packages/ui/src/services/example.service.stories.tsx
import { DataTable } from '../components/data-display/data-table';
import { ExampleService } from './example.service';
import { ApiManager } from '../lib/api-manager';
import { createHttpClient } from '../lib/http-client';
import { createCortexApiConfig } from '../lib/cortex-api-setup';

const apiManager = new ApiManager(createHttpClient);
const cortexApi = apiManager.createInstance('cortex', 
  createCortexApiConfig({ baseURL: 'http://localhost:4005/api/v1' })
);
const exampleService = new ExampleService(cortexApi);

// Use DataTable with columns, search, filters, etc.
```

### App Setup Pattern (Not Yet Implemented)
```typescript
// apps/mule-client/src/lib/cortex-api-setup.ts
import { ApiManager, createHttpClient, createCortexApiConfig } from '@asyml8/ui';
import { supabase } from './supabase';

const apiManager = new ApiManager(createHttpClient);

export const cortexApi = apiManager.createInstance('cortex', 
  createCortexApiConfig({
    baseURL: process.env.NEXT_PUBLIC_CORTEX_API_URL ?? 'http://localhost:4005/api/v1',
    getAuthToken: async () => {
      const { data: { session } } = await supabase.auth.getSession();
      return session?.access_token ?? null;
    },
  })
);

// apps/mule-client/src/services/workflow.service.ts
import { WorkflowService } from '@asyml8/ui';
import { cortexApi } from '../lib/cortex-api-setup';

export const workflowService = new WorkflowService(cortexApi);

// apps/mule-client/src/stores/workflows.store.ts
import { createAppQueryStore, defaultQueryConfig } from '@asyml8/ui';
import { workflowService } from '../services/workflow.service';

export const workflowsStore = createAppQueryStore(['workflows']);

export const workflowsQueryConfig = {
  queryFn: () => workflowService.listWorkflows({ limit: 100 }),
  ...defaultQueryConfig,
};
```

---

## Commands to Resume

### Start Cortex API
```bash
cd services/cortex
poetry run uvicorn app.main:app --reload
```

### Start Storybook
```bash
cd packages/ui
npm run storybook
```

### Build UI Package
```bash
cd packages/ui
npm run build
```

---

## Git Status

**Last Commits:**
- `aeaf7d5d8` - fix(ui): add external delete button as workaround for DataTable
- `fc3d69caa` - fix(ui): handle 204 No Content in CortexBaseService delete
- `7b4ba3e64` - feat(ui): integrate DataTable in Cortex workflow story
- `9eeda691c` - feat(cortex): add DISABLE_AUTHENTICATION setting for development
- `449612c55` - fix(ui): create CortexBaseService for direct API responses
- `8d2e6f30e` - feat(ui): add Cortex API client foundation (Phase 1)

**Branch:** main

**Uncommitted Changes:** None (all work committed)

---

## Questions to Ask When Resuming

1. Should we complete all 9 remaining services before moving to UI?
2. Or start building Workflow Builder UI with just WorkflowService?
3. Do we need to update the implementation plan document?

---

## Reference Documents

- `/services/cortex/docs/ui/01-workflow-builder-screen.md` - Screen spec
- `/services/cortex/docs/ui/workflow-builder-implementation-plan.md` - Original plan (needs updating)
- `/services/cortex/docs/ui/phase-1-technical-plan-updated.md` - Phase 1 details

---

## Environment Variables

### Cortex API (.env)
```bash
DISABLE_AUTHENTICATION=true
ALLOWED_ORIGINS=["http://localhost:3000","http://localhost:6006","http://localhost:4005"]
```

---

## Testing Checklist

When resuming, verify:
- [ ] Cortex API running on http://localhost:4005
- [ ] Storybook running on http://localhost:6006
- [ ] Can create workflows in Storybook
- [ ] Can delete workflows in Storybook
- [ ] No CORS errors in browser console
- [ ] Authentication disabled (no 401 errors)

---

## Key Decisions Made

1. **No hooks in ui package** - Apps create stores using factory
2. **CortexBaseService** - Handles direct API responses (not wrapped in `{body: T}`)
3. **Namespaced types** - Cortex* prefix to avoid conflicts
4. **Pure library** - No instances, only factories
5. **Storybook for testing** - Each service gets a story with DataTable
6. **Auth bypass for dev** - DISABLE_AUTHENTICATION setting

---

## Contact Points

- Cortex API docs: http://localhost:4005/api/v1/docs
- Storybook: http://localhost:6006
- OpenAPI spec: http://localhost:4005/api/v1/openapi.json
