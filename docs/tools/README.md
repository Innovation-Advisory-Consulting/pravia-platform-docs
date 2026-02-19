# MCP Extensions

**Model Context Protocol (MCP) servers extend Amazon Q's capabilities with specialized tools and integrations.**

## Currently Installed MCPs

### ✅ Active Local MCPs

| MCP | Purpose | Status |
|-----|---------|--------|
| **filesystem** | File system operations | ✅ Active (2.10s load time) |
| **npm-packages** | NPM package information and versions | ✅ Active (0.08s load time) |
| **aws-resources** | AWS resource recommendations and best practices | ✅ Active (0.20s load time) |

### 🛠️ Available Local MCPs

| MCP | Purpose | Location |
|-----|---------|----------|
| **aws-docs-mcp** | AWS documentation and guides | `./tools/aws-docs-mcp/` |
| **component-converter-mcp** | UI component conversion tools | `./tools/component-converter-mcp/` |
| **context-manager-mcp** | Context and session management | `./tools/context-manager-mcp/` (disabled) |
| **frontend-templates-mcp** | Frontend code templates | `./tools/frontend-templates-mcp/` |
| **monorepo-compliance-mcp** | Monorepo standards and compliance | `./tools/monorepo-compliance-mcp/` (disabled) |

### 🔧 CI/CD Tools

| Tool | Purpose | Location |
|------|---------|----------|
| **ci-cd** | Continuous integration and deployment tools | `./tools/ci-cd/` |

## Installing Additional MCPs

```bash
# Unified MCP installer
./tools/install-mcps.sh
```

**Options:**
- **1** - Show custom MCP status (local MCPs in `./tools/`)
- **2** - Install popular MCPs (from npm registry to `../mcp-servers/`)
- **3** - Both (show status + install popular MCPs)

### Available Public MCPs

| MCP | Purpose | Use Cases |
|-----|---------|----------|
| **sqlite** | SQLite database operations | Local database management, testing |
| **puppeteer** | Web automation | Scraping, testing, browser automation |
| **fetch** | HTTP requests | API interactions, web service calls |
| **memory** | Persistent context storage | Session memory, conversation history |

## AWS & Cloud MCPs

| MCP | Purpose | Use Cases |
|-----|---------|----------|
| **aws-kb** | AWS knowledge base | Best practices, service recommendations |
| **kubernetes** | Kubernetes management | Cluster operations, deployment management |
| **docker** | Container management | Docker operations, image management |

## Productivity MCPs

| MCP | Purpose | Use Cases |
|-----|---------|----------|
| **everart** | AI image generation | Creating visuals, design assets |
| **sequential-thinking** | Enhanced reasoning | Complex problem solving, analysis |
| **time** | Time zone operations | Scheduling, time conversions |
| **weather** | Weather information | Location-based weather data |

## Integration MCPs

| MCP | Purpose | Use Cases |
|-----|---------|----------|
| **gdrive** | Google Drive management | File operations, document access |
| **slack** | Slack workspace integration | Team communication, notifications |
| **youtube-transcript** | Video transcript extraction | Content analysis, documentation |
| **neon** | Neon database management | Serverless PostgreSQL operations |

## Manual Installation

To install individual MCPs manually:

```bash
# Install a specific MCP
npx @modelcontextprotocol/create-server@latest <mcp-name> --yes

# Examples
npx @modelcontextprotocol/create-server@latest filesystem --yes
npx @modelcontextprotocol/create-server@latest github --yes
```

## Usage

Once installed, MCPs automatically extend Q's capabilities:

```bash
# Start Q CLI with MCP extensions
q chat

# MCPs work transparently - just ask Q to:
# - "Search for AWS Lambda best practices"
# - "Read the package.json file"
# - "Create a GitHub issue for this bug"
# - "Query the user database"
```