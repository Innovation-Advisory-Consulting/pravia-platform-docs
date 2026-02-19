# UI Reusable Component Creation Prompt

**PROMPT: Creating Reusable Components from MCP Templates**

You are tasked with creating a reusable component based on existing MCP template code. Follow these rules EXACTLY:

## MANDATORY REQUIREMENTS

### 1. COPY FIRST, MODIFY SECOND
- Read the ENTIRE original MCP template file(s) first
- Copy the EXACT code structure, styling, and layout
- Only make changes to replace hardcoded values with props
- Never "improve" or "optimize" the original code

### 2. VISUAL FIDELITY IS SACRED
- The result must look IDENTICAL to the original template
- Same colors, spacing, fonts, icons, animations, shadows
- Same component hierarchy and DOM structure
- Same CSS classes and styling approach

### 3. ICON REQUIREMENTS
- Use EXACT same Iconify icon names from template
- Never replace with emojis, SVGs, or custom icons
- Import Iconify component properly: `import { Iconify } from 'src/components/iconify'`

### 4. STYLING REQUIREMENTS
- Copy ALL sx props, styled components, and CSS exactly
- Use same theme variables (primary.lighter, etc.)
- Keep same component sizes, padding, margins
- Preserve hover states, transitions, and interactions

### 5. COMPONENT STRUCTURE
- Keep same MUI component hierarchy
- Use same props and configurations
- Preserve same event handlers and state management
- Don't change component nesting or layout

### 6. VALIDATION PROCESS
- Before coding, describe what the original looks like
- After coding, compare pixel-by-pixel with original
- Test all interactions (hover, click, selection, etc.)
- Verify all icons, colors, and spacing match

### 7. FORBIDDEN ACTIONS
- Never say "this should work" without testing
- Never use placeholder icons or simplified styling  
- Never change the visual design "for better UX"
- Never skip reading the complete original code
- Never assume anything works without verification

## PROCESS

1. Read and analyze the complete original MCP template code
2. Identify what needs to be made configurable (data, callbacks, etc.)
3. Create interfaces for the configurable parts
4. Copy the original code structure exactly
5. Replace only the hardcoded parts with props
6. Test that visual output matches original exactly
7. If it doesn't match, fix it before claiming completion

## SUCCESS CRITERIA

- Visual output is indistinguishable from original template
- All functionality works identically
- Component is properly configurable via props
- Code compiles without errors
- No console errors or warnings

## FAILURE INDICATORS

- Any visual differences from original
- Missing icons or wrong icon types
- Different colors, spacing, or layout
- Broken functionality or interactions
- Compilation errors

**If you cannot meet these requirements exactly, say "I cannot complete this task properly" rather than delivering subpar work.**
