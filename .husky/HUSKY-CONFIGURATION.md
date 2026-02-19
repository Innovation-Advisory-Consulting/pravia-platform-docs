# Husky - Git Hooks Manager

## Overview
Husky is a tool that manages Git Hooks, enabling automated script execution at specific points in the Git workflow. This ensures code quality and consistency across the project before commits are finalized.

## Directory Structure

```
.husky/
├── _/                      # Husky internal files
│   ├── husky.sh           # Base script (deprecated in v10)
│   ├── .gitignore
│   └── [hook templates]   # Available but unconfigured hooks
└── pre-commit             # Active pre-commit hook
```

## Active Hooks

### pre-commit Hook

**Purpose:** Automatically lint and format code before allowing a commit to complete.

**Execution Trigger:** Runs before `git commit` is finalized.

**Workflow:**

```
Developer runs: git commit -m "message"
    ↓
Husky intercepts commit
    ↓
Detects changed files
    ↓
Runs appropriate linters/formatters
    ↓
Auto-fixes code issues
    ↓
Adds fixes to commit
    ↓
Commit completes
```

#### Monitored Paths and Actions

| Path | Detection Pattern | Commands Executed | Purpose |
|------|------------------|-------------------|---------|
| `apps/mule-vite/` | `^apps/mule-vite/` | `pnpm lint:fix`<br>`pnpm fm:fix` | ESLint fixes<br>Prettier formatting |
| `apps/mule-incidents/` | `^apps/mule-incidents/` | `pnpm lint:fix`<br>`pnpm fm:fix` | ESLint fixes<br>Prettier formatting |
| `api/flux/` | `^api/flux/` | `pnpm format-lint` | Format and lint validation |
| `api/foundry/` | `^api/foundry/` | `pnpm format-lint` | Format and lint validation |
| `api/incidents/` | `^api/incidents/` | `pnpm format-lint` | Format and lint validation |

#### Script Logic

**Step 1: Detect Changes**
```bash
git diff --cached --name-only | grep -q "^apps/mule-vite/"
```
- Checks staged files for changes in specific paths
- Uses regex patterns for path matching

**Step 2: Execute Commands**
```bash
cd apps/mule-vite && pnpm lint:fix && pnpm fm:fix
```
- Navigates to changed directory
- Runs linting and formatting commands
- Executes sequentially (fails if lint:fix fails)

**Step 3: Stage Fixes**
```bash
git add -u apps/mule-vite/ 2>/dev/null || true
```
- Adds corrected files back to staging
- Suppresses errors with `2>/dev/null || true`
- Only stages modified files (`-u` flag)

**Step 4: Return to Root**
```bash
cd ../..
```
- Returns to repository root
- Prepares for next path check

## Commands Reference

### Frontend Applications (mule-vite, mule-incidents)

**`pnpm lint:fix`**
- Tool: ESLint
- Action: Automatically fixes linting errors
- Scope: JavaScript/TypeScript files
- Config: `eslint.config.mjs`

**`pnpm fm:fix`**
- Tool: Prettier
- Action: Formats code according to style rules
- Scope: All supported file types
- Config: `prettier.config.mjs`

### Backend APIs (flux, foundry, incidents)

**`pnpm format-lint`**
- Tool: Prettier + ESLint
- Action: Format code and validate linting rules
- Scope: TypeScript files
- Config: `.prettierrc`, `.eslintrc.js`

## Benefits

### 1. Code Quality Enforcement
- Prevents commits with linting errors
- Ensures consistent code formatting
- Catches issues before code review

### 2. Developer Experience
- Automatic fixes reduce manual work
- No need to remember to run linters
- Immediate feedback on code quality

### 3. Team Consistency
- All developers follow same standards
- Reduces style-related code review comments
- Maintains uniform codebase appearance

### 4. Performance Optimization
- Only processes changed files
- Skips directories without modifications
- Parallel execution not needed (sequential is fast)

## Usage Examples

### Example 1: Frontend Change
```bash
# Developer modifies mule-vite
$ vim apps/mule-vite/src/app.tsx

# Stage changes
$ git add apps/mule-vite/src/app.tsx

# Attempt commit
$ git commit -m "feat: update app component"

# Husky executes:
Running lint and format for mule-vite...
✓ ESLint fixes applied
✓ Prettier formatting applied

# Commit completes with fixes included
[main abc1234] feat: update app component
 1 file changed, 10 insertions(+), 5 deletions(-)
```

### Example 2: Backend Change
```bash
# Developer modifies flux API
$ vim api/flux/src/app.module.ts

# Stage and commit
$ git add api/flux/src/app.module.ts
$ git commit -m "refactor: update module imports"

# Husky executes:
Running format-lint for flux...
✓ Code formatted and validated

[main def5678] refactor: update module imports
 1 file changed, 3 insertions(+), 2 deletions(-)
```

### Example 3: Multiple Projects
```bash
# Changes in both frontend and backend
$ git add apps/mule-vite/ api/foundry/
$ git commit -m "feat: update frontend and API"

# Husky executes both:
Running lint and format for mule-vite...
✓ mule-vite processed

Running format-lint for foundry...
✓ foundry processed

[main ghi9012] feat: update frontend and API
 5 files changed, 25 insertions(+), 10 deletions(-)
```

## Troubleshooting

### Issue 1: Hook Not Executing
**Symptom:** Commits complete without running linters

**Solutions:**
```bash
# Reinstall husky
pnpm install

# Verify hook is executable
chmod +x .husky/pre-commit

# Check git hooks path
git config core.hooksPath
# Should output: .husky
```

### Issue 2: Lint Errors Block Commit
**Symptom:** Commit fails with linting errors

**Solutions:**
```bash
# Fix errors manually
cd apps/mule-vite
pnpm lint:fix

# Or skip hook temporarily (not recommended)
git commit --no-verify -m "message"
```

### Issue 3: Slow Hook Execution
**Symptom:** Pre-commit takes too long

**Causes:**
- Large number of changed files
- Slow linter configuration
- Network issues (if linter downloads configs)

**Solutions:**
- Commit smaller changesets
- Optimize ESLint/Prettier configs
- Use local config files

### Issue 4: Husky Deprecation Warning
**Symptom:** Warning about deprecated husky.sh

**Action Required:**
- Update to Husky v10 when available
- Remove deprecated script references
- Follow migration guide

## Configuration Files

### Husky Installation
Configured in `package.json`:
```json
{
  "scripts": {
    "prepare": "husky install"
  }
}
```

### Hook Permissions
All hooks must be executable:
```bash
chmod +x .husky/pre-commit
```

## Best Practices

1. **Never Skip Hooks in Production Code**
   - Use `--no-verify` only for emergencies
   - Fix issues properly instead of bypassing

2. **Keep Hooks Fast**
   - Only process changed files
   - Avoid heavy operations
   - Use incremental linting

3. **Test Hooks Locally**
   - Verify hooks work before pushing
   - Test with various file changes
   - Ensure error handling works

4. **Document Custom Hooks**
   - Add comments to hook scripts
   - Explain non-obvious logic
   - Update this documentation

5. **Maintain Consistency**
   - Use same linter configs across projects
   - Keep hook logic simple
   - Follow monorepo patterns

## Available But Unconfigured Hooks

The following Git hooks are available but not currently configured:

- `applypatch-msg` - Runs after patch is applied
- `commit-msg` - Validates commit message format
- `post-applypatch` - Runs after patch and commit
- `post-checkout` - Runs after checkout
- `post-commit` - Runs after commit completes
- `post-merge` - Runs after merge
- `post-rewrite` - Runs after rebase/amend
- `pre-applypatch` - Runs before applying patch
- `pre-auto-gc` - Runs before garbage collection
- `pre-merge-commit` - Runs before merge commit
- `pre-push` - Runs before push to remote
- `pre-rebase` - Runs before rebase
- `prepare-commit-msg` - Modifies commit message

**Future Enhancements:**
- Add `commit-msg` hook for conventional commits
- Add `pre-push` hook for running tests
- Add `post-merge` hook for dependency updates

## Related Documentation
- Husky Official Docs: https://typicode.github.io/husky/
- Git Hooks Reference: https://git-scm.com/docs/githooks
- ESLint: https://eslint.org/
- Prettier: https://prettier.io/

## Version Information
- **Husky Version:** v8.x (v10 migration pending)
- **Git Version Required:** 2.9+
- **Node.js Version Required:** 18+
