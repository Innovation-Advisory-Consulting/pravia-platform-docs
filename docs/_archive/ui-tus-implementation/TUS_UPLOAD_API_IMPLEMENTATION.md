# TUS Upload API - Implementation Guide (Part 2)

## Entity Layer

### Upload Entity

**src/modules/upload/entity/upload.entity.ts**

```typescript
import { Entity, Column, Index } from 'typeorm';
import { BaseEntity } from '@asyml8/api-core';

export enum UploadStatus {
  PENDING = 'pending',
  UPLOADING = 'uploading',
  COMPLETED = 'completed',
  FAILED = 'failed',
  EXPIRED = 'expired',
}

export enum StorageBackend {
  S3 = 's3',
  LOCAL = 'local',
}

@Entity('upload', { schema: 'uploads' })
@Index(['userId', 'status'])
@Index(['tenantId', 'status'])
export class Upload extends BaseEntity {
  @Column({ type: 'varchar', length: 500 })
  filename: string;

  @Column({ name: 'original_filename', type: 'varchar', length: 500 })
  originalFilename: string;

  @Column({ name: 'mime_type', type: 'varchar', length: 100, nullable: true })
  mimeType: string;

  @Column({ type: 'bigint' })
  size: number;

  @Column({
    type: 'enum',
    enum: UploadStatus,
    default: UploadStatus.PENDING,
  })
  @Index()
  status: UploadStatus;

  @Column({ name: 'upload_offset', type: 'bigint', default: 0 })
  uploadOffset: number;

  @Column({ name: 'upload_length', type: 'bigint', nullable: true })
  uploadLength: number;

  @Column({
    name: 'storage_backend',
    type: 'enum',
    enum: StorageBackend,
  })
  storageBackend: StorageBackend;

  @Column({ name: 'storage_path', type: 'text' })
  storagePath: string;

  @Column({ name: 'storage_url', type: 'text', nullable: true })
  storageUrl: string;

  @Column({ name: 'user_id', type: 'uuid', nullable: true })
  @Index()
  userId: string;

  @Column({ name: 'tenant_id', type: 'uuid', nullable: true })
  @Index()
  tenantId: string;

  @Column({ name: 'tus_id', type: 'varchar', length: 255, unique: true })
  @Index()
  tusId: string;

  @Column({ name: 'upload_metadata', type: 'jsonb', nullable: true })
  uploadMetadata: Record<string, any>;

  @Column({ name: 'expires_at', type: 'timestamp', nullable: true })
  @Index()
  expiresAt: Date;
}
```

---

## DTO Layer

### Create Upload DTO

**src/modules/upload/dto/create-upload.dto.ts**

```typescript
import { IsString, IsOptional, IsUUID, IsEnum, IsNumber, IsObject } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { StorageBackend } from '../entity/upload.entity';

export class CreateUploadDto {
  @ApiProperty({ description: 'Original filename' })
  @IsString()
  filename: string;

  @ApiProperty({ description: 'File size in bytes' })
  @IsNumber()
  size: number;

  @ApiProperty({ description: 'MIME type', required: false })
  @IsString()
  @IsOptional()
  mimeType?: string;

  @ApiProperty({ description: 'Storage backend', enum: StorageBackend })
  @IsEnum(StorageBackend)
  storageBackend: StorageBackend;

  @ApiProperty({ description: 'User ID', required: false })
  @IsUUID()
  @IsOptional()
  userId?: string;

  @ApiProperty({ description: 'Tenant ID', required: false })
  @IsUUID()
  @IsOptional()
  tenantId?: string;

  @ApiProperty({ description: 'Additional metadata', required: false })
  @IsObject()
  @IsOptional()
  metadata?: Record<string, any>;
}
```

### Update Upload DTO

**src/modules/upload/dto/update-upload.dto.ts**

```typescript
import { PartialType } from '@nestjs/swagger';
import { CreateUploadDto } from './create-upload.dto';
import { IsEnum, IsOptional } from 'class-validator';
import { UploadStatus } from '../entity/upload.entity';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateUploadDto extends PartialType(CreateUploadDto) {
  @ApiProperty({ enum: UploadStatus, required: false })
  @IsEnum(UploadStatus)
  @IsOptional()
  status?: UploadStatus;
}
```

### Query DTO

**src/modules/upload/dto/upload-query.dto.ts**

```typescript
import { IsOptional, IsUUID, IsEnum, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { UploadStatus } from '../entity/upload.entity';

export class UploadQueryDto {
  @ApiProperty({ required: false })
  @IsUUID()
  @IsOptional()
  userId?: string;

  @ApiProperty({ required: false })
  @IsUUID()
  @IsOptional()
  tenantId?: string;

  @ApiProperty({ enum: UploadStatus, required: false })
  @IsEnum(UploadStatus)
  @IsOptional()
  status?: UploadStatus;

  @ApiProperty({ required: false })
  @IsDateString()
  @IsOptional()
  fromDate?: string;

  @ApiProperty({ required: false })
  @IsDateString()
  @IsOptional()
  toDate?: string;
}
```

---

## Repository Layer

**src/modules/upload/upload.repository.ts**

```typescript
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { Upload, UploadStatus } from './entity/upload.entity';
import { UploadQueryDto } from './dto/upload-query.dto';

@Injectable()
export class UploadRepository {
  constructor(
    @InjectRepository(Upload)
    private readonly repo: Repository<Upload>,
  ) {}

  async findAll(query: UploadQueryDto): Promise<Upload[]> {
    const where: any = {};

    if (query.userId) where.userId = query.userId;
    if (query.tenantId) where.tenantId = query.tenantId;
    if (query.status) where.status = query.status;

    return this.repo.find({ where });
  }

  async findById(id: string): Promise<Upload> {
    return this.repo.findOne({ where: { id } });
  }

  async findByTusId(tusId: string): Promise<Upload> {
    return this.repo.findOne({ where: { tusId } });
  }

  async create(data: Partial<Upload>): Promise<Upload> {
    const entity = this.repo.create(data);
    return this.repo.save(entity);
  }

  async update(id: string, data: Partial<Upload>): Promise<Upload> {
    await this.repo.update(id, data);
    return this.findById(id);
  }

  async updateByTusId(tusId: string, data: Partial<Upload>): Promise<Upload> {
    await this.repo.update({ tusId }, data);
    return this.findByTusId(tusId);
  }

  async remove(id: string): Promise<void> {
    await this.repo.softDelete(id);
  }

  async findExpired(): Promise<Upload[]> {
    return this.repo.find({
      where: {
        expiresAt: LessThan(new Date()),
        status: UploadStatus.UPLOADING,
      },
    });
  }

  async markAsExpired(ids: string[]): Promise<void> {
    await this.repo.update(ids, { status: UploadStatus.EXPIRED });
  }
}
```

---

## Service Layer

### Upload Service

**src/modules/upload/upload.service.ts**

```typescript
import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { UploadRepository } from './upload.repository';
import { CreateUploadDto } from './dto/create-upload.dto';
import { UpdateUploadDto } from './dto/update-upload.dto';
import { UploadQueryDto } from './dto/upload-query.dto';
import { Upload, UploadStatus } from './entity/upload.entity';
import { randomUUID } from 'crypto';

@Injectable()
export class UploadService {
  constructor(private readonly repository: UploadRepository) {}

  async findAll(query: UploadQueryDto): Promise<Upload[]> {
    return this.repository.findAll(query);
  }

  async findOne(id: string): Promise<Upload> {
    const upload = await this.repository.findById(id);
    if (!upload) {
      throw new NotFoundException(`Upload with ID ${id} not found`);
    }
    return upload;
  }

  async findByTusId(tusId: string): Promise<Upload> {
    const upload = await this.repository.findByTusId(tusId);
    if (!upload) {
      throw new NotFoundException(`Upload with TUS ID ${tusId} not found`);
    }
    return upload;
  }

  async create(dto: CreateUploadDto): Promise<Upload> {
    const tusId = randomUUID();
    const storagePath = this.generateStoragePath(dto.filename, tusId);
    
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24); // 24 hour expiry

    return this.repository.create({
      ...dto,
      originalFilename: dto.filename,
      tusId,
      storagePath,
      uploadOffset: 0,
      uploadLength: dto.size,
      status: UploadStatus.PENDING,
      expiresAt,
      uploadMetadata: dto.metadata,
    });
  }

  async update(id: string, dto: UpdateUploadDto): Promise<Upload> {
    await this.findOne(id); // Check exists
    return this.repository.update(id, dto);
  }

  async updateProgress(
    tusId: string,
    offset: number,
    status?: UploadStatus,
  ): Promise<Upload> {
    const upload = await this.findByTusId(tusId);
    
    const updateData: Partial<Upload> = {
      uploadOffset: offset,
    };

    if (status) {
      updateData.status = status;
    }

    // If upload is complete
    if (upload.uploadLength && offset >= upload.uploadLength) {
      updateData.status = UploadStatus.COMPLETED;
    }

    return this.repository.updateByTusId(tusId, updateData);
  }

  async remove(id: string): Promise<void> {
    await this.findOne(id); // Check exists
    await this.repository.remove(id);
  }

  async cleanupExpired(): Promise<number> {
    const expired = await this.repository.findExpired();
    if (expired.length > 0) {
      await this.repository.markAsExpired(expired.map(u => u.id));
    }
    return expired.length;
  }

  private generateStoragePath(filename: string, tusId: string): string {
    const ext = filename.split('.').pop();
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    
    return `uploads/${year}/${month}/${tusId}.${ext}`;
  }
}
```

---

## Controller Layer

**src/modules/upload/upload.controller.ts**

```typescript
import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { UploadService } from './upload.service';
import { CreateUploadDto } from './dto/create-upload.dto';
import { UpdateUploadDto } from './dto/update-upload.dto';
import { UploadQueryDto } from './dto/upload-query.dto';

@Controller('uploads')
@ApiTags('Uploads')
export class UploadController {
  constructor(private readonly service: UploadService) {}

  @Get()
  @ApiOperation({ summary: 'Get all uploads' })
  @ApiResponse({ status: 200, description: 'Returns all uploads' })
  async findAll(@Query() query: UploadQueryDto) {
    return this.service.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get upload by ID' })
  @ApiResponse({ status: 200, description: 'Returns upload' })
  @ApiResponse({ status: 404, description: 'Upload not found' })
  async findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create upload' })
  @ApiResponse({ status: 201, description: 'Upload created' })
  async create(@Body() dto: CreateUploadDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update upload' })
  @ApiResponse({ status: 200, description: 'Upload updated' })
  @ApiResponse({ status: 404, description: 'Upload not found' })
  async update(@Param('id') id: string, @Body() dto: UpdateUploadDto) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete upload' })
  @ApiResponse({ status: 204, description: 'Upload deleted' })
  @ApiResponse({ status: 404, description: 'Upload not found' })
  async remove(@Param('id') id: string) {
    await this.service.remove(id);
  }

  @Post('cleanup')
  @ApiOperation({ summary: 'Cleanup expired uploads' })
  @ApiResponse({ status: 200, description: 'Returns count of cleaned uploads' })
  async cleanup() {
    const count = await this.service.cleanupExpired();
    return { cleaned: count };
  }
}
```

---

## Module Configuration

**src/modules/upload/upload.module.ts**

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Upload } from './entity/upload.entity';
import { UploadController } from './upload.controller';
import { UploadService } from './upload.service';
import { UploadRepository } from './upload.repository';

@Module({
  imports: [TypeOrmModule.forFeature([Upload])],
  controllers: [UploadController],
  providers: [UploadService, UploadRepository],
  exports: [UploadService, TypeOrmModule],
})
export class UploadModule {}
```

---

*Continue to Part 3 for TUS Integration...*
