# Development Workflow

[← Back to Main](../../README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Local Development

```bash
# Start everything for development
pnpm dev:supabase              # Full Supabase + all apps (recommended)
pnpm dev                       # Simple PostgreSQL + all apps
pnpm dev:auth                  # Simple PostgreSQL + auth API only

# Individual services
pnpm supabase:start            # Full Supabase stack only
pnpm db:start                  # Simple PostgreSQL only

# Work on specific components
cd packages/ui && pnpm storybook    # Component development
cd apps/pravia-web && pnpm dev      # Frontend only (assumes database running)
```

## Database Options

### Option 1: Simple PostgreSQL (Quick Development)
```bash
pnpm dev              # PostgreSQL + all apps
pnpm db:start         # PostgreSQL + pgAdmin only
```
- **PostgreSQL**: localhost:5432 (postgres/postgres)
- **pgAdmin**: http://localhost:5050 
  - Email: admin@asyml8.com
  - Password: admin123
  - **Add Minimal Server**:
    - Host: `minimal-postgres` *(same Docker network)*
    - Port: `5432`
    - User: `postgres`
    - Password: `postgres`
  - **Add Supabase Server**:
    - Host: `host.docker.internal` *(in supabase container with other images)*
    - Port: `54322`
    - User: `postgres`
    - Password: `postgres`

### Option 2: Full Supabase Stack (Official CLI)
```bash
pnpm dev:supabase     # Supabase + all apps
pnpm supabase:start   # Supabase stack only
```
- **API URL**: http://127.0.0.1:54321
- **Database**: postgresql://postgres:postgres@127.0.0.1:54322/postgres
- **Studio**: http://127.0.0.1:54323
- **Mailpit**: http://127.0.0.1:54324

## Connection Details for APIs

**Simple PostgreSQL** (`pnpm dev`):
```env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_DB_NAME=postgres
```

**Full Supabase** (`pnpm dev:supabase` - **recommended**):
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

## Related Documentation
- [Database Options](./database-options.md) - Detailed database setup
- [Configuration](./configuration.md) - Environment variables and setup
