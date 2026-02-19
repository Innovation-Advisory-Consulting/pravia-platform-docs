# Getting Started with Pravia

[← Back to Main](../../README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Prerequisites Checklist
- [ ] Node.js 20+ installed
- [ ] pnpm 9+ installed (`npm install -g pnpm`)
- [ ] Docker Desktop running
- [ ] **Supabase CLI** installed (`brew install supabase/tap/supabase`)
- [ ] Git installed

## Get Running in 2 Minutes
```bash
# Clone and setup
git clone <your-repo-url>
cd pravia-monorepo
pnpm install

# Start with full Supabase stack (recommended)
pnpm dev:supabase

# OR start with simple PostgreSQL only
pnpm dev
```

✅ **Expected Result**: All services running
- Frontend: http://localhost:3000
- APIs: Various ports (check terminal output)
- **Supabase Studio**: http://127.0.0.1:54323

## Start Database (PostgreSQL + pgAdmin)
```bash
# Start local PostgreSQL with pgAdmin
pnpm db:start

# Check status
pnpm db:logs

# Stop when done
pnpm db:stop
```

✅ **Expected Result**: 
- PostgreSQL: localhost:54322 (postgres/postgres)
- pgAdmin: http://localhost:5050 (admin@asyml8.com/admin123)

## Next Steps
- [Architecture Overview](./architecture.md) - Understand the system design
- [Essential Commands](./commands.md) - Key development commands
- [Development Workflow](../development/README.md) - Daily development setup
