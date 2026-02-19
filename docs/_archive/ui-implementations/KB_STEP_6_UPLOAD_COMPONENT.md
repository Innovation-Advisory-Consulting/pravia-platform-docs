# Step 6: Upload Component

## File Location
`packages/ui/src/views/cortex/knowledge-base/knowledge-base-upload.tsx`

## Purpose
File upload interface that integrates QuantumFileUpload with workflow triggering.

## Implementation

```typescript
import { useState } from 'react';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Chip from '@mui/material/Chip';
import Alert from '@mui/material/Alert';
import { QuantumFileUpload } from '../../../components/inputs/quantum-file-upload';
import { useDocumentUpload } from './hooks/use-document-upload';
import { useDocumentProcessing } from './hooks/use-document-processing';
import type { KBUploadConfig, StorageAdapter } from '../types';

interface KnowledgeBaseUploadProps {
  config: KBUploadConfig;
  storageAdapter: StorageAdapter;
  helixApiUrl: string;
  onUploadComplete?: (documentId: string) => void;
}

export const KnowledgeBaseUpload = ({
  config,
  storageAdapter,
  helixApiUrl,
  onUploadComplete,
}: KnowledgeBaseUploadProps) => {
  const [tags, setTags] = useState<string[]>([]);
  const [description, setDescription] = useState('');
  const [executionId, setExecutionId] = useState<string | null>(null);

  const { handleUploadComplete, isTriggering, triggerError } = useDocumentUpload({
    config,
    helixApiUrl,
    onSuccess: (execId) => {
      setExecutionId(execId);
    },
  });

  const { isProcessing, isComplete, isFailed, execution } = useDocumentProcessing({
    executionId,
    helixApiUrl,
    onComplete: (exec) => {
      const documentId = exec.data?.documentId;
      if (documentId) {
        onUploadComplete?.(documentId);
      }
    },
  });

  const handleFileUploadComplete = async (fileUrl: string) => {
    await handleUploadComplete(fileUrl, {
      tags,
      description,
    });
  };

  return (
    <Stack spacing={3}>
      {/* Metadata Inputs */}
      <Stack spacing={2}>
        <TextField
          label="Description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          multiline
          rows={2}
          fullWidth
        />
        
        <TextField
          label="Tags (comma-separated)"
          placeholder="research, ai, important"
          onChange={(e) => {
            const value = e.target.value;
            setTags(value.split(',').map(t => t.trim()).filter(Boolean));
          }}
          fullWidth
        />
        
        {tags.length > 0 && (
          <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
            {tags.map((tag) => (
              <Chip
                key={tag}
                label={tag}
                size="small"
                onDelete={() => setTags(tags.filter(t => t !== tag))}
              />
            ))}
          </Box>
        )}
      </Stack>

      {/* File Upload */}
      <QuantumFileUpload
        storageAdapter={storageAdapter}
        config={{
          maxFileSize: config.maxFileSize || 10 * 1024 * 1024,
          allowedTypes: config.allowedTypes || [
            'application/pdf',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'text/plain',
            'text/markdown',
          ],
        }}
        onUploadComplete={(file) => handleFileUploadComplete(file.url)}
        title="Upload Documents"
      />

      {/* Status Messages */}
      {isTriggering && (
        <Alert severity="info">Triggering document processing...</Alert>
      )}
      
      {isProcessing && (
        <Alert severity="info">Processing document into knowledge base...</Alert>
      )}
      
      {isComplete && (
        <Alert severity="success">
          Document successfully added to knowledge base!
        </Alert>
      )}
      
      {isFailed && (
        <Alert severity="error">
          Processing failed: {execution?.error || 'Unknown error'}
        </Alert>
      )}
      
      {triggerError && (
        <Alert severity="error">
          Failed to trigger workflow: {triggerError.message}
        </Alert>
      )}
    </Stack>
  );
};
```

## Usage Example

```typescript
import { KnowledgeBaseUpload } from './knowledge-base-upload';
import { supabaseAdapter } from '@asyml8/ui/adapters';

<KnowledgeBaseUpload
  config={{
    knowledgeBaseId: 'kb-123',
    workflowId: '5Wba1MKHnLpdc8IB',
    maxFileSize: 10 * 1024 * 1024,
    allowedTypes: ['application/pdf', 'text/plain'],
  }}
  storageAdapter={supabaseAdapter}
  helixApiUrl="http://localhost:4005"
  onUploadComplete={(docId) => {
    console.log('Document added:', docId);
  }}
/>
```

## Features

- Metadata input (tags, description)
- File upload via QuantumFileUpload
- Automatic workflow triggering
- Real-time processing status
- Error handling
- Success/failure notifications

## Accepted File Types

- PDF (`.pdf`)
- Word Documents (`.docx`)
- Text Files (`.txt`)
- Markdown (`.md`)

## Next Steps

Proceed to Step 7: Document List Component
