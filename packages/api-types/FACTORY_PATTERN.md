# Factory Pattern Implementation

## Overview

Services and slices now use a factory pattern where configuration is passed at creation time, not globally.

## Usage

```typescript
import { createFluxServices, createFluxSlices } from '@asyml8/api-types';
import { dataApi } from './axios-config';

// Create services with config
const fluxApi = createFluxServices({ axios: dataApi, basePath: '/api' });

// Create slices (pass services)
const fluxSlices = createFluxSlices(fluxApi);

// Use them
await fluxApi.accounts.listAccounts();
useQuery(fluxSlices.accounts.queryConfig);
```

## Generated Code

### Services

Each service is a factory function:

```typescript
// src/api/flux/services/accounts.service.ts
export const createAccountsService = (axios: AxiosInstance, basePath: string) => {
  const service = new BaseService(axios);
  
  return {
    getAccounts: (id: string) => service.get(`${basePath}/accounts/${id}`),
    listAccounts: () => service.list(`${basePath}/accounts`),
    createAccounts: (data) => service.post(`${basePath}/accounts`, data),
    updateAccounts: (id, data) => service.put(`${basePath}/accounts/${id}`, data),
    deleteAccounts: (id) => service.delete(`${basePath}/accounts/${id}`),
  };
};
```

### Services Index

```typescript
// src/api/flux/services/index.ts
export interface FluxServiceConfig {
  axios: AxiosInstance;
  basePath?: string;
}

export const createFluxServices = (config: FluxServiceConfig): ApiServices => {
  const { axios, basePath = '/api' } = config;
  
  return {
    accounts: createAccountsService(axios, basePath),
    contacts: createContactsService(axios, basePath),
    // ... all other services
  };
};

export type FluxServices = ReturnType<typeof createFluxServices>;
```

### Slices

Each slice is a factory function that accepts a service:

```typescript
// src/api/flux/slices/accounts.slice.ts
export const createAccountsSlice = (service: ResourceService<AccountDto>) => {
  const accountsQuery = createAppQuery(['accounts']);
  
  const accountsQueryConfig = {
    queryFn: () => service.listAccounts(),
    ...defaultQueryConfig,
  };
  
  const createAccountsZustandSlice: StateCreator<AccountsSlice> = createQuerySlice({
    initialFilters: { searchQuery: '' },
  });
  
  return {
    query: accountsQuery,
    queryConfig: accountsQueryConfig,
    createSlice: createAccountsZustandSlice,
  };
};
```

### Slices Index

```typescript
// src/api/flux/slices/index.ts
export const createFluxSlices = (services: ApiServices): ApiSlices => ({
  accounts: createAccountsSlice(services.accounts),
  contacts: createContactsSlice(services.contacts),
  // ... all other slices
});

export type FluxSlices = ReturnType<typeof createFluxSlices>;
```

## Root Exports

```typescript
// src/index.ts
export * as FluxTypes from './api/flux/types';
export { createFluxServices } from './api/flux/services';
export type { FluxServices, FluxServiceConfig } from './api/flux/services';
export { createFluxSlices } from './api/flux/slices';
export type { FluxSlices } from './api/flux/slices';
```

## Benefits

✅ **No global state** - Configuration passed explicitly  
✅ **Testable** - Easy to mock services and config  
✅ **Type-safe** - Full TypeScript support  
✅ **Flexible** - Different configs for different instances  
✅ **Clear dependencies** - Slices depend on services explicitly  

## Migration from Global Config

### Before (Global Config)
```typescript
import { configureFluxApi } from '@asyml8/api-types';

configureFluxApi(dataApi, '/api');
// Services use global config internally
```

### After (Factory Pattern)
```typescript
import { createFluxServices, createFluxSlices } from '@asyml8/api-types';

const fluxApi = createFluxServices({ axios: dataApi, basePath: '/api' });
const fluxSlices = createFluxSlices(fluxApi);
```

## Multiple Instances

You can create multiple instances with different configs:

```typescript
const prodApi = createFluxServices({ 
  axios: prodAxios, 
  basePath: '/api' 
});

const devApi = createFluxServices({ 
  axios: devAxios, 
  basePath: '/dev/api' 
});
```
