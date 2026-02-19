# Step 9: Main View Integration

## File Location
`packages/ui/src/views/cortex/knowledge-base/index.tsx`

## Purpose
Main view that combines upload and list components with routing.

## Implementation

```typescript
import { useState } from 'react';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';
import { KnowledgeBaseUpload } from './knowledge-base-upload';
import { KnowledgeBaseList } from './knowledge-base-list';
import { KnowledgeBaseDetail } from './knowledge-base-detail';
import type { KBDocument, KBUploadConfig } from './types';
import type { StorageAdapter } from '../../../types/quantum-file-upload';

interface KnowledgeBaseViewProps {
  knowledgeBaseId: string;
  workflowId: string;
  storageAdapter: StorageAdapter;
  forgeApiUrl: string;
  helixApiUrl: string;
  cortexApiUrl: string;
  config?: Partial<KBUploadConfig>;
}

export const KnowledgeBaseView = ({
  knowledgeBaseId,
  workflowId,
  storageAdapter,
  forgeApiUrl,
  helixApiUrl,
  cortexApiUrl,
  config = {},
}: KnowledgeBaseViewProps) => {
  const [activeTab, setActiveTab] = useState(0);
  const [selectedDocument, setSelectedDocument] = useState<KBDocument | null>(null);

  const uploadConfig: KBUploadConfig = {
    knowledgeBaseId,
    workflowId,
    maxFileSize: config.maxFileSize || 10 * 1024 * 1024,
    allowedTypes: config.allowedTypes || [
      'application/pdf',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'text/plain',
      'text/markdown',
    ],
    chunkSize: config.chunkSize || 1000,
    chunkOverlap: config.chunkOverlap || 200,
  };

  const handleUploadComplete = (documentId: string) => {
    // Switch to documents tab after upload
    setActiveTab(1);
  };

  const handleViewDocument = (document: KBDocument) => {
    setSelectedDocument(document);
  };

  const handleCloseDetail = () => {
    setSelectedDocument(null);
  };

  // Show detail view if document selected
  if (selectedDocument) {
    return (
      <KnowledgeBaseDetail
        documentId={selectedDocument.id}
        knowledgeBaseId={knowledgeBaseId}
        cortexApiUrl={cortexApiUrl}
        onClose={handleCloseDetail}
      />
    );
  }

  return (
    <Box>
      <Stack spacing={3}>
        {/* Header */}
        <Typography variant="h4">Knowledge Base</Typography>

        {/* Tabs */}
        <Tabs value={activeTab} onChange={(_, value) => setActiveTab(value)}>
          <Tab label="Upload Documents" />
          <Tab label="Manage Documents" />
        </Tabs>

        {/* Tab Panels */}
        <Box>
          {activeTab === 0 && (
            <KnowledgeBaseUpload
              config={uploadConfig}
              storageAdapter={storageAdapter}
              helixApiUrl={helixApiUrl}
              onUploadComplete={handleUploadComplete}
            />
          )}

          {activeTab === 1 && (
            <KnowledgeBaseList
              knowledgeBaseId={knowledgeBaseId}
              cortexApiUrl={cortexApiUrl}
              onViewDocument={handleViewDocument}
            />
          )}
        </Box>
      </Stack>
    </Box>
  );
};

// Export all components
export { KnowledgeBaseUpload } from './knowledge-base-upload';
export { KnowledgeBaseList } from './knowledge-base-list';
export { KnowledgeBaseDetail } from './knowledge-base-detail';
export * from './types';
```

## Usage Example

```typescript
import { KnowledgeBaseView } from '@asyml8/ui';
import { supabaseAdapter } from '@asyml8/ui/adapters';

function App() {
  return (
    <KnowledgeBaseView
      knowledgeBaseId="kb-123"
      workflowId="5Wba1MKHnLpdc8IB"
      storageAdapter={supabaseAdapter}
      forgeApiUrl="http://localhost:3000"
      helixApiUrl="http://localhost:4005"
      cortexApiUrl="http://localhost:4006"
      config={{
        maxFileSize: 20 * 1024 * 1024, // 20MB
        chunkSize: 1500,
        chunkOverlap: 300,
      }}
    />
  );
}
```

## Features

- Tab navigation (Upload / Manage)
- Upload documents tab
- Manage documents tab
- Document detail view (modal-like)
- Auto-switch to manage tab after upload
- Configurable settings

## Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| knowledgeBaseId | string | Yes | Cortex knowledge base ID |
| workflowId | string | Yes | n8n workflow ID for processing |
| storageAdapter | StorageAdapter | Yes | File storage adapter |
| forgeApiUrl | string | Yes | Forge API base URL |
| helixApiUrl | string | Yes | Helix API base URL |
| cortexApiUrl | string | Yes | Cortex API base URL |
| config | Partial<KBUploadConfig> | No | Optional configuration |

## Configuration Options

```typescript
{
  maxFileSize: number;        // Max file size in bytes (default: 10MB)
  allowedTypes: string[];     // MIME types (default: PDF, DOCX, TXT, MD)
  chunkSize: number;          // Chunk size in chars (default: 1000)
  chunkOverlap: number;       // Chunk overlap in chars (default: 200)
}
```

## Next Steps

Proceed to Step 10: Package Exports & Integration
