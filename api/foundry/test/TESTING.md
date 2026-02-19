# Foundry Testing

## Overview
Test files for Foundry API.

## Structure
- `*.e2e-spec.ts` - End-to-end tests
- `setup-e2e.ts` - E2E test setup
- `setup.ts` - General test setup
- `test-setup.ts` - Test configuration
- `jest-e2e.json` - Jest E2E configuration

## Running Tests
```bash
pnpm test          # Unit tests
pnpm test:e2e      # E2E tests
pnpm test:cov      # With coverage
pnpm test:all      # All tests
```

See parent: `api/foundry/FOUNDRY-API.md`
