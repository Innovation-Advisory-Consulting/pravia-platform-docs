# API Documentation

[← Back to Main](../../README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Application Services

### Frontend Application
- **pravia-web** - Frontend React/Next.js application
- **Local URL**: http://localhost:3000

### Backend APIs
- **pravia-platform-api** - Core backend API service
- **pravia-data-api** - Data synchronization and ETL API
- **pravia-auth-api** - Authentication API service
- **pravia-compliance-api** - Compliance and regulatory API for SAML/OIDC

## Local Development Endpoints

### Simple PostgreSQL (`pnpm dev`)
- **Frontend**: http://localhost:3000
- **APIs**: Various ports (check terminal output)
- **pgAdmin**: http://localhost:5050
  - Login: `admin@asyml8.com` / `admin123`

### Full Supabase (`pnpm dev:supabase` - recommended)
- **Frontend**: http://localhost:3000
- **APIs**: Various ports (check terminal output)
- **Supabase API**: http://127.0.0.1:54321
- **Supabase Studio**: http://127.0.0.1:54323
- **Database**: postgresql://postgres:postgres@127.0.0.1:54322/postgres
- **Mailpit**: http://127.0.0.1:54324

## Database Connection Details

### Simple PostgreSQL Configuration
```env
DATABASE_HOST=localhost
DATABASE_PORT=54322
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_DB_NAME=postgres
```

### Full Supabase Configuration
```env
DATABASE_HOST=localhost
DATABASE_PORT=54322
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_DB_NAME=postgres

# Supabase API config
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH
SUPABASE_SERVICE_KEY=sb_secret_N7UND0UgjKTVK-Uodkm0Hg_xSvEMPvz
```

## Application Configuration

### Frontend (pravia-web)
```bash
# apps/pravia-web/.env.local
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_SUPABASE_URL=http://localhost:8000
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

### Backend API (pravia-platform-api)
```bash
# apps/pravia-platform-api/.env.local
DATABASE_URL=postgresql://postgres:supabase123@localhost:5432/postgres
SUPABASE_SERVICE_KEY=your-service-key
```

## Production Endpoints

### Supabase Services
- **Supabase Studio**: `https://studio.yourdomain.com`
- **Supabase API**: `https://api.yourdomain.com`
- **REST API**: `https://api.yourdomain.com/rest/v1/`
- **Auth API**: `https://api.yourdomain.com/auth/v1/`
- **Storage API**: `https://api.yourdomain.com/storage/v1/`
- **Realtime**: `wss://api.yourdomain.com/realtime/v1/`

## API Testing

### Authentication Test
```bash
curl -X POST https://your-domain.com/auth/v1/signup \
  -H "Content-Type: application/json" \
  -H "apikey: $(grep ANON_KEY .env | cut -d'=' -f2)" \
  -d '{"email": "test@yourdomain.com", "password": "password123"}'
```

## Service Documentation Links

### Application READMEs
- [**Frontend (Next.js)**](../../apps/pravia-web/README.md) - React app setup, routing, and components
- [**Core API**](../../apps/pravia-platform-api/README.md) - Main backend service and business logic
- [**Auth API**](../../apps/pravia-auth-api/README.md) - Authentication and user management
- [**Data API**](../../apps/pravia-data-api/README.md) - ETL processes and data synchronization
- [**Compliance API**](../../apps/pravia-compliance-api/README.md) - SAML/OIDC identity provider integration

### Shared Packages
- [**SDK**](../../packages/sdk/README.md) - API client and TypeScript type definitions
- [**Configuration**](../../packages/config/README.md) - Environment and app configuration
- [**Utilities**](../../packages/utils/README.md) - Common TypeScript utilities and helpers
