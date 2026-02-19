# Service and Slice Generation Setup

## What Was Added

The API types package now automatically generates:

1. **Services** - Type-safe service classes with CRUD methods
2. **Slices** - Zustand slices and React Query configurations

## Files Created

### Scripts
- `scripts/generate-services.js` - Generates service classes from API types
- `scripts/generate-slices.js` - Generates Zustand slices and React Query configs

### Generated Output
- `src/generated/services/` - Service classes for each API
- `src/generated/slices/` - Zustand slices for each API

## Usage

### Generate Everything
```bash
pnpm generate:dev    # From local dev servers
pnpm generate:qa     # From QA environment
pnpm generate:prod   # From production
```

### Generate Individually
```bash
pnpm generate:services  # Only services
pnpm generate:slices    # Only slices
```

## Pattern

The generators follow the same pattern as the existing account service and slice:

### Service Pattern
```typescript
class FluxService extends BaseService {
  async getFlux(id: string): Promise<FluxDto>
  async listFluxs(): Promise<FluxDto[]>
  async createFlux(data: Partial<FluxDto>): Promise<FluxDto>
  async updateFlux(id: string, data: Partial<FluxDto>): Promise<FluxDto>
  async deleteFlux(id: string): Promise<void>
}
```

### Slice Pattern
```typescript
export const fluxsQuery = createAppQuery(['fluxs']);
export const fluxsQueryConfig = { queryFn: () => fluxService.listFluxs(), ...defaultQueryConfig };
export type FluxsSlice = QuerySliceState<FluxDto, FluxFilters>;
export const createFluxsSlice: StateCreator<FluxsSlice> = createQuerySlice<FluxDto, FluxFilters>({ ... });
```

## Integration

Services and slices are automatically exported from the main package:

```typescript
// Import services
import { fluxService, foundryService } from '@asyml8/api-types/generated/services';

// Import slices
import { createFluxsSlice, fluxsQuery } from '@asyml8/api-types/generated/slices';
```

## Notes

- Services use the first DTO type found in each API's data-contracts.ts
- Slices include basic search filters by default
- Both follow the naming conventions from the account examples
- Generated files are checked into git (not in .gitignore)
