# Monorepo Best Practices & Common Pitfalls

## Core Principles

### 1. Dependency Version Consistency
**Rule:** All packages in the monorepo MUST use identical versions of shared dependencies.

#### Critical Dependencies to Align:
- Runtime libraries (React, Vue, Angular)
- Type systems (TypeScript, Zod, Joi)
- State management (Redux, Zustand, React Query)
- Form libraries (React Hook Form, Formik)
- Testing frameworks (Jest, Vitest)

#### Quick Check:
```bash
# Find version inconsistencies
grep -r "\"<package-name>\":" */package.json | sort
```

### 2. Proper Package Architecture

#### Shared Libraries Should Use Peer Dependencies:
```json
{
  "peerDependencies": {
    "react": "^X.X.X",
    "typescript": "^X.X.X"
  },
  "devDependencies": {
    // Include peers for development
    "react": "^X.X.X",
    "typescript": "^X.X.X"
  }
}
```

#### Applications Should Provide Dependencies:
```json
{
  "dependencies": {
    "react": "^X.X.X",
    "typescript": "^X.X.X",
    "@company/ui": "workspace:*"
  }
}
```

### 3. Build Strategy

#### Always Build in Dependency Order:
1. **Shared packages first** (utils, ui, core)
2. **Applications last** (web, mobile, api)

```bash
# Correct build order
pnpm --filter "./packages/*" build
pnpm --filter "./apps/*" build
```

### 4. Context Sharing (React/Vue/Angular)

#### Problem: Context/Provider not found across packages
**Root Cause:** Different instances of the same library

#### Solution:
- Make context libraries peer dependencies
- Ensure single instance across monorepo
- Use proper module resolution

### 5. TypeScript Configuration

#### Root tsconfig.base.json:
```json
{
  "compilerOptions": {
    "paths": {
      "@company/ui": ["./packages/ui/dist"],     // Use DIST
      "@company/utils": ["./packages/utils/dist"] // Not SRC
    }
  }
}
```

#### Package tsconfig.json:
```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "noEmit": false,        // Enable output
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

### 6. Common Anti-Patterns

#### ❌ Don't Do:
- Different versions of the same dependency
- Import from `src` in path mappings
- Bundle shared dependencies in packages
- Skip peer dependency declarations
- Build apps before packages

#### ✅ Do:
- Align all dependency versions
- Use `dist` in path mappings
- Make shared deps peer dependencies
- Build packages before apps
- Test cross-package imports

### 7. Debugging Workflow

#### When Things Break:

1. **Check Version Alignment:**
   ```bash
   find . -name "package.json" -exec grep -H "\"react\":" {} \;
   ```

2. **Verify Build Outputs:**
   ```bash
   ls -la packages/*/dist/
   ```

3. **Check Workspace Linking:**
   ```bash
   ls -la apps/*/node_modules/@company/
   ```

4. **Clean Slate Recovery:**
   ```bash
   # Nuclear option
   find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null
   find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null
   pnpm install
   ```

### 8. Warning Signs

#### Immediate Investigation Required:
- Peer dependency warnings during install
- "Module not found" for workspace packages
- Context/Provider not found errors
- Type incompatibility between packages
- Different behavior in development vs production

### 9. Testing Strategy

#### Before Any Dependency Change:
- [ ] All packages build successfully
- [ ] All apps build successfully  
- [ ] Cross-package imports work
- [ ] Context sharing works (if applicable)
- [ ] No peer dependency warnings
- [ ] Storybook/dev tools work

### 10. Package.json Patterns

#### Shared Library Template:
```json
{
  "name": "@company/shared-lib",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "default": "./dist/index.js"
    }
  },
  "peerDependencies": {
    // Dependencies the consumer must provide
  },
  "devDependencies": {
    // Include peers + build tools
  }
}
```

#### Application Template:
```json
{
  "name": "@company/app",
  "dependencies": {
    // All runtime dependencies
    "@company/shared-lib": "workspace:*"
  },
  "devDependencies": {
    // Build and dev tools only
  }
}
```

---

## Golden Rule: In monorepos, consistency prevents chaos. One misaligned dependency can cascade into multiple failures across packages.
