# Step 8: Document Detail Component

## File Location
`packages/ui/src/views/cortex/knowledge-base/knowledge-base-detail.tsx`

## Purpose
Display detailed information about a document including chunks and metadata.

## Implementation

```typescript
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import { DocumentStatusChip } from './components/document-status-chip';
import { ChunkPreview } from './components/chunk-preview';
import { useKnowledgeBase } from './hooks/use-knowledge-base';
import { formatNumber } from '../../../utils/format-number';
import type { KBDocument } from './types';

interface KnowledgeBaseDetailProps {
  documentId: string;
  knowledgeBaseId: string;
  cortexApiUrl: string;
  onClose?: () => void;
}

export const KnowledgeBaseDetail = ({
  documentId,
  knowledgeBaseId,
  cortexApiUrl,
  onClose,
}: KnowledgeBaseDetailProps) => {
  const kb = useKnowledgeBase({ knowledgeBaseId, cortexApiUrl });
  const { data, isLoading } = kb.useDocument(documentId);

  if (isLoading) return <Typography>Loading...</Typography>;
  if (!data) return <Typography>Document not found</Typography>;

  const { document, chunks } = data;

  const handleReprocess = () => {
    kb.reprocessDocument.mutate(documentId);
  };

  const handleDelete = () => {
    if (confirm(`Delete "${document.name}"?`)) {
      kb.deleteDocument.mutate(documentId, {
        onSuccess: () => onClose?.(),
      });
    }
  };

  return (
    <Stack spacing={3}>
      {/* Header */}
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <Typography variant="h4">{document.name}</Typography>
        <Stack direction="row" spacing={1}>
          <Button variant="outlined" onClick={handleReprocess}>
            Re-process
          </Button>
          <Button variant="outlined" color="error" onClick={handleDelete}>
            Delete
          </Button>
          {onClose && (
            <Button variant="text" onClick={onClose}>
              Close
            </Button>
          )}
        </Stack>
      </Stack>

      {/* Document Info Card */}
      <Card>
        <CardContent>
          <Stack spacing={2}>
            <Typography variant="h6">Document Information</Typography>
            <Divider />
            
            <Stack direction="row" spacing={2}>
              <Box sx={{ flex: 1 }}>
                <Typography variant="caption" color="text.secondary">
                  Status
                </Typography>
                <Box sx={{ mt: 0.5 }}>
                  <DocumentStatusChip status={document.status} />
                </Box>
              </Box>
              
              <Box sx={{ flex: 1 }}>
                <Typography variant="caption" color="text.secondary">
                  Type
                </Typography>
                <Typography variant="body2">
                  {document.mimeType.split('/')[1]?.toUpperCase()}
                </Typography>
              </Box>
              
              <Box sx={{ flex: 1 }}>
                <Typography variant="caption" color="text.secondary">
                  Size
                </Typography>
                <Typography variant="body2">
                  {formatNumber(document.size, { notation: 'compact' })}B
                </Typography>
              </Box>
            </Stack>

            <Stack direction="row" spacing={2}>
              <Box sx={{ flex: 1 }}>
                <Typography variant="caption" color="text.secondary">
                  Chunks
                </Typography>
                <Typography variant="body2">{document.chunkCount}</Typography>
              </Box>
              
              <Box sx={{ flex: 1 }}>
                <Typography variant="caption" color="text.secondary">
                  Vectors
                </Typography>
                <Typography variant="body2">{document.vectorCount}</Typography>
              </Box>
              
              <Box sx={{ flex: 1 }}>
                <Typography variant="caption" color="text.secondary">
                  Uploaded
                </Typography>
                <Typography variant="body2">
                  {new Date(document.createdAt).toLocaleString()}
                </Typography>
              </Box>
            </Stack>

            {document.metadata.description && (
              <>
                <Divider />
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    Description
                  </Typography>
                  <Typography variant="body2">
                    {document.metadata.description}
                  </Typography>
                </Box>
              </>
            )}

            {document.metadata.tags && document.metadata.tags.length > 0 && (
              <>
                <Divider />
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    Tags
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 1, mt: 1, flexWrap: 'wrap' }}>
                    {document.metadata.tags.map((tag: string) => (
                      <Chip key={tag} label={tag} size="small" />
                    ))}
                  </Box>
                </Box>
              </>
            )}
          </Stack>
        </CardContent>
      </Card>

      {/* Chunks Card */}
      <Card>
        <CardContent>
          <Stack spacing={2}>
            <Typography variant="h6">
              Document Chunks ({chunks.length})
            </Typography>
            <Divider />
            
            <Stack spacing={2}>
              {chunks.map((chunk) => (
                <ChunkPreview key={chunk.id} chunk={chunk} />
              ))}
            </Stack>
          </Stack>
        </CardContent>
      </Card>
    </Stack>
  );
};
```

## Chunk Preview Component

**File**: `packages/ui/src/views/cortex/knowledge-base/components/chunk-preview.tsx`

```typescript
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Paper from '@mui/material/Paper';
import type { DocumentChunk } from '../types';

interface ChunkPreviewProps {
  chunk: DocumentChunk;
}

export const ChunkPreview = ({ chunk }: ChunkPreviewProps) => {
  return (
    <Paper variant="outlined" sx={{ p: 2 }}>
      <Box sx={{ mb: 1 }}>
        <Typography variant="caption" color="text.secondary">
          Chunk {chunk.position + 1} • Characters {chunk.startChar}-{chunk.endChar}
        </Typography>
      </Box>
      <Typography variant="body2" sx={{ whiteSpace: 'pre-wrap' }}>
        {chunk.content.length > 500
          ? `${chunk.content.substring(0, 500)}...`
          : chunk.content}
      </Typography>
    </Paper>
  );
};
```

## Usage Example

```typescript
import { KnowledgeBaseDetail } from './knowledge-base-detail';

<KnowledgeBaseDetail
  documentId="doc-456"
  knowledgeBaseId="kb-123"
  cortexApiUrl="http://localhost:4006"
  onClose={() => console.log('Close detail view')}
/>
```

## Features

- Document metadata display
- Status, type, size information
- Chunk count and vector count
- Tags and description
- Chunk list with preview
- Re-process button
- Delete button
- Close button

## Information Displayed

### Document Info
- Status (chip)
- File type
- File size
- Chunk count
- Vector count
- Upload date
- Description
- Tags

### Chunks
- Chunk position
- Character range
- Content preview (truncated at 500 chars)

## Next Steps

Proceed to Step 9: Main View Integration
