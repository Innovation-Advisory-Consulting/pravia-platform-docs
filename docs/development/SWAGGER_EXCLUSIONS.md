# Swagger Type Generation Exclusions

## Exclude Entire Endpoints

Use `@ApiExcludeEndpoint()` to hide endpoints from Swagger (and generated types):

```typescript
import { ApiExcludeEndpoint } from '@nestjs/swagger';

@Controller('internal')
export class InternalController {
  
  @Get('debug')
  @ApiExcludeEndpoint()  // ← Won't appear in Swagger or generated types
  debugInfo() {
    return { debug: 'info' };
  }
}
```

## Exclude DTO Properties

Use `@ApiHideProperty()` to hide specific fields:

```typescript
import { ApiProperty, ApiHideProperty } from '@nestjs/swagger';

export class UserDto {
  @ApiProperty()
  name: string;
  
  @ApiProperty()
  email: string;
  
  @ApiHideProperty()  // ← Won't appear in generated types
  internalId: string;
}
```

## Exclude Entire Controllers

Don't use `@ApiTags()` on controllers you want to exclude:

```typescript
// This controller won't appear in Swagger
@Controller('internal')
export class InternalController {
  // No @ApiTags() decorator
}
```

## Example: Test-Only Endpoints

```typescript
@Controller('accounts')
export class AccountsController {
  
  @Get()
  @ApiTags('Accounts - Portal')
  list() {
    // Included in Swagger
  }
  
  @Delete(':id')
  @UseGuards(TestOnlyGuard)
  @ApiExcludeEndpoint()  // ← Excluded from Swagger
  deleteForTesting(@Param('id') id: string) {
    // Not in generated types
  }
}
```

## When to Exclude

Exclude endpoints/properties that are:
- Internal/debug only
- Test-only operations
- Deprecated (use `@ApiDeprecated()` instead to mark as deprecated)
- Implementation details not needed by frontend
- Security-sensitive fields

## Note

Excluded items:
- ✅ Won't appear in Swagger UI
- ✅ Won't be in generated TypeScript types
- ✅ Still work at runtime (just not documented)
