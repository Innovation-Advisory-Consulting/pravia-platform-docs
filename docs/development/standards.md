# Development Standards

[← Back to Development](./README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Code Quality Standards

The Pravia platform enforces consistent code quality through automated tooling and established conventions.

## 🔧 Linting & Formatting

### **ESLint Configuration**
All TypeScript and JavaScript code follows our ESLint rules:

```javascript
// .eslintrc.js
{
  "extends": [
    "eslint:recommended",
    "@typescript-eslint/recommended", 
    "prettier"
  ],
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"]
}
```

**Key Rules:**
- **TypeScript-first** - Strict type checking with `@typescript-eslint/recommended`
- **ES2022 syntax** - Modern JavaScript features enabled
- **JSX support** - React component development
- **Prettier integration** - Automatic code formatting

### **Prettier Configuration**
Consistent code formatting across all files:

```json
{
  "semi": true,
  "trailingComma": "es5", 
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

**Standards:**
- **Single quotes** for strings
- **Semicolons** required
- **2-space indentation** (no tabs)
- **80-character line limit**
- **ES5 trailing commas** for compatibility

### **Commands**
```bash
# Lint all code
pnpm lint

# Fix linting issues
pnpm lint:fix

# Format all code
pnpm format

# Check formatting
pnpm format:check
```

## 📁 File & Directory Conventions

### **Naming Standards**
- **Files**: `kebab-case.ts` for utilities, `PascalCase.tsx` for React components
- **Directories**: `kebab-case` for all directories
- **Variables**: `camelCase` for variables and functions
- **Constants**: `SCREAMING_SNAKE_CASE` for constants
- **Types/Interfaces**: `PascalCase` with descriptive names

### **Import Organization**
```typescript
// 1. Node modules
import React from 'react';
import { FastifyInstance } from 'fastify';

// 2. Internal packages (workspace)
import { validateEmail } from '@asyml8/utils';
import { Button } from '@asyml8/ui';

// 3. Relative imports
import { UserService } from './services/user-service';
import './styles.css';
```

### **File Structure**
```
src/
├── components/          # React components
│   ├── ui/             # Reusable UI components
│   └── features/       # Feature-specific components
├── services/           # Business logic services
├── utils/              # Utility functions
├── types/              # TypeScript type definitions
├── hooks/              # Custom React hooks (frontend)
├── middleware/         # Express/Fastify middleware (backend)
└── __tests__/          # Test files
```

## 🎯 TypeScript Standards

### **Type Safety**
- **Strict mode enabled** - No implicit any, strict null checks
- **Explicit return types** for all functions
- **Interface over type** for object definitions
- **Enum for constants** when appropriate

### **Example Standards**
```typescript
// ✅ Good - Explicit types and interfaces
interface UserCreateRequest {
  email: string;
  name: string;
  role: UserRole;
}

export async function createUser(
  request: UserCreateRequest
): Promise<User> {
  // Implementation
}

// ❌ Bad - Implicit any and missing types
export async function createUser(request) {
  // Implementation
}
```

## 🧪 Testing Standards

### **Jest Configuration**
All projects use Jest for unit and integration testing:

```json
{
  "preset": "ts-jest",
  "testEnvironment": "node",
  "collectCoverageFrom": [
    "src/**/*.{ts,tsx}",
    "!src/**/*.d.ts"
  ],
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    }
  }
}
```

### **Test Organization**
```
src/
├── services/
│   ├── user-service.ts
│   └── __tests__/
│       └── user-service.test.ts
└── components/
    ├── Button.tsx
    └── __tests__/
        └── Button.test.tsx
```

### **Test Commands**
```bash
# Run all tests
pnpm test

# Watch mode for development
pnpm test:watch

# Coverage report
pnpm test:cov

# Debug tests
pnpm test:debug

# End-to-end tests
pnpm test:e2e
```

### **Test Standards**
- **Descriptive test names** - Clear what is being tested
- **AAA pattern** - Arrange, Act, Assert
- **Mock external dependencies** - Use Jest mocks for services
- **Test edge cases** - Error conditions and boundary values
- **80% coverage minimum** - Enforced by CI/CD

### **Example Test Structure**
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = { email: 'test@example.com', name: 'Test User' };
      
      // Act
      const result = await userService.createUser(userData);
      
      // Assert
      expect(result).toMatchObject({
        id: expect.any(String),
        email: userData.email,
        name: userData.name
      });
    });

    it('should throw error for invalid email', async () => {
      // Arrange
      const invalidData = { email: 'invalid', name: 'Test' };
      
      // Act & Assert
      await expect(userService.createUser(invalidData))
        .rejects.toThrow('Invalid email format');
    });
  });
});
```

## 🎭 Future: Playwright Integration

### **E2E Testing Roadmap**
We plan to integrate Playwright for comprehensive end-to-end testing:

```typescript
// Future implementation
import { test, expect } from '@playwright/test';

test('user can sign up and login', async ({ page }) => {
  await page.goto('/signup');
  await page.fill('[data-testid=email]', 'user@example.com');
  await page.fill('[data-testid=password]', 'password123');
  await page.click('[data-testid=submit]');
  
  await expect(page).toHaveURL('/dashboard');
});
```

**Planned Features:**
- **Cross-browser testing** - Chrome, Firefox, Safari
- **Mobile testing** - Responsive design validation
- **Visual regression** - Screenshot comparisons
- **API testing** - Backend endpoint validation
- **Performance testing** - Core Web Vitals monitoring

## 🚀 Automation

### **Pre-commit Hooks**
```bash
# Automatically run on git commit
- lint-staged
- type checking
- test execution
- format validation
```

### **CI/CD Integration**
- **Pull request checks** - All standards enforced
- **Automated testing** - Full test suite execution
- **Code coverage** - Minimum thresholds enforced
- **Security scanning** - Dependency vulnerability checks

---
**Navigation**: [← Development Guide](./README.md) | [Next: Testing →](./testing.md)
