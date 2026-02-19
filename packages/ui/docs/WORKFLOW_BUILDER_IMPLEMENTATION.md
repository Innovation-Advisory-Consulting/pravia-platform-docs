# Workflow Builder Implementation Plan

## Overview
Visual workflow builder for creating and editing multi-step AI workflows. Combines workflow metadata management with step configuration in a single, intuitive interface.

## Architecture Integration

From the Component-Oriented Architecture Diagram:
```
Workflow Builder (Frontend)
  ↓
WorkflowsController (API)
  ↓
Workflow Service (Core)
  ↓
Orchestration Layer (CrewAI)
  ├── Workflow Engine
  ├── Step Executor
  ├── Agent Dispatcher
  └── Tool Dispatcher
```

## API Integration

### Endpoints
```
GET    /api/v1/workflows              - List workflows
GET    /api/v1/workflows/:id          - Get workflow details
POST   /api/v1/workflows              - Create workflow
PUT    /api/v1/workflows/:id          - Update workflow
DELETE /api/v1/workflows/:id          - Delete workflow

GET    /api/v1/workflows/:id/steps    - Get workflow steps
POST   /api/v1/workflows/:id/steps    - Create step
PUT    /api/v1/workflows/:id/steps/:stepId    - Update step
DELETE /api/v1/workflows/:id/steps/:stepId    - Delete step
```

### Data Models

**MatrixWorkflow**:
```typescript
{
  id: string                    // UUID
  name: string
  description?: string
  status: 'draft' | 'published'
  created_at: string
  updated_at: string
  tenant_id: string
  created_by: string
}
```

**MatrixWorkflowStep**:
```typescript
{
  id: string                    // UUID
  workflow_id: string           // UUID
  name: string
  step_index: number            // Order in workflow
  agent_id?: string             // UUID
  tool_ids?: string[]           // UUIDs
  prompt_ids?: string[]         // UUIDs
  timeout_seconds?: number
  config?: Record<string, any>  // Step-specific configuration
}
```

## Implementation Phases

### Phase 1: Foundation (2-3 hours)
**Goal**: Set up data layer and basic structure

**Tasks**:
1. Create WorkflowService with CRUD operations
2. Add workflow types to matrix.ts
3. Add workflow endpoints to matrix-endpoints.ts
4. Create React Query hooks (useWorkflows, useWorkflow, etc.)

**Files**:
- `src/services/workflow.service.ts`
- `src/types/matrix.ts` (add workflow types)
- `src/lib/matrix-endpoints.ts` (add workflow endpoints)
- `src/hooks/use-workflows.ts`

### Phase 2: Basic CRUD Views (3-4 hours)
**Goal**: Standard list and form views for workflows

**Tasks**:
1. Create WorkflowListView (following CRUD_PATTERNS.md)
2. Create WorkflowFormView (name, description, status)
3. Create WorkflowDetailDialog
4. Add Storybook stories

**Files**:
- `src/views/matrix/workflows/workflow-list-view.tsx`
- `src/views/matrix/workflows/workflow-form-view.tsx`
- `src/views/matrix/workflows/workflow-detail-dialog.tsx`
- `src/views/matrix/workflows/workflows.stories.tsx`

**Features**:
- Filter tabs: All, Draft, Published
- Search: name, description
- Columns: Name, Description, Status, Steps Count, Updated
- Actions: View, Edit, Delete, Publish/Unpublish

### Phase 3: Visual Canvas (4-5 hours)
**Goal**: ReactFlow-based visual workflow editor

**Tasks**:
1. Make existing AIWorkflow components editable
2. Add node drag & drop
3. Add node delete functionality
4. Add "Add Step" button
5. Add connection validation

**Files**:
- `src/views/ai-workflow/workflow-flow.tsx` (update)
- `src/views/ai-workflow/nodes/workflow-step-node.tsx` (update)
- `src/views/ai-workflow/components/add-step-button.tsx` (new)

**Features**:
- Drag nodes to reorder
- Click node to edit
- Delete node button (on hover)
- Add step button (floating or toolbar)
- Visual connection lines
- Auto-layout on changes

### Phase 4: Configuration Panels (4-5 hours)
**Goal**: Drawer-based step configuration

**Tasks**:
1. Create FlyoutDrawer component (reusable)
2. Create StepConfigForm
3. Create WorkflowPropertiesForm
4. Integrate with canvas

**Files**:
- `src/components/surfaces/flyout-drawer.tsx`
- `src/views/ai-workflow/components/step-config-form.tsx`
- `src/views/ai-workflow/components/workflow-properties-form.tsx`

**StepConfigForm Fields**:
- Step name (required)
- Agent selector (searchable dropdown)
- Tools (multi-select with checkboxes)
- Prompts (multi-select)
- Timeout (number input, seconds)
- Advanced config (JSON editor)

**WorkflowPropertiesForm Fields**:
- Workflow name (required)
- Description
- Status (draft/published toggle)
- Tags
- Input schema (auto-generated, read-only)

### Phase 5: Main Builder Component (3-4 hours)
**Goal**: Integrate all pieces into WorkflowBuilder

**Tasks**:
1. Create WorkflowBuilder container
2. Create WorkflowToolbar
3. Implement state management
4. Add auto-save
5. Add validation

**Files**:
- `src/views/ai-workflow/workflow-builder.tsx`
- `src/views/ai-workflow/components/workflow-toolbar.tsx`
- `src/views/ai-workflow/hooks/use-auto-save.ts`

**WorkflowToolbar Actions**:
- Left: Back button, Workflow name (editable inline)
- Center: Add Step, Properties buttons
- Right: Test, Save, Publish buttons

**State Management**:
- Selected node ID
- Drawer open/closed
- Drawer mode (step config / workflow properties)
- Unsaved changes indicator

### Phase 6: Smart Features (4-5 hours)
**Goal**: Enhance UX with intelligent features

**Tasks**:
1. Auto-save functionality (debounced)
2. Input schema generator
3. Workflow validation
4. Smart suggestions (agent/tool recommendations)

**Files**:
- `src/views/ai-workflow/hooks/use-auto-save.ts`
- `src/views/ai-workflow/utils/generate-input-schema.ts`
- `src/views/ai-workflow/utils/validate-workflow.ts`
- `src/views/ai-workflow/utils/suggest-agent.ts`

**Validation Rules**:
- All steps must have agents
- All steps must have at least one tool
- No disconnected nodes
- Valid step order
- Required fields filled

**Smart Suggestions**:
- Suggest agents based on step name
- Suggest tools based on agent type
- Suggest prompts based on category

### Phase 7: Testing & Integration (2-3 hours)
**Goal**: Test execution and polish

**Tasks**:
1. Create TestExecutionModal
2. Add to navigation
3. Error handling
4. Loading states
5. Responsive design

**Files**:
- `src/views/ai-workflow/components/test-execution-modal.tsx`
- Update navigation config

**TestExecutionModal**:
- Dynamic form based on input schema
- Submit to create test job
- Link to Job Monitor
- Show execution status

## Component Structure

```
src/views/ai-workflow/
├── workflow-builder.tsx              # Main container
├── workflow-flow.tsx                 # ReactFlow canvas (updated)
├── nodes/
│   └── workflow-step-node.tsx        # Step node (updated)
├── components/
│   ├── workflow-toolbar.tsx          # Top toolbar
│   ├── add-step-button.tsx           # Add step button
│   ├── step-config-form.tsx          # Step configuration
│   ├── workflow-properties-form.tsx  # Workflow metadata
│   └── test-execution-modal.tsx      # Test workflow
├── hooks/
│   └── use-auto-save.ts              # Auto-save logic
└── utils/
    ├── generate-input-schema.ts      # Schema generation
    ├── validate-workflow.ts          # Validation
    └── suggest-agent.ts              # Smart suggestions

src/views/matrix/workflows/
├── workflow-list-view.tsx            # CRUD list view
├── workflow-form-view.tsx            # Basic form
├── workflow-detail-dialog.tsx        # Detail view
├── workflows.stories.tsx             # Storybook
└── index.ts                          # Exports
```

## User Flow

### Creating a Workflow
1. Click "Create Workflow" from list view
2. Enter name and description
3. Opens Workflow Builder (empty canvas)
4. Click "Add Step" button
5. Configure step (agent, tools, prompts)
6. Add more steps as needed
7. Auto-saves as you work
8. Click "Publish" when ready

### Editing a Workflow
1. Click workflow name from list view
2. Opens Workflow Builder with existing steps
3. Click node to edit step
4. Drag nodes to reorder
5. Delete nodes as needed
6. Changes auto-save
7. Click "Publish" to update

### Testing a Workflow
1. Click "Test" button in toolbar
2. Modal opens with input form
3. Fill in required inputs
4. Click "Run Test"
5. Creates job and redirects to Job Monitor
6. View execution in real-time

## ReactFlow Integration

### Node Types
```typescript
const nodeTypes = {
  workflowStep: WorkflowStepNode,
}
```

### Node Data
```typescript
interface WorkflowStepNodeData {
  step: MatrixWorkflowStep
  agent?: MatrixAgent
  tools?: MatrixTool[]
  prompts?: MatrixPrompt[]
  onEdit: (step: MatrixWorkflowStep) => void
  onDelete: (stepId: string) => void
}
```

### Edge Configuration
```typescript
const edgeOptions = {
  type: 'smoothstep',
  animated: true,
  style: { stroke: theme.palette.primary.main },
}
```

### Layout Algorithm
```typescript
// Auto-layout steps vertically
function layoutSteps(steps: MatrixWorkflowStep[]) {
  return steps.map((step, index) => ({
    id: step.id,
    type: 'workflowStep',
    position: { x: 250, y: index * 150 },
    data: { step },
  }))
}
```

## Auto-save Implementation

```typescript
function useAutoSave(workflowId: string, data: Workflow, delay = 2000) {
  const [isSaving, setIsSaving] = useState(false)
  const [lastSaved, setLastSaved] = useState<Date | null>(null)
  
  const debouncedSave = useMemo(
    () => debounce(async (data: Workflow) => {
      setIsSaving(true)
      try {
        await workflowService.updateWorkflow(workflowId, data)
        setLastSaved(new Date())
      } catch (error) {
        console.error('Auto-save failed:', error)
      } finally {
        setIsSaving(false)
      }
    }, delay),
    [workflowId, delay]
  )
  
  useEffect(() => {
    debouncedSave(data)
  }, [data, debouncedSave])
  
  return { isSaving, lastSaved }
}
```

## Validation Implementation

```typescript
interface ValidationResult {
  valid: boolean
  errors: string[]
  warnings: string[]
}

function validateWorkflow(workflow: Workflow): ValidationResult {
  const errors: string[] = []
  const warnings: string[] = []
  
  // Check workflow has name
  if (!workflow.name) {
    errors.push('Workflow name is required')
  }
  
  // Check workflow has steps
  if (!workflow.steps || workflow.steps.length === 0) {
    errors.push('Workflow must have at least one step')
  }
  
  // Check each step
  workflow.steps?.forEach((step, index) => {
    if (!step.agent_id) {
      errors.push(`Step ${index + 1}: Agent is required`)
    }
    if (!step.tool_ids || step.tool_ids.length === 0) {
      warnings.push(`Step ${index + 1}: No tools assigned`)
    }
  })
  
  return {
    valid: errors.length === 0,
    errors,
    warnings,
  }
}
```

## Storybook Stories

```
Views/Matrix/Workflows/
  ├── List View
  ├── Create Form
  ├── Edit Form
  ├── Detail Dialog
  └── Workflow Builder
      ├── Empty Canvas
      ├── With Steps
      └── Editing Step
```

## Testing Strategy

### Unit Tests
- WorkflowService methods
- Validation logic
- Schema generation
- Auto-save debouncing

### Integration Tests
- Create workflow
- Add/edit/delete steps
- Publish workflow
- Test execution

### E2E Tests
- Complete workflow creation flow
- Edit existing workflow
- Test workflow execution
- Error handling

## Performance Considerations

- Debounced auto-save (2 seconds)
- Lazy load agent/tool/prompt lists
- Virtualized dropdowns for large lists
- Memoized validation
- Optimistic UI updates

## Estimated Timeline

| Phase | Tasks | Estimated Time |
|-------|-------|----------------|
| Phase 1 | Foundation | 2-3 hours |
| Phase 2 | Basic CRUD | 3-4 hours |
| Phase 3 | Visual Canvas | 4-5 hours |
| Phase 4 | Config Panels | 4-5 hours |
| Phase 5 | Main Builder | 3-4 hours |
| Phase 6 | Smart Features | 4-5 hours |
| Phase 7 | Testing & Polish | 2-3 hours |
| **Total** | | **22-29 hours** |

## Dependencies

- ✅ @xyflow/react (ReactFlow)
- ✅ AgentService
- ✅ ToolService
- ✅ PromptService
- ❌ WorkflowService (to be created)
- ❌ Workflow types (to be added)

## Success Criteria

- ✅ Can create a 3-step workflow in under 2 minutes
- ✅ Changes auto-save without user action
- ✅ Input schema auto-generates from steps
- ✅ Validation prevents publishing invalid workflows
- ✅ No navigation to separate CRUD screens needed
- ✅ Works on desktop and tablet
- ✅ All API operations have error handling
- ✅ Loading states for all async operations

## Future Enhancements

1. **Conditional Steps**: Branch based on previous step output
2. **Parallel Execution**: Run multiple steps simultaneously
3. **Loop Steps**: Repeat steps based on conditions
4. **Sub-workflows**: Nest workflows within workflows
5. **Version Control**: Track workflow changes over time
6. **Templates**: Pre-built workflow templates
7. **Collaboration**: Multi-user editing with conflict resolution
8. **AI Suggestions**: AI-powered workflow optimization

## Next Steps

1. Complete Phase 1 (Foundation)
2. Build basic CRUD views (Phase 2)
3. Enhance existing AIWorkflow components (Phase 3)
4. Build configuration panels (Phase 4)
5. Integrate into WorkflowBuilder (Phase 5)
6. Add smart features (Phase 6)
7. Test and polish (Phase 7)
