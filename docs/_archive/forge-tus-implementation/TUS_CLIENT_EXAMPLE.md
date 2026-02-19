# TUS Client Example

## Browser Client (tus-js-client)

### Installation
```bash
npm install tus-js-client
```

### Basic Upload
```typescript
import * as tus from 'tus-js-client';

const file = document.querySelector('input[type=file]').files[0];

const upload = new tus.Upload(file, {
  endpoint: 'http://localhost:4002/api/files',
  retryDelays: [0, 3000, 5000, 10000, 20000],
  metadata: {
    filename: file.name,
    filetype: file.type,
    userId: 'user-123',
    tenantId: 'tenant-456',
  },
  onError: (error) => {
    console.error('Upload failed:', error);
  },
  onProgress: (bytesUploaded, bytesTotal) => {
    const percentage = ((bytesUploaded / bytesTotal) * 100).toFixed(2);
    console.log(`Progress: ${percentage}%`);
  },
  onSuccess: () => {
    console.log('Upload completed!');
    console.log('Upload URL:', upload.url);
  },
});

// Start upload
upload.start();

// Pause
upload.abort();

// Resume
upload.start();
```

### React Hook
```typescript
import { useState, useCallback } from 'react';
import * as tus from 'tus-js-client';

export function useFileUpload() {
  const [progress, setProgress] = useState(0);
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [uploadUrl, setUploadUrl] = useState<string | null>(null);

  const upload = useCallback((file: File, metadata?: Record<string, string>) => {
    setIsUploading(true);
    setError(null);
    setProgress(0);

    const tusUpload = new tus.Upload(file, {
      endpoint: '/api/files',
      metadata: {
        filename: file.name,
        filetype: file.type,
        ...metadata,
      },
      onError: (err) => {
        setError(err.message);
        setIsUploading(false);
      },
      onProgress: (bytesUploaded, bytesTotal) => {
        setProgress((bytesUploaded / bytesTotal) * 100);
      },
      onSuccess: () => {
        setUploadUrl(tusUpload.url);
        setIsUploading(false);
        setProgress(100);
      },
    });

    tusUpload.start();

    return {
      abort: () => tusUpload.abort(),
      resume: () => tusUpload.start(),
    };
  }, []);

  return { upload, progress, isUploading, error, uploadUrl };
}
```

### Usage in Component
```typescript
function UploadComponent() {
  const { upload, progress, isUploading, error } = useFileUpload();

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      upload(file, {
        userId: 'current-user-id',
        tenantId: 'current-tenant-id',
      });
    }
  };

  return (
    <div>
      <input type="file" onChange={handleFileChange} disabled={isUploading} />
      {isUploading && <progress value={progress} max="100" />}
      {error && <div>Error: {error}</div>}
    </div>
  );
}
```

## Node.js Client

```typescript
import * as tus from 'tus-js-client';
import * as fs from 'fs';

const file = fs.createReadStream('./large-file.zip');
const stats = fs.statSync('./large-file.zip');

const upload = new tus.Upload(file, {
  endpoint: 'http://localhost:4002/api/files',
  metadata: {
    filename: 'large-file.zip',
    filetype: 'application/zip',
  },
  uploadSize: stats.size,
  onError: (error) => {
    console.error('Failed:', error);
  },
  onProgress: (bytesUploaded, bytesTotal) => {
    console.log(`${bytesUploaded}/${bytesTotal} bytes uploaded`);
  },
  onSuccess: () => {
    console.log('Upload complete!');
  },
});

upload.start();
```

## cURL Example

```bash
# Create upload
curl -X POST http://localhost:4002/api/files \
  -H "Upload-Length: 1000000" \
  -H "Upload-Metadata: filename dGVzdC5wZGY=,filetype YXBwbGljYXRpb24vcGRm" \
  -H "Tus-Resumable: 1.0.0"

# Upload data (use Location header from previous response)
curl -X PATCH http://localhost:4002/api/files/{upload-id} \
  -H "Upload-Offset: 0" \
  -H "Content-Type: application/offset+octet-stream" \
  -H "Tus-Resumable: 1.0.0" \
  --data-binary @file.pdf
```

## Testing

```bash
# Check TUS server info
curl -I http://localhost:4002/api/files

# Should return:
# Tus-Resumable: 1.0.0
# Tus-Version: 1.0.0
# Tus-Max-Size: 52428800
```
