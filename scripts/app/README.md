# App Generator

CLI tool to scaffold new Vite + React applications from the `mule-vite` base template.

## Usage

```bash
node scripts/app/generate-app.js
```

## Interactive Prompts

The generator will ask for:

| Prompt | Description | Default | Example |
|--------|-------------|---------|---------|
| **App name** | Lowercase, kebab-case package name | `my-app` | `provider-portal` |
| **Display name** | Human-readable application name | Auto-generated from app name | `Provider Portal` |
| **Description** | Package.json description | Auto-generated | `Provider Portal application built with Vite and React` |
| **Port number** | Dev server port | `8081` | `8082` |
| **Package scope** | NPM package scope | `@asyml8` | `@asyml8` |
| **Author** | Package author | `Tony Henderson` | `Tony Henderson` |

## What Gets Generated

The generator creates a new app in `/apps/{app-name}` with:

### Directory Structure
```
apps/{app-name}/
├── public/              # Static assets (favicon, logos, config)
├── scripts/             # Build and utility scripts
├── src/                 # Application source code
│   ├── api/            # API client modules
│   ├── components/     # Reusable React components
│   ├── constants/      # App constants
│   ├── contexts/       # React contexts
│   ├── guards/         # Route guards
│   ├── hooks/          # Custom React hooks
│   ├── layouts/        # Page layouts
│   ├── lib/            # Third-party library configs
│   ├── locales/        # i18n translations
│   ├── pages/          # Page components
│   ├── routes/         # Route definitions
│   ├── sections/       # Feature sections
│   ├── services/       # Business logic services
│   ├── store/          # State management (Zustand)
│   ├── types/          # TypeScript types
│   └── utils/          # Utility functions
├── .env                # Base environment variables
├── .env.localhost      # Local development overrides
├── .env.development    # Development environment config
├── index.html          # HTML entry point
├── package.json        # Package configuration
├── vite.config.ts      # Vite configuration
├── tsconfig.json       # TypeScript configuration
└── README.md           # App documentation
```

### Template Tokens

The following tokens are replaced throughout all files:

- `{{APP_NAME}}` → Package name (e.g., `provider-portal`)
- `{{APP_DISPLAY_NAME}}` → Display name (e.g., `Provider Portal`)
- `{{APP_TITLE}}` → HTML title (e.g., `Pravia Provider Portal`)
- `{{APP_DESCRIPTION}}` → Package description
- `{{AUTHOR}}` → Author name
- `{{VERSION}}` → Initial version (`1.0.0`)
- `{{BUILD_DATE}}` → Generation timestamp
- `{{PORT}}` → Dev server port

## Next Steps After Generation

```bash
# Navigate to the new app
cd apps/{app-name}

# Install dependencies
pnpm install

# Start development server
pnpm dev
```

## Template Source

The base template is located at `/scripts/app/base-app/` and is derived from the `mule-vite` application with:

- All business logic and domain-specific code included
- Template tokens in place of configurable values
- Excluded: `node_modules`, `dist`, `_archive`, `docs`, build artifacts

## Customization

To modify the base template:

1. Edit files in `/scripts/app/base-app/`
2. Use `{{TOKEN}}` syntax for values that should be parameterized
3. Update the `replacements` object in `generate-app.js` if adding new tokens

## Excluded from Template

- `node_modules/` - Dependencies
- `dist/`, `build/` - Build outputs
- `package-lock.json` - Lock file (pnpm workspace uses pnpm-lock.yaml)
