# Phase 1: Foundation (API & Data Layer)

## Goal
Create a robust API client and React Query hooks to communicate with Cortex API.

---

## Step 1.1: Create Cortex API Client

### File Structure
```
packages/ui/src/
├── api/
│   ├── cortex-client.ts       # Main API client class
│   ├── types.ts               # API request/response types
│   └── config.ts              # API configuration
```

### Implementation

#### `packages/ui/src/api/config.ts`
```typescript
export const API_CONFIG = {
  baseURL: process.env.NEXT_PUBLIC_CORTEX_API_URL || 'http://localhost:4005',
  apiVersion: '/api/v1',
  timeout: 30000,
};

export function getApiUrl(path: string): string {
  return `${API_CONFIG.baseURL}${API_CONFIG.apiVersion}${path}`;
}
```

#### `packages/ui/src/api/types.ts`
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

// Error response
export interface ApiError {
  detail: string;
  status_code: number;
}
```

#### `packages/ui/src/api/cortex-client.ts`
```typescript
import { getApiUrl } from './config';
import type {
  Workflow,
  WorkflowStep,
  CreateWorkflowRequest,
  UpdateWorkflowRequest,
  CreateStepRequest,
  UpdateStepRequest,
  Agent,
  Tool,
  Prompt,
  PaginatedResponse,
  ApiError,
} from './types';

export class CortexApiClient {
  private async request<T>(
    path: string,
    options?: RequestInit
  ): Promise<T> {
    const url = getApiUrl(path);
    
    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
    });

    if (!response.ok) {
      const error: ApiError = await response.json();
      throw new Error(error.detail || 'API request failed');
    }

    return response.json();
  }

  // Workflows
  async getWorkflows(params?: {
    status?: string;
    skip?: number;
    limit?: number;
  }): Promise<PaginatedResponse<Workflow>> {
    const searchParams = new URLSearchParams();
    if (params?.status) searchParams.set('status', params.status);
    if (params?.skip) searchParams.set('skip', params.skip.toString());
    if (params?.limit) searchParams.set('limit', params.limit.toString());
    
    const query = searchParams.toString();
    return this.request(`/workflows${query ? `?${query}` : ''}`);
  }

  async getWorkflow(id: string): Promise<Workflow> {
    return this.request(`/workflows/${id}`);
  }

  async createWorkflow(data: CreateWorkflowRequest): Promise<Workflow> {
    return this.request('/workflows', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updateWorkflow(
    id: string,
    data: UpdateWorkflowRequest
  ): Promise<Workflow> {
    return this.request(`/workflows/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async deleteWorkflow(id: string): Promise<void> {
    return this.request(`/workflows/${id}`, {
      method: 'DELETE',
    });
  }

  // Workflow Steps
  async getWorkflowSteps(workflowId: string): Promise<WorkflowStep[]> {
    return this.request(`/workflows/${workflowId}/steps`);
  }

  async createStep(
    workflowId: string,
    data: CreateStepRequest
  ): Promise<WorkflowStep> {
    return this.request(`/workflows/${workflowId}/steps`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updateStep(
    workflowId: string,
    stepId: string,
    data: UpdateStepRequest
  ): Promise<WorkflowStep> {
    return this.request(`/workflows/${workflowId}/steps/${stepId}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async deleteStep(workflowId: string, stepId: string): Promise<void> {
    return this.request(`/workflows/${workflowId}/steps/${stepId}`, {
      method: 'DELETE',
    });
  }

  // Agents
  async getAgents(params?: {
    skip?: number;
    limit?: number;
  }): Promise<PaginatedResponse<Agent>> {
    const searchParams = new URLSearchParams();
    if (params?.skip) searchParams.set('skip', params.skip.toString());
    if (params?.limit) searchParams.set('limit', params.limit.toString());
    
    const query = searchParams.toString();
    return this.request(`/agents${query ? `?${query}` : ''}`);
  }

  // Tools
  async getTools(params?: {
    skip?: number;
    limit?: number;
  }): Promise<PaginatedResponse<Tool>> {
    const searchParams = new URLSearchParams();
    if (params?.skip) searchParams.set('skip', params.skip.toString());
    if (params?.limit) searchParams.set('limit', params.limit.toString());
    
    const query = searchParams.toString();
    return this.request(`/tools${query ? `?${query}` : ''}`);
  }

  // Prompts
  async getPrompts(params?: {
    skip?: number;
    limit?: number;
  }): Promise<PaginatedResponse<Prompt>> {
    const searchParams = new URLSearchParams();
    if (params?.skip) searchParams.set('skip', params.skip.toString());
    if (params?.limit) searchParams.set('limit', params.limit.toString());
    
    const query = searchParams.toString();
    return this.request(`/prompts${query ? `?${query}` : ''}`);
  }
}

// Singleton instance
export const cortexApi = new CortexApiClient();
```

### Testing Step 1.1

Create test file: `packages/ui/src/api/__tests__/cortex-client.test.ts`

```typescript
import { cortexApi } from '../cortex-client';

describe('CortexApiClient', () => {
  beforeEach(() => {
    global.fetch = jest.fn();
  });

  it('should fetch workflows', async () => {
    const mockResponse = {
      items: [{ id: '1', name: 'Test Workflow' }],
      total: 1,
      skip: 0,
      limit: 10,
    };

    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: async () => mockResponse,
    });

    const result = await cortexApi.getWorkflows();
    expect(result).toEqual(mockResponse);
  });

  it('should create workflow', async () => {
    const mockWorkflow = { id: '1', name: 'New Workflow' };

    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: async () => mockWorkflow,
    });

    const result = await cortexApi.createWorkflow({ name: 'New Workflow' });
    expect(result).toEqual(mockWorkflow);
  });

  it('should handle errors', async () => {
    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: false,
      json: async () => ({ detail: 'Not found', status_code: 404 }),
    });

    await expect(cortexApi.getWorkflow('invalid')).rejects.toThrow('Not found');
  });
});
```

**Acceptance Criteria:**
- ✅ All API methods defined
- ✅ Type-safe request/response
- ✅ Error handling works
- ✅ Tests pass

---

## Step 1.2: Create React Query Hooks

### File Structure
```
packages/ui/src/
├── hooks/
│   ├── use-workflows.ts       # Workflow hooks
│   ├── use-workflow-steps.ts  # Step hooks
│   ├── use-agents.ts          # Agent hooks
│   ├── use-tools.ts           # Tool hooks
│   └── use-prompts.ts         # Prompt hooks
```

### Dependencies
```bash
npm install @tanstack/react-query
```

### Implementation

#### `packages/ui/src/hooks/use-workflows.ts`
```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { cortexApi } from '../api/cortex-client';
import type {
  Workflow,
  CreateWorkflowRequest,
  UpdateWorkflowRequest,
} from '../api/types';

// Query keys
export const workflowKeys = {
  all: ['workflows'] as const,
  lists: () => [...workflowKeys.all, 'list'] as const,
  list: (filters: string) => [...workflowKeys.lists(), filters] as const,
  details: () => [...workflowKeys.all, 'detail'] as const,
  detail: (id: string) => [...workflowKeys.details(), id] as const,
};

// Fetch workflows
export function useWorkflows(params?: { status?: string }) {
  return useQuery({
    queryKey: workflowKeys.list(JSON.stringify(params || {})),
    queryFn: () => cortexApi.getWorkflows(params),
  });
}

// Fetch single workflow
export function useWorkflow(id: string) {
  return useQuery({
    queryKey: workflowKeys.detail(id),
    queryFn: () => cortexApi.getWorkflow(id),
    enabled: !!id,
  });
}

// Create workflow
export function useCreateWorkflow() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateWorkflowRequest) => cortexApi.createWorkflow(data),
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
      cortexApi.updateWorkflow(id, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: workflowKeys.detail(variables.id) });
      queryClient.invalidateQueries({ queryKey: workflowKeys.lists() });
    },
  });
}

// Delete workflow
export function useDeleteWorkflow() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => cortexApi.deleteWorkflow(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: workflowKeys.lists() });
    },
  });
}
```

#### `packages/ui/src/hooks/use-workflow-steps.ts`
```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { cortexApi } from '../api/cortex-client';
import type { CreateStepRequest, UpdateStepRequest } from '../api/types';
import { workflowKeys } from './use-workflows';

// Fetch workflow steps
export function useWorkflowSteps(workflowId: string) {
  return useQuery({
    queryKey: [...workflowKeys.detail(workflowId), 'steps'],
    queryFn: () => cortexApi.getWorkflowSteps(workflowId),
    enabled: !!workflowId,
  });
}

// Create step
export function useCreateStep(workflowId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateStepRequest) =>
      cortexApi.createStep(workflowId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: [...workflowKeys.detail(workflowId), 'steps'],
      });
      queryClient.invalidateQueries({ queryKey: workflowKeys.detail(workflowId) });
    },
  });
}

// Update step
export function useUpdateStep(workflowId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ stepId, data }: { stepId: string; data: UpdateStepRequest }) =>
      cortexApi.updateStep(workflowId, stepId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: [...workflowKeys.detail(workflowId), 'steps'],
      });
    },
  });
}

// Delete step
export function useDeleteStep(workflowId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (stepId: string) => cortexApi.deleteStep(workflowId, stepId),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: [...workflowKeys.detail(workflowId), 'steps'],
      });
    },
  });
}
```

#### `packages/ui/src/hooks/use-agents.ts`
```typescript
import { useQuery } from '@tanstack/react-query';
import { cortexApi } from '../api/cortex-client';

export const agentKeys = {
  all: ['agents'] as const,
  lists: () => [...agentKeys.all, 'list'] as const,
};

export function useAgents() {
  return useQuery({
    queryKey: agentKeys.lists(),
    queryFn: () => cortexApi.getAgents({ limit: 100 }),
  });
}
```

#### `packages/ui/src/hooks/use-tools.ts`
```typescript
import { useQuery } from '@tanstack/react-query';
import { cortexApi } from '../api/cortex-client';

export const toolKeys = {
  all: ['tools'] as const,
  lists: () => [...toolKeys.all, 'list'] as const,
};

export function useTools() {
  return useQuery({
    queryKey: toolKeys.lists(),
    queryFn: () => cortexApi.getTools({ limit: 100 }),
  });
}
```

#### `packages/ui/src/hooks/use-prompts.ts`
```typescript
import { useQuery } from '@tanstack/react-query';
import { cortexApi } from '../api/cortex-client';

export const promptKeys = {
  all: ['prompts'] as const,
  lists: () => [...promptKeys.all, 'list'] as const,
};

export function usePrompts() {
  return useQuery({
    queryKey: promptKeys.lists(),
    queryFn: () => cortexApi.getPrompts({ limit: 100 }),
  });
}
```

### Setup React Query Provider

#### `packages/ui/src/providers/query-provider.tsx`
```typescript
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { ReactNode } from 'react';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000, // 1 minute
      retry: 1,
    },
  },
});

export function QueryProvider({ children }: { children: ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
```

### Testing Step 1.2

Create test file: `packages/ui/src/hooks/__tests__/use-workflows.test.tsx`

```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useWorkflows, useCreateWorkflow } from '../use-workflows';
import { cortexApi } from '../../api/cortex-client';

jest.mock('../../api/cortex-client');

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
};

describe('useWorkflows', () => {
  it('should fetch workflows', async () => {
    const mockData = { items: [], total: 0, skip: 0, limit: 10 };
    (cortexApi.getWorkflows as jest.Mock).mockResolvedValue(mockData);

    const { result } = renderHook(() => useWorkflows(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(mockData);
  });
});

describe('useCreateWorkflow', () => {
  it('should create workflow', async () => {
    const mockWorkflow = { id: '1', name: 'Test' };
    (cortexApi.createWorkflow as jest.Mock).mockResolvedValue(mockWorkflow);

    const { result } = renderHook(() => useCreateWorkflow(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ name: 'Test' });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(mockWorkflow);
  });
});
```

**Acceptance Criteria:**
- ✅ All hooks defined
- ✅ Query invalidation works
- ✅ Loading/error states handled
- ✅ Tests pass
- ✅ React Query DevTools accessible

---

## Environment Setup

### Add to `.env.local`
```bash
NEXT_PUBLIC_CORTEX_API_URL=http://localhost:4005
```

### Update `next.config.js` (if needed)
```javascript
module.exports = {
  env: {
    NEXT_PUBLIC_CORTEX_API_URL: process.env.NEXT_PUBLIC_CORTEX_API_URL,
  },
};
```

---

## Verification Checklist

### Step 1.1 Complete When:
- [ ] API client class created
- [ ] All CRUD methods implemented
- [ ] Types defined for all entities
- [ ] Error handling works
- [ ] Unit tests pass
- [ ] Can make successful API call to Cortex backend

### Step 1.2 Complete When:
- [ ] All React Query hooks created
- [ ] Query keys properly structured
- [ ] Cache invalidation works
- [ ] Loading states accessible
- [ ] Error states accessible
- [ ] Unit tests pass
- [ ] Can fetch and mutate data in React component

---

## Demo Script

```typescript
// Test in a simple component
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

## Next Steps After Phase 1

Once Phase 1 is complete:
1. Verify all API endpoints work with Cortex backend
2. Test error scenarios (network failure, 404, 500)
3. Confirm data structure matches Cortex API responses
4. Move to Phase 2: Editable Canvas
