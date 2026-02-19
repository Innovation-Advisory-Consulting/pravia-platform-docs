# Step 2: TypeScript Types & Interfaces

## File Location
`packages/ui/src/views/cortex/knowledge-base/types.ts`

## Type Definitions

```typescript
// Document Status
export enum DocumentStatus {
  UPLOADING = 'uploading',
  PROCESSING = 'processing',
  READY = 'ready',
  FAILED = 'failed',
}

// Document Type
export enum DocumentType {
  PDF = 'application/pdf',
  DOCX = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  TXT = 'text/plain',
  MD = 'text/markdown',
}

// Knowledge Base Document
export interface KBDocument {
  id: string;
  knowledgeBaseId: string;
  name: string;
  originalFilename: string;
  mimeType: string;
  size: number;
  status: DocumentStatus;
  uploadId: string;
  fileUrl: string;
  chunkCount: number;
  vectorCount: number;
  metadata: DocumentMetadata;
  processingLogs?: ProcessingLog[];
  executionId?: string;
  createdAt: string;
  updatedAt: string;
}

// Document Metadata
export interface DocumentMetadata {
  tags?: string[];
  description?: string;
  category?: string;
  author?: string;
  [key: string]: any;
}

// Document Chunk
export interface DocumentChunk {
  id: string;
  documentId: string;
  content: string;
  position: number;
  startChar: number;
  endChar: number;
  metadata: ChunkMetadata;
  createdAt: string;
}

// Chunk Metadata
export interface ChunkMetadata {
  pageNumber?: number;
  section?: string;
  [key: string]: any;
}

// Processing Log
export interface ProcessingLog {
  timestamp: string;
  level: 'info' | 'warning' | 'error';
  message: string;
  data?: any;
}

// Workflow Execution
export interface WorkflowExecution {
  id: string;
  workflowId: string;
  status: 'running' | 'success' | 'error' | 'waiting';
  startedAt: string;
  finishedAt?: string;
  data?: any;
  error?: string;
}

// Upload Configuration
export interface KBUploadConfig {
  knowledgeBaseId: string;
  workflowId: string;
  maxFileSize?: number;
  allowedTypes?: string[];
  chunkSize?: number;
  chunkOverlap?: number;
}

// API Response Types
export interface ListDocumentsResponse {
  documents: KBDocument[];
  total: number;
  page: number;
  limit: number;
}

export interface DocumentDetailResponse {
  document: KBDocument;
  chunks: DocumentChunk[];
}

export interface UploadResponse {
  uploadId: string;
  fileUrl: string;
}

export interface WorkflowTriggerResponse {
  executionId: string;
  status: string;
}

// Filter & Search Types
export interface DocumentFilters {
  status?: DocumentStatus[];
  type?: string[];
  dateFrom?: string;
  dateTo?: string;
  search?: string;
}

export interface SearchQuery {
  query: string;
  limit?: number;
  threshold?: number;
  filters?: DocumentFilters;
}

export interface SearchResult {
  chunk: DocumentChunk;
  document: KBDocument;
  score: number;
}
```

## Usage Example

```typescript
import { KBDocument, DocumentStatus, KBUploadConfig } from './types';

const config: KBUploadConfig = {
  knowledgeBaseId: 'kb-123',
  workflowId: '5Wba1MKHnLpdc8IB',
  maxFileSize: 10 * 1024 * 1024, // 10MB
  allowedTypes: ['application/pdf', 'text/plain'],
};

const document: KBDocument = {
  id: 'doc-456',
  knowledgeBaseId: 'kb-123',
  name: 'example.pdf',
  originalFilename: 'example.pdf',
  mimeType: 'application/pdf',
  size: 1024000,
  status: DocumentStatus.READY,
  uploadId: 'upload-789',
  fileUrl: 'https://storage.example.com/files/example.pdf',
  chunkCount: 42,
  vectorCount: 42,
  metadata: {
    tags: ['research', 'ai'],
    description: 'Research paper on AI',
  },
  createdAt: '2025-11-28T20:00:00Z',
  updatedAt: '2025-11-28T20:05:00Z',
};
```

## Next Steps

Proceed to Step 3: Upload Hook Implementation
