# CustomSnackbar Refactoring - Expandable Notifications Integration

## Summary

Successfully refactored the CustomSnackbar notification system to support expandable notifications using a component composition pattern. This makes the system extensible and easy to add new notification types.

## Changes Made

### 1. New Structure

```
custom-snackbar/
├── notifications/                              # NEW: Notification components folder
│   ├── standard-notification.tsx              # Extracted from provider
│   ├── expandable-notification.tsx            # Moved and adapted
│   ├── standalone-expandable-notification.tsx # Backward compatibility
│   └── index.ts
├── custom-snackbar-provider.tsx               # Refactored to use components
├── notification-store.ts                      # Updated with new fields
├── types.ts                                   # Extended with expandable options
├── utils.ts                                   # Added showExpandableError()
├── CustomSnackbar.stories.tsx                 # Updated with examples
└── index.ts                                   # Updated exports
```

### 2. Component Extraction

**StandardNotification** (`notifications/standard-notification.tsx`)
- Extracted Alert logic from provider
- Parameterized with props: message, type, icon, actions, closable, onClose
- Reusable and testable in isolation

**ExpandableNotification** (`notifications/expandable-notification.tsx`)
- Moved from `src/components/expandable-notification.tsx`
- Adapted to work with notification system (removed fixed positioning)
- Uses new API: `message`, `type` (instead of `title`, `severity`)

**StandaloneExpandableNotification** (`notifications/standalone-expandable-notification.tsx`)
- Backward compatibility wrapper
- Keeps old API: `title`, `severity`
- Has fixed positioning for standalone use
- Exported as `ExpandableNotification` for existing code

### 3. Provider Refactoring

**Before:**
```tsx
<Snackbar>
  <Alert severity={...} icon={...} action={...}>
    {message}
  </Alert>
</Snackbar>
```

**After:**
```tsx
{notification.expandable ? (
  <div style={{ position: 'fixed', ... }}>
    <ExpandableNotification {...props} />
  </div>
) : (
  <Snackbar>
    <StandardNotification {...props} />
  </Snackbar>
)}
```

### 4. Type System Updates

**types.ts** - Added expandable fields:
```typescript
interface NotificationOptions {
  // ... existing fields
  expandable?: boolean;
  errors?: ExpandableNotificationError[];
  onRetry?: () => void;
  retryText?: string;
  detailsTitle?: string;
  expandDirection?: 'right' | 'up';
}
```

### 5. New Utility Function

**utils.ts** - Added `showExpandableError()`:
```typescript
showExpandableError(
  message: ReactNode,
  errors: ExpandableNotificationError[],
  options?: { onRetry, retryText, ... }
): string
```

### 6. Storybook Updates

Added new demo section and story:
- "Expandable Error Notifications" section in Interactive demo
- New `ExpandableErrors` story with examples
- Shows multiple service errors and validation errors

## Usage

### Standard Notifications (unchanged)
```typescript
showSuccess('Operation completed!');
showError('Something went wrong');
```

### New: Expandable Error Notifications
```typescript
showExpandableError(
  'Multiple errors occurred',
  [
    { service: 'API Gateway', message: 'Connection timeout' },
    { service: 'Database', message: 'Query failed' },
    { service: 'Cache', message: 'Redis connection lost' }
  ],
  {
    onRetry: () => retryOperation(),
    retryText: 'Retry All'
  }
);
```

## Benefits

1. **Separation of Concerns**
   - Provider = Orchestration (positioning, stacking, lifecycle)
   - Components = Presentation (how each type looks/behaves)

2. **Easy to Extend**
   - Add new notification types by creating new components in `notifications/`
   - No need to modify provider logic

3. **Testable**
   - Each notification component can be tested in isolation
   - Provider logic is simpler and easier to test

4. **Type Safe**
   - Full TypeScript support
   - Proper type inference for all options

## Migration Path

Use the notification system for all new and existing code:
```typescript
import { showExpandableError } from '@asyml8/ui';

// In component or effect
useEffect(() => {
  if (errors.length > 0) {
    const id = showExpandableError('Multiple errors', errors, {
      onRetry: handleRetry
    });
    
    // Clean up on unmount
    return () => dismissNotification(id);
  }
}, [errors]);
```

## Future Enhancements

Easy to add new notification types:
- `ToastNotification` - Minimal toast-style notifications
- `BannerNotification` - Full-width banner at top
- `ModalNotification` - Center-screen modal-style
- `ProgressNotification` - With built-in progress bar

Just create new component in `notifications/` folder and add to provider's component map.

## Testing

- ✅ TypeScript compilation passes
- ✅ InitializeView updated to use new API
- ✅ Storybook stories updated
- ⏳ Manual testing recommended
- ⏳ Unit tests (if needed)

## Files Changed

- Created: `notifications/standard-notification.tsx`
- Created: `notifications/expandable-notification.tsx`
- Created: `notifications/index.ts`
- Modified: `custom-snackbar-provider.tsx`
- Modified: `notification-store.ts`
- Modified: `types.ts`
- Modified: `utils.ts`
- Modified: `index.ts`
- Modified: `CustomSnackbar.stories.tsx`
- Modified: `views/initialize/initialize-view.tsx` (updated to use new API)
- Deleted: `src/components/expandable-notification.tsx`
- Modified: `src/components/index.ts`
