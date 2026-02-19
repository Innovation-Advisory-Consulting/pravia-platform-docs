# Step 1: Knowledge Base Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    UI Package Component                      │
│  KnowledgeBaseView (packages/ui/src/views/cortex/)         │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ├─► QuantumFileUpload (existing)
                   │   └─► Forge API (TUS upload)
                   │
                   ├─► Helix API (n8n workflows)
                   │   └─► n8n Workflow
                   │       ├─► Download file
                   │       ├─► Extract text
                   │       ├─► Chunk document
                   │       ├─► Generate embeddings
                   │       └─► Store in Cortex
                   │
                   └─► Cortex API (knowledge base)
                       ├─► List documents
                       ├─► Get details
                       ├─► Delete documents
                       └─► Search
```

## Data Flow

### Upload Flow
```
1. User selects file
2. QuantumFileUpload → Forge API (TUS upload)
3. Upload complete → Get file URL
4. Trigger n8n workflow via Helix API
5. Pass file URL + metadata to workflow
6. Workflow processes → Cortex KB
7. Poll execution status
8. Update UI when complete
```

### Management Flow
```
1. Load documents from Cortex API
2. Display in DataTable
3. User actions: View/Delete/Re-process
4. Update via Cortex API
5. Refresh list
```

## Component Structure

```
packages/ui/src/views/cortex/knowledge-base/
├── index.tsx                          # Main view
├── knowledge-base-upload.tsx          # Upload section
├── knowledge-base-list.tsx            # Document table
├── knowledge-base-detail.tsx          # Detail view
├── components/
│   ├── document-status-chip.tsx       # Status indicator
│   ├── processing-progress.tsx        # Progress display
│   └── chunk-preview.tsx              # Chunk viewer
├── hooks/
│   ├── use-knowledge-base.ts          # Main KB operations
│   ├── use-document-upload.ts         # Upload + workflow
│   └── use-document-processing.ts     # Status polling
└── types.ts                           # TypeScript types
```

## API Endpoints Required

### Forge API (File Upload)
- `POST /api/upload/tus` - TUS upload
- `GET /api/upload/:id` - Upload details
- `GET /api/upload/:id/file` - Download file

### Helix API (n8n)
- `POST /api/n8n/workflows/:id/execute` - Trigger workflow
- `GET /api/n8n/executions/:id` - Execution status
- `GET /api/n8n/executions/:id/logs` - Execution logs

### Cortex API (Knowledge Base)
- `GET /api/cortex/knowledge-bases/:kbId/documents` - List
- `GET /api/cortex/knowledge-bases/:kbId/documents/:docId` - Get
- `DELETE /api/cortex/knowledge-bases/:kbId/documents/:docId` - Delete
- `POST /api/cortex/knowledge-bases/:kbId/documents/:docId/reprocess` - Re-process
- `GET /api/cortex/knowledge-bases/:kbId/documents/:docId/chunks` - Get chunks
- `POST /api/cortex/knowledge-bases/:kbId/search` - Search

## n8n Workflow Structure

**Workflow Name**: "Document to Knowledge Base"

**Nodes**:
1. Webhook/Trigger - Receive file URL + metadata
2. Download File - Fetch from Forge storage
3. Extract Text - Parse PDF/DOCX/TXT
4. Chunk Document - Split into chunks
5. Generate Embeddings - Call embedding API
6. Store in Cortex - Save document/chunks/vectors
7. Update Status - Mark complete/failed

## Technology Stack

- **UI**: React 19, MUI v7, TypeScript
- **File Upload**: QuantumFileUpload (existing), TUS protocol
- **Workflow**: n8n via Helix API
- **State**: React Query (TanStack Query)
- **Forms**: React Hook Form + Zod
- **Data Display**: DataTable (existing)

## Next Steps

Proceed to Step 2: TypeScript Types & Interfaces
