# Service Factory Pattern

## Generated Code

Each API now generates a factory function that creates all services at once:

```typescript
// src/api/flux/services/index.ts

export const createFluxServices = (axios: AxiosInstance) => ({
  accounts: accountsService,
  contacts: contactsService,
  submissions: submissionsService,
  documentTypes: documentTypesService,
  // ... all other services
});

export type FluxServices = ReturnType<typeof createFluxServices>;
```

## Usage

### One-time Setup

Configure the API at app startup:

```typescript
// src/lib/api-setup.ts
import { configureFluxApi } from '@asyml8/api-types';
import { dataApi } from './axios-config';

configureFluxApi(dataApi, '/api');
```

### Using Services

**Option A: Factory (Recommended)**

```typescript
import { createFluxServices } from '@asyml8/api-types';

const api = createFluxServices();

// Type-safe access to all services
const accounts = await api.accounts.listAccounts();
const contacts = await api.contacts.listContacts();
```

**Option B: Direct Import**

```typescript
import { accountsService, contactsService } from '@asyml8/api-types';

const accounts = await accountsService.listAccounts();
const contacts = await contactsService.listContacts();
```

## Benefits

- ✅ One-line initialization: `const api = createFluxServices()`
- ✅ Type-safe access to all services via `FluxServices` type
- ✅ Auto-generated - no manual maintenance
- ✅ Consistent pattern across Flux and Foundry APIs
- ✅ Services automatically added/removed when swagger changes

## Implementation

The generator:
1. Collects all resource names from swagger paths
2. Sorts them alphabetically
3. Generates exports for each service
4. Generates imports for each service
5. Creates factory function that returns object with all services
6. Exports TypeScript type for the factory return value

Note: The `axios` parameter is currently unused since services use the global config pattern (`getFluxAxiosInstance()`), but it's included for API consistency and potential future use.
