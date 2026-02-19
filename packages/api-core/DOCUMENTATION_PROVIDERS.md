# API Documentation Providers

The api-core package now supports multiple API documentation providers: **Swagger UI**, **ReDoc**, and **Scalar**.

## Available Providers

### 1. Swagger UI (Default)
- **URL:** `/docs`
- **Best for:** Interactive API testing
- **Features:** Try-it-out functionality, authorization, request/response examples

### 2. ReDoc
- **URL:** `/redoc`
- **Best for:** Clean, professional documentation
- **Features:** Three-panel layout, better for large APIs, mobile-friendly

### 3. Scalar
- **URL:** `/scalar`
- **Best for:** Modern, fast documentation with built-in API client
- **Features:** Dark mode, better performance, Postman-like interface

## Configuration

### Single Provider

```typescript
await createNestApp(AppModule, {
  title: 'My API',
  description: 'API Description',
  swagger: {
    docProvider: 'swagger',  // or 'redoc' or 'scalar'
  },
});
```

### All Providers

```typescript
await createNestApp(AppModule, {
  title: 'My API',
  description: 'API Description',
  swagger: {
    docProvider: 'all',  // Enables all three
  },
});
```

## Output

When using `docProvider: 'all'`, the server will log:

```
🚀 My API v1.0.0 running on http://localhost:4002/api
📚 Swagger docs: http://localhost:4002/docs
📖 ReDoc docs: http://localhost:4002/redoc
⚡ Scalar docs: http://localhost:4002/scalar
```

## Comparison

| Feature | Swagger UI | ReDoc | Scalar |
|---------|-----------|-------|--------|
| Interactive Testing | ✅ | ❌ | ✅ |
| Clean Design | ⚠️ | ✅ | ✅ |
| Performance | ⚠️ | ✅ | ✅ |
| Mobile Support | ⚠️ | ✅ | ✅ |
| Dark Mode | ❌ | ⚠️ | ✅ |
| Built-in API Client | ❌ | ❌ | ✅ |
| Large API Support | ⚠️ | ✅ | ✅ |

## Examples

### Silo API (All Providers)
```typescript
// api/silo/src/main.ts
await createNestApp(AppModule, {
  title: 'Silo API',
  description: 'Content Storage API',
  swagger: {
    docProvider: 'all',
  },
});
```

### Nexus API (Swagger Only)
```typescript
// api/nexus/src/main.ts
await createNestApp(AppModule, {
  title: 'Nexus API',
  description: 'Core Platform API',
  swagger: {
    docProvider: 'swagger',  // Default
  },
});
```

### Foundry API (ReDoc Only)
```typescript
// api/foundry/src/main.ts
await createNestApp(AppModule, {
  title: 'Foundry API',
  description: 'Data Processing API',
  swagger: {
    docProvider: 'redoc',  // Clean docs for external partners
  },
});
```

## Dependencies

The following packages are installed at the workspace root:
- `redoc-express` - ReDoc integration
- `@scalar/fastify-api-reference` - Scalar integration

No additional configuration needed per API.

## Migration

Existing APIs will continue to use Swagger UI by default. To enable additional providers:

1. Update `main.ts` to add `docProvider` option
2. Rebuild the API
3. Access new documentation URLs

No breaking changes - all existing Swagger configurations remain compatible.
