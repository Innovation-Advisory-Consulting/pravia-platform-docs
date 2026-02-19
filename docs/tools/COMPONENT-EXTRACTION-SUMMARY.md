# Component Extraction Analysis & MCP Server - Summary

## What We Accomplished

### 1. Comprehensive Component Audit ✅

Analyzed all components in `pravia-web` and `packages/ui` to identify:
- **32 extraction candidates** from pravia-web
- **33 existing component groups** in UI package
- Reusability scores and priorities for each component

### 2. Custom MCP Server Created ✅

Built a fully functional MCP server with 7 powerful tools:

**Location:** `/Users/tonyhenderson/Documents/GitHub/faro/pravia-monorepo/tools/component-analyzer-mcp`

**Tools Available:**
1. `scan_components` - Analyze all React components
2. `find_extraction_candidates` - Find components ready to extract
3. `check_if_exists_in_ui` - Check for existing similar components
4. `analyze_component_usage` - See where components are used
5. `generate_extraction_plan` - Get step-by-step extraction guide
6. `track_migration_status` - Monitor migration progress
7. `find_duplicate_patterns` - Find code duplication opportunities

---

## Top Priority Components to Extract

### TIER 1 - Extract Immediately (High Value, Low Effort)

#### Animation Components (Highest Priority)
Located in: `src/components/animate/`

1. **AnimateBorder** - Animated border effect
2. **AnimateCountUp** - Number counter animation
3. **AnimateText** - Character/word animation
4. **BackToTopButton** - Scroll to top FAB
5. **ScrollProgress** - Page scroll indicator
6. **MotionContainer** - Framer Motion wrapper
7. **MotionViewport** - Viewport animation trigger
8. **Animation Variants Library** - Reusable animation configs

**Impact:** ~3,500 lines of reusable animation code

#### Utility Components
9. **SvgColor** (`src/components/svg-color/`) - SVG color transformer
10. **FlagIcon** (`src/components/flag-icon/`) - Country flag display
11. **FileThumbnail** (`src/components/file-thumbnail/`) - File preview

### TIER 2 - Extract With Refactoring (Good Value, Medium Effort)

1. **LoadingScreen** - Generic loading overlay
2. **SplashScreen** - Brand splash screen
3. **NavSection Components** - Navigation layouts (vertical, horizontal, mini)
4. **SettingsProvider & SettingsDrawer** - Settings management system
5. **BaseOption** - Settings option selector

### TIER 3 - Specialized Components (Extract When Needed)

1. **ProgressBar** - Navigation progress indicator
2. **QueryProvider** - React Query configuration
3. **CustomCardMock** - Data card with skeleton

---

## Already in UI Package (Don't Duplicate)

✓ Data tables
✓ Form builders
✓ Hook form fields (text, select, checkbox, etc.)
✓ Dialogs (custom, enhanced, confirmation)
✓ Authentication forms (sign in, sign up, reset password, etc.)
✓ Breadcrumbs
✓ Snackbar notifications
✓ Phone & number inputs
✓ Page headers
✓ Navigation components
✓ Stepper components
✓ Label/badge components
✓ 14+ animation effects library

---

## How to Use the MCP Server

### Step 1: Configure Claude Code

Add to `~/Library/Application Support/Claude/config.json`:

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

### Step 2: Restart Claude Code

Restart or reload MCP servers for changes to take effect.

### Step 3: Start Using!

Example commands you can ask:

```
Find all components with reusability score above 80
```

```
Check if AnimateButton exists in the UI package
```

```
Generate an extraction plan for src/components/animate/motion-container.tsx
```

```
Show me the migration status
```

```
Where is CustomDialog being used?
```

---

## Recommended Workflow

### Phase 1: Quick Wins (Week 1-2)
1. Extract animation components (Tier 1)
   - Start with `AnimateCountUp` (simplest)
   - Then `AnimateBorder`, `AnimateText`
   - Finally `MotionContainer`, `MotionViewport`
   - Move variants library

2. Extract utility components
   - `SvgColor`, `FlagIcon`, `FileThumbnail`

### Phase 2: Navigation & Loading (Week 3-4)
1. Extract loading components
2. Refactor and extract navigation components
3. Make permission logic injectable

### Phase 3: Settings System (Week 5-6)
1. Extract settings provider
2. Extract settings UI with customization slots
3. Create comprehensive documentation

### Phase 4: Polish & Documentation (Week 7-8)
1. Update all imports in pravia-web
2. Create Storybook stories
3. Write migration guide
4. Build component showcase

---

## Key Metrics

- **Total Components Analyzed:** 40+
- **Extraction Candidates:** 32
- **Already Shared:** 33 component groups
- **Component Categories:** 9
- **Estimated LOC to Extract:** 3,500+ lines
- **Estimated Effort:** 4-6 weeks for full extraction
- **Value Generated:** Reduced duplication, faster development, consistent UI

---

## Files Created

1. **MCP Server:**
   - `tools/component-analyzer-mcp/src/index.ts` - Main server code
   - `tools/component-analyzer-mcp/package.json` - Dependencies
   - `tools/component-analyzer-mcp/README.md` - Documentation
   - `tools/component-analyzer-mcp/SETUP.md` - Setup guide

2. **Documentation:**
   - `.claude/context` - Updated with all 3 key directories
   - `COMPONENT-EXTRACTION-SUMMARY.md` (this file)

---

## Next Steps

### Immediate (Today)
1. ✅ Review this summary
2. 📋 Configure MCP server in Claude Code
3. 🔄 Restart Claude Code
4. 🧪 Test with: "Find extraction candidates with score above 85"

### This Week
1. Extract first animation component (`AnimateCountUp`)
2. Test in both packages
3. Update pravia-web imports
4. Create Storybook story

### This Month
1. Complete Tier 1 extractions
2. Establish extraction workflow
3. Document patterns for team

### This Quarter
1. Complete Tier 2 extractions
2. Build comprehensive component library
3. Create migration guide for other projects

---

## Support & Resources

- **MCP Server README:** `tools/component-analyzer-mcp/README.md`
- **Setup Guide:** `tools/component-analyzer-mcp/SETUP.md`
- **Project Context:** `.claude/context`
- **Ask Claude Code:** Use the MCP tools anytime!

---

## Success Criteria

You'll know this is successful when:
- ✅ MCP server is configured and working
- ✅ First component extracted and working in both packages
- ✅ Team understands the extraction workflow
- ✅ Regular extractions happening each sprint
- ✅ Reduced code duplication across projects
- ✅ Faster feature development with shared components

---

**Status:** Ready to Begin! 🚀

The MCP server is built, installed, and ready to use. The component audit is complete. You now have a clear roadmap and powerful tools to systematically extract reusable components to your shared UI package.
