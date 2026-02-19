# Swagger API Documentation Standards

## Overview
This prompt provides standards for creating comprehensive Swagger/OpenAPI documentation for NestJS APIs with proper schemas, examples, and descriptions.

## DTO Standards

### Required Imports
```typescript
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsString, IsOptional, IsObject, IsNumber, Min, Max } from 'class-validator';
```

### Property Decorators Template
```typescript
@ApiProperty({
  description: 'Clear description of the field purpose',
  example: 'realistic_example_value',
  format: 'email|uuid|date-time', // when applicable
  minimum: 1, // for numbers
  maximum: 1000, // for numbers
  minLength: 8, // for strings
  type: 'string|number|object|array'
})

@ApiPropertyOptional({
  description: 'Description for optional fields',
  example: 'example_value',
  default: 'default_value', // when applicable
  type: 'object',
  properties: { // for nested objects
    key: { type: 'string', example: 'value' }
  }
})
```

### Example DTO Structure
```typescript
export class CreateResourceDto {
  @ApiProperty({
    description: 'Resource name',
    example: 'My Resource',
    minLength: 1,
    maxLength: 100
  })
  @IsString()
  name: string;

  @ApiPropertyOptional({
    description: 'Resource metadata',
    example: {
      category: 'important',
      tags: ['tag1', 'tag2']
    },
    type: 'object'
  })
  @IsOptional()
  @IsObject()
  metadata?: {
    category?: string;
    tags?: string[];
    [key: string]: any;
  };
}
```

## Controller Standards

### Required Imports
```typescript
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth, ApiBody } from '@nestjs/swagger';
```

### Endpoint Documentation Template
```typescript
@Post('resource')
@UseGuards(AuthGuard('jwt')) // if protected
@ApiBearerAuth() // if protected
@ApiOperation({
  summary: 'Brief action description (under 50 chars)',
  description: 'Detailed description explaining what the endpoint does, when to use it, and any important behavior. Include business context and use cases.'
})
@ApiBody({
  description: 'Request body description',
  type: CreateResourceDto,
  examples: {
    basic: {
      summary: 'Basic example',
      value: {
        name: 'Example Resource',
        metadata: {
          category: 'test'
        }
      }
    },
    advanced: {
      summary: 'Advanced example',
      value: {
        name: 'Advanced Resource',
        metadata: {
          category: 'production',
          tags: ['important', 'featured'],
          settings: {
            enabled: true,
            priority: 'high'
          }
        }
      }
    }
  }
})
@ApiResponse({
  status: 201,
  description: 'Resource created successfully',
  schema: {
    type: 'object',
    properties: {
      id: { type: 'string', example: 'uuid-here' },
      name: { type: 'string', example: 'My Resource' },
      createdAt: { type: 'string', example: '2024-01-15T10:30:00Z' },
      metadata: {
        type: 'object',
        example: {
          category: 'important',
          tags: ['tag1', 'tag2']
        }
      }
    }
  }
})
@ApiResponse({ status: 400, description: 'Invalid request data' })
@ApiResponse({ status: 401, description: 'Authentication required' })
@ApiResponse({ status: 403, description: 'Insufficient permissions' })
@ApiParam({ 
  name: 'id', 
  description: 'Resource UUID',
  example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
})
@ApiQuery({
  name: 'page',
  required: false,
  description: 'Page number for pagination',
  example: 1,
  type: 'number'
})
async createResource(@Body() data: CreateResourceDto) {
  // implementation
}
```

## Response Schema Standards

### Success Response Template
```typescript
@ApiResponse({
  status: 200,
  description: 'Operation completed successfully',
  schema: {
    type: 'object',
    properties: {
      // Primary data
      id: { type: 'string', example: 'uuid-example' },
      name: { type: 'string', example: 'Resource Name' },
      
      // Timestamps
      createdAt: { type: 'string', example: '2024-01-15T10:30:00Z' },
      updatedAt: { type: 'string', example: '2024-01-15T10:30:00Z' },
      
      // Nested objects
      metadata: {
        type: 'object',
        properties: {
          key: { type: 'string', example: 'value' }
        }
      },
      
      // Arrays
      items: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            id: { type: 'string', example: 'item-uuid' },
            name: { type: 'string', example: 'Item Name' }
          }
        }
      }
    }
  }
})
```

### Paginated Response Template
```typescript
@ApiResponse({
  status: 200,
  description: 'Paginated results retrieved successfully',
  schema: {
    type: 'object',
    properties: {
      data: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            id: { type: 'string', example: 'uuid' },
            name: { type: 'string', example: 'Item Name' }
          }
        }
      },
      pagination: {
        type: 'object',
        properties: {
          page: { type: 'number', example: 1 },
          perPage: { type: 'number', example: 50 },
          total: { type: 'number', example: 150 },
          totalPages: { type: 'number', example: 3 }
        }
      }
    }
  }
})
```

### Error Response Standards
```typescript
@ApiResponse({ status: 400, description: 'Bad Request - Invalid input data' })
@ApiResponse({ status: 401, description: 'Unauthorized - Authentication required' })
@ApiResponse({ status: 403, description: 'Forbidden - Insufficient permissions' })
@ApiResponse({ status: 404, description: 'Not Found - Resource does not exist' })
@ApiResponse({ status: 409, description: 'Conflict - Resource already exists' })
@ApiResponse({ status: 422, description: 'Unprocessable Entity - Validation failed' })
@ApiResponse({ status: 500, description: 'Internal Server Error' })
```

## Best Practices

### 1. Descriptions
- **Summary**: Brief, action-oriented (e.g., "Create user", "Update profile")
- **Description**: Detailed explanation including business context
- **Examples**: Realistic data that developers would actually use

### 2. Examples
- Provide multiple examples for complex endpoints (basic, advanced)
- Use realistic data (not "string", "number")
- Include edge cases when relevant

### 3. Schema Definitions
- Always define complete response schemas
- Include all possible fields
- Use proper types and formats
- Add examples for each property

### 4. Error Handling
- Document all possible error responses
- Use standard HTTP status codes
- Provide clear error descriptions

### 5. Authentication
- Always include `@ApiBearerAuth()` for protected endpoints
- Document authentication requirements in descriptions
- Include 401/403 responses for protected endpoints

## Implementation Checklist

- [ ] All DTOs have `@ApiProperty` decorators with examples
- [ ] All endpoints have `@ApiOperation` with summary and description
- [ ] All endpoints have complete `@ApiResponse` schemas
- [ ] All parameters have `@ApiParam` or `@ApiQuery` documentation
- [ ] Protected endpoints have `@ApiBearerAuth()` and auth error responses
- [ ] Complex endpoints have multiple examples
- [ ] Response schemas match actual API responses
- [ ] All error cases are documented

## Testing Documentation

After implementing:
1. Start the API server
2. Visit `/docs` endpoint
3. Verify all schemas show properly
4. Test "Try it out" functionality
5. Confirm examples are realistic and helpful
6. Check that response schemas match actual API responses
