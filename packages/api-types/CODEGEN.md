# API Type Generation

Automatically generate TypeScript types, services, and slices from multiple Swagger/OpenAPI specifications.

## Prerequisites

1. **Start API servers** (for local generation)
   ```bash
   # Terminal 1 - Flux API
   cd api/flux
   pnpm dev
   
   # Terminal 2 - Foundry API (optional)
   cd api/foundry
   pnpm dev
   ```

2. **Install dependencies**
   ```bash
   pnpm install
   ```

## Usage

### Generate from Local Dev Servers

```bash
pnpm generate:dev
```

Generates types, services, and slices from:
- `http://localhost:4001/docs-json` → `flux.ts`
- `http://localhost:4002/docs-json` → `foundry.ts`

### Generate from QA Environment

```bash
pnpm generate:qa
```

### Generate from Production

```bash
pnpm generate:prod
```

### Generate Only Services or Slices

```bash
pnpm generate:services  # Generate only services
pnpm generate:slices    # Generate only slices
```

## Output

Generated files are saved to:
```
src/generated/
  ├── flux/
  │   ├── data-contracts.ts
  │   └── index.ts
  ├── foundry/
  │   ├── data-contracts.ts
  │   └── index.ts
  ├── services/
  │   ├── flux.service.ts
  │   ├── foundry.service.ts
  │   └── index.ts
  ├── slices/
  │   ├── flux.slice.ts
  │   ├── foundry.slice.ts
  │   └── index.ts
  └── index.ts
```

## Using Generated Types

### Import from Specific API

```typescript
import type { flux, foundry } from '@asyml8/api-types/generated';

// Flux API types
type RegisterRequest = flux.paths['/api/register']['post']['requestBody']['content']['application/json'];
type RegisterResponse = flux.paths['/api/register']['post']['responses']['201']['content']['application/json'];

// Foundry API types
type SubmissionRequest = foundry.paths['/api/submissions']['post']['requestBody']['content']['application/json'];
```

### Using Generated Services

```typescript
import { fluxService } from '@asyml8/api-types/generated/services';

// List all items
const items = await fluxService.listFluxs();

// Get single item
const item = await fluxService.getFlux('123');

// Create new item
const newItem = await fluxService.createFlux({ name: 'Test' });

// Update item
const updated = await fluxService.updateFlux('123', { name: 'Updated' });

// Delete item
await fluxService.deleteFlux('123');
```

### Using Generated Slices

```typescript
import { createFluxsSlice, fluxsQuery, fluxsQueryConfig } from '@asyml8/api-types/generated/slices';
import { useQuery } from '@tanstack/react-query';

// In React component
function MyComponent() {
  const { data, isLoading } = useQuery({
    queryKey: fluxsQuery.queryKey,
    ...fluxsQueryConfig,
  });
  
  return <div>{/* render data */}</div>;
}

// In Zustand store
import { create } from 'zustand';

const useStore = create(createFluxsSlice);
```

## Example: Type-Safe API Client

```typescript
import type { flux } from '@asyml8/api-types/generated';

type RegisterEndpoint = flux.paths['/api/register']['post'];
type RegisterRequest = RegisterEndpoint['requestBody']['content']['application/json'];
type RegisterResponse = RegisterEndpoint['responses']['201']['content']['application/json'];

async function registerOrganization(data: RegisterRequest): Promise<RegisterResponse> {
  const response = await fetch('/api/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  
  return response.json();
}

// Usage - fully type-safe!
const result = await registerOrganization({
  organizationType: 448150002,
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  phone: '555-1234',
  businessPhone: '555-5678',
  organizationName: 'Test Org',
  acceptedTerms: true,
});

console.log(result.body.id); // ✅ TypeScript knows this exists
```
