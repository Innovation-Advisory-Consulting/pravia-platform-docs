# Step 10: Package Exports & Integration

## Update Package Exports

### File: `packages/ui/src/views/index.ts`

Add knowledge base exports:

```typescript
// Existing exports...

// Cortex Knowledge Base
export { 
  KnowledgeBaseView,
  KnowledgeBaseUpload,
  KnowledgeBaseList,
  KnowledgeBaseDetail,
} from './cortex/knowledge-base';

export type {
  KBDocument,
  DocumentChunk,
  DocumentStatus,
  DocumentType,
  KBUploadConfig,
  DocumentFilters,
  SearchQuery,
  SearchResult,
} from './cortex/knowledge-base/types';
```

### File: `packages/ui/src/index.ts`

Ensure views are exported:

```typescript
// Views
export * from './views';
```

## Folder Structure Verification

Ensure this structure exists:

```
packages/ui/src/views/cortex/knowledge-base/
├── index.tsx
├── knowledge-base-upload.tsx
├── knowledge-base-list.tsx
├── knowledge-base-detail.tsx
├── types.ts
├── components/
│   ├── document-status-chip.tsx
│   ├── processing-progress.tsx (optional)
│   └── chunk-preview.tsx
└── hooks/
    ├── use-knowledge-base.ts
    ├── use-document-upload.ts
    └── use-document-processing.ts
```

## Import Patterns

### From Main Entry
```typescript
import { 
  KnowledgeBaseView,
  KBDocument,
  DocumentStatus 
} from '@asyml8/ui';
```

### From Subpath
```typescript
import { KnowledgeBaseView } from '@asyml8/ui/views';
import type { KBDocument } from '@asyml8/ui/views';
```

## Integration in Consumer Apps

### Example: Pravia Web App

**File**: `apps/pravia-web/src/pages/knowledge-base.tsx`

```typescript
import { KnowledgeBaseView } from '@asyml8/ui';
import { supabaseAdapter } from '@asyml8/ui/adapters';

export default function KnowledgeBasePage() {
  return (
    <KnowledgeBaseView
      knowledgeBaseId={process.env.NEXT_PUBLIC_KB_ID!}
      workflowId={process.env.NEXT_PUBLIC_WORKFLOW_ID!}
      storageAdapter={supabaseAdapter}
      forgeApiUrl={process.env.NEXT_PUBLIC_FORGE_API_URL!}
      helixApiUrl={process.env.NEXT_PUBLIC_HELIX_API_URL!}
      cortexApiUrl={process.env.NEXT_PUBLIC_CORTEX_API_URL!}
    />
  );
}
```

### Environment Variables

Add to `.env.local`:

```bash
NEXT_PUBLIC_KB_ID=kb-123
NEXT_PUBLIC_WORKFLOW_ID=5Wba1MKHnLpdc8IB
NEXT_PUBLIC_FORGE_API_URL=http://localhost:3000
NEXT_PUBLIC_HELIX_API_URL=http://localhost:4004
NEXT_PUBLIC_CORTEX_API_URL=http://localhost:4005
```

## Storybook Stories

### File: `packages/ui/src/views/cortex/knowledge-base/knowledge-base.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { KnowledgeBaseView } from './index';

const meta: Meta<typeof KnowledgeBaseView> = {
  title: 'Views/Cortex/KnowledgeBase',
  component: KnowledgeBaseView,
  parameters: {
    layout: 'fullscreen',
  },
};

export default meta;
type Story = StoryObj<typeof KnowledgeBaseView>;

export const Default: Story = {
  args: {
    knowledgeBaseId: 'kb-123',
    workflowId: '5Wba1MKHnLpdc8IB',
    forgeApiUrl: 'http://localhost:3000',
    helixApiUrl: 'http://localhost:4004',
    cortexApiUrl: 'http://localhost:4005',
    storageAdapter: {
      upload: async (file) => ({
        url: 'https://example.com/file.pdf',
        key: 'file.pdf',
      }),
      delete: async (key) => {},
      getUrl: async (key) => 'https://example.com/file.pdf',
    },
  },
};
```

## Testing Checklist

- [ ] Upload component renders
- [ ] File upload triggers workflow
- [ ] Processing status updates
- [ ] Document list displays
- [ ] Status chips show correct colors
- [ ] Actions menu works (View, Delete, Re-process)
- [ ] Detail view displays document info
- [ ] Chunks display correctly
- [ ] Tab navigation works
- [ ] Error handling works
- [ ] Loading states display

## Build & Publish

```bash
# From packages/ui directory
npm run build

# Version will auto-increment
# Publish to npm or internal registry
npm publish
```

## Documentation Updates

Update `packages/ui/README.md`:

```markdown
### Views
- **Auth Forms**: SignInForm, SignUpForm, ResetPasswordForm, etc.
- **Knowledge Base**: KnowledgeBaseView - Upload and manage documents in Cortex KB

## Knowledge Base View

Upload and manage documents in Cortex knowledge bases with automatic processing via n8n workflows.

\`\`\`tsx
import { KnowledgeBaseView } from '@asyml8/ui';

<KnowledgeBaseView
  knowledgeBaseId="kb-123"
  workflowId="workflow-id"
  storageAdapter={supabaseAdapter}
  forgeApiUrl="http://localhost:3000"
  helixApiUrl="http://localhost:4004"
  cortexApiUrl="http://localhost:4005"
/>
\`\`\`

Features:
- File upload with metadata (tags, description)
- Automatic document processing via n8n
- Document list with filtering
- Document detail view with chunks
- Re-process and delete actions
```

## Next Steps

Proceed to Step 11: API Implementation Guide
