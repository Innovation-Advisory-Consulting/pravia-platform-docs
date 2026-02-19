# Job Monitor Implementation Plan

## Overview
Job Monitor provides real-time visibility into workflow execution, allowing users to track job progress, view step-by-step execution logs, monitor costs, and debug failures.

## Architecture Integration

From the Component-Oriented Architecture Diagram:
```
Job Monitor (Frontend) 
  ↓
JobsController (API)
  ↓
Job Service (Core)
  ↓
Job Runtime Storage
  ├── Jobs_Main (Job Table)
  ├── Jobs_Steps (Job Step Logs)
  ├── Jobs_Costs (Cost Tracking)
  └── Jobs_Metrics (Metrics)
```

## API Integration

### Endpoints
```
POST   /api/v1/jobs              - Create and start job
GET    /api/v1/jobs              - List all jobs
GET    /api/v1/jobs/:id          - Get job details
POST   /api/v1/jobs/:id/cancel   - Cancel running job
POST   /api/v1/jobs/:id/resume   - Resume failed job
GET    /api/v1/jobs/:id/steps    - Get job steps
```

### Data Models

**MatrixJob**:
```typescript
{
  id: string                    // UUID
  tenant_id: string             // UUID
  workflow_id: string           // UUID
  status: JobStatus             // 'pending' | 'running' | 'completed' | 'failed' | 'cancelled'
  input_payload: Record<string, any>
  output_payload?: Record<string, any>
  error_message?: string
  started_at?: string           // ISO datetime
  completed_at?: string         // ISO datetime
  created_at: string            // ISO datetime
}
```

**MatrixJobStep**:
```typescript
{
  id: string                    // UUID
  job_id: string                // UUID
  step_id: string               // UUID (workflow step)
  step_index: number
  status: JobStepStatus         // 'pending' | 'running' | 'completed' | 'failed' | 'skipped'
  input_data?: Record<string, any>
  output_data?: Record<string, any>
  error_message?: string
  attempt_number: number
  started_at?: string           // ISO datetime
  completed_at?: string         // ISO datetime
}
```

**Request/Response Types**:
```typescript
interface CreateJobRequest {
  workflow_id: string
  input_payload?: Record<string, any>
}

interface JobListResponse {
  items: MatrixJob[]
  total: number
  skip: number
  limit: number
}

interface JobStepsResponse {
  job_id: string
  steps: MatrixJobStep[]
}
```

## Views to Build

### 1. JobListView
**Purpose**: Browse and manage job executions

**Features**:
- DataTable with pagination
- Filter tabs:
  - All (default)
  - Running (status: 'running')
  - Completed (status: 'completed')
  - Failed (status: 'failed')
  - Cancelled (status: 'cancelled')
- Search: workflow name (requires workflow lookup)
- Columns:
  - Job ID (truncated, copyable)
  - Workflow Name (clickable link to workflow)
  - Status (chip with color coding)
  - Started At (relative time: "2 minutes ago")
  - Duration (calculated: completed_at - started_at)
  - Progress (if running: "Step 3/5")
  - Actions menu (View/Cancel/Resume/Re-run)
- Real-time updates:
  - Auto-refresh every 3 seconds for running jobs
  - Polling indicator
  - Manual refresh button
- Bulk actions:
  - Cancel multiple running jobs
  - Delete completed/failed jobs

**Status Colors**:
- Pending: `default` (gray)
- Running: `info` (blue) with pulse animation
- Completed: `success` (green)
- Failed: `error` (red)
- Cancelled: `warning` (orange)

**CRUD Operations**:
- Create: Start new job (requires workflow selection)
- Read: View job details
- Update: Cancel/Resume job
- Delete: Remove completed/failed jobs

### 2. JobDetailView
**Purpose**: View detailed job execution information

**Layout**: Three-panel layout
1. **Left Panel**: Job Info
2. **Center Panel**: Step Timeline
3. **Right Panel**: Step Details (selected step)

**Job Info Panel** (Left):
- Job ID (copyable)
- Workflow Name (link to workflow)
- Status badge
- Timestamps:
  - Created: `2024-11-24 10:30:00`
  - Started: `2024-11-24 10:30:05`
  - Completed: `2024-11-24 10:32:15`
  - Duration: `2m 10s`
- Input Payload (collapsible JSON viewer)
- Output Payload (collapsible JSON viewer)
- Error Message (if failed, highlighted)
- Actions:
  - Cancel (if running)
  - Resume (if failed)
  - Re-run (create new job with same input)
  - Download Logs (JSON export)

**Step Timeline Panel** (Center):
- Visual timeline of step execution
- Each step shows:
  - Step index and name
  - Status icon and color
  - Duration
  - Agent used (if applicable)
  - Click to view details
- Progress indicator for running jobs
- Expandable error messages

**Step Details Panel** (Right):
- Selected step information:
  - Step name and index
  - Status and attempt number
  - Agent/Tool/Prompt used
  - Timestamps (started, completed, duration)
  - Input data (JSON viewer)
  - Output data (JSON viewer)
  - Error message (if failed)
  - Retry history (if multiple attempts)

**Real-time Updates**:
- Poll every 2 seconds if job is running
- Update step statuses dynamically
- Show live progress
- Auto-scroll to current step

### 3. CreateJobDialog
**Purpose**: Start a new job execution

**Features**:
- Workflow selector (dropdown with search)
- Input payload editor:
  - Dynamic form based on workflow input schema
  - JSON editor fallback
  - Validation
- Start button
- Success notification with link to job details

## Service Layer

### JobService
```typescript
class JobService extends MatrixBaseService {
  // Jobs
  async listJobs(params?: {
    skip?: number
    limit?: number
    status?: JobStatus
  }): Promise<JobListResponse>
  
  async getJob(id: string): Promise<MatrixJob>
  
  async createJob(data: CreateJobRequest): Promise<MatrixJob>
  
  async cancelJob(id: string): Promise<MatrixJob>
  
  async resumeJob(id: string): Promise<MatrixJob>
  
  // Steps
  async getJobSteps(jobId: string): Promise<JobStepsResponse>
}
```

### Endpoints Configuration
```typescript
export const matrixEndpoints = {
  // ... existing endpoints
  jobs: {
    list: '/jobs',
    details: (id: string) => `/jobs/${id}`,
    create: '/jobs',
    cancel: (id: string) => `/jobs/${id}/cancel`,
    resume: (id: string) => `/jobs/${id}/resume`,
    steps: (id: string) => `/jobs/${id}/steps`,
  },
}
```

## Real-time Updates

### Polling Strategy
```typescript
// Use React Query with refetch interval
const { data: jobs } = useQuery({
  queryKey: ['jobs'],
  queryFn: () => jobService.listJobs(),
  refetchInterval: (data) => {
    // Poll every 3 seconds if any jobs are running
    const hasRunningJobs = data?.items.some(j => j.status === 'running')
    return hasRunningJobs ? 3000 : false
  },
})
```

### Alternative: WebSocket (Future Enhancement)
- Real-time job status updates
- Step completion notifications
- Error alerts
- More efficient than polling

## UI Components

### Status Indicators
```typescript
// Status chip with icon and color
<Chip 
  icon={<Iconify icon={getStatusIcon(status)} />}
  label={status}
  color={getStatusColor(status)}
  size="small"
  sx={status === 'running' ? { animation: 'pulse 2s infinite' } : {}}
/>
```

### Duration Display
```typescript
// Format duration nicely
function formatDuration(startedAt: string, completedAt?: string): string {
  const start = new Date(startedAt)
  const end = completedAt ? new Date(completedAt) : new Date()
  const diff = end.getTime() - start.getTime()
  
  const seconds = Math.floor(diff / 1000)
  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  
  if (hours > 0) return `${hours}h ${minutes % 60}m`
  if (minutes > 0) return `${minutes}m ${seconds % 60}s`
  return `${seconds}s`
}
```

### Step Timeline Component
```typescript
// Visual timeline with status indicators
<Timeline>
  {steps.map((step, index) => (
    <TimelineItem key={step.id}>
      <TimelineSeparator>
        <TimelineDot color={getStepColor(step.status)}>
          <Iconify icon={getStepIcon(step.status)} />
        </TimelineDot>
        {index < steps.length - 1 && <TimelineConnector />}
      </TimelineSeparator>
      <TimelineContent>
        <Typography variant="subtitle2">{step.name}</Typography>
        <Typography variant="caption">{formatDuration(step.started_at, step.completed_at)}</Typography>
      </TimelineContent>
    </TimelineItem>
  ))}
</Timeline>
```

## Error Handling

### Error States
- **Job Not Found**: Show 404 message with link back to list
- **Permission Denied**: Show access denied message
- **Network Error**: Show retry button
- **Job Execution Failed**: Highlight error in step timeline

### Error Display
```typescript
// Error message with details
{job.error_message && (
  <Alert severity="error" sx={{ mb: 2 }}>
    <AlertTitle>Job Failed</AlertTitle>
    {job.error_message}
  </Alert>
)}
```

## Testing Strategy

### Unit Tests
- JobService methods
- Duration formatting
- Status color mapping
- Filter logic

### Integration Tests
- Job list loading
- Job detail loading
- Real-time updates
- Cancel/Resume actions

### E2E Tests
- Create and monitor job
- View job details
- Cancel running job
- Resume failed job

## Storybook Stories

Following CRUD_PATTERNS.md structure:

```
Views/Matrix/Jobs/
  ├── List View
  ├── Detail View
  ├── Create Dialog
  └── Loading State
```

### Mock Data
```typescript
const mockJobs: MatrixJob[] = [
  {
    id: '123e4567-e89b-12d3-a456-426614174000',
    tenant_id: 'tenant-1',
    workflow_id: 'workflow-1',
    status: 'running',
    input_payload: { query: 'test' },
    started_at: new Date(Date.now() - 60000).toISOString(),
    created_at: new Date(Date.now() - 65000).toISOString(),
  },
  // ... more mock jobs
]
```

## Performance Considerations

### Optimization
- Virtualized list for large job lists
- Lazy loading of step details
- Debounced search
- Cached workflow names
- Pagination for steps (if > 50 steps)

### Memory Management
- Stop polling when component unmounts
- Clear intervals on cleanup
- Limit stored job history

## Estimated Timeline

| Component | Estimated Time |
|-----------|----------------|
| Types & Service | 1 hour |
| JobListView | 2-3 hours |
| JobDetailView | 3-4 hours |
| CreateJobDialog | 1 hour |
| Real-time Updates | 1 hour |
| Storybook Stories | 1 hour |
| Testing & Polish | 1-2 hours |
| **Total** | **10-13 hours** |

## Dependencies

- ✅ WorkflowService (for workflow names)
- ✅ DataTable component
- ✅ React Query (for polling)
- ❌ JobService (to be created)
- ❌ Job types (to be added to matrix.ts)

## Future Enhancements

1. **WebSocket Integration**: Real-time updates without polling
2. **Cost Tracking**: Display job execution costs
3. **Metrics Dashboard**: Aggregate job statistics
4. **Job Comparison**: Compare multiple job executions
5. **Export Logs**: Download job logs in various formats
6. **Job Templates**: Save input payloads as templates
7. **Scheduled Jobs**: Cron-like job scheduling
8. **Job Chains**: Trigger jobs based on completion

## Next Steps

1. Add Job types to `src/types/matrix.ts`
2. Create `JobService` in `src/services/job.service.ts`
3. Add job endpoints to `src/lib/matrix-endpoints.ts`
4. Build `JobListView` following CRUD patterns
5. Build `JobDetailView` with timeline
6. Add Storybook stories
7. Integration testing
