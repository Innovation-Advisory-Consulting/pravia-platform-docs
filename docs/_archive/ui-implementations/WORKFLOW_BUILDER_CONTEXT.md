# Workflow Builder Context

## Project Status

Visual workflow builder component for `packages/ui` library to integrate with Helix API n8n endpoints.

## Backend API (Helix)

**Base URL:** `http://localhost:4005/api/n8n`

### Available Endpoints

#### Workflows
- `GET /workflows` - List all workflows
- `GET /workflows/:id` - Get workflow with nodes and connections
- `POST /workflows` - Create new workflow
- `PUT /workflows/:id` - Update workflow
- `DELETE /workflows/:id` - Delete workflow

#### Nodes (Granular Updates)
- `GET /workflows/:id/nodes` - Get all nodes
- `GET /workflows/:id/nodes/:nodeId` - Get specific node
- `POST /workflows/:id/nodes` - Add node
- `PATCH /workflows/:id/nodes/:nodeId` - Update node (position, parameters)
- `DELETE /workflows/:id/nodes/:nodeId` - Delete node

#### Connections
- `GET /workflows/:id/connections` - Get all connections
- `POST /workflows/:id/connections` - Add connection
- `DELETE /workflows/:id/connections/:source/:target` - Delete connection

#### Executions
- `GET /executions` - List all executions
- `GET /workflows/:id/executions` - Get workflow executions
- `POST /workflows/:id/execute` - Execute workflow

## Data Structures

### n8n Node
```typescript
interface N8nNode {
  id: string;
  name: string;
  type: string;  // e.g., 'n8n-nodes-base.httpRequest'
  typeVersion: number;
  position: [number, number];  // [x, y]
  parameters: Record<string, any>;
  webhookId?: string;
}
```

### n8n Connection
```typescript
interface N8nConnections {
  [nodeName: string]: {
    main?: Array<Array<{
      node: string;      // Target node name
      type: string;      // 'main'
      index: number;     // 0
    }>>;
  };
}
```

### n8n Workflow
```typescript
interface N8nWorkflow {
  id: string;
  name: string;
  active: boolean;
  nodes: N8nNode[];
  connections: N8nConnections;
  settings: Record<string, any>;
  tags?: string[];
  createdAt: string;
  updatedAt: string;
}
```

## API Request Examples

### Add Node
```typescript
POST /api/n8n/workflows/123/nodes
{
  "name": "Upload to Storage",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 1,
  "position": [450, 300],
  "parameters": {
    "url": "http://localhost:4005/api/documents/upload",
    "method": "POST"
  }
}
```

### Update Node Position
```typescript
PATCH /api/n8n/workflows/123/nodes/http-1
{
  "position": [500, 350]
}
```

### Add Connection
```typescript
POST /api/n8n/workflows/123/connections
{
  "sourceNode": "Webhook - Document Upload",
  "targetNode": "Upload to Storage",
  "type": "main",
  "index": 0
}
```

## Component Requirements

### WorkflowBuilder Component

**Location:** `packages/ui/src/components/WorkflowBuilder/`

**Props:**
```typescript
interface WorkflowBuilderProps {
  workflowId: string;
  onSave?: (workflow: N8nWorkflow) => void;
  onError?: (error: Error) => void;
  readOnly?: boolean;
}
```

**Features:**
1. Visual canvas with React Flow
2. Node palette (drag & drop)
3. Node parameter editor panel
4. Connection creation (drag lines)
5. Node positioning (drag nodes)
6. Delete nodes/connections
7. Auto-save on changes
8. Undo/redo support

### Sub-components

```
WorkflowBuilder/
├── index.tsx                 # Main component
├── WorkflowCanvas.tsx        # React Flow canvas
├── NodePalette.tsx           # Draggable node types
├── NodeParametersPanel.tsx   # Edit node settings
├── hooks/
│   ├── useWorkflow.ts        # Load/save workflow
│   ├── useNodes.ts           # Node CRUD operations
│   └── useConnections.ts     # Connection CRUD operations
├── utils/
│   ├── transformers.ts       # n8n ↔ React Flow conversion
│   └── api.ts                # API client
└── types.ts                  # TypeScript types
```

## React Flow Integration

### Dependencies
```bash
npm install reactflow
```

### Transform n8n → React Flow
```typescript
// n8n node → React Flow node
const toReactFlowNode = (n8nNode: N8nNode) => ({
  id: n8nNode.id,
  type: 'custom',
  position: { x: n8nNode.position[0], y: n8nNode.position[1] },
  data: {
    label: n8nNode.name,
    nodeType: n8nNode.type,
    parameters: n8nNode.parameters
  }
});

// n8n connections → React Flow edges
const toReactFlowEdges = (connections: N8nConnections, nodes: N8nNode[]) => {
  const edges = [];
  Object.entries(connections).forEach(([sourceName, conn]) => {
    conn.main?.[0]?.forEach(target => {
      const sourceNode = nodes.find(n => n.name === sourceName);
      const targetNode = nodes.find(n => n.name === target.node);
      edges.push({
        id: `${sourceNode.id}-${targetNode.id}`,
        source: sourceNode.id,
        target: targetNode.id,
        type: 'smoothstep'
      });
    });
  });
  return edges;
};
```

## Key Implementation Details

### 1. Incremental Updates
Use PATCH endpoints for individual changes, not full workflow replacement.

### 2. Optimistic Updates
Update UI immediately, sync with backend in background.

### 3. Error Recovery
Reload workflow if API call fails.

### 4. Debouncing
Debounce position updates (300ms) to avoid excessive API calls.

### 5. Node Names vs IDs
- n8n uses **node names** for connections
- React Flow uses **node IDs**
- Must map between them when transforming

## Example Workflow

**Document Processing Workflow** (already exists in n8n):
- ID: `5Wba1MKHnLpdc8IB`
- 9 nodes: Webhook → Upload → Process → Wait → Check → Switch → Store (TRP/SSP) → Respond
- Can be used for testing

## Environment Setup

```env
# .env
N8N_URL=http://localhost:5678
N8N_API_KEY=n8n_api_5062da57e48d9aff7119232c98d59e31591da9e9c1378b04015c5a0ea87837ff65a325bd6e3205e1
```

## Documentation References

- **API Docs:** `api/helix/docs/N8N_API.md`
- **Integration Guide:** `api/helix/docs/VISUAL_BUILDER_INTEGRATION.md`
- **Helix Module:** `api/helix/src/modules/n8n/`

## Next Steps

1. Create WorkflowBuilder component in packages/ui
2. Implement React Flow canvas
3. Add node palette with drag & drop
4. Create parameter editor panel
5. Implement API hooks
6. Add error handling and loading states
7. Test with existing Document Processing workflow
8. Add undo/redo functionality
9. Implement auto-save
10. Add real-time collaboration (future)

## Testing

**Test Workflow ID:** `5Wba1MKHnLpdc8IB`

```bash
# Start Helix API
cd api/helix && npm run dev

# Start n8n
pnpm n8n:start

# Test endpoints
curl http://localhost:4005/api/n8n/workflows/5Wba1MKHnLpdc8IB
```

## Important Notes

- n8n must be running (port 5678)
- Helix API must be running (port 4005)
- Use node **names** for connections, not IDs
- Always reload workflow after node deletion (connections auto-removed)
- Validate node types before adding
- Handle concurrent edits gracefully
