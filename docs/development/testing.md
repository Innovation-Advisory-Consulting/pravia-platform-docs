# Testing Guide

[← Back to Development](./README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Testing Strategy

The Pravia platform uses a comprehensive testing approach with Jest for unit/integration tests and planned Playwright integration for end-to-end testing.

## 🧪 Jest Testing

### **Test Types**
- **Unit Tests** - Individual functions and components
- **Integration Tests** - Service interactions and API endpoints
- **Component Tests** - React component behavior and rendering
- **E2E Tests** - Full user workflows (Jest + Supertest for APIs)

### **Configuration**
Each project includes Jest configuration optimized for TypeScript:

```json
{
  "preset": "ts-jest",
  "testEnvironment": "node",
  "roots": ["<rootDir>/src"],
  "testMatch": [
    "**/__tests__/**/*.+(ts|tsx|js)",
    "**/*.(test|spec).+(ts|tsx|js)"
  ],
  "transform": {
    "^.+\\.(ts|tsx)$": "ts-jest"
  },
  "collectCoverageFrom": [
    "src/**/*.{ts,tsx}",
    "!src/**/*.d.ts",
    "!src/index.ts"
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

### **Available Commands**
```bash
# Run all tests
pnpm test

# Watch mode for development
pnpm test:watch

# Generate coverage report
pnpm test:cov

# Debug tests with Node inspector
pnpm test:debug

# Run E2E tests (API projects)
pnpm test:e2e
```

## 🎯 Writing Effective Tests

### **Test Structure (AAA Pattern)**
```typescript
describe('Feature or Component Name', () => {
  describe('specific method or behavior', () => {
    it('should do something specific when condition is met', () => {
      // Arrange - Set up test data and mocks
      const input = { email: 'test@example.com' };
      const mockService = jest.fn().mockResolvedValue({ id: '123' });
      
      // Act - Execute the code under test
      const result = await functionUnderTest(input);
      
      // Assert - Verify the expected outcome
      expect(result).toEqual({ id: '123' });
      expect(mockService).toHaveBeenCalledWith(input);
    });
  });
});
```

### **Backend API Testing**
```typescript
// Example: NestJS controller test
describe('UserController', () => {
  let controller: UserController;
  let service: UserService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      controllers: [UserController],
      providers: [
        {
          provide: UserService,
          useValue: {
            create: jest.fn(),
            findById: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<UserController>(UserController);
    service = module.get<UserService>(UserService);
  });

  describe('createUser', () => {
    it('should create a new user', async () => {
      // Arrange
      const createUserDto = { email: 'test@example.com', name: 'Test User' };
      const expectedUser = { id: '1', ...createUserDto };
      jest.spyOn(service, 'create').mockResolvedValue(expectedUser);

      // Act
      const result = await controller.create(createUserDto);

      // Assert
      expect(result).toEqual(expectedUser);
      expect(service.create).toHaveBeenCalledWith(createUserDto);
    });
  });
});
```

### **Frontend Component Testing**
```typescript
// Example: React component test
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '../Button';

describe('Button Component', () => {
  it('should render with correct text', () => {
    // Arrange & Act
    render(<Button>Click me</Button>);
    
    // Assert
    expect(screen.getByRole('button')).toHaveTextContent('Click me');
  });

  it('should call onClick handler when clicked', () => {
    // Arrange
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    // Act
    fireEvent.click(screen.getByRole('button'));
    
    // Assert
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('should be disabled when loading', () => {
    // Arrange & Act
    render(<Button loading>Click me</Button>);
    
    // Assert
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

### **Integration Testing**
```typescript
// Example: API integration test with Supertest
describe('User API Integration', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('POST /users', () => {
    it('should create a new user', async () => {
      const createUserDto = {
        email: 'test@example.com',
        name: 'Test User',
      };

      const response = await request(app.getHttpServer())
        .post('/users')
        .send(createUserDto)
        .expect(201);

      expect(response.body).toMatchObject({
        id: expect.any(String),
        email: createUserDto.email,
        name: createUserDto.name,
      });
    });
  });
});
```

## 🎭 Playwright E2E Testing (Planned)

### **Future Implementation**
Playwright will provide comprehensive end-to-end testing capabilities:

```typescript
// playwright.config.ts (planned)
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
});
```

### **Planned E2E Test Examples**
```typescript
// e2e/auth.spec.ts (planned)
import { test, expect } from '@playwright/test';

test.describe('Authentication Flow', () => {
  test('user can sign up, verify email, and login', async ({ page }) => {
    // Sign up
    await page.goto('/signup');
    await page.fill('[data-testid=email]', 'user@example.com');
    await page.fill('[data-testid=password]', 'SecurePass123!');
    await page.click('[data-testid=signup-button]');
    
    // Verify redirect to verification page
    await expect(page).toHaveURL('/verify-email');
    await expect(page.locator('h1')).toContainText('Check your email');
    
    // Simulate email verification (mock API call)
    await page.goto('/verify?token=mock-token');
    await expect(page).toHaveURL('/dashboard');
    
    // Verify user is logged in
    await expect(page.locator('[data-testid=user-menu]')).toBeVisible();
  });

  test('user can login with existing account', async ({ page }) => {
    await page.goto('/login');
    await page.fill('[data-testid=email]', 'existing@example.com');
    await page.fill('[data-testid=password]', 'password123');
    await page.click('[data-testid=login-button]');
    
    await expect(page).toHaveURL('/dashboard');
  });
});

// e2e/crm.spec.ts (planned)
test.describe('CRM Functionality', () => {
  test('user can create and manage contacts', async ({ page }) => {
    // Login first
    await page.goto('/login');
    // ... login steps
    
    // Navigate to contacts
    await page.click('[data-testid=nav-contacts]');
    await expect(page).toHaveURL('/contacts');
    
    // Create new contact
    await page.click('[data-testid=add-contact]');
    await page.fill('[data-testid=contact-name]', 'John Doe');
    await page.fill('[data-testid=contact-email]', 'john@example.com');
    await page.click('[data-testid=save-contact]');
    
    // Verify contact appears in list
    await expect(page.locator('[data-testid=contact-list]')).toContainText('John Doe');
  });
});
```

### **Planned Features**
- **Cross-browser testing** - Chrome, Firefox, Safari
- **Mobile testing** - iOS and Android viewports
- **Visual regression** - Screenshot comparisons
- **API testing** - Backend endpoint validation
- **Performance testing** - Core Web Vitals monitoring
- **Accessibility testing** - WCAG compliance checks

## 📊 Coverage Requirements

### **Minimum Coverage Thresholds**
- **Branches**: 80%
- **Functions**: 80%
- **Lines**: 80%
- **Statements**: 80%

### **Coverage Reports**
```bash
# Generate HTML coverage report
pnpm test:cov

# View coverage report
open coverage/lcov-report/index.html
```

### **CI/CD Integration**
- Coverage reports uploaded to code coverage services
- Pull requests blocked if coverage drops below threshold
- Coverage trends tracked over time

## 🚀 Best Practices

### **Test Organization**
- **Co-locate tests** with source code in `__tests__` folders
- **Group related tests** using `describe` blocks
- **Use descriptive names** that explain the expected behavior
- **Test edge cases** and error conditions

### **Mocking Strategy**
- **Mock external dependencies** (APIs, databases, services)
- **Use Jest mocks** for consistent behavior
- **Avoid mocking internal modules** when possible
- **Reset mocks** between tests

### **Performance**
- **Run tests in parallel** when possible
- **Use `beforeAll`/`afterAll`** for expensive setup
- **Avoid unnecessary async/await** in synchronous tests
- **Clean up resources** after tests complete

---
**Navigation**: [← Standards](./standards.md) | [← Development Guide](./README.md)
