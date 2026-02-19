# Pravia Monorepo Coding Standards

## File Naming Conventions

### TypeScript/JavaScript Files
- **Services**: `kebab-case.service.ts` (e.g., `user.service.ts`, `contact.service.ts`)
- **Components**: `PascalCase.tsx` (e.g., `UserProfile.tsx`, `ContactList.tsx`)
- **Hooks**: `camelCase.ts` with `use` prefix (e.g., `useAuth.ts`, `useContacts.ts`)
- **Utils**: `kebab-case.ts` (e.g., `format-date.ts`, `api-helpers.ts`)
- **Types**: `kebab-case.types.ts` (e.g., `user.types.ts`, `api.types.ts`)
- **Constants**: `kebab-case.constants.ts` (e.g., `api.constants.ts`)

### Directories
- **All directories**: `kebab-case` (e.g., `user-management/`, `auth-api/`)
- **Component directories**: Match component name (e.g., `UserProfile/`)

## Project Structure Standards

### Frontend (Next.js/React)
```
src/
├── app/                    # Next.js app router
├── components/             # Reusable UI components
├── services/              # Business logic & API calls
├── hooks/                 # Custom React hooks
├── utils/                 # Pure utility functions
├── types/                 # TypeScript type definitions
├── constants/             # Application constants
├── stores/                # State management
└── lib/                   # Third-party integrations
```

### Backend (NestJS)
```
src/
├── modules/               # Feature modules
│   ├── auth/
│   ├── user-management/
│   └── [feature]/
├── common/                # Shared utilities
├── database/              # Database config & migrations
└── main.ts               # Application entry point
```

## Code Organization

### Service Files
```typescript
// user.service.ts
export class UserService {
  // Public methods first
  async getUsers(): Promise<User[]> { }
  
  // Private methods last
  private validateUser(): boolean { }
}
```

### Component Files
```typescript
// UserProfile.tsx
interface UserProfileProps {
  userId: string;
}

export function UserProfile({ userId }: UserProfileProps) {
  // Component logic
}
```

### Index Files
Always create `index.ts` files for clean imports:
```typescript
// services/index.ts
export * from './user.service';
export * from './contact.service';
```

## Import Standards

### Import Order
1. External libraries
2. Internal modules (using path aliases)
3. Relative imports

```typescript
// External
import React from 'react';
import { Button } from '@mui/material';

// Internal
import { UserService } from '@/services';
import { User } from '@/types';

// Relative
import './UserProfile.css';
```

### Path Aliases
Use consistent path aliases:
- `@/` for `src/`
- `@/components` for components
- `@/services` for services
- `@/utils` for utilities

## TypeScript Standards

### Type Definitions
```typescript
// Interfaces for objects
interface User {
  id: string;
  name: string;
  email: string;
}

// Types for unions/primitives
type UserRole = 'admin' | 'user' | 'guest';
type UserId = string;
```

### Function Signatures
```typescript
// Explicit return types for public functions
export async function getUser(id: string): Promise<User | null> {
  // Implementation
}

// Use generics when appropriate
export function createService<T>(config: ServiceConfig<T>): Service<T> {
  // Implementation
}
```

## API Standards

### Endpoint Naming
- **REST**: `/api/users`, `/api/users/:id`
- **Actions**: `/api/users/:id/activate`
- **Nested**: `/api/users/:id/contacts`

### Response Format
```typescript
// Success response
{
  data: T,
  message?: string,
  meta?: {
    total: number,
    page: number,
    limit: number
  }
}

// Error response
{
  error: {
    code: string,
    message: string,
    details?: any
  }
}
```

## Database Standards

### Table Naming
- **Tables**: `snake_case` (e.g., `user_profiles`, `auth_audit_logs`)
- **Columns**: `snake_case` (e.g., `created_at`, `user_id`)
- **Indexes**: `idx_table_column` (e.g., `idx_users_email`)

### Schema Organization
- **Supabase**: `auth.*` (managed by Supabase)
- **Business**: `pravia.*` (application data)
- **Views**: `pravia.*_view` (materialized views)

## Testing Standards

### File Naming
- **Unit tests**: `*.spec.ts`
- **Integration tests**: `*.integration.spec.ts`
- **E2E tests**: `*.e2e.spec.ts`

### Test Structure
```typescript
describe('UserService', () => {
  describe('getUser', () => {
    it('should return user when found', async () => {
      // Arrange
      const userId = 'test-id';
      
      // Act
      const result = await userService.getUser(userId);
      
      // Assert
      expect(result).toBeDefined();
    });
  });
});
```

## Git Standards

### Branch Naming
- **Features**: `feature/user-management`
- **Fixes**: `fix/auth-validation`
- **Hotfixes**: `hotfix/security-patch`

### Commit Messages
```
type(scope): description

feat(auth): add user registration
fix(api): resolve validation error
docs(readme): update installation steps
```

## Documentation Standards

### Code Comments
```typescript
/**
 * Retrieves user profile with contact information
 * @param userId - The unique user identifier
 * @returns Promise resolving to user with contacts or null
 */
export async function getUserWithContacts(userId: string): Promise<UserWithContacts | null> {
  // Implementation details only when complex
}
```

### README Structure
```markdown
# Project Name

## Overview
Brief description

## Installation
Step-by-step setup

## Usage
Code examples

## API Documentation
Endpoint descriptions

## Contributing
Development guidelines
```

## Performance Standards

### Bundle Size
- Keep components under 50KB
- Lazy load routes and heavy components
- Use dynamic imports for large libraries

### Database
- Always use indexes on foreign keys
- Limit query results (max 1000 records)
- Use materialized views for complex joins

## Security Standards

### Environment Variables
- Never commit `.env` files
- Use `.env.example` for documentation
- Prefix sensitive vars with `PRIVATE_`

### API Security
- Always validate input data
- Use TypeScript for type safety
- Implement rate limiting
- Log security events

## Linting & Formatting

### ESLint Rules
- Enforce TypeScript strict mode
- Require explicit return types
- No unused variables/imports
- Consistent import ordering

### Prettier Config
- 2 spaces indentation
- Single quotes
- Trailing commas
- Line length: 100 characters

---

## Quick Reference

### Creating New Services
1. Create `feature.service.ts` in `/src/services/`
2. Export from `/src/services/index.ts`
3. Add corresponding types in `/src/types/`
4. Write tests in `feature.service.spec.ts`

### Adding New Components
1. Create `ComponentName.tsx` in `/src/components/`
2. Create `ComponentName.types.ts` if complex props
3. Export from component `index.ts`
4. Add Storybook story if reusable

### Database Changes
1. Create migration file
2. Update entity definitions
3. Refresh materialized views if needed
4. Update API documentation

---

*Last updated: October 2024*
*Version: 1.0*