# Step 5: Knowledge Base Operations Hook

## File Location
`packages/ui/src/views/cortex/knowledge-base/hooks/use-knowledge-base.ts`

## Purpose
Handle CRUD operations for knowledge base documents via Cortex API.

## Implementation

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import type { 
  KBDocument, 
  DocumentFilters, 
  ListDocumentsResponse,
  DocumentDetailResponse 
} from '../types';

interface UseKnowledgeBaseProps {
  knowledgeBaseId: string;
  cortexApiUrl: string;
}

export const useKnowledgeBase = ({
  knowledgeBaseId,
  cortexApiUrl,
}: UseKnowledgeBaseProps) => {
  const queryClient = useQueryClient();
  const baseUrl = `${cortexApiUrl}/api/cortex/knowledge-bases/${knowledgeBaseId}`;

  // List documents
  const useDocuments = (filters?: DocumentFilters) => {
    const params = new URLSearchParams();
    if (filters?.status) params.append('status', filters.status.join(','));
    if (filters?.search) params.append('search', filters.search);

    return useQuery({
      queryKey: ['kb-documents', knowledgeBaseId, filters],
      queryFn: async (): Promise<ListDocumentsResponse> => {
        const response = await fetch(`${baseUrl}/documents?${params}`);
        if (!response.ok) throw new Error('Failed to fetch documents');
        return response.json();
      },
    });
  };

  // Get document details
  const useDocument = (documentId: string | null) => {
    return useQuery({
      queryKey: ['kb-document', documentId],
      queryFn: async (): Promise<DocumentDetailResponse> => {
        const response = await fetch(`${baseUrl}/documents/${documentId}`);
        if (!response.ok) throw new Error('Failed to fetch document');
        return response.json();
      },
      enabled: !!documentId,
    });
  };

  // Delete document
  const deleteDocument = useMutation({
    mutationFn: async (documentId: string) => {
      const response = await fetch(`${baseUrl}/documents/${documentId}`, {
        method: 'DELETE',
      });
      if (!response.ok) throw new Error('Failed to delete document');
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['kb-documents', knowledgeBaseId] });
    },
  });

  // Re-process document
  const reprocessDocument = useMutation({
    mutationFn: async (documentId: string) => {
      const response = await fetch(`${baseUrl}/documents/${documentId}/reprocess`, {
        method: 'POST',
      });
      if (!response.ok) throw new Error('Failed to reprocess document');
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['kb-documents', knowledgeBaseId] });
    },
  });

  // Update document metadata
  const updateDocument = useMutation({
    mutationFn: async ({ 
      documentId, 
      metadata 
    }: { 
      documentId: string; 
      metadata: any 
    }) => {
      const response = await fetch(`${baseUrl}/documents/${documentId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ metadata }),
      });
      if (!response.ok) throw new Error('Failed to update document');
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['kb-documents', knowledgeBaseId] });
    },
  });

  return {
    useDocuments,
    useDocument,
    deleteDocument,
    reprocessDocument,
    updateDocument,
  };
};
```

## Usage Example

```typescript
import { useKnowledgeBase } from './hooks/use-knowledge-base';

const MyComponent = () => {
  const kb = useKnowledgeBase({
    knowledgeBaseId: 'kb-123',
    cortexApiUrl: 'http://localhost:4006',
  });

  // List documents
  const { data: documents, isLoading } = kb.useDocuments({
    status: ['ready'],
    search: 'research',
  });

  // Get document details
  const { data: detail } = kb.useDocument('doc-456');

  // Delete document
  const handleDelete = (id: string) => {
    kb.deleteDocument.mutate(id);
  };

  // Re-process document
  const handleReprocess = (id: string) => {
    kb.reprocessDocument.mutate(id);
  };

  return <div>Document list here</div>;
};
```

## API Integration Points

### Cortex API Endpoints

```
GET /api/cortex/knowledge-bases/:kbId/documents
Query params: status, search, page, limit
Response: { documents: KBDocument[], total: number }

GET /api/cortex/knowledge-bases/:kbId/documents/:docId
Response: { document: KBDocument, chunks: DocumentChunk[] }

DELETE /api/cortex/knowledge-bases/:kbId/documents/:docId
Response: 204 No Content

POST /api/cortex/knowledge-bases/:kbId/documents/:docId/reprocess
Response: { executionId: string }

PATCH /api/cortex/knowledge-bases/:kbId/documents/:docId
Body: { metadata: {...} }
Response: { document: KBDocument }
```

## Next Steps

Proceed to Step 6: Upload Component
