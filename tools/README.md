# Development Tools

This directory contains specialized development tools that enhance productivity, code quality, and monitoring capabilities for the Pravia CRM Platform.

## Directory Structure

```
tools/
├── mcp/            # Model Context Protocol servers for AI-assisted development
├── monitoring/     # Application monitoring and observability tools
└── quickstart/     # Quick start templates and examples
```

---

## 1. MCP (Model Context Protocol) Servers

**Purpose:** AI-powered development tools that integrate with Claude Code and other AI assistants to enhance development workflows.

**Location:** `tools/mcp/`

### What is MCP?

Model Context Protocol (MCP) is a standard for connecting AI assistants to external tools and data sources. These servers provide specialized capabilities to AI assistants like Claude Code, enabling them to understand and work with your codebase more effectively.

### Available MCP Servers

#### Component Analyzer MCP
**Path:** `tools/mcp/component-analyzer-mcp/`

**Purpose:** Analyze React components and identify opportunities to extract reusable components to the shared UI package.

**Features:**
- **Component Scanning** - Analyze all React components automatically
- **Extraction Candidates** - Identify components with high reusability scores (0-100)
- **Duplicate Detection** - Find duplicate patterns across components
- **Usage Analysis** - Track component usage throughout codebase
- **Existence Checking** - Check if similar components exist in UI package
- **Migration Tracking** - Track which components have been migrated
- **Extraction Planning** - Generate detailed extraction plans

**Reusability Scoring Criteria:**
- Props Interface (+20)
- Default Props (+10)
- Documentation (+15)
- Generic Nature (+25)
- Minimal Dependencies (+20)
- Low Complexity (+10)

**Available Tools:**
- `scan_components` - Scan and analyze React components
- `find_extraction_candidates` - Find components with high reusability scores
- `check_if_exists_in_ui` - Check if component exists in UI package
- `analyze_component_usage` - Show where component is used
- `generate_extraction_plan` - Generate step-by-step extraction plan
- `track_migration_status` - Track migration progress
- `find_duplicate_patterns` - Find duplicate code patterns

**Installation:**
```bash
cd tools/mcp/component-analyzer-mcp
npm install
npm run build
```

**Configuration (Claude Code):**
Add to `~/Library/Application Support/Claude/config.json`:
```json
{
  "mcpServers": {
    "component-analyzer": {
      "command": "node",
      "args": ["/path/to/tools/mcp/component-analyzer-mcp/dist/index.js"],
      "env": {
        "MONOREPO_ROOT": "/path/to/pravia-mule-platform"
      }
    }
  }
}
```

**Usage Examples:**
```
Can you scan all my components and find extraction candidates?
Check if there's already a similar component to AnimateText in the UI package
Generate an extraction plan for the MotionContainer component
Show me everywhere the CustomCard component is used
```

**Documentation:**
- `tools/mcp/component-analyzer-mcp/README.md` (7KB)
- `tools/mcp/component-analyzer-mcp/SETUP.md` (4KB)

---

#### AWS Docs MCP
**Path:** `tools/mcp/aws-docs-mcp/`

**Purpose:** Provide AI assistants with access to AWS documentation and best practices.

**Features:**
- Search AWS documentation
- Get service-specific guidance
- Access AWS best practices
- CDK examples and patterns

**Installation:**
```bash
cd tools/mcp/aws-docs-mcp
npm install
npm run build
```

**Documentation:** `tools/mcp/aws-docs-mcp/README.md`

---

#### AWS Resources MCP
**Path:** `tools/mcp/aws-resources-mcp/`

**Purpose:** Query and manage AWS resources directly from AI assistants.

**Features:**
- List AWS resources
- Get resource details
- Query CloudFormation stacks
- Check resource status

**Installation:**
```bash
cd tools/mcp/aws-resources-mcp
npm install
```

**Documentation:** `tools/mcp/aws-resources-mcp/README.md` (4KB)

---

#### Frontend Templates MCP
**Path:** `tools/mcp/frontend-templates-mcp/`

**Purpose:** Generate frontend components and pages from templates.

**Features:**
- Generate React components
- Create page templates
- Generate forms with validation
- Create CRUD interfaces

**Installation:**
```bash
cd tools/mcp/frontend-templates-mcp
npm install
```

**Documentation:** `tools/mcp/frontend-templates-mcp/README.md` (2.5KB)

---

#### Monorepo Compliance MCP
**Path:** `tools/mcp/monorepo-compliance-mcp/`

**Purpose:** Ensure monorepo structure and conventions are followed.

**Features:**
- Check package structure
- Validate dependencies
- Enforce naming conventions
- Check for circular dependencies

**Installation:**
```bash
cd tools/mcp/monorepo-compliance-mcp
npm install
```

---

#### NPM Packages MCP
**Path:** `tools/mcp/npm-packages-mcp/`

**Purpose:** Search and analyze NPM packages.

**Features:**
- Search NPM registry
- Get package information
- Check package versions
- Analyze dependencies

**Installation:**
```bash
cd tools/mcp/npm-packages-mcp
npm install
```

---

#### Context Manager MCP
**Path:** `tools/mcp/context-manager-mcp/`

**Purpose:** Manage AI assistant context and conversation history.

**Features:**
- Save conversation context
- Load previous contexts
- Organize context by project
- Share context between sessions

---

#### Component Converter MCP
**Path:** `tools/mcp/component-converter-mcp/`

**Purpose:** Convert components between different frameworks and libraries.

**Features:**
- Convert between React and Vue
- Convert class components to functional
- Convert to TypeScript
- Update to latest patterns

---

### Installing All MCP Servers

**Bulk Installation:**
```bash
cd tools/mcp
./install-mcps.sh
```

This script installs and builds all MCP servers at once.

---

## 2. Monitoring Tools

**Purpose:** Application monitoring and observability tools.

**Location:** `tools/monitoring/`

### Faro Agent

**Path:** `tools/monitoring/faro-agent/`

**Purpose:** Desktop app for monitoring SaaS application health.

**Technology Stack:**
- Electron + Vite + React 19 + TypeScript
- Zustand (state management)
- TanStack Query (data fetching)
- Fastify (embedded HTTP server)
- Better-SQLite3 (database)
- @asyml8/ui (components and theme)

**Architecture:**
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

**Features:**
- ✅ Full CRUD for services (Create, Read, Update, Delete)
- ✅ Embedded Fastify REST API
- ✅ SQLite database for persistence
- ✅ TanStack Query for caching and auto-refetch
- ✅ Zustand for state management
- ✅ @asyml8/ui components and theme
- ✅ Cross-platform (macOS, Windows, Linux)

**Setup:**
```bash
cd tools/monitoring/faro-agent
pnpm install

# Start development
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

**API Endpoints:**
```
GET    /api/health              # Server health check
GET    /api/services            # Get all services
GET    /api/services/:id        # Get service by ID
POST   /api/services            # Create service
PUT    /api/services/:id        # Update service
DELETE /api/services/:id        # Delete service
POST   /api/check-health        # Check URL health
```

**Database:**
SQLite database stored at: `~/Library/Application Support/faro-agent/faro.db` (macOS)

**Schema:**
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

**Future Enhancements:**
- Health check monitoring with auto-refresh
- WebSocket for real-time updates
- Charts for uptime visualization
- Desktop notifications
- System tray integration
- Export/import configuration

**Documentation:**
- `tools/monitoring/faro-agent/README.md` (3.5KB)
- `tools/monitoring/faro-agent/QUICKSTART.md` (1.8KB)

---

## 3. Quickstart Templates

**Purpose:** Quick start templates and examples for rapid development.

**Location:** `tools/quickstart/`

### Base API Template

**Path:** `tools/quickstart/base-api/`

**Purpose:** Minimal NestJS API template for quick prototyping.

**Features:**
- NestJS + Fastify
- Docker support
- Basic health check
- Swagger documentation
- TypeScript configuration

**Usage:**
```bash
cd tools/quickstart/base-api
npm install
npm run start:dev
```

**Access:**
- API: http://localhost:3000
- Swagger: http://localhost:3000/docs

**Note:** This is a simpler alternative to the full API generator in `scripts/api/`. Use this for quick prototypes and experiments.

---

## Development Workflow with Tools

### Component Extraction Workflow

1. **Scan Components:**
   ```
   Ask Claude: "Scan all components and find extraction candidates"
   ```

2. **Check for Duplicates:**
   ```
   Ask Claude: "Check if AnimateButton exists in UI package"
   ```

3. **Analyze Usage:**
   ```
   Ask Claude: "Show me everywhere CustomDialog is used"
   ```

4. **Generate Plan:**
   ```
   Ask Claude: "Generate extraction plan for MotionContainer"
   ```

5. **Track Progress:**
   ```
   Ask Claude: "Show migration status of all components"
   ```

### Monitoring Workflow

1. **Start Faro Agent:**
   ```bash
   cd tools/monitoring/faro-agent
   pnpm dev
   ```

2. **Add Services:**
   - Add URLs to monitor
   - Set check intervals
   - Enable/disable monitoring

3. **View Health:**
   - Real-time health status
   - Uptime statistics
   - Response times

### Quick Prototyping

1. **Use Base API:**
   ```bash
   cd tools/quickstart/base-api
   npm install
   npm run start:dev
   ```

2. **Develop Feature:**
   - Add endpoints
   - Test with Swagger
   - Iterate quickly

3. **Migrate to Full API:**
   - Use `scripts/api/generate-api.js` for production version
   - Copy working code from prototype

---

## Best Practices

### MCP Servers

- Install only the MCP servers you need
- Keep MCP servers updated
- Configure proper environment variables
- Test MCP tools before relying on them
- Document custom MCP servers

### Monitoring

- Monitor critical services only
- Set appropriate check intervals
- Configure alerts for failures
- Review monitoring data regularly
- Keep monitoring lightweight

### Quick Start Templates

- Use for prototyping only
- Don't use in production
- Migrate to full templates when ready
- Keep templates minimal
- Document template limitations

---

## Troubleshooting

### MCP Server Issues

**Issue:** MCP server not responding
```bash
# Check if server is running
ps aux | grep mcp

# Restart Claude Code
# Reload MCP servers
```

**Issue:** Environment variables not set
```bash
# Check config.json
cat ~/Library/Application\ Support/Claude/config.json

# Verify MONOREPO_ROOT is correct
```

### Faro Agent Issues

**Issue:** Port already in use
```bash
# Use custom port
SERVER_PORT=3020 pnpm dev
```

**Issue:** Database locked
```bash
# Close all Faro Agent instances
# Delete database and restart
rm ~/Library/Application\ Support/faro-agent/faro.db
```

---

## Related Documentation

- [MCP Documentation](../docs/tools/README.md)
- [Component Extraction Guide](../docs/tools/COMPONENT-EXTRACTION-SUMMARY.md)
- [Development Standards](../docs/development/standards.md)
- [UI Components Guide](../docs/development/ui-components.md)
