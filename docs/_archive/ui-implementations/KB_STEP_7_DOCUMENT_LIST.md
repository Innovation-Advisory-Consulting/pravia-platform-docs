# Step 7: Document List Component

## File Location
`packages/ui/src/views/cortex/knowledge-base/knowledge-base-list.tsx`

## Purpose
Display and manage knowledge base documents in a DataTable.

## Implementation

```typescript
import { useState } from 'react';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import MenuItem from '@mui/material/MenuItem';
import { DataTable } from '../../../components/data-display/data-table';
import { Iconify } from '../../../components/data-display/iconify';
import { CustomPopover, usePopover } from '../../../components/utils/custom-popover';
import { DocumentStatusChip } from './components/document-status-chip';
import { useKnowledgeBase } from './hooks/use-knowledge-base';
import { formatNumber } from '../../../utils/format-number';
import type { KBDocument, DocumentFilters } from './types';

interface KnowledgeBaseListProps {
  knowledgeBaseId: string;
  cortexApiUrl: string;
  onViewDocument?: (document: KBDocument) => void;
}

export const KnowledgeBaseList = ({
  knowledgeBaseId,
  cortexApiUrl,
  onViewDocument,
}: KnowledgeBaseListProps) => {
  const [filters, setFilters] = useState<DocumentFilters>({});
  const popover = usePopover();
  const [selectedDoc, setSelectedDoc] = useState<KBDocument | null>(null);

  const kb = useKnowledgeBase({ knowledgeBaseId, cortexApiUrl });
  const { data, isLoading } = kb.useDocuments(filters);

  const handleDelete = (doc: KBDocument) => {
    if (confirm(`Delete "${doc.name}"?`)) {
      kb.deleteDocument.mutate(doc.id);
    }
  };

  const handleReprocess = (doc: KBDocument) => {
    kb.reprocessDocument.mutate(doc.id);
  };

  const columns = [
    {
      field: 'name',
      headerName: 'Name',
      flex: 1,
      renderCell: (params: any) => (
        <Button
          variant="text"
          onClick={() => onViewDocument?.(params.row)}
          sx={{ textAlign: 'left', justifyContent: 'flex-start' }}
        >
          {params.value}
        </Button>
      ),
    },
    {
      field: 'mimeType',
      headerName: 'Type',
      width: 120,
      renderCell: (params: any) => {
        const type = params.value.split('/')[1]?.toUpperCase() || 'FILE';
        return <Box sx={{ fontWeight: 600 }}>{type}</Box>;
      },
    },
    {
      field: 'size',
      headerName: 'Size',
      width: 100,
      renderCell: (params: any) => formatNumber(params.value, { notation: 'compact' }),
    },
    {
      field: 'status',
      headerName: 'Status',
      width: 120,
      renderCell: (params: any) => <DocumentStatusChip status={params.value} />,
    },
    {
      field: 'chunkCount',
      headerName: 'Chunks',
      width: 100,
      align: 'center',
    },
    {
      field: 'createdAt',
      headerName: 'Uploaded',
      width: 150,
      renderCell: (params: any) => new Date(params.value).toLocaleDateString(),
    },
    {
      field: 'actions',
      headerName: '',
      width: 60,
      sortable: false,
      renderCell: (params: any) => (
        <IconButton
          onClick={(e) => {
            setSelectedDoc(params.row);
            popover.onOpen(e);
          }}
        >
          <Iconify icon="eva:more-vertical-fill" />
        </IconButton>
      ),
    },
  ];

  return (
    <Box>
      <DataTable
        rows={data?.documents || []}
        columns={columns}
        loading={isLoading}
        getRowId={(row) => row.id}
      />

      {/* Actions Menu */}
      <CustomPopover open={popover.open} anchorEl={popover.anchorEl} onClose={popover.onClose}>
        <MenuItem
          onClick={() => {
            if (selectedDoc) onViewDocument?.(selectedDoc);
            popover.onClose();
          }}
        >
          <Iconify icon="eva:eye-fill" />
          View Details
        </MenuItem>
        
        <MenuItem
          onClick={() => {
            if (selectedDoc) handleReprocess(selectedDoc);
            popover.onClose();
          }}
        >
          <Iconify icon="eva:refresh-fill" />
          Re-process
        </MenuItem>
        
        <MenuItem
          onClick={() => {
            if (selectedDoc) handleDelete(selectedDoc);
            popover.onClose();
          }}
          sx={{ color: 'error.main' }}
        >
          <Iconify icon="eva:trash-2-fill" />
          Delete
        </MenuItem>
      </CustomPopover>
    </Box>
  );
};
```

## Status Chip Component

**File**: `packages/ui/src/views/cortex/knowledge-base/components/document-status-chip.tsx`

```typescript
import Chip from '@mui/material/Chip';
import { DocumentStatus } from '../types';

interface DocumentStatusChipProps {
  status: DocumentStatus;
}

export const DocumentStatusChip = ({ status }: DocumentStatusChipProps) => {
  const config = {
    [DocumentStatus.UPLOADING]: { label: 'Uploading', color: 'info' as const },
    [DocumentStatus.PROCESSING]: { label: 'Processing', color: 'warning' as const },
    [DocumentStatus.READY]: { label: 'Ready', color: 'success' as const },
    [DocumentStatus.FAILED]: { label: 'Failed', color: 'error' as const },
  };

  const { label, color } = config[status];

  return <Chip label={label} color={color} size="small" />;
};
```

## Usage Example

```typescript
import { KnowledgeBaseList } from './knowledge-base-list';

<KnowledgeBaseList
  knowledgeBaseId="kb-123"
  cortexApiUrl="http://localhost:4006"
  onViewDocument={(doc) => {
    console.log('View document:', doc);
  }}
/>
```

## Features

- DataTable with sortable columns
- Status indicators (chips)
- Actions menu (View, Re-process, Delete)
- File type display
- Size formatting
- Date formatting
- Loading states

## Columns

1. **Name** - Clickable to view details
2. **Type** - File type (PDF, DOCX, TXT, MD)
3. **Size** - Formatted file size
4. **Status** - Color-coded chip
5. **Chunks** - Number of chunks
6. **Uploaded** - Upload date
7. **Actions** - Menu with options

## Next Steps

Proceed to Step 8: Document Detail Component
