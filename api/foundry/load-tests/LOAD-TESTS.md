# Load Tests

## Overview
Artillery load testing configuration for Foundry API.

## Test Files
- `auth-flow.yml` - Authentication flow testing
- `admin-operations.yml` - Admin endpoint testing
- `stress-test.yml` - Stress testing
- `setup.js` - Test setup and configuration

## Running Tests
```bash
pnpm load:setup    # Setup test users
pnpm load:test     # Run load tests
pnpm load:stress   # Stress test
pnpm load:report   # Generate report
```

See parent: `api/foundry/FOUNDRY-API.md`
