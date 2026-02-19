# Migration Guide: Mule-Vite Services & Slices to Generated API Types

## Overview

Migrate from manually maintained services and slices to auto-generated ones from `@asyml8/api-types`.

## Step 1: Create API Instances

Add at app startup (e.g., `src/main.tsx` or `src/lib/api-setup.ts`):

```typescript
import { createFluxServices, createFluxSlices, createFoundryServices, createFoundrySlices } from '@asyml8/api-types';
import { dataApi } from 'src/lib/api-setup';

// Create service instances with config
export const fluxApi = createFluxServices({ axios: dataApi, basePath: '/api' });
export const foundryApi = createFoundryServices({ axios: dataApi, basePath: '/api' });

// Create slice instances (pass services)
export const fluxSlices = createFluxSlices(fluxApi);
export const foundrySlices = createFoundrySlices(foundryApi);
```

## Step 2: Update Service Imports

### Before (Manual Services)
```typescript
import { accountService } from 'src/services/account.service';

const accounts = await accountService.listAccounts();
```

### After (Generated Services)
```typescript
import { fluxApi } from 'src/lib/api-setup';

const accounts = await fluxApi.accounts.listAccounts();
```

## Step 3: Update Slice Imports

### Before (Manual Slices)
```typescript
import { accountsQuery, accountsQueryConfig, createAccountsSlice } from 'src/store/accounts.slice';

const { data } = useQuery({
  queryKey: accountsQuery.queryKey,
  ...accountsQueryConfig,
});
```

### After (Generated Slices)
```typescript
import { fluxSlices } from 'src/lib/api-setup';

const { data } = useQuery({
  queryKey: fluxSlices.accounts.query,
  ...fluxSlices.accounts.queryConfig,
});

// Zustand slice
const useStore = create(fluxSlices.accounts.createSlice);
```

## Step 4: Update Type Imports

### Before
```typescript
import type { AccountDto } from '@asyml8/api-types/src/generated/flux';
```

### After
```typescript
import type { FluxTypes } from '@asyml8/api-types';

type Account = FluxTypes.AccountDto;
```

## Step 5: Check API Versions (Optional)

View information about all generated APIs:

```typescript
import { API_VERSIONS } from '@asyml8/api-types';

// Display all APIs
API_VERSIONS.forEach(api => {
  console.log(`${api.title} v${api.version}`);
  console.log(`Generated: ${api.generatedAt}`);
});

// Find specific API
const fluxInfo = API_VERSIONS.find(api => api.name === 'flux');
```

## Step 6: Delete Manual Files

Once migrated, delete:
- `src/services/account.service.ts`
- `src/services/account-public.service.ts`
- `src/services/contact.service.ts`
- `src/services/submission.service.ts`
- `src/services/user.service.ts`
- `src/services/document-types.service.ts`
- `src/store/accounts.slice.ts`
- `src/store/accounts-public.slice.ts`

## Key Differences

### Services

**Manual:**
- Singular method names: `getAccount()`, `listAccounts()`
- Uses endpoints helper: `endpoints.accounts.details(id)`
- Singleton instance: `accountService`

**Generated:**
- Plural method names: `getAccounts()`, `listAccounts()`
- Direct URLs: `/api/accounts/${id}`
- Factory pattern: `createFluxServices({ axios, basePath })`
- Implements `ApiServices` interface

### Slices

**Manual:**
- Direct exports: `accountsQuery`, `accountsQueryConfig`
- Custom filters: `{ type?: string; searchQuery?: string }`

**Generated:**
- Same pattern: grouped by resource
- Factory pattern: `createFluxSlices()`
- Implements `ApiSlices` interface
- Basic filters: `{ searchQuery?: string }`
- Add custom filters manually if needed

## Custom Filters (Optional)

If you need custom filters beyond `searchQuery`, extend the generated slice:

```typescript
import { createFluxSlices } from '@asyml8/api-types';
import type { FluxTypes } from '@asyml8/api-types';

// Extend filters
export type ExtendedAccountFilters = {
  searchQuery?: string;
  type?: string;
  status?: string;
};

// Create custom slice with extended filters
export const createExtendedAccountsSlice: StateCreator<
  QuerySliceState<FluxTypes.AccountDto, ExtendedAccountFilters>
> = createQuerySlice({
  initialFilters: {
    searchQuery: '',
    type: undefined,
    status: undefined,
  },
});
```

## Benefits

- ✅ Auto-generated from swagger specs
- ✅ Always in sync with API
- ✅ Type-safe with common interfaces
- ✅ Less maintenance
- ✅ Consistent patterns across all resources
- ✅ Works with both Flux and Foundry APIs
- ✅ Version tracking with `API_VERSIONS`
