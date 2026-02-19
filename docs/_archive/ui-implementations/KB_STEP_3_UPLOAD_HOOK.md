# Step 3: Document Upload Hook

## File Location
`packages/ui/src/views/cortex/knowledge-base/hooks/use-document-upload.ts`

## Purpose
Handle file upload to Forge API and trigger n8n workflow via Helix API.

## Implementation

```typescript
import { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import type { 
  KBUploadConfig, 
  WorkflowExecution, 
  WorkflowTriggerResponse 
} from '../types';

interface UseDocumentUploadProps {
  config: KBUploadConfig;
  helixApiUrl: string;
  onSuccess?: (executionId: string) => void;
  onError?: (error: Error) => void;
}

export const useDocumentUpload = ({
  config,
  helixApiUrl,
  onSuccess,
  onError,
}: UseDocumentUploadProps) => {
  const [uploadProgress, setUploadProgress] = useState(0);

  // Trigger n8n workflow
  const triggerWorkflow = async (fileUrl: string, metadata: any) => {
    const response = await fetch(
      `${helixApiUrl}/api/n8n/workflows/${config.workflowId}/execute`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          fileUrl,
          knowledgeBaseId: config.knowledgeBaseId,
          metadata,
          chunkSize: config.chunkSize || 1000,
          chunkOverlap: config.chunkOverlap || 200,
        }),
      }
    );

    if (!response.ok) {
      throw new Error('Failed to trigger workflow');
    }

    return response.json() as Promise<WorkflowTriggerResponse>;
  };

  // Mutation for workflow trigger
  const workflowMutation = useMutation({
    mutationFn: ({ fileUrl, metadata }: { fileUrl: string; metadata: any }) =>
      triggerWorkflow(fileUrl, metadata),
    onSuccess: (data) => {
      onSuccess?.(data.executionId);
    },
    onError: (error: Error) => {
      onError?.(error);
    },
  });

  // Handle upload complete from QuantumFileUpload
  const handleUploadComplete = async (fileUrl: string, metadata: any = {}) => {
    await workflowMutation.mutateAsync({ fileUrl, metadata });
  };

  return {
    handleUploadComplete,
    isTriggering: workflowMutation.isPending,
    triggerError: workflowMutation.error,
    uploadProgress,
    setUploadProgress,
  };
};
```

## Usage Example

```typescript
import { useDocumentUpload } from './hooks/use-document-upload';

const MyComponent = () => {
  const { handleUploadComplete, isTriggering } = useDocumentUpload({
    config: {
      knowledgeBaseId: 'kb-123',
      workflowId: '5Wba1MKHnLpdc8IB',
    },
    helixApiUrl: 'http://localhost:4005',
    onSuccess: (executionId) => {
      console.log('Workflow triggered:', executionId);
    },
    onError: (error) => {
      console.error('Failed to trigger workflow:', error);
    },
  });

  // Called when QuantumFileUpload completes
  const onFileUploaded = (fileUrl: string) => {
    handleUploadComplete(fileUrl, {
      tags: ['important'],
      description: 'My document',
    });
  };

  return <div>Upload component here</div>;
};
```

## API Integration Points

### Helix API Endpoint
```
POST /api/n8n/workflows/:workflowId/execute

Request Body:
{
  "fileUrl": "https://storage.example.com/file.pdf",
  "knowledgeBaseId": "kb-123",
  "metadata": {
    "tags": ["tag1"],
    "description": "..."
  },
  "chunkSize": 1000,
  "chunkOverlap": 200
}

Response:
{
  "executionId": "exec-456",
  "status": "running"
}
```

## Next Steps

Proceed to Step 4: Processing Status Hook
