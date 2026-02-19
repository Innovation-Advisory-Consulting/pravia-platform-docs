# Quick Start

## 🚀 Get Started

```bash
# 1. Install dependencies
pnpm install

# 2. Start development
pnpm dev
```

The app will:
- Start Fastify server on `http://localhost:3000`
- Start React dev server on `http://localhost:5173`
- Open Electron window automatically

## ✅ What's Built

**22 files created with:**
- ✅ Electron + Fastify server (localhost:3000)
- ✅ Better-SQLite3 database
- ✅ React 19 + TypeScript
- ✅ Zustand state management
- ✅ TanStack Query data fetching
- ✅ @asyml8/ui components
- ✅ Full CRUD for services

## 📝 Test the App

1. **Add a service**: Fill in the form at the top
2. **View services**: See cards below
3. **Delete service**: Click trash icon

## 🔧 API Endpoints

All available at `http://localhost:3000/api`:
- `GET /health` - Server status
- `GET /services` - List all services
- `POST /services` - Create service
- `PUT /services/:id` - Update service
- `DELETE /services/:id` - Delete service
- `POST /check-health` - Check URL health

## 📦 Build for Production

```bash
# All platforms
pnpm build

# Platform-specific
pnpm build:mac      # macOS DMG
pnpm build:win      # Windows installer
pnpm build:linux    # Linux AppImage
```

## 🗄️ Database Location

- **macOS**: `~/Library/Application Support/faro-agent/faro.db`
- **Windows**: `%APPDATA%/faro-agent/faro.db`
- **Linux**: `~/.config/faro-agent/faro.db`

## 🎨 Theme

Toggle dark/light mode using the settings icon (gear) in the top right.

## 📚 Stack

- **Frontend**: React 19, MUI, @asyml8/ui
- **State**: Zustand + TanStack Query
- **Backend**: Fastify (embedded)
- **Database**: Better-SQLite3
- **Desktop**: Electron

---

**Ready to go!** Run `pnpm install && pnpm dev`
