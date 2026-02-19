# Common API Interfaces

## Overview

All APIs (Flux, Foundry, etc.) implement common interfaces to ensure consistency and interchangeability.

## Interfaces

### ApiServices

Defines the structure for service collections:

```typescript
// src/core/api-services.interface.ts

export interface ResourceService<T = any> {
  get?: (id: string) => Promise<T>;
  list?: () => Promise<T[]>;
  create?: (data: Partial<T>) => Promise<T>;
  update?: (id: string, data: Partial<T>) => Promise<T>;
  delete?: (id: string) => Promise<void>;
}

export interface ApiServices {
  [resourceName: string]: ResourceService;
}
```

### ApiSlices

Defines the structure for slice collections:

```typescript
// src/core/api-slices.interface.ts

export interface ResourceSlice<T = any, F = any> {
  query: QueryKey;
  queryConfig: {
    queryFn: () => Promise<T[]>;
    [key: string]: any;
  };
  createSlice: StateCreator<any>;
}

export interface ApiSlices {
  [resourceName: string]: ResourceSlice;
}
```

## Implementation

### Flux API

```typescript
// Generated in src/api/flux/services/index.ts
export const createFluxServices = (_axios: AxiosInstance): ApiServices => ({
  accounts: accountsService,
  contacts: contactsService,
  submissions: submissionsService,
  // ... all other services
});

export type FluxServices = ReturnType<typeof createFluxServices>;
```

```typescript
// Generated in src/api/flux/slices/index.ts
export const createFluxSlices = (): ApiSlices => ({
  accounts: {
    query: accountsQuery,
    queryConfig: accountsQueryConfig,
    createSlice: createAccountsSlice,
  },
  contacts: {
    query: contactsQuery,
    queryConfig: contactsQueryConfig,
    createSlice: createContactsSlice,
  },
  // ... all other slices
});

export type FluxSlices = ReturnType<typeof createFluxSlices>;
```

### Foundry API

When generated, will follow the same pattern:

```typescript
export const createFoundryServices = (_axios: AxiosInstance): ApiServices => ({...});
export type FoundryServices = ReturnType<typeof createFoundryServices>;

export const createFoundrySlices = (): ApiSlices => ({...});
export type FoundrySlices = ReturnType<typeof createFoundrySlices>;
```

## Benefits

✅ **Consistency** - All APIs expose the same structure  
✅ **Interchangeability** - Easy to swap between APIs  
✅ **Type Safety** - TypeScript enforces the interface  
✅ **Maintainability** - Changes to interface apply to all APIs  
✅ **Discoverability** - IDE autocomplete works across all APIs  

## Usage

```typescript
import { createFluxServices, createFluxSlices } from '@asyml8/api-types';

// Both implement common interfaces
const services = createFluxServices();
const slices = createFluxSlices();

// Type-safe access
const accounts = await services.accounts.listAccounts();
const { data } = useQuery(slices.accounts.queryConfig);
```

## Generic Functions

The common interfaces enable writing generic functions that work with any API:

```typescript
import type { ApiServices, ApiSlices } from '@asyml8/api-types';

function useResource<T>(
  services: ApiServices,
  slices: ApiSlices,
  resourceName: string
) {
  const service = services[resourceName];
  const slice = slices[resourceName];
  
  return useQuery({
    queryKey: slice.query,
    queryFn: slice.queryConfig.queryFn,
  });
}

// Works with any API
const fluxAccounts = useResource(fluxServices, fluxSlices, 'accounts');
const foundryAccounts = useResource(foundryServices, foundrySlices, 'accounts');
```
