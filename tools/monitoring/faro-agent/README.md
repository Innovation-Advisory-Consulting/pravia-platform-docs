# Faro Agent

Desktop app for monitoring SaaS application health.

## Stack

- **Electron** + **Vite** + **React 19** + **TypeScript**
- **Zustand** (state) + **TanStack Query** (data fetching)
- **Fastify** (embedded HTTP server) + **Better-SQLite3** (database)
- **@asyml8/ui** (components/theme from mule-vite)

## Architecture

```
Electron Main Process
├── Fastify Server (localhost:3000)
│   └── REST API with CRUD for services
├── Better-SQLite3 Database
└── Window Management

React Renderer
├── TanStack Query → HTTP to localhost:3000
├── Zustand Stores
└── @asyml8/ui Components
```

## Setup

```bash
# Install dependencies
pnpm install

# Start development (default ports: API=3010, Vite=5173)
pnpm dev

# Start with custom ports
SERVER_PORT=3020 VITE_PORT=5174 pnpm dev

# Build for production
pnpm build

# Build platform-specific
pnpm build:mac      # macOS DMG
pnpm build:win      # Windows installer
pnpm build:linux    # Linux AppImage
```

## Features

- ✅ Full CRUD for services (Create, Read, Update, Delete)
- ✅ Embedded Fastify REST API
- ✅ SQLite database for persistence
- ✅ TanStack Query for caching and auto-refetch
- ✅ Zustand for state management
- ✅ @asyml8/ui components and theme
- ✅ Cross-platform (macOS, Windows, Linux)

## API Endpoints

```
GET    /api/health              # Server health check
GET    /api/services            # Get all services
GET    /api/services/:id        # Get service by ID
POST   /api/services            # Create service
PUT    /api/services/:id        # Update service
DELETE /api/services/:id        # Delete service
POST   /api/check-health        # Check URL health
```

## Project Structure

```
faro-agent/
├── electron/              # Electron main process
│   ├── main.ts           # Electron + Fastify server
│   ├── preload.ts        # IPC bridge
│   ├── database.ts       # SQLite setup
│   └── routes.ts         # Fastify CRUD routes
├── src/                  # React renderer
│   ├── main.tsx          # React entry
│   ├── app.tsx           # Providers
│   ├── stores/           # Zustand stores
│   ├── queries/          # TanStack Query hooks
│   ├── pages/            # Page components
│   ├── components/       # UI components
│   ├── layouts/          # Layout components
│   ├── routes/           # Routing
│   └── lib/              # Utilities
└── resources/            # App icons
```

## Development

The app runs two processes:
1. **Main Process**: Electron + Fastify server on port 3000
2. **Renderer Process**: React app on port 5173 (dev) or bundled (prod)

Frontend makes HTTP calls to `http://localhost:3000/api` for all data operations.

## Database

SQLite database stored at: `~/Library/Application Support/faro-agent/faro.db` (macOS)

Schema:
```sql
services (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  url TEXT NOT NULL,
  interval INTEGER DEFAULT 30000,
  enabled INTEGER DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
```

## Next Steps

- Add health check monitoring with auto-refresh
- Add WebSocket for real-time updates
- Add charts for uptime visualization
- Add desktop notifications
- Add system tray integration
- Add export/import configuration

---

Built with ❤️ using Electron + Fastify + React
