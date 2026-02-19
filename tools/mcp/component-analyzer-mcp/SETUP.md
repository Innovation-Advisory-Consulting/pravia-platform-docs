# Setup Guide for Component Analyzer MCP

## Quick Start

### 1. The MCP server has been built and is ready to use!

Location: `/Users/tonyhenderson/Documents/GitHub/faro/pravia-monorepo/tools/component-analyzer-mcp`

### 2. Add to Claude Code Configuration

Open your Claude Code MCP configuration file:
```bash
open ~/Library/Application\ Support/Claude/config.json
```

Add this configuration to the `mcpServers` section:

```json
{
  "mcpServers": {
    "component-analyzer": {
      "command": "node",
      "args": [
        "/Users/tonyhenderson/Documents/GitHub/faro/pravia-monorepo/tools/component-analyzer-mcp/dist/index.js"
      ],
      "env": {
        "MONOREPO_ROOT": "/Users/tonyhenderson/Documents/GitHub/faro/pravia-monorepo"
      }
    }
  }
}
```

**Note:** If you already have other MCP servers configured, just add the `component-analyzer` entry to your existing `mcpServers` object.

### 3. Restart Claude Code

After saving the config file, restart Claude Code or reload the MCP servers for the changes to take effect.

### 4. Verify Installation

Once restarted, you should be able to ask Claude Code:

```
List all available MCP tools
```

You should see tools like:
- `scan_components`
- `find_extraction_candidates`
- `check_if_exists_in_ui`
- `analyze_component_usage`
- `generate_extraction_plan`
- `track_migration_status`
- `find_duplicate_patterns`

## Example Usage

### Find Components to Extract
```
Use the component analyzer to find all components with high reusability scores
```

### Check for Duplicates
```
Check if AnimateButton already exists in the UI package
```

### Analyze Usage
```
Show me everywhere the CustomDialog component is used in pravia-web
```

### Generate Extraction Plan
```
Generate a detailed plan to extract the MotionContainer component to the UI package
```

### Track Progress
```
Show me the migration status - which components have been moved to the UI package?
```

## Workflow Recommendations

### Phase 1: Discovery
1. Run `scan_components` to catalog all components
2. Run `find_extraction_candidates` to see high-priority targets
3. Run `track_migration_status` to see current state

### Phase 2: Planning
1. For each candidate, run `check_if_exists_in_ui` to avoid duplicates
2. Run `analyze_component_usage` to understand impact
3. Run `generate_extraction_plan` to get step-by-step guide

### Phase 3: Execution
1. Follow the extraction plan
2. Update imports across codebase
3. Re-run `track_migration_status` to verify

### Phase 4: Ongoing
- Weekly: Run `find_extraction_candidates` to find new opportunities
- Monthly: Run `track_migration_status` to review progress

## Troubleshooting

### MCP Server Not Showing Up
1. Check that the path in config.json is correct
2. Verify the build was successful: `ls -la tools/component-analyzer-mcp/dist/`
3. Check Claude Code logs for errors
4. Restart Claude Code completely

### "MONOREPO_ROOT not found" Error
1. Verify the `MONOREPO_ROOT` path in config.json
2. Make sure it points to the root of your monorepo
3. Use absolute paths, not relative paths

### Component Analysis Seems Wrong
1. Clear the cache by restarting the MCP server
2. Re-run `scan_components` to refresh the analysis
3. Check that the component files are in the expected location

## Next Steps

After setup, I recommend:

1. **Run initial scan**: Discover all components and get baseline metrics
2. **Review top candidates**: Focus on the Tier 1 components from the audit
3. **Start with animations**: Extract the animation components first (highest value)
4. **Create workflow**: Establish a regular cadence for component extraction

## Need Help?

The MCP server is fully functional and ready to use. If you encounter issues:
1. Check the README.md in the component-analyzer-mcp directory
2. Review the logs when running commands
3. Ask Claude Code to help debug specific issues
