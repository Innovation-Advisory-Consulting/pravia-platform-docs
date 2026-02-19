# Step 4: Document Processing Status Hook

## File Location
`packages/ui/src/views/cortex/knowledge-base/hooks/use-document-processing.ts`

## Purpose
Poll n8n workflow execution status until completion.

## Implementation

```typescript
import { useQuery } from '@tanstack/react-query';
import type { WorkflowExecution } from '../types';

interface UseDocumentProcessingProps {
  executionId: string | null;
  helixApiUrl: string;
  enabled?: boolean;
  onComplete?: (execution: WorkflowExecution) => void;
  onError?: (execution: WorkflowExecution) => void;
}

export const useDocumentProcessing = ({
  executionId,
  helixApiUrl,
  enabled = true,
  onComplete,
  onError,
}: UseDocumentProcessingProps) => {
  const fetchExecutionStatus = async (): Promise<WorkflowExecution> => {
    const response = await fetch(
      `${helixApiUrl}/api/n8n/executions/${executionId}`
    );

    if (!response.ok) {
      throw new Error('Failed to fetch execution status');
    }

    return response.json();
  };

  const query = useQuery({
    queryKey: ['workflow-execution', executionId],
    queryFn: fetchExecutionStatus,
    enabled: enabled && !!executionId,
    refetchInterval: (data) => {
      // Stop polling if execution is complete
      if (!data) return 2000;
      
      const { status } = data;
      if (status === 'success') {
        onComplete?.(data);
        return false;
      }
      if (status === 'error') {
        onError?.(data);
        return false;
      }
      
      // Continue polling every 2 seconds
      return 2000;
    },
  });

  const isProcessing = query.data?.status === 'running' || query.data?.status === 'waiting';
  const isComplete = query.data?.status === 'success';
  const isFailed = query.data?.status === 'error';

  return {
    execution: query.data,
    isProcessing,
    isComplete,
    isFailed,
    error: query.error,
  };
};
```

## Usage Example

```typescript
import { useState } from 'react';
import { useDocumentProcessing } from './hooks/use-document-processing';

const MyComponent = () => {
  const [executionId, setExecutionId] = useState<string | null>(null);

  const { execution, isProcessing, isComplete, isFailed } = useDocumentProcessing({
    executionId,
    helixApiUrl: 'http://localhost:4005',
    onComplete: (exec) => {
      console.log('Processing complete!', exec);
      // Refresh document list
    },
    onError: (exec) => {
      console.error('Processing failed:', exec.error);
    },
  });

  return (
    <div>
      {isProcessing && <p>Processing document...</p>}
      {isComplete && <p>Document ready!</p>}
      {isFailed && <p>Processing failed: {execution?.error}</p>}
    </div>
  );
};
```

## API Integration Points

### Helix API Endpoint
```
GET /api/n8n/executions/:executionId

Response:
{
  "id": "exec-456",
  "workflowId": "5Wba1MKHnLpdc8IB",
  "status": "running" | "success" | "error" | "waiting",
  "startedAt": "2025-11-28T20:00:00Z",
  "finishedAt": "2025-11-28T20:05:00Z",
  "data": {
    "documentId": "doc-789",
    "chunkCount": 42
  },
  "error": "Error message if failed"
}
```

## Polling Strategy

- Poll every 2 seconds while status is `running` or `waiting`
- Stop polling when status is `success` or `error`
- Trigger callbacks on completion/failure
- Use React Query's `refetchInterval` for automatic polling

## Next Steps

Proceed to Step 5: Knowledge Base Operations Hook
