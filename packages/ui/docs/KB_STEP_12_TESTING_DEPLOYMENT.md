# Step 12: Testing & Deployment

## Testing Strategy

### Unit Tests

#### Hook Tests

**File**: `packages/ui/src/views/cortex/knowledge-base/hooks/__tests__/use-document-upload.test.ts`

```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useDocumentUpload } from '../use-document-upload';

const createWrapper = () => {
  const queryClient = new QueryClient();
  return ({ children }: any) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
};

describe('useDocumentUpload', () => {
  it('should trigger workflow on upload complete', async () => {
    const onSuccess = vi.fn();
    
    const { result } = renderHook(
      () => useDocumentUpload({
        config: {
          knowledgeBaseId: 'kb-123',
          workflowId: 'workflow-123',
        },
        helixApiUrl: 'http://localhost:4004',
        onSuccess,
      }),
      { wrapper: createWrapper() }
    );

    await result.current.handleUploadComplete('https://file.pdf', {});
    
    await waitFor(() => {
      expect(onSuccess).toHaveBeenCalled();
    });
  });
});
```

#### Component Tests

**File**: `packages/ui/src/views/cortex/knowledge-base/__tests__/knowledge-base-upload.test.tsx`

```typescript
import { render, screen } from '@testing-library/react';
import { KnowledgeBaseUpload } from '../knowledge-base-upload';

describe('KnowledgeBaseUpload', () => {
  it('should render upload component', () => {
    render(
      <KnowledgeBaseUpload
        config={{
          knowledgeBaseId: 'kb-123',
          workflowId: 'workflow-123',
        }}
        storageAdapter={mockAdapter}
        helixApiUrl="http://localhost:4004"
      />
    );

    expect(screen.getByText('Upload Documents')).toBeInTheDocument();
  });
});
```

### Integration Tests

#### End-to-End Flow

```typescript
describe('Knowledge Base E2E', () => {
  it('should upload and process document', async () => {
    // 1. Render view
    render(<KnowledgeBaseView {...props} />);
    
    // 2. Upload file
    const file = new File(['content'], 'test.pdf', { type: 'application/pdf' });
    const input = screen.getByLabelText('Upload');
    await userEvent.upload(input, file);
    
    // 3. Wait for processing
    await waitFor(() => {
      expect(screen.getByText('Processing complete')).toBeInTheDocument();
    });
    
    // 4. Switch to documents tab
    await userEvent.click(screen.getByText('Manage Documents'));
    
    // 5. Verify document appears
    expect(screen.getByText('test.pdf')).toBeInTheDocument();
  });
});
```

### Manual Testing Checklist

#### Upload Flow
- [ ] Select file via button
- [ ] Drag and drop file
- [ ] Add tags and description
- [ ] Upload triggers successfully
- [ ] Processing status updates
- [ ] Success message appears
- [ ] Auto-switch to documents tab

#### Document List
- [ ] Documents load and display
- [ ] Status chips show correct colors
- [ ] File types display correctly
- [ ] Sizes format properly
- [ ] Dates format correctly
- [ ] Search works
- [ ] Filters work

#### Document Actions
- [ ] View document opens detail
- [ ] Re-process triggers workflow
- [ ] Delete removes document
- [ ] Actions menu opens/closes

#### Document Detail
- [ ] Document info displays
- [ ] Chunks list displays
- [ ] Chunk content shows
- [ ] Re-process button works
- [ ] Delete button works
- [ ] Close returns to list

#### Error Handling
- [ ] Upload errors show message
- [ ] Workflow trigger errors show
- [ ] Processing errors show
- [ ] API errors show
- [ ] Network errors handled

---

## Storybook Testing

### Run Storybook

```bash
cd packages/ui
npm run storybook
```

### Test Stories

1. Navigate to **Views → Cortex → KnowledgeBase**
2. Test each story:
   - Default
   - With Documents
   - Processing State
   - Error State

### Interaction Testing

Use Storybook's interaction testing:

```typescript
export const WithInteraction: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);
    
    // Click upload tab
    await userEvent.click(canvas.getByText('Upload Documents'));
    
    // Add description
    const input = canvas.getByLabelText('Description');
    await userEvent.type(input, 'Test document');
    
    // Verify
    expect(input).toHaveValue('Test document');
  },
};
```

---

## Performance Testing

### Bundle Size

Check impact on bundle size:

```bash
cd packages/ui
npm run build
npm run analyze
```

Ensure:
- Knowledge Base components are tree-shakeable
- No unnecessary dependencies included
- Code splitting works properly

### Load Testing

Test with large document lists:

```typescript
// Generate mock data
const mockDocuments = Array.from({ length: 1000 }, (_, i) => ({
  id: `doc-${i}`,
  name: `document-${i}.pdf`,
  status: 'ready',
  // ...
}));

// Test rendering performance
const { rerender } = render(
  <KnowledgeBaseList documents={mockDocuments} />
);
```

---

## Deployment

### Build Package

```bash
cd packages/ui
npm run build
```

### Version Management

Version auto-increments on build. To manually set:

```bash
npm version patch  # 1.0.643 → 1.0.644
npm version minor  # 1.0.643 → 1.1.0
npm version major  # 1.0.643 → 2.0.0
```

### Publish to Registry

```bash
# Publish to npm
npm publish

# Or publish to private registry
npm publish --registry https://registry.example.com
```

### Consumer App Updates

```bash
# In consumer app (e.g., apps/pravia-web)
pnpm update @asyml8/ui
```

---

## Environment Setup

### Development

```bash
# .env.local
NEXT_PUBLIC_KB_ID=kb-dev-123
NEXT_PUBLIC_WORKFLOW_ID=5Wba1MKHnLpdc8IB
NEXT_PUBLIC_FORGE_API_URL=http://localhost:4002
NEXT_PUBLIC_HELIX_API_URL=http://localhost:4004
NEXT_PUBLIC_CORTEX_API_URL=http://localhost:4005
```

### Staging

```bash
NEXT_PUBLIC_KB_ID=kb-staging-123
NEXT_PUBLIC_WORKFLOW_ID=workflow-staging-id
NEXT_PUBLIC_FORGE_API_URL=https://forge-staging.example.com
NEXT_PUBLIC_HELIX_API_URL=https://helix-staging.example.com
NEXT_PUBLIC_CORTEX_API_URL=https://cortex-staging.example.com
```

### Production

```bash
NEXT_PUBLIC_KB_ID=kb-prod-123
NEXT_PUBLIC_WORKFLOW_ID=workflow-prod-id
NEXT_PUBLIC_FORGE_API_URL=https://forge.example.com
NEXT_PUBLIC_HELIX_API_URL=https://helix.example.com
NEXT_PUBLIC_CORTEX_API_URL=https://cortex.example.com
```

---

## Monitoring

### Error Tracking

Integrate with error tracking service:

```typescript
import * as Sentry from '@sentry/react';

const { handleUploadComplete } = useDocumentUpload({
  config,
  helixApiUrl,
  onError: (error) => {
    Sentry.captureException(error, {
      tags: {
        component: 'KnowledgeBaseUpload',
        knowledgeBaseId: config.knowledgeBaseId,
      },
    });
  },
});
```

### Analytics

Track usage:

```typescript
import { analytics } from '@/lib/analytics';

const handleUploadComplete = (documentId: string) => {
  analytics.track('kb_document_uploaded', {
    documentId,
    knowledgeBaseId,
  });
};
```

---

## Rollback Plan

If issues occur in production:

1. **Revert Package Version**
   ```bash
   pnpm add @asyml8/ui@1.0.642
   ```

2. **Disable Feature**
   ```typescript
   const ENABLE_KB = process.env.NEXT_PUBLIC_ENABLE_KB === 'true';
   
   {ENABLE_KB && <KnowledgeBaseView {...props} />}
   ```

3. **Hotfix**
   - Create hotfix branch
   - Fix issue
   - Publish patch version
   - Deploy

---

## Documentation

### Update Changelog

**File**: `packages/ui/CHANGELOG.md`

```markdown
## [1.0.644] - 2025-11-28

### Added
- Knowledge Base view for document upload and management
- Integration with Helix n8n API for document processing
- Integration with Cortex API for knowledge base operations
- Document upload with metadata (tags, description)
- Document list with filtering and search
- Document detail view with chunks
- Re-process and delete actions
- Real-time processing status updates

### Components
- `KnowledgeBaseView` - Main view
- `KnowledgeBaseUpload` - Upload component
- `KnowledgeBaseList` - Document list
- `KnowledgeBaseDetail` - Detail view

### Hooks
- `useDocumentUpload` - Upload and workflow trigger
- `useDocumentProcessing` - Status polling
- `useKnowledgeBase` - CRUD operations
```

### Update README

See Step 10 for README updates.

---

## Success Criteria

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Storybook stories work
- [ ] Manual testing checklist complete
- [ ] Bundle size acceptable
- [ ] Performance acceptable
- [ ] Documentation complete
- [ ] Deployed to staging
- [ ] Tested in staging
- [ ] Deployed to production
- [ ] Monitoring in place

---

## Next Steps

Implementation complete! Begin building components following the steps in order.
