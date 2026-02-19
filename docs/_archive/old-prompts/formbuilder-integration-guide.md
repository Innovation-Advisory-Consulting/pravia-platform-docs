# FormBuilder Integration Guide

## Overview
This prompt provides a comprehensive guide for integrating the FormBuilder component into any CRUD interface within the Pravia monorepo, following the successful pattern established for the Roles management system.

## Prerequisites
- FormBuilder component exists in `@asyml8/ui` package
- Target page/section exists in `apps/pravia-web/src/sections/`
- MUI Dialog and form validation requirements understood

## Integration Steps

### 1. Analyze Existing Data Structure
```typescript
// Examine the existing interface in the list view
interface ExistingEntity {
  id: string;
  // ... existing fields
}

// Extend interface for form fields
interface FormEntity extends ExistingEntity {
  // Add any missing form-specific fields
  newField?: string;
  permissions?: string[];
  // ... other form fields
}
```

### 2. Create Form Dialog Component

**File**: `src/sections/[module]/[entity]-form-dialog.tsx`

```typescript
'use client';

import { useState } from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, Button, IconButton, Alert } from '@mui/material';
import { FormBuilder, FormField } from '@asyml8/ui';
import { Iconify } from 'src/components/iconify';

interface EntityFormDialogProps {
  open: boolean;
  onClose: () => void;
  entity?: Entity | null;
  onSubmit: (data: Partial<Entity>) => void;
  loading?: boolean;
}

const formFields: FormField[] = [
  {
    id: 'name',
    type: 'text',
    name: 'name',
    label: 'Name',
    required: true,
    placeholder: 'Enter name',
    width: 2, // Full width: 2, Half width: 1
  },
  {
    id: 'status',
    type: 'select',
    name: 'status',
    label: 'Status',
    required: true,
    width: 1,
    options: [
      { label: 'Active', value: 'active' },
      { label: 'Inactive', value: 'inactive' },
    ],
  },
  {
    id: 'permissions',
    type: 'multiselect',
    name: 'permissions',
    label: 'Permissions',
    width: 2,
    options: [
      { label: 'Read', value: 'read' },
      { label: 'Write', value: 'write' },
    ],
  },
  {
    id: 'isEnabled',
    type: 'checkbox',
    name: 'isEnabled',
    label: 'Enable feature',
    width: 2,
  },
];

export function EntityFormDialog({ open, onClose, entity, onSubmit, loading = false }: EntityFormDialogProps) {
  const [formRef, setFormRef] = useState<HTMLFormElement | null>(null);

  const handleSubmit = (data: Record<string, any>) => {
    onSubmit(data as Partial<Entity>);
  };

  const handleClose = () => {
    if (!loading) {
      onClose();
    }
  };

  const handleSave = () => {
    if (formRef) {
      const submitEvent = new Event('submit', { bubbles: true, cancelable: true });
      formRef.dispatchEvent(submitEvent);
    }
  };

  const isEdit = !!entity?.id;
  const title = isEdit ? 'Edit Entity' : 'Add New Entity';

  // Map existing data to form format
  const defaultValues = entity ? {
    name: entity.name || '',
    status: entity.status || 'active',
    permissions: Array.isArray(entity.permissions) ? entity.permissions : [],
    isEnabled: entity.isEnabled || false,
  } : undefined;

  return (
    <Dialog 
      fullWidth
      maxWidth={false}
      open={open} 
      onClose={handleClose}
      slotProps={{
        paper: {
          sx: { maxWidth: 720 },
        },
      }}
    >
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', pb: 2 }}>
        {title}
        <IconButton onClick={handleClose} disabled={loading}>
          <Iconify icon="mingcute:close-line" />
        </IconButton>
      </DialogTitle>

      <DialogContent sx={{ px: 3 }}>
        {isEdit && (
          <Alert severity="info" sx={{ mb: 3 }}>
            Entity is currently active and in use
          </Alert>
        )}
        
        <div ref={setFormRef}>
          <FormBuilder
            fields={formFields}
            onSubmit={handleSubmit}
            loading={loading}
            columns={2}
            hideSubmitButton={true}
            defaultValues={defaultValues}
          />
        </div>
      </DialogContent>

      <DialogActions sx={{ px: 3, pb: 3 }}>
        <Button 
          onClick={handleClose} 
          disabled={loading}
          variant="outlined"
        >
          Cancel
        </Button>
        <Button 
          onClick={handleSave}
          disabled={loading}
          variant="contained"
        >
          {loading ? 'Saving...' : isEdit ? 'Update' : 'Create'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
```

### 3. Update List View Component

**File**: `src/sections/[module]/view/[entity]-list-view.tsx`

```typescript
// Add imports
import { useState } from 'react';
import { EntityFormDialog } from '../entity-form-dialog';

// Add state management
const [dialogOpen, setDialogOpen] = useState(false);
const [selectedEntity, setSelectedEntity] = useState<Entity | null>(null);
const [loading, setLoading] = useState(false);

// Add handlers
const handleAddEntity = () => {
  setSelectedEntity(null);
  setDialogOpen(true);
};

const handleEditEntity = (entity: Entity) => {
  setSelectedEntity(entity);
  setDialogOpen(true);
};

const handleCloseDialog = () => {
  setDialogOpen(false);
  setSelectedEntity(null);
};

const handleSubmitEntity = async (data: Partial<Entity>) => {
  setLoading(true);
  try {
    // API call simulation
    await new Promise(resolve => setTimeout(resolve, 1000));
    console.log('Entity data:', data);
    handleCloseDialog();
  } catch (error) {
    console.error('Error saving entity:', error);
  } finally {
    setLoading(false);
  }
};

// Update button click handler
<Button
  variant="contained"
  startIcon={<Iconify icon="mingcute:add-line" />}
  onClick={handleAddEntity}
>
  Add Entity
</Button>

// Update table row click
onRowClick={handleEditEntity}

// Add dialog at the end of component
<EntityFormDialog
  open={dialogOpen}
  onClose={handleCloseDialog}
  entity={selectedEntity}
  onSubmit={handleSubmitEntity}
  loading={loading}
/>
```

### 4. Update Index Exports

**File**: `src/sections/[module]/index.ts`

```typescript
export { EntityListView } from './view/entity-list-view';
export { EntityFormDialog } from './entity-form-dialog';
```

## FormBuilder Field Types & Configuration

### Field Types
- `text` - Basic text input
- `email` - Email input with validation
- `number` - Numeric input
- `password` - Password input with masking
- `select` - Single selection dropdown
- `multiselect` - Multiple selection with chips
- `checkbox` - Boolean checkbox
- `date` - Date picker (requires DatePicker provider)

### Field Width Control
- `width: 1` - Half width (50% in two-column layout)
- `width: 2` - Full width (100% in any layout)

### Layout Options
- `columns: 1` - Single column layout
- `columns: 2` - Two column responsive layout

### Props Configuration
```typescript
interface FormBuilderProps {
  fields: FormField[];
  onSubmit: (data: Record<string, any>) => void;
  loading?: boolean;
  columns?: 1 | 2;
  skeleton?: boolean;
  hideSubmitButton?: boolean;
  defaultValues?: Record<string, any>;
}
```

## Dialog Standards (MCP Template Pattern)

### Dialog Structure
```typescript
<Dialog 
  fullWidth
  maxWidth={false}
  open={open} 
  onClose={handleClose}
  slotProps={{
    paper: {
      sx: { maxWidth: 720 }, // Standard width
    },
  }}
>
```

### Form Layout
- Uses CSS Grid with `rowGap: 3` (24px) and `columnGap: 2` (16px)
- Responsive columns: `{ xs: 'repeat(1, 1fr)', sm: 'repeat(2, 1fr)' }`
- Top padding: `pt: 1` to prevent label cutoff

### Button Layout
- Cancel: `variant="outlined"`
- Save: `variant="contained"`
- Proper loading states and disabled states

## Data Mapping Best Practices

### Handle Missing Fields
```typescript
const defaultValues = entity ? {
  name: entity.name || '',
  status: entity.status || 'active',
  permissions: Array.isArray(entity.permissions) ? entity.permissions : [],
  isEnabled: entity.isEnabled || false,
} : undefined;
```

### Type Safety
- Extend existing interfaces for form-specific fields
- Handle type mismatches (number vs array, etc.)
- Provide sensible defaults for missing optional fields

## Validation & Error Handling

### Zod Schema (Automatic)
- FormBuilder automatically generates Zod schema from field configuration
- Required fields are validated
- Email fields get email validation
- Custom validation can be added to field definitions

### Error Display
- Field-level errors show below inputs
- Helper text support for additional guidance
- Form submission blocked until validation passes

## Testing Checklist

- [ ] Form opens on "Add" button click
- [ ] Form opens on row click with populated data
- [ ] All field types render correctly
- [ ] Validation works for required fields
- [ ] Form submits with correct data structure
- [ ] Loading states work properly
- [ ] Dialog closes after successful submission
- [ ] Responsive layout works on mobile/desktop
- [ ] Checkbox alignment matches text inputs
- [ ] No label cutoff issues

## Common Issues & Solutions

### Label Cutoff
- Add `pt: 1` to form container
- Ensure no negative margins on first fields

### Checkbox Spacing
- Use `ml: 1.75` for checkbox alignment
- Avoid negative margins that affect other fields

### Data Population
- Check data structure matches form field names
- Handle missing fields with defaults
- Convert data types as needed (number to array, etc.)

### Form Submission
- Use external buttons with `hideSubmitButton={true}`
- Trigger submission via form ref and dispatchEvent
- Handle async operations with proper loading states

This guide ensures consistent FormBuilder integration across all CRUD interfaces in the Pravia monorepo.
