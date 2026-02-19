# CRUD List View Patterns

Standard patterns for implementing CRUD (Create, Read, Update, Delete) list views in the UI package.

## Architecture Principles

### Library vs Application Pattern

The `@asyml8/ui` package is a **library** that supports two data fetching patterns:

1. **Service Pattern** (packages/ui) - Class-based services with dependency injection
2. **Store Pattern** (apps) - TanStack Query stores created from services

### Service Pattern (Library - packages/ui)

**Services are classes** that encapsulate API calls:

```typescript
// packages/ui/src/services/agent.service.ts
export class AgentService extends MatrixBaseService {
  async listAgents(params?: QueryParams): Promise<AgentListResponse> {
    return this.get(matrixEndpoints.agents.list, params);
  }
  
  async getAgent(id: string): Promise<MatrixAgent> {
    return this.get(matrixEndpoints.agents.details(id));
  }
  
  async createAgent(data: CreateAgentRequest): Promise<MatrixAgent> {
    return this.post(matrixEndpoints.agents.create, data);
  }
}
```

**Views accept services as props** (dependency injection):

```typescript
// packages/ui/src/views/matrix/agents/agent-list-view.tsx
export interface AgentListViewProps {
  agentService: AgentService;
  modelService: ModelService; // Related services if needed
  onAgentClick?: (agent: MatrixAgent) => void;
}

export function AgentListView({ agentService, modelService }: AgentListViewProps) {
  // Use service with DataTable's queryKey/queryFn pattern
  <DataTable
    queryKey={['agents']}
    queryFn={() => agentService.listAgents({ limit: 100 })}
    columns={columns}
  />
}
```

### Store Pattern (Application - apps/*)

**Apps create stores** from services for centralized state management:

```typescript
// apps/mule-client/src/services/organization.service.ts
export const organizationService = {
  getAll: async (): Promise<Organization[]> => {
    const { data } = await axios.get('/organizations');
    return data;
  },
};

// apps/mule-client/src/stores/organizations.store.ts
import { createAppQueryStore, defaultQueryConfig } from '@asyml8/ui';
import { organizationService } from 'src/services/organization.service';

export const organizationsStore = createAppQueryStore(['organizations']);

export const organizationsQueryConfig = {
  queryFn: organizationService.getAll,
  ...defaultQueryConfig,
};

// apps/mule-client - Usage
<DataTable
  store={organizationsStore}
  columns={columns}
/>
```

### DataTable Dual-Pattern Support

DataTable supports **both patterns**:

```typescript
// Pattern 1: Direct queryKey/queryFn (used in packages/ui)
<DataTable
  queryKey={['agents']}
  queryFn={() => agentService.listAgents()}
  columns={columns}
/>

// Pattern 2: Store (used in apps)
<DataTable
  store={agentsStore}
  columns={columns}
/>
```

**Implementation in DataTable:**
```typescript
export function DataTable<T>({ store, queryKey, queryFn, ... }) {
  // Use store if provided, otherwise fall back to legacy query
  const legacyQuery = useQuery({
    queryKey: queryKey || [],
    queryFn: queryFn || (() => Promise.resolve([])),
    enabled: !store && !!queryKey && !!queryFn,
  });

  const storeQuery = store?.useQuery();
  
  const { data = [], isLoading, error } = store ? storeQuery! : legacyQuery;
}
```

### Service Injection (Dependency Injection)

**All views receive services as props** - never instantiate services internally:

```typescript
// ✅ CORRECT - Services passed as props
export interface EntityListViewProps {
  entityService: EntityService;
  relatedService?: RelatedService; // If needed
  onEntityClick?: (entity: Entity) => void;
}

export function EntityListView({ entityService, relatedService }: EntityListViewProps) {
  // Use services here
}

// ❌ WRONG - Don't instantiate services internally
export function EntityListView() {
  const service = new EntityService(); // BAD!
}
```

**Benefits:**
- Loose coupling
- Testability (can mock services)
- Flexibility (apps can swap implementations)
- Consistent with TanStack Query provider pattern

### Data Fetching with TanStack Query

Use `useQuery` directly in components with passed services:

```typescript
export function EntityListView({ entityService }: EntityListViewProps) {
  // Direct useQuery with service
  const { data, refetch } = useQuery({
    queryKey: ['entities'],
    queryFn: () => entityService.listEntities({ limit: 100 }),
  });
  
  const entities = data?.items || [];
}
```

### Mutations

Use `useMutation` for create/update/delete operations:

```typescript
export function EntityListView({ entityService }: EntityListViewProps) {
  const queryClient = useQueryClient();
  
  const deleteMutation = useMutation({
    mutationFn: (id: string) => entityService.deleteEntity(id),
    onSuccess: () => {
      // Invalidate cache to refetch
      queryClient.invalidateQueries({ queryKey: ['entities'] });
    },
  });
  
  const handleDelete = async (id: string) => {
    await deleteMutation.mutateAsync(id);
  };
}
```

## Standard Features

All list views should include:

### ✅ Core Features
- **DataTable** with pagination
- **Search** across relevant fields
- **Filter tabs** for common categories/statuses
- **Filter dropdowns** for additional filtering
- **Bulk selection** with multi-delete
- **Drawer-based editing** (not dialogs)
- **Action menu** (View/Edit/Delete)
- **Clickable name cells** with hover link icon

### ✅ UX Patterns
- Name column is underlined link that opens edit drawer
- Hover shows link icon on name
- Category/status columns use Chips
- Action menu (⋮) in last column
- Drawer opens from right (configurable)
- View mode shows JSON preview
- Edit/Create mode shows form

## Implementation Checklist

### 1. Imports
```tsx
import { useState, useEffect } from 'react';
import { Stack, Button, Typography, IconButton, Menu, MenuItem, ListItemIcon, ListItemText, Drawer, Box, Link, Chip } from '@mui/material';
import { DataTable } from '../../../components/data-display/data-table';
import type { FilterTab, SearchConfig } from '../../../components/data-display/data-table';
import { Iconify } from '../../../components/data-display/iconify';
```

### 2. Props Interface
```tsx
export interface EntityListViewProps {
  entityService: EntityService;
  onEntityClick?: (entity: Entity) => void;
  drawerAnchor?: 'left' | 'right' | 'top' | 'bottom';
}
```

### 3. State Management
```tsx
const [selected, setSelected] = useState<string[]>([]);
const [refreshKey, setRefreshKey] = useState(0);
const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
const [menuEntity, setMenuEntity] = useState<Entity | null>(null);
const [drawerOpen, setDrawerOpen] = useState(false);
const [drawerMode, setDrawerMode] = useState<'view' | 'edit' | 'create'>('view');
const [selectedEntity, setSelectedEntity] = useState<Entity | null>(null);
const [filterOptions, setFilterOptions] = useState<string[]>([]);
```

### 4. Load Filter Options
```tsx
useEffect(() => {
  entityService.listEntities({ limit: 100 }).then((response) => {
    const uniqueValues = [...new Set(response.items.map(e => e.category))];
    setFilterOptions(uniqueValues);
  });
}, [entityService]);
```

### 5. Filter Tabs
```tsx
const filterTabs: FilterTab<Entity>[] = [
  {
    id: 'all',
    label: 'All',
    filter: (data) => data,
    color: 'default',
  },
  {
    id: 'active',
    label: 'Active',
    filter: (data) => data.filter(e => e.is_active),
    color: 'success',
  },
  // Add more tabs as needed
];
```

### 6. Search Config
```tsx
const searchConfig: SearchConfig<Entity> = {
  placeholder: 'Search entities...',
  searchFields: ['name', 'category', 'description'],
  filterOptions: [
    {
      label: 'Category',
      value: 'category',
      options: filterOptions,
    },
  ],
};
```

### 7. Name Column with Link
```tsx
{ 
  id: 'name' as keyof Entity, 
  label: 'Name',
  render: (val, row) => (
    <Link
      component="button"
      variant="body2"
      onClick={(e) => {
        e.stopPropagation();
        handleNameClick(row);
      }}
      sx={{
        textDecoration: 'underline',
        cursor: 'pointer',
        display: 'inline-flex',
        alignItems: 'center',
        gap: 0.5,
        '&:hover .link-icon': {
          opacity: 1,
        },
      }}
    >
      {val}
      <Iconify 
        icon="solar:link-bold" 
        width={16} 
        className="link-icon"
        sx={{ opacity: 0, transition: 'opacity 0.2s' }}
      />
    </Link>
  ),
},
```

### 8. Category Column with Chip
```tsx
{ 
  id: 'category' as keyof Entity, 
  label: 'Category',
  render: (val) => <Chip label={val} size="small" />
},
```

### 9. Action Menu Column
```tsx
{
  id: 'id' as keyof Entity,
  label: '',
  render: (_, row) => (
    <IconButton
      size="small"
      onClick={(e) => handleMenuOpen(e, row)}
    >
      <Iconify icon="eva:more-vertical-fill" />
    </IconButton>
  ),
},
```

### 10. Action Menu
```tsx
<Menu
  anchorEl={anchorEl}
  open={Boolean(anchorEl)}
  onClose={handleMenuClose}
>
  <MenuItem onClick={handleViewDetails}>
    <ListItemIcon>
      <Iconify icon="solar:eye-bold" width={20} />
    </ListItemIcon>
    <ListItemText>View Details</ListItemText>
  </MenuItem>
  <MenuItem onClick={handleEdit}>
    <ListItemIcon>
      <Iconify icon="solar:pen-bold" width={20} />
    </ListItemIcon>
    <ListItemText>Edit</ListItemText>
  </MenuItem>
  <MenuItem onClick={handleDeleteSingle}>
    <ListItemIcon>
      <Iconify icon="solar:trash-bin-trash-bold" width={20} />
    </ListItemIcon>
    <ListItemText>Delete</ListItemText>
  </MenuItem>
</Menu>
```

### 11. Drawer
```tsx
<Drawer
  anchor={drawerAnchor}
  open={drawerOpen}
  onClose={() => setDrawerOpen(false)}
>
  <Box sx={{ width: drawerAnchor === 'left' || drawerAnchor === 'right' ? 500 : 'auto', p: 3 }}>
    {drawerMode === 'view' && selectedEntity && (
      <Stack spacing={2}>
        <Typography variant="h5">Entity Details</Typography>
        <Box
          component="pre"
          sx={{
            p: 2,
            bgcolor: 'grey.900',
            color: 'grey.100',
            borderRadius: 1,
            overflow: 'auto',
            fontSize: '0.875rem',
          }}
        >
          {JSON.stringify(selectedEntity, null, 2)}
        </Box>
        <Button onClick={() => setDrawerOpen(false)}>Close</Button>
      </Stack>
    )}
    {(drawerMode === 'edit' || drawerMode === 'create') && (
      <EntityFormView
        entityService={entityService}
        entity={drawerMode === 'edit' ? selectedEntity || undefined : undefined}
        open={true}
        onClose={() => setDrawerOpen(false)}
        onSave={handleSave}
        useDialog={false}
      />
    )}
  </Box>
</Drawer>
```

### 12. Form View Props
```tsx
export interface EntityFormViewProps {
  entityService: EntityService;
  entity?: Entity;
  open: boolean;
  onClose: () => void;
  onSave?: (entity: Entity) => void;
  useDialog?: boolean; // Support both dialog and drawer modes
}
```

## Storybook Structure

Each entity should have stories organized directly under the entity name (no redundant component level):

```
Views/Matrix/{Entity}/
  ├── List View       (story)
  ├── Create Form     (story)
  ├── Edit Form       (story)
  └── Detail Dialog   (story)
```

### Service Setup for Stories

Always create service instances at the story file level:

```typescript
import { ApiManager } from '../../../lib/api-manager';
import { createHttpClient } from '../../../lib/http-client';
import { createMatrixApiConfig } from '../../../lib/matrix-api-setup';
import { EntityService } from '../../../services/entity.service';

// Create service instances once
const apiManager = new ApiManager(createHttpClient);
const matrixApi = apiManager.createInstance('matrix', 
  createMatrixApiConfig({
    baseURL: 'http://localhost:4005/api/v1',
  })
);
const entityService = new EntityService(matrixApi);

// Pass to stories
export const ListView: Story = {
  args: {
    entityService,
  },
};
```

### Story Template

```tsx
import type { Meta, StoryObj } from '@storybook/react';
import { useState } from 'react';
import { Box } from '@mui/material';

// Single meta export for all stories
const meta = {
  title: 'Views/Matrix/{Entity}',
  component: EntityListView,
  parameters: { layout: 'padded' },
  tags: ['autodocs'],
} satisfies Meta<typeof EntityListView>;

export default meta;
type Story = StoryObj<typeof meta>;

// List View
export const ListView: Story = {
  args: { entityService },
};

// Create Form
export const CreateForm: Story = {
  render: () => {
    const [open, setOpen] = useState(true);
    return (
      <Box sx={{ p: 3 }}>
        <EntityFormView
          entityService={entityService}
          open={open}
          onClose={() => setOpen(false)}
          useDialog={false}
        />
      </Box>
    );
  },
};

// Edit Form
export const EditForm: Story = {
  render: () => {
    const [open, setOpen] = useState(true);
    return (
      <Box sx={{ p: 3 }}>
        <EntityFormView
          entityService={entityService}
          entity={mockEntity}
          open={open}
          onClose={() => setOpen(false)}
          useDialog={false}
        />
      </Box>
    );
  },
};

// Detail Dialog
export const DetailDialog: Story = {
  render: () => (
    <EntityDetailDialog
      entity={mockEntity}
      open={true}
      onClose={() => {}}
    />
  ),
};
```

## Examples

See implementations in:
- `/src/views/matrix/agents/agents.stories.tsx`
- `/src/views/matrix/models/models.stories.tsx`
- `/src/views/matrix/tools/tools.stories.tsx`
- `/src/views/matrix/prompts/prompts.stories.tsx`

## Icons

Standard icons from Iconify:
- **View**: `solar:eye-bold`
- **Edit**: `solar:pen-bold`
- **Delete**: `solar:trash-bin-trash-bold`
- **Link**: `solar:link-bold`
- **Menu**: `eva:more-vertical-fill`

## Color Scheme

Filter tab colors:
- `default` - Gray
- `primary` - Blue
- `secondary` - Purple
- `success` - Green
- `warning` - Orange
- `error` - Red
- `info` - Light blue
