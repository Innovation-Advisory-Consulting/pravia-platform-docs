# Deployment Scripts

Shared deployment system for publishing monorepo packages to private git repositories.

## Prerequisites

### SSH Setup (Required for Private Repos)

**1. Generate SSH key:**
```bash
ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519 -N ""
```

**2. Add key to SSH agent:**
```bash
ssh-add ~/.ssh/id_ed25519
```

**3. Copy public key:**
```bash
cat ~/.ssh/id_ed25519.pub
```

**4. Add to GitHub:**
- Go to https://github.com/settings/keys
- Click "New SSH key"
- Paste the public key
- Give it a title (e.g., "Deploy Key")
- Click "Add SSH key"

**5. Test connection:**
```bash
ssh -T git@github.com
# Should see: "Hi username! You've successfully authenticated..."
```

**For GitLab:**
- Add key at https://gitlab.com/-/profile/keys
- Test: `ssh -T git@gitlab.com`

**For Bitbucket:**
- Add key at https://bitbucket.org/account/settings/ssh-keys/
- Test: `ssh -T git@bitbucket.org`

### Auto-start SSH Agent on macOS

Add to `~/.zshrc` or `~/.bash_profile`:
```bash
# Start SSH agent
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
```

## Quick Start

1. **Configure deployment targets** in `deploy-config.env`:
```bash
packages/api-types=git@github.com:yourorg/api-types.git
packages/ui=git@github.com:yourorg/ui-components.git
packages/api-core=git@github.com:yourorg/api-core.git
```

2. **Deploy a package**:
```bash
# From monorepo root
pnpm deploy:api-types

# Or directly
bash scripts/deploy.sh packages/api-types

# Or with custom repo
bash scripts/deploy-to-git.sh packages/api-types git@github.com:org/repo.git
```

## Scripts

### `deploy.sh`
Wrapper script that reads configuration and deploys packages.

**Usage:**
```bash
./deploy.sh <package-path>
```

**Example:**
```bash
./deploy.sh packages/api-types
```

Lists available packages if run without arguments.

### `deploy-to-git.sh`
Core deployment script with full logging and error handling.

**Usage:**
```bash
./deploy-to-git.sh <package-path> <git-repo-url>
```

**Example:**
```bash
./deploy-to-git.sh packages/api-types git@github.com:org/api-types.git
```

**What it does:**
1. Validates package exists
2. Reads package name and version from `package.json`
3. Runs `pnpm build`
4. Copies deployment files to temp directory:
   - `dist/` (build output)
   - `package.json`
   - `README.md` (if exists)
   - `LICENSE` (if exists)
   - `.npmignore` (if exists)
5. Initializes git repo (if needed)
6. Commits with message: `Release vX.Y.Z - timestamp`
7. Force pushes to remote `main` branch
8. Creates and pushes version tag `vX.Y.Z`
9. Cleans up temp directory
10. Saves log file: `deploy_YYYYMMDD_HHMMSS.log`

**Environment Variables:**
- `GIT_USER_NAME` - Git commit author name (default: "CI Deploy")
- `GIT_USER_EMAIL` - Git commit author email (default: "deploy@pravia.local")

**Example with custom git config:**
```bash
GIT_USER_NAME="John Doe" GIT_USER_EMAIL="john@example.com" \
  ./deploy-to-git.sh packages/api-types git@github.com:org/api-types.git
```

### `deploy-config.env`
Configuration file mapping package paths to git repository URLs.

**Format:**
```bash
# Comments start with #
<package-path>=<git-repo-url>
```

**Example:**
```bash
# API packages
packages/api-types=git@github.com:myorg/api-types.git
packages/api-core=git@github.com:myorg/api-core.git

# UI packages
packages/ui=git@github.com:myorg/ui-components.git
```

## Logging

Each deployment creates a timestamped log file with color-coded output:

- **[INFO]** - General information (blue)
- **[SUCCESS]** - Successful operations (green)
- **[WARN]** - Warnings, non-critical issues (yellow)
- **[ERROR]** - Errors that stop deployment (red)

**Log file location:** `deploy_YYYYMMDD_HHMMSS.log` in current directory

**Example log output:**
```
[INFO] Starting deployment at Thu Jan 15 17:51:04 PST 2026
[INFO] Package: packages/api-types
[INFO] Target repo: git@github.com:org/api-types.git
[INFO] Deploying @pravia/api-types@1.2.3
[INFO] Building package...
[SUCCESS] Build completed
[INFO] Copying files...
[INFO] Committing changes...
[INFO] Pushing to remote...
[SUCCESS] Successfully pushed to git@github.com:org/api-types.git
[INFO] Creating version tag...
[SUCCESS] Deployment complete!
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Deploy Package
on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: pnpm/action-setup@v2
      
      - name: Setup SSH
        uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.DEPLOY_SSH_KEY }}
      
      - run: pnpm install
      
      - run: pnpm deploy:api-types
        env:
          GIT_USER_NAME: github-actions
          GIT_USER_EMAIL: actions@github.com
```

**Setup:**
1. Generate deploy key: `ssh-keygen -t ed25519 -C "deploy@ci" -f deploy_key -N ""`
2. Add `deploy_key.pub` to target repo: Settings > Deploy keys > Add (enable write access)
3. Add `deploy_key` (private) to source repo: Settings > Secrets > New secret named `DEPLOY_SSH_KEY`

### GitLab CI
```yaml
deploy:
  stage: deploy
  before_script:
    - eval $(ssh-agent -s)
    - echo "$DEPLOY_SSH_KEY" | tr -d '\r' | ssh-add -
    - mkdir -p ~/.ssh
    - chmod 700 ~/.ssh
    - ssh-keyscan github.com >> ~/.ssh/known_hosts
  script:
    - pnpm install
    - pnpm deploy:api-types
  only:
    - tags
```

**Setup:**
1. Generate deploy key: `ssh-keygen -t ed25519 -C "deploy@ci" -f deploy_key -N ""`
2. Add `deploy_key.pub` to target repo
3. Add `deploy_key` (private) to GitLab: Settings > CI/CD > Variables > Add `DEPLOY_SSH_KEY`

## Troubleshooting

**SSH authentication fails:**
```bash
# Check if SSH key is loaded
ssh-add -l

# If empty, add your key
ssh-add ~/.ssh/id_ed25519

# Test GitHub connection
ssh -T git@github.com

# Check SSH key permissions (should be 600)
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

**"Permission denied (publickey)":**
- Verify key is added to GitHub/GitLab/Bitbucket
- Check you're using SSH URL format: `git@github.com:org/repo.git`
- Not HTTPS format: `https://github.com/org/repo.git`

**Build fails:**
- Check package has `build` script in `package.json`
- Verify dependencies are installed: `pnpm install`

**Push fails:**
- Ensure SSH key has write access to target repo
- Test SSH: `ssh -T git@github.com`
- Check repo URL is correct in `deploy-config.env`

**No dist directory warning:**
- Package may not produce a `dist/` folder
- Script continues but only deploys `package.json` and docs

**Tag already exists:**
- Version tag already pushed (non-fatal warning)
- Bump version in `package.json` before deploying

## Package Requirements

Each deployable package should have:

**Required:**
- `package.json` with `name` and `version`
- `build` script in `package.json`

**Recommended:**
- `README.md` - Package documentation
- `LICENSE` - License file
- `.npmignore` - Files to exclude from deployment

**Example package.json:**
```json
{
  "name": "@pravia/api-types",
  "version": "1.2.3",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "deploy": "bash ../../scripts/deploy.sh packages/api-types"
  }
}
```
