# DataTable Integration Guide

This guide explains how to integrate a new data source with the DataTable component in the Pravia web app.

## Overview

The DataTable component requires:
1. **Service Layer** - API calls and data fetching
2. **Store Layer** - Query state management  
3. **View Layer** - Component with columns and data transformation
4. **Type Definitions** - TypeScript interfaces

## Step 1: Create the Service

### 1.1 Add API Endpoints to axios config

```typescript
// src/lib/axios.ts
export const endpoints = {
  // ... existing endpoints
  yourEntity: {
    list: '/api/your-entity',  // or full URL if different port
    details: (id: string) => `/api/your-entity/${id}`,
    create: '/api/your-entity',
    update: (id: string) => `/api/your-entity/${id}`,
    delete: (id: string) => `/api/your-entity/${id}`,
  },
};
```

### 1.2 Create the Service File

```typescript
// src/lib/your-entity-service.ts
import axiosInstance, { endpoints } from './axios';

export interface YourEntity {
  id: string;
  name?: string;
  email?: string;
  // ... other fields from your API
}

export const yourEntityService = {
  async listEntities(): Promise<YourEntity[]> {
    const response = await axiosInstance.get(endpoints.yourEntity.list);
    console.log('Raw API response:', response.data);
    return response.data.body || response.data; // Adjust based on API structure
  },

  async getEntity(id: string): Promise<YourEntity> {
    const response = await axiosInstance.get(endpoints.yourEntity.details(id));
    return response.data.body || response.data;
  },

  async createEntity(entity: Partial<YourEntity>): Promise<YourEntity> {
    const response = await axiosInstance.post(endpoints.yourEntity.create, entity);
    return response.data.body || response.data;
  },

  async updateEntity(id: string, entity: Partial<YourEntity>): Promise<YourEntity> {
    const response = await axiosInstance.put(endpoints.yourEntity.update(id), entity);
    return response.data.body || response.data;
  },

  async deleteEntity(id: string): Promise<void> {
    await axiosInstance.delete(endpoints.yourEntity.delete(id));
  },
};
```

## Step 2: Create the Store

```typescript
// src/stores/your-entity-store.ts
import { createQueryStore } from '@asyml8/ui';
import { yourEntityService } from 'src/lib/your-entity-service';

export const yourEntityStore = createQueryStore(['your-entity']);

export const yourEntityQueryConfig = {
  queryFn: () => yourEntityService.listEntities(),
  staleTime: 5 * 60 * 1000, // 5 minutes
};
```

## Step 3: Create the View Component

```typescript
// src/sections/your-section/your-entity/view/your-entity-list-view.tsx
'use client';

import { Avatar, Box, Typography } from '@mui/material';
import { DataTable, Column, PageHeader } from '@asyml8/ui';
import { DashboardContent } from 'src/layouts/dashboard';
import { Iconify } from 'src/components/iconify';
import { useTranslation } from 'src/hooks/use-translation';
import { yourEntityStore, yourEntityQueryConfig } from 'src/stores/your-entity-store';
import type { YourEntity } from 'src/lib/your-entity-service';

// Transform API data to display format
const transformEntity = (entity: YourEntity) => ({
  id: entity.id,
  name: entity.name || 'Unknown',
  email: entity.email || '',
  // ... map other fields
});

export function YourEntityListView() {
  const { t } = useTranslation();

  // CRITICAL: Use (_, row) => pattern, NOT (row) =>
  const columns: Column<ReturnType<typeof transformEntity>>[] = [
    {
      id: 'name',
      label: 'Name',
      render: (_, entity) => (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Avatar sx={{ width: 40, height: 40 }}>
            {(entity.name || 'U').charAt(0).toUpperCase()}
          </Avatar>
          <Box>
            <Typography variant="subtitle2">{entity.name || 'Unknown'}</Typography>
            <Typography variant="body2" color="text.secondary">
              {entity.email}
            </Typography>
          </Box>
        </Box>
      ),
    },
    {
      id: 'otherField',
      label: 'Other Field',
      render: (_, entity) => (
        <Typography variant="body2">
          {entity.otherField || '-'}
        </Typography>
      ),
    },
  ];

  return (
    <DashboardContent>
      <PageHeader
        title="Your Entities"
        action={{
          label: "Add Entity",
          onClick: () => console.log("Add entity clicked"),
          icon: <Iconify icon="mingcute:add-line" />,
        }}
      />

      <DataTable
        store={{
          useQuery: () => {
            const query = yourEntityStore.useQuery(yourEntityQueryConfig);
            return {
              ...query,
              data: Array.isArray(query.data) ? query.data.map(transformEntity) : [],
            };
          },
        }}
        columns={columns}
        getRowId={(entity) => entity.id}
        searchConfig={{
          placeholder: 'Search entities...',
          searchFields: ['name', 'email'], // Fields to search
        }}
      />
    </DashboardContent>
  );
}
```

## Step 4: Create the Page

```typescript
// src/app/your-section/your-entity/page.tsx
import { YourEntityListView } from 'src/sections/your-section/your-entity/view/your-entity-list-view';

export default function YourEntityPage() {
  return <YourEntityListView />;
}
```

## Common Issues & Solutions

### 1. Empty Table Despite Data Loading
**Problem**: Data loads in console but table is empty
**Solution**: Check column render functions use `(_, row) =>` pattern, not `(row) =>`

### 2. API Data Not Loading
**Problem**: Network errors or undefined data
**Solutions**:
- Check API endpoint URLs in axios config
- Verify API is running on correct port
- Check CORS settings if cross-origin
- Verify authentication tokens

### 3. Data Structure Mismatch
**Problem**: Fields are undefined in transform function
**Solutions**:
- Log raw API response: `console.log('Raw API response:', response.data)`
- Check if data is nested (e.g., `response.data.body`)
- Verify field names match API response exactly

### 4. TypeScript Errors
**Problem**: Type mismatches in columns or transform
**Solutions**:
- Ensure interface matches API response structure
- Use `ReturnType<typeof transformEntity>` for column types
- Add optional fields with `?` if they might be missing

## Best Practices

1. **Always log raw API responses** during development
2. **Use consistent naming** between service, store, and view files
3. **Handle empty/null values** in transform function with fallbacks
4. **Use proper TypeScript types** for better development experience
5. **Follow the working users service pattern** as reference
6. **Test with real API data** before removing console logs

## Example File Structure

```
src/
├── lib/
│   └── your-entity-service.ts
├── stores/
│   └── your-entity-store.ts
├── sections/
│   └── your-section/
│       └── your-entity/
│           └── view/
│               └── your-entity-list-view.tsx
└── app/
    └── your-section/
        └── your-entity/
            └── page.tsx
```

## Reference Implementation

See the working examples:
- **Users**: `src/sections/admin/users/view/users-list-view.tsx`
- **Contacts**: `src/sections/workspace/contacts/view/contacts-list-view.tsx`

The users service is the gold standard - copy its patterns exactly.