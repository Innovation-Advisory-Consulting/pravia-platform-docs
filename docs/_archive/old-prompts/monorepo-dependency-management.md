# Monorepo Dependency Management Guidelines

## Critical Rules for Package Dependencies

### 1. Version Consistency Across Monorepo
**ALWAYS ensure all packages use the same versions of shared dependencies.**

#### Key Dependencies That Must Match:
- `react` and `react-dom`
- `typescript`
- `@tanstack/react-query`
- `zod`
- `react-hook-form`
- `@hookform/resolvers`

#### Check Before Making Changes:
```bash
# Compare versions across packages
grep -r "\"react\":" packages/*/package.json apps/*/package.json
grep -r "\"zod\":" packages/*/package.json apps/*/package.json
```

### 2. Proper Peer Dependencies for Shared Packages

#### For UI/Component Libraries:
```json
{
  "peerDependencies": {
    "react": "^19.1.1",
    "react-dom": "^19.1.1",
    "@tanstack/react-query": "^5.0.0",
    "react-hook-form": "^7.62.0",
    "zod": "^4.1.11",
    "@hookform/resolvers": "^3.3.0"
  },
  "devDependencies": {
    // Include peer deps in devDependencies for development
    "react": "^19.1.1",
    "react-dom": "^19.1.1",
    "@tanstack/react-query": "^5.0.0",
    "react-hook-form": "^7.62.0",
    "zod": "^4.1.11"
  }
}
```

### 3. React Context Sharing Issues

#### Problem: "No QueryClient set, use QueryClientProvider to set one"
**Root Cause:** Different React Query instances between app and package

#### Solution Checklist:
- [ ] Make `@tanstack/react-query` a peer dependency in UI package
- [ ] Remove it from UI package dependencies
- [ ] Ensure app provides the QueryClient context
- [ ] Verify path mapping points to built `dist` folder, not `src`

### 4. TypeScript Configuration for Packages

#### Standalone Package tsconfig.json:
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "skipLibCheck": true,
    "strict": true,
    "noEmit": false,
    "esModuleInterop": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "react-jsx",
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["dist", "node_modules", ".storybook"]
}
```

#### Path Mapping in Root tsconfig.base.json:
```json
{
  "paths": {
    "@asyml8/ui": ["./packages/ui/dist"],  // Use DIST, not src
    "@asyml8/utils": ["./packages/utils/dist"]
  }
}
```

### 5. Proper Build Order

#### Always build packages before apps:
```bash
# 1. Build shared packages first
pnpm --filter "./packages/*" build

# 2. Then build apps
pnpm --filter "./apps/*" build
```

### 6. Common Troubleshooting Steps

#### When encountering dependency issues:

1. **Check version alignment:**
   ```bash
   # Find version mismatches
   find . -name "package.json" -exec grep -l "react" {} \; | xargs grep "\"react\":"
   ```

2. **Clean and reinstall:**
   ```bash
   # Clean all node_modules
   find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
   
   # Clean dist folders
   find ./packages -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
   
   # Reinstall
   pnpm install
   ```

3. **Verify package exports:**
   ```bash
   # Check if package built correctly
   ls -la packages/ui/dist/
   cat packages/ui/dist/index.js
   ```

4. **Test workspace linking:**
   ```bash
   # Verify symlinks exist
   ls -la apps/*/node_modules/@asyml8/
   ```

### 7. Red Flags to Watch For

#### Immediate Investigation Required:
- Different React versions between packages
- "Module not found" errors for workspace packages
- "No QueryClient set" or similar context errors
- TypeScript errors about incompatible types between packages
- Peer dependency warnings during install

#### Before Making Changes:
- [ ] Check if change affects shared dependencies
- [ ] Verify all packages use same versions
- [ ] Test build order (packages → apps)
- [ ] Confirm peer dependencies are properly configured

### 8. Emergency Recovery

#### If monorepo is broken:
```bash
# 1. Reset to working state
git stash
git checkout main

# 2. Clean everything
find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
find ./packages -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true

# 3. Fresh install and build
pnpm install
pnpm --filter "./packages/*" build
pnpm --filter "./apps/*" build
```

### 9. Testing Checklist

#### Before committing dependency changes:
- [ ] All packages build successfully
- [ ] All apps build successfully
- [ ] Storybook works (if applicable)
- [ ] No peer dependency warnings
- [ ] Context providers work across package boundaries
- [ ] No "Module not found" errors

---

## Remember: In a monorepo, consistency is king. One mismatched version can break everything.
