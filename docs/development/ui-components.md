# UI Components Package

The `@asyml8/ui` package contains reusable React components built with Material-UI.

## Installation

The UI package is automatically available in all apps within the monorepo via workspace dependencies.

## Usage

```typescript
import { DataTable, Column } from '@asyml8/ui';
```

## Components

### DataTable

A reusable data table component with TanStack Query integration.

**Features:**
- Sorting, pagination, selection
- Dense mode toggle
- Loading and error states
- Customizable columns with render functions

**Example:**
```typescript
const columns: Column<User>[] = [
  {
    id: 'name',
    label: 'Name',
    sortable: true,
    render: (_, user) => <UserNameCell user={user} />
  },
  { id: 'email', label: 'Email', width: 220 },
];

<DataTable
  queryKey={['users']}
  queryFn={fetchUsers}
  columns={columns}
  getRowId={(user) => user.id}
  onRowSelect={(ids) => console.log('Selected:', ids)}
/>
```

## Development Commands

From monorepo root:

```bash
# Build UI package
pnpm --filter @asyml8/ui build

# Watch mode for development
pnpm --filter @asyml8/ui dev

# Run Storybook
pnpm --filter @asyml8/ui storybook
```

## Adding New Components

1. Create component in `packages/ui/src/components/`
2. Export from `packages/ui/src/index.ts`
3. Build the package: `pnpm --filter @asyml8/ui build`
4. Use in apps: `import { NewComponent } from '@asyml8/ui'`
