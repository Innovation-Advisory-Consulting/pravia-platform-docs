# Essential Commands

[← Back to Main](../../README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Development Commands

| Task | Command | Status Check |
|------|---------|--------------|
| **Development** |
| **Recommended** | `pnpm dev:supabase` | Full Supabase + all apps |
| Quick development | `pnpm dev` | Simple PostgreSQL + all apps |
| Auth API only | `pnpm dev:auth` | PostgreSQL + auth API |
| Supabase only | `pnpm supabase:start` | Full Supabase stack |
| Database only | `pnpm db:start` | Simple PostgreSQL |
| Build everything | `pnpm build` | No errors in output |
| Run tests | `pnpm test` | All tests pass |
| Lint code | `pnpm lint` | No lint errors |

## Supabase Commands

| Task | Command | Status Check |
|------|---------|--------------|
| Start local | `pnpm supabase:local` | Studio at http://localhost:3000 |
| Stop local | `pnpm supabase:stop` | All containers stopped |
| View logs | `pnpm supabase:logs` | Real-time log output |
| Reset/fresh start | `pnpm supabase:reset` | Clean state |

## AWS Deployment Commands

| Task | Command | Result |
|------|---------|--------|
| Deploy foundation | `cdk deploy --app "npx ts-node --prefer-ts-exts bin/foundation.ts" pravia-foundation` | Shared infrastructure |
| Deploy development | `cdk deploy -c environment=development` | pravia-supabase-development |
| Deploy production | `cdk deploy -c environment=production` | pravia-supabase-production |
| Destroy environment | `cdk destroy -c environment=development` | Resources cleaned up |

## Docker Commands

| Task | Command | Status Check |
|------|---------|--------------|
| Build images | `pnpm docker:build` | Images created |
| Start compose | `pnpm docker:up` | Services running |
| Stop compose | `pnpm docker:down` | Services stopped |

---
**Navigation**: [← Architecture](./architecture.md) | [Next: Development →](../development/README.md)
