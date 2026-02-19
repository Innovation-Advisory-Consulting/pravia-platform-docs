# Phase 1: Foundation (API & Data Layer) - Updated

## Goal
Create Cortex API client following the existing mule-client pattern using ApiManager, BaseService, and Axios.

---

## Step 1.1: Create Cortex API Setup

### File Structure
```
packages/ui/src/
├── lib/
│   ├── cortex-api-setup.ts   # Cortex API instance configuration
│   └── cortex-endpoints.ts   # Endpoint definitions
├── services/
│   ├── workflow.service.ts   # Workflow CRUD
│   ├── agent.service.ts      # Agent operations
│   ├── tool.service.ts       # Tool operations
│   └── prompt.service.ts     # Prompt operations
└── types/
    └── cortex.ts             # Cortex API types
```

### Implementation

#### `packages/ui/src/types/cortex.ts`
```typescript
// Workflow types
export type WorkflowStatus = 'draft' | 'published';

export interface Workflow {
  id: string;
  name: string;
  description?: string;
  status: WorkflowStatus;
  created_at: string;
  updated_at: string;
  tenant_id: string;
  created_by: string;
}

export interface WorkflowStep {
  id: string;
  workflow_id: string;
  name: string;
  step_index: number;
  agent_id?: string;
  tool_ids?: string[];
  prompt_ids?: string[];
  timeout_seconds?: number;
  config?: Record<string, any>;
}

export interface CreateWorkflowRequest {
  name: string;
  description?: string;
}

export interface UpdateWorkflowRequest {
  name?: string;
  description?: string;
  status?: WorkflowStatus;
}

export interface CreateStepRequest {
  name: string;
  step_index: number;
  agent_id?: string;
  tool_ids?: string[];
  prompt_ids?: string[];
  timeout_seconds?: number;
  config?: Record<string, any>;
}

export interface UpdateStepRequest {
  name?: string;
  agent_id?: string;
  tool_ids?: string[];
  prompt_ids?: string[];
  timeout_seconds?: number;
  config?: Record<string, any>;
}

// Agent types
export interface Agent {
  id: string;
  name: string;
  description?: string;
  category: string;
  model_name: string;
  temperature: number;
  max_tokens: number;
  tool_permissions: string[];
}

// Tool types
export interface Tool {
  id: string;
  name: string;
  description?: string;
  category: string;
  input_schema: Record<string, any>;
  output_schema: Record<string, any>;
}

// Prompt types
export interface Prompt {
  id: string;
  name: string;
  content: string;
  category: string;
  variables: Record<string, string>;
}

// Paginated response
export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  skip: number;
  limit: number;
}
```

#### `packages/ui/src/lib/cortex-endpoints.ts`
```typescript
export const cortexEndpoints = {
  workflows: {
    list: '/workflows',
    details: (id: string) => `/workflows/${id}`,
    create: '/workflows',
    update: (id: string) => `/workflows/${id}`,
    delete: (id: string) => `/workflows/${id}`,
    steps: {
      list: (workflowId: string) => `/workflows/${workflowId}/steps`,
      create: (workflowId: string) => `/workflows/${workflowId}/steps`,
      update: (workflowId: string, stepId: string) => 
        `/workflows/${workflowId}/steps/${stepId}`,
      delete: (workflowId: string, stepId: string) => 
        `/workflows/${workflowId}/steps/${stepId}`,
    },
  },
  agents: {
    list: '/agents',
    details: (id: string) => `/agents/${id}`,
  },
  tools: {
    list: '/tools',
    details: (id: string) => `/tools/${id}`,
  },
  prompts: {
    list: '/prompts',
    details: (id: string) => `/prompts/${id}`,
  },
  jobs: {
    list: '/jobs',
    details: (id: string) => `/jobs/${id}`,
    create: '/jobs',
  },
};
```

#### `packages/ui/src/lib/cortex-api-setup.ts`
```typescript
import { ApiManager, createHttpClient } from '@asyml8/ui';

// Create manager instance (reuse existing from ui package)
export const cortexApiManager = new ApiManager(createHttpClient);

// Configure Cortex API instance
export const cortexApi = cortexApiManager.createInstance('cortex', {
  baseURL: process.env.NEXT_PUBLIC_CORTEX_API_URL ?? 'http://localhost:4005/api/v1',
  getAuthToken: async () => {
    // TODO: Integrate with your auth system (Supabase or other)
    // For now, return null (no auth)
    return null;
  },
  onError: (error) => {
    // TODO: Integrate with notification system
    console.error('Cortex API Error:', error);
  },
});
```

---

### Services Implementation

#### `packages/ui/src/services/workflow.service.ts`
```typescript
import { BaseService } from '@asyml8/ui';
import { cortexApi } from '../lib/cortex-api-setup';
import { cortexEndpoints } from '../lib/cortex-endpoints';
import type {
  Workflow,
  WorkflowStep,
  CreateWorkflowRequest,
  UpdateWorkflowRequest,
  CreateStepRequest,
  UpdateStepRequest,
  PaginatedResponse,
} from '../types/cortex';

class WorkflowService extends BaseService {
  // Workflows
  async listWorkflows(params?: {
    status?: string;
    skip?: number;
    limit?: number;
  }): Promise<PaginatedResponse<Workflow>> {
    return this.get(cortexEndpoints.workflows.list, params);
  }

  async getWorkflow(id: string): Promise<Workflow> {
    return this.get(cortexEndpoints.workflows.details(id));
  }

  async createWorkflow(data: CreateWorkflowRequest): Promise<Workflow> {
    return this.post(cortexEndpoints.workflows.create, data);
  }

  async updateWorkflow(
    id: string,
    data: UpdateWorkflowRequest
  ): Promise<Workflow> {
    return this.put(cortexEndpoints.workflows.update(id), data);
  }

  async deleteWorkflow(id: string): Promise<void> {
    return this.delete(cortexEndpoints.workflows.delete(id));
  }

  // Workflow Steps
  async listSteps(workflowId: string): Promise<WorkflowStep[]> {
    return this.list(cortexEndpoints.workflows.steps.list(workflowId));
  }

  async createStep(
    workflowId: string,
    data: CreateStepRequest
  ): Promise<WorkflowStep> {
    return this.post(cortexEndpoints.workflows.steps.create(workflowId), data);
  }

  async updateStep(
    workflowId: string,
    stepId: string,
    data: UpdateStepRequest
  ): Promise<WorkflowStep> {
    return this.put(
      cortexEndpoints.workflows.steps.update(workflowId, stepId),
      data
    );
  }

  async deleteStep(workflowId: string, stepId: string): Promise<void> {
    return this.delete(
      cortexEndpoints.workflows.steps.delete(workflowId, stepId)
    );
  }
}

export const workflowService = new WorkflowService(cortexApi);
```

#### `packages/ui/src/services/agent.service.ts`
```typescript
import { BaseService } from '@asyml8/ui';
import { cortexApi } from '../lib/cortex-api-setup';
import { cortexEndpoints } from '../lib/cortex-endpoints';
import type { Agent, PaginatedResponse } from '../types/cortex';

class AgentService extends BaseService {
  async listAgents(params?: {
    skip?: number;
    limit?: number;
  }): Promise<PaginatedResponse<Agent>> {
    return this.get(cortexEndpoints.agents.list, params);
  }

  async getAgent(id: string): Promise<Agent> {
    return this.get(cortexEndpoints.agents.details(id));
  }
}

export const agentService = new AgentService(cortexApi);
```

#### `packages/ui/src/services/tool.service.ts`
```typescript
import { BaseService } from '@asyml8/ui';
import { cortexApi } from '../lib/cortex-api-setup';
import { cortexEndpoints } from '../lib/cortex-endpoints';
import type { Tool, PaginatedResponse } from '../types/cortex';

class ToolService extends BaseService {
  async listTools(params?: {
    skip?: number;
    limit?: number;
  }): Promise<PaginatedResponse<Tool>> {
    return this.get(cortexEndpoints.tools.list, params);
  }

  async getTool(id: string): Promise<Tool> {
    return this.get(cortexEndpoints.tools.details(id));
  }
}

export const toolService = new ToolService(cortexApi);
```

#### `packages/ui/src/services/prompt.service.ts`
```typescript
import { BaseService } from '@asyml8/ui';
import { cortexApi } from '../lib/cortex-api-setup';
import { cortexEndpoints } from '../lib/cortex-endpoints';
import type { Prompt, PaginatedResponse } from '../types/cortex';

class PromptService extends BaseService {
  async listPrompts(params?: {
    skip?: number;
    limit?: number;
  }): Promise<PaginatedResponse<Prompt>> {
    return this.get(cortexEndpoints.prompts.list, params);
  }

  async getPrompt(id: string): Promise<Prompt> {
    return this.get(cortexEndpoints.prompts.details(id));
  }
}

export const promptService = new PromptService(cortexApi);
```

---

## Step 1.2: Create React Query Hooks & Stores

### File Structure
```
packages/ui/src/
├── hooks/
│   ├── use-workflows.ts       # Workflow hooks (if needed for complex logic)
│   └── ...
└── stores/
    ├── workflows.store.ts     # Workflow query store
    ├── agents.store.ts        # Agent query store
    ├── tools.store.ts         # Tool query store
    └── prompts.store.ts       # Prompt query store
```

### Implementation

#### `packages/ui/src/stores/workflows.store.ts`
```typescript
import { createAppQueryStore, defaultQueryConfig } from '@asyml8/ui';
import { workflowService } from '../services/workflow.service';

// Create shared workflows store
export const workflowsStore = createAppQueryStore(['workflows']);

// Query configuration for workflows list
export const workflowsQueryConfig = {
  queryFn: () => workflowService.listWorkflows({ limit: 100 }),
  ...defaultQueryConfig,
};

// Create store for single workflow
export const createWorkflowStore = (id: string) => 
  createAppQueryStore(['workflows', id]);

// Query configuration for single workflow
export const workflowQueryConfig = (id: string) => ({
  queryFn: () => workflowService.getWorkflow(id),
  ...defaultQueryConfig,
});

// Create store for workflow steps
export const createWorkflowStepsStore = (workflowId: string) =>
  createAppQueryStore(['workflows', workflowId, 'steps']);

// Query configuration for workflow steps
export const workflowStepsQueryConfig = (workflowId: string) => ({
  queryFn: () => workflowService.listSteps(workflowId),
  ...defaultQueryConfig,
});
```

#### `packages/ui/src/stores/agents.store.ts`
```typescript
import { createAppQueryStore, defaultQueryConfig } from '@asyml8/ui';
import { agentService } from '../services/agent.service';

export const agentsStore = createAppQueryStore(['agents']);

export const agentsQueryConfig = {
  queryFn: () => agentService.listAgents({ limit: 100 }),
  ...defaultQueryConfig,
  staleTime: Infinity, // Agents don't change often
};
```

#### `packages/ui/src/stores/tools.store.ts`
```typescript
import { createAppQueryStore, defaultQueryConfig } from '@asyml8/ui';
import { toolService } from '../services/tool.service';

export const toolsStore = createAppQueryStore(['tools']);

export const toolsQueryConfig = {
  queryFn: () => toolService.listTools({ limit: 100 }),
  ...defaultQueryConfig,
  staleTime: Infinity, // Tools don't change often
};
```

#### `packages/ui/src/stores/prompts.store.ts`
```typescript
import { createAppQueryStore, defaultQueryConfig } from '@asyml8/ui';
import { promptService } from '../services/prompt.service';

export const promptsStore = createAppQueryStore(['prompts']);

export const promptsQueryConfig = {
  queryFn: () => promptService.listPrompts({ limit: 100 }),
  ...defaultQueryConfig,
};
```

### Usage in Components

#### Using Query Store Directly
```typescript
'use client';

import { workflowsStore, workflowsQueryConfig } from '../stores/workflows.store';

function WorkflowList() {
  // Use the store's query hook
  const { data, isLoading, error, refetch } = workflowsStore.useQuery(workflowsQueryConfig);

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      <h1>Workflows: {data?.total}</h1>
      <button onClick={() => refetch()}>Refresh</button>
      {data?.items.map(workflow => (
        <div key={workflow.id}>{workflow.name}</div>
      ))}
    </div>
  );
}
```

#### Using Store for Non-Reactive Access
```typescript
// Get cached data without subscribing
const workflows = workflowsStore.getData();

// Set data in cache
workflowsStore.setData(newData);

// Invalidate to trigger refetch
workflowsStore.invalidate();
```

#### Using Mutations with Store Invalidation
```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { workflowService } from '../services/workflow.service';
import { workflowsStore } from '../stores/workflows.store';

function CreateWorkflowButton() {
  const queryClient = useQueryClient();

  const createMutation = useMutation({
    mutationFn: (data: CreateWorkflowRequest) => 
      workflowService.createWorkflow(data),
    onSuccess: () => {
      // Invalidate the workflows list
      workflowsStore.invalidate();
    },
  });

  return (
    <button 
      onClick={() => createMutation.mutate({ name: 'New Workflow' })}
      disabled={createMutation.isPending}
    >
      {createMutation.isPending ? 'Creating...' : 'Create Workflow'}
    </button>
  );
}
```

---

## Step 1.2: Create React Query Hooks (Optional)

### Implementation

#### `packages/ui/src/hooks/use-workflows.ts`
```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { workflowService } from '../services/workflow.service';
import type {
  CreateWorkflowRequest,
  UpdateWorkflowRequest,
  CreateStepRequest,
  UpdateStepRequest,
} from '../types/cortex';

// Query keys
export const workflowKeys = {
  all: ['workflows'] as const,
  lists: () => [...workflowKeys.all, 'list'] as const,
  list: (filters: string) => [...workflowKeys.lists(), filters] as const,
  details: () => [...workflowKeys.all, 'detail'] as const,
  detail: (id: string) => [...workflowKeys.details(), id] as const,
  steps: (id: string) => [...workflowKeys.detail(id), 'steps'] as const,
};

// Fetch workflows
export function useWorkflows(params?: { status?: string }) {
  return useQuery({
    queryKey: workflowKeys.list(JSON.stringify(params || {})),
    queryFn: () => workflowService.listWorkflows(params),
  });
}

// Fetch single workflow
export function useWorkflow(id: string) {
  return useQuery({
    queryKey: workflowKeys.detail(id),
    queryFn: () => workflowService.getWorkflow(id),
    enabled: !!id,
  });
}

// Fetch workflow steps
export function useWorkflowSteps(workflowId: string) {
  return useQuery({
    queryKey: workflowKeys.steps(workflowId),
    queryFn: () => workflowService.listSteps(workflowId),
    enabled: !!workflowId,
  });
}

// Create workflow
export function useCreateWorkflow() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateWorkflowRequest) =>
      workflowService.createWorkflow(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: workflowKeys.lists() });
    },
  });
}

// Update workflow
export function useUpdateWorkflow() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateWorkflowRequest }) =>
      workflowService.updateWorkflow(id, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: workflowKeys.detail(variables.id),
      });
      queryClient.invalidateQueries({ queryKey: workflowKeys.lists() });
    },
  });
}

// Delete workflow
export function useDeleteWorkflow() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => workflowService.deleteWorkflow(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: workflowKeys.lists() });
    },
  });
}

// Create step
export function useCreateStep(workflowId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateStepRequest) =>
      workflowService.createStep(workflowId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: workflowKeys.steps(workflowId),
      });
      queryClient.invalidateQueries({
        queryKey: workflowKeys.detail(workflowId),
      });
    },
  });
}

// Update step
export function useUpdateStep(workflowId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ stepId, data }: { stepId: string; data: UpdateStepRequest }) =>
      workflowService.updateStep(workflowId, stepId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: workflowKeys.steps(workflowId),
      });
    },
  });
}

// Delete step
export function useDeleteStep(workflowId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (stepId: string) =>
      workflowService.deleteStep(workflowId, stepId),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: workflowKeys.steps(workflowId),
      });
    },
  });
}
```

#### `packages/ui/src/hooks/use-agents.ts`
```typescript
import { useQuery } from '@tanstack/react-query';
import { agentService } from '../services/agent.service';

export const agentKeys = {
  all: ['agents'] as const,
  lists: () => [...agentKeys.all, 'list'] as const,
};

export function useAgents() {
  return useQuery({
    queryKey: agentKeys.lists(),
    queryFn: () => agentService.listAgents({ limit: 100 }),
  });
}
```

#### `packages/ui/src/hooks/use-tools.ts`
```typescript
import { useQuery } from '@tanstack/react-query';
import { toolService } from '../services/tool.service';

export const toolKeys = {
  all: ['tools'] as const,
  lists: () => [...toolKeys.all, 'list'] as const,
};

export function useTools() {
  return useQuery({
    queryKey: toolKeys.lists(),
    queryFn: () => toolService.listTools({ limit: 100 }),
  });
}
```

#### `packages/ui/src/hooks/use-prompts.ts`
```typescript
import { useQuery } from '@tanstack/react-query';
import { promptService } from '../services/prompt.service';

export const promptKeys = {
  all: ['prompts'] as const,
  lists: () => [...promptKeys.all, 'list'] as const,
};

export function usePrompts() {
  return useQuery({
    queryKey: promptKeys.lists(),
    queryFn: () => promptService.listPrompts({ limit: 100 }),
  });
}
```

---

## Step 1.3: Export from UI Package

### Update `packages/ui/src/index.ts`

Add Cortex API exports so consuming apps can use them:

```typescript
// Existing exports...
export * from './lib/api-manager';
export * from './lib/base-service';
export * from './lib/http-client';
// ... other exports

// Cortex API exports (NEW)
export * from './lib/cortex-api-setup';
export * from './lib/cortex-endpoints';
export * from './services/workflow.service';
export * from './services/agent.service';
export * from './services/tool.service';
export * from './services/prompt.service';
export * from './stores/workflows.store';
export * from './stores/agents.store';
export * from './stores/tools.store';
export * from './stores/prompts.store';
export * from './types/cortex';
```

### Usage in Consuming App

Now any app can use Cortex API:

```typescript
// In apps/mule-client or apps/automation-app
import {
  workflowsStore,
  workflowsQueryConfig,
  workflowService,
  type Workflow,
} from '@asyml8/ui';

function MyComponent() {
  const { data, isLoading } = workflowsStore.useQuery(workflowsQueryConfig);
  
  // ... use data
}
```

---

## Provider Setup (Already Exists)

### Query Provider is Already Configured

The `QueryProvider` is already set up in the consuming app (e.g., mule-client):

**Location:** `apps/mule-client/src/providers/query-provider.tsx`

```typescript
'use client';

import { useState } from 'react';
import { useInitQueryStore } from '@asyml8/ui';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

export function QueryProvider({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
            gcTime: 5 * 60 * 1000,
            retry: 1,
            refetchOnWindowFocus: false,
          },
        },
      })
  );

  return (
    <QueryClientProvider client={queryClient}>
      <QueryStoreInitializer />
      {children}
    </QueryClientProvider>
  );
}

function QueryStoreInitializer() {
  useInitQueryStore(); // Initializes the query store from @asyml8/ui
  return null;
}
```

### Root Layout Already Wraps App

**Location:** `apps/mule-client/src/app/layout.tsx`

```typescript
export default async function RootLayout({ children }: RootLayoutProps) {
  return (
    <html>
      <body>
        <AuthProvider>
          <SettingsProvider>
            <ThemeProvider>
              <QueryProvider>  {/* ← Already here */}
                <I18nProvider>
                  <CustomSnackbarProvider>
                    {children}
                  </CustomSnackbarProvider>
                </I18nProvider>
              </QueryProvider>
            </ThemeProvider>
          </SettingsProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
```

### What This Means for Cortex API

**No additional provider setup needed!**

Your Cortex stores and services will automatically work because:
1. ✅ `QueryProvider` is already wrapping the app
2. ✅ `useInitQueryStore()` is already called
3. ✅ Query client is already configured
4. ✅ All stores created with `createAppQueryStore` will work

**You just need to:**
1. Create Cortex API instance in `packages/ui`
2. Create services in `packages/ui`
3. Create stores in `packages/ui`
4. Export them from `packages/ui/src/index.ts`
5. Import and use in any app (mule-client, new automation app, etc.)

---

## Environment Setup

### Add to `.env.local`
```bash
NEXT_PUBLIC_CORTEX_API_URL=http://localhost:4005/api/v1
```

---

## Key Differences from Original Plan

### ✅ Advantages of This Approach:
1. **Consistent with existing codebase** - Uses same patterns as mule-client
2. **Reuses existing infrastructure** - ApiManager, BaseService, auth interceptors
3. **Less code to write** - BaseService handles common CRUD operations
4. **Centralized error handling** - Already configured in createHttpClient
5. **Auth integration ready** - Just plug in getAuthToken function

### 📝 Notes:
- Cortex API returns data directly (not wrapped in `{ body: T }`)
- May need to adjust BaseService methods or create CortexBaseService
- Auth integration depends on your auth system (Supabase, etc.)

---

## Testing Step 1.1 & 1.2

```typescript
// Test in a component
function TestComponent() {
  const { data: workflows, isLoading } = useWorkflows();
  const createWorkflow = useCreateWorkflow();

  if (isLoading) return <div>Loading...</div>;

  return (
    <div>
      <h1>Workflows: {workflows?.total}</h1>
      <button
        onClick={() => createWorkflow.mutate({ name: 'Test Workflow' })}
      >
        Create Workflow
      </button>
    </div>
  );
}
```

---

## Acceptance Criteria

### Step 1.1 Complete When:
- [ ] Cortex API instance configured
- [ ] All services created (workflow, agent, tool, prompt)
- [ ] Endpoints defined
- [ ] Types defined
- [ ] Can make successful API call to Cortex backend

### Step 1.2 Complete When:
- [ ] All query stores created (workflows, agents, tools, prompts)
- [ ] Query configurations defined with proper staleTime
- [ ] Store methods work (getData, setData, invalidate)
- [ ] Can fetch data using store.useQuery()
- [ ] Mutations properly invalidate stores
- [ ] Can access cached data non-reactively

---

## Next Steps

1. Verify Cortex API response format matches BaseService expectations
2. If needed, create custom CortexBaseService
3. Integrate auth token retrieval
4. Test all CRUD operations
5. Move to Phase 2: Editable Canvas
