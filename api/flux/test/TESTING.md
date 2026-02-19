# Flux Testing

## Overview
Test files for Flux API including unit, integration, and E2E tests.

## Structure
- `integration/` - Integration tests
- `mocks/` - Test mocks and fixtures
- `*.e2e-spec.ts` - End-to-end tests
- `setup-e2e.ts` - E2E test setup
- `setup-integration.ts` - Integration test setup
- `setup.ts` - General test setup
- `test-helper.ts` - Test utilities
- `jest-e2e.json` - E2E Jest configuration
- `jest-integration.json` - Integration Jest configuration

## Running Tests
```bash
pnpm test              # Unit tests
pnpm test:e2e          # E2E tests
pnpm test:integration  # Integration tests
pnpm test:cov          # With coverage
```

See parent: `api/flux/FLUX-API.md`
