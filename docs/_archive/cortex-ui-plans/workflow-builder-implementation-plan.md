# Workflow Builder Implementation Plan

## Overview
Extend existing AIWorkflow components to create an editable Workflow Builder. Break down into small, testable steps.

---

## Phase 1: Foundation (API & Data Layer)

### Step 1.1: Create Cortex API Client
**File:** `packages/ui/src/api/cortex-client.ts`

```typescript
// Basic CRUD operations for workflows
export class CortexClient {
  async getWorkflows(params?: { status?: string })
  async getWorkflow(id: string)
  async createWorkflow(data: CreateWorkflowRequest)
  async updateWorkflow(id: string, data: UpdateWorkflowRequest)
  async deleteWorkflow(id: string)
  
  async createStep(workflowId: string, data: CreateStepRequest)
  async updateStep(workflowId: string, stepId: string, data: UpdateStepRequest)
  async deleteStep(workflowId: string, stepId: string)
  
  async getAgents()
  async getTools()
  async getPrompts()
}
```

**Test:** Can fetch and create workflows via API

---

### Step 1.2: Create React Query Hooks
**File:** `packages/ui/src/hooks/use-workflows.ts`

```typescript
export function useWorkflows(params?: { status?: string })
export function useWorkflow(id: string)
export function useCreateWorkflow()
export function useUpdateWorkflow()
export function useDeleteWorkflow()

export function useCreateStep(workflowId: string)
export function useUpdateStep(workflowId: string)
export function useDeleteStep(workflowId: string)

export function useAgents()
export function useTools()
export function usePrompts()
```

**Test:** Hooks fetch data and handle loading/error states

---

## Phase 2: Editable Canvas

### Step 2.1: Add Edit Mode to WorkflowFlow
**File:** `packages/ui/src/views/ai-workflow/workflow-flow.tsx`

**Changes:**
- Add `editable?: boolean` prop
- Add `onNodeClick?: (nodeId: string) => void` prop
- Add `onNodesChange?: (nodes: Node[]) => void` prop
- Enable `nodesDraggable={editable}`
- Enable `elementsSelectable={editable}`

**Test:** Can click and drag nodes in edit mode

---

### Step 2.2: Add Node Actions (Delete, Add)
**File:** `packages/ui/src/views/ai-workflow/nodes/workflow-step-node.tsx`

**Changes:**
- Add delete button (shows on hover in edit mode)
- Add `onDelete?: () => void` prop
- Style changes for selected state

**Test:** Can delete nodes, see visual feedback

---

### Step 2.3: Create Add Step Button Component
**File:** `packages/ui/src/views/ai-workflow/components/add-step-button.tsx`

```typescript
export function AddStepButton({ 
  onClick,
  position?: 'toolbar' | 'canvas'
}) {
  // Floating action button or toolbar button
}
```

**Test:** Button triggers add step action

---

## Phase 3: Configuration Panels

### Step 3.1: Create Base Flyout Drawer Component
**File:** `packages/ui/src/components/flyout-drawer.tsx`

```typescript
export function FlyoutDrawer({
  open: boolean,
  onClose: () => void,
  title: string,
  children: ReactNode,
  width?: number
}) {
  // Slides in from right
  // Backdrop click closes
  // ESC key closes
}
```

**Test:** Drawer opens/closes with animation

---

### Step 3.2: Create Step Configuration Form
**File:** `packages/ui/src/views/ai-workflow/components/step-config-form.tsx`

```typescript
export function StepConfigForm({
  step: WorkflowStep | null,
  agents: Agent[],
  tools: Tool[],
  prompts: Prompt[],
  onSave: (data: StepFormData) => void,
  onCancel: () => void,
  onDelete?: () => void
}) {
  // Form fields:
  // - Step name
  // - Agent selector (searchable dropdown)
  // - Tools (multi-select checkboxes)
  // - Prompts (multi-select)
  // - Timeout (number input)
  // - Advanced settings (collapsible)
}
```

**Test:** Form validates and submits data

---

### Step 3.3: Create Workflow Properties Form
**File:** `packages/ui/src/views/ai-workflow/components/workflow-properties-form.tsx`

```typescript
export function WorkflowPropertiesForm({
  workflow: Workflow,
  onSave: (data: WorkflowFormData) => void,
  onCancel: () => void
}) {
  // Form fields:
  // - Name
  // - Description
  // - Tags
  // - Input schema (read-only, auto-generated)
  // - Timeout
  // - Retry policy
}
```

**Test:** Form updates workflow properties

---

## Phase 4: Main Builder Component

### Step 4.1: Create Workflow Builder Container
**File:** `packages/ui/src/views/ai-workflow/workflow-builder.tsx`

```typescript
export function WorkflowBuilder({ 
  workflowId?: string  // undefined = new workflow
}) {
  // State management:
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null)
  const [showProperties, setShowProperties] = useState(false)
  
  // Data fetching:
  const { data: workflow } = useWorkflow(workflowId)
  const { data: agents } = useAgents()
  const { data: tools } = useTools()
  const { data: prompts } = usePrompts()
  
  // Mutations:
  const createStep = useCreateStep(workflowId)
  const updateStep = useUpdateStep(workflowId)
  const deleteStep = useDeleteStep(workflowId)
  
  // Layout:
  // - Top toolbar
  // - WorkflowFlow (editable)
  // - FlyoutDrawer (step config)
  // - FlyoutDrawer (workflow properties)
}
```

**Test:** Can create, edit, delete steps

---

### Step 4.2: Add Toolbar Component
**File:** `packages/ui/src/views/ai-workflow/components/workflow-toolbar.tsx`

```typescript
export function WorkflowToolbar({
  workflow: Workflow,
  onAddStep: () => void,
  onShowProperties: () => void,
  onTest: () => void,
  onSave: () => void,
  onPublish: () => void,
  isSaving: boolean
}) {
  // Left: Menu toggle, workflow name (editable)
  // Center: Add step, properties buttons
  // Right: Test, save, publish buttons
}
```

**Test:** All toolbar actions work

---

## Phase 5: Smart Features

### Step 5.1: Auto-save Functionality
**File:** `packages/ui/src/views/ai-workflow/hooks/use-auto-save.ts`

```typescript
export function useAutoSave(
  workflowId: string,
  data: Workflow,
  delay: number = 2000
) {
  // Debounced auto-save
  // Shows "Saving..." indicator
  // Shows "Saved" confirmation
}
```

**Test:** Changes auto-save after delay

---

### Step 5.2: Input Schema Generator
**File:** `packages/ui/src/views/ai-workflow/utils/generate-input-schema.ts`

```typescript
export function generateInputSchema(workflow: Workflow): JSONSchema {
  // Analyze steps
  // Extract required inputs from prompts/tools
  // Generate JSON Schema
}
```

**Test:** Schema generates correctly from workflow

---

### Step 5.3: Validation System
**File:** `packages/ui/src/views/ai-workflow/utils/validate-workflow.ts`

```typescript
export function validateWorkflow(workflow: Workflow): ValidationResult {
  // Check all steps have agents
  // Check all steps have tools
  // Check no disconnected nodes
  // Return errors/warnings
}
```

**Test:** Validation catches issues

---

### Step 5.4: Smart Suggestions
**File:** `packages/ui/src/views/ai-workflow/utils/suggest-agent.ts`

```typescript
export function suggestAgent(
  stepName: string,
  agents: Agent[]
): Agent | null {
  // Simple keyword matching
  // Return best match
}

export function suggestTools(
  agent: Agent,
  tools: Tool[]
): Tool[] {
  // Return commonly used tools for agent
}
```

**Test:** Suggestions are relevant

---

## Phase 6: Integration & Polish

### Step 6.1: Add to Navigation
**File:** Update menu to include Workflows under AUTOMATION

**Test:** Can navigate to builder from menu

---

### Step 6.2: Add Workflow Library Screen
**File:** `packages/ui/src/views/ai-workflow/workflow-library.tsx`

```typescript
export function WorkflowLibrary() {
  // List view of workflows
  // Filter by status
  // Search
  // Actions: New, Edit, Clone, Delete
}
```

**Test:** Can browse and manage workflows

---

### Step 6.3: Add Test Execution Modal
**File:** `packages/ui/src/views/ai-workflow/components/test-execution-modal.tsx`

```typescript
export function TestExecutionModal({
  workflow: Workflow,
  open: boolean,
  onClose: () => void
}) {
  // Dynamic form based on input schema
  // Submit to create test job
  // Show execution in real-time
}
```

**Test:** Can test workflow execution

---

### Step 6.4: Error Handling & Loading States
- Add error boundaries
- Add loading skeletons
- Add empty states
- Add error messages

**Test:** All error cases handled gracefully

---

### Step 6.5: Responsive Design
- Test on different screen sizes
- Adjust flyout widths
- Mobile considerations

**Test:** Works on tablet/desktop

---

## Testing Strategy

### Unit Tests
- API client functions
- Utility functions (validation, schema generation)
- Form validation logic

### Integration Tests
- Workflow CRUD operations
- Step CRUD operations
- Auto-save functionality

### E2E Tests
- Create workflow end-to-end
- Edit existing workflow
- Delete workflow
- Publish workflow

---

## Estimated Timeline

| Phase | Steps | Estimated Time |
|-------|-------|----------------|
| Phase 1 | 1.1 - 1.2 | 2-3 hours |
| Phase 2 | 2.1 - 2.3 | 3-4 hours |
| Phase 3 | 3.1 - 3.3 | 4-5 hours |
| Phase 4 | 4.1 - 4.2 | 3-4 hours |
| Phase 5 | 5.1 - 5.4 | 4-5 hours |
| Phase 6 | 6.1 - 6.5 | 4-5 hours |
| **Total** | | **20-26 hours** |

---

## Dependencies

- `@tanstack/react-query` - Data fetching
- `react-hook-form` - Form management
- `zod` - Form validation
- `@mui/material` - UI components (already installed)
- `@xyflow/react` - React Flow (already installed)

---

## Success Criteria

✅ Can create a 3-step workflow in under 2 minutes
✅ Changes auto-save
✅ Input schema auto-generates
✅ Validation prevents publishing invalid workflows
✅ No navigation to separate CRUD screens needed
✅ Works on desktop and tablet
✅ All API operations have error handling
✅ Loading states for all async operations

---

## Next Steps

1. Review and approve this plan
2. Set up project structure
3. Start with Phase 1, Step 1.1
4. Test each step before moving to next
5. Demo after each phase completion
