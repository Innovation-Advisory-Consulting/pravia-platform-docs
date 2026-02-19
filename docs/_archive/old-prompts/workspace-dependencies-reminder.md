# Workspace Dependencies - CRITICAL REMINDER

## ❌ WRONG: `workspace:*` for external packages
```json
{
  "devDependencies": {
    "typescript": "workspace:*",     // FAILS - not a workspace package
    "@types/node": "workspace:*",    // FAILS - not a workspace package
    "eslint": "workspace:*"          // FAILS - not a workspace package
  }
}
```

## ✅ CORRECT: `workspace:*` only for internal packages
```json
{
  "dependencies": {
    "@asyml8/ui": "workspace:*",        // ✅ Internal workspace package
    "@asyml8/api-types": "workspace:*", // ✅ Internal workspace package
    "@asyml8/api-core": "workspace:*"   // ✅ Internal workspace package
  }
}
```

## Key Rules:
1. `workspace:*` ONLY works for packages defined in `pnpm-workspace.yaml`
2. External npm packages (typescript, eslint, etc.) must use specific versions even if they're in root
3. Dependency hoisting happens automatically through pnpm, not through `workspace:*`
4. The workspace dependency checker script is wrong about external packages

## Current Workspace Packages:
- `@asyml8/ui`
- `@asyml8/api-types` 
- `@asyml8/api-core`

## External packages that CAN'T use workspace:*:
- typescript, @types/node, eslint, prettier, etc.
