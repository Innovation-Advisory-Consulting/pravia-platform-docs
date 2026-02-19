# Configuration API - Visual Architecture

## 🗄️ Database Schema: `external`
**Host:** aws-1-us-east-2.pooler.supabase.com  
**Database:** postgres  
**Schema:** external

---

## 📊 Complete Entity & Controller Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CONFIGURATION API ARCHITECTURE                       │
│                         Schema: external (Supabase)                          │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  MODULE 1: CONFIGURATION                                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 ENTITIES (3)                          🎮 CONTROLLERS                     │
│  ├─ Configuration                         ├─ ConfigurationController         │
│  │  └─ external.configuration            │  └─ /api/configurations          │
│  │     • id (uuid, PK)                   │     GET    /                      │
│  │     • name (varchar)                  │     GET    /:id                   │
│  │     • description (text)              │     GET    /:id/metadata          │
│  │     • configuration_template_id (FK)  │     POST   /                      │
│  │     • configuration_group_id (uuid)   │     PATCH  /:id                   │
│  │     • is_enabled (boolean)            │     DELETE /:id                   │
│  │     • created_at, updated_at          │                                   │
│  │     • deleted_at (soft delete)        │                                   │
│  │                                       │                                   │
│  ├─ ConfigurationTemplate                │  ConfigurationTemplateController  │
│  │  └─ external.configuration_template   │  └─ /api/configuration-templates  │
│  │     • id (uuid, PK)                   │     GET    /                      │
│  │     • name (varchar)                  │     GET    /:id                   │
│  │     • description (text)              │     POST   /                      │
│  │     • configuration_type_id (FK)      │     PATCH  /:id                   │
│  │     • created_at, updated_at          │     DELETE /:id                   │
│  │                                       │                                   │
│  └─ ConfigurationType                    │  ConfigurationTypeController      │
│     └─ external.configuration_type       │  └─ /api/configuration-types      │
│        • id (uuid, PK)                   │     GET    /                      │
│        • name (varchar, unique)          │     GET    /:id                   │
│        • description (text)              │     POST   /                      │
│        • created_at, updated_at          │     PATCH  /:id                   │
│                                          │     DELETE /:id                   │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  MODULE 2: ATTRIBUTE                                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 ENTITIES (4)                          🎮 CONTROLLERS                     │
│  ├─ AttribTemplate                        ├─ AttribTemplateController        │
│  │  └─ external.attrib_template          │  └─ /api/attrib-templates        │
│  │     • id (uuid, PK)                   │     GET    /                      │
│  │     • name (varchar)                  │     GET    /:id                   │
│  │     • description (text)              │     POST   /                      │
│  │     • configuration_template_id (FK)  │     PATCH  /:id                   │
│  │     • attrib_val_type_id (FK)         │     DELETE /:id                   │
│  │     • sort_idx (int)                  │                                   │
│  │     • value (text) - default          │                                   │
│  │     • options (text) - JSON           │                                   │
│  │     • can_override (boolean)          │                                   │
│  │     • configuration_media_id (FK)     │                                   │
│  │                                       │                                   │
│  ├─ AttribValType                        │  AttribValTypeController          │
│  │  └─ external.attrib_val_type         │  └─ /api/attrib-val-types         │
│  │     • id (uuid, PK)                   │     GET    /                      │
│  │     • name (varchar, unique)          │     GET    /:id                   │
│  │     • description (text)              │     POST   /                      │
│  │     • created_at, updated_at          │     PATCH  /:id                   │
│  │                                       │     DELETE /:id                   │
│  │                                       │                                   │
│  ├─ ConfigurationAttribVal               │  ConfigurationAttribValController │
│  │  └─ external.configuration_attrib_val│  └─ /api/configuration-attrib-vals│
│  │     • id (uuid, PK)                   │     GET    /                      │
│  │     • configuration_id (FK)           │     GET    /:id                   │
│  │     • attrib_template_id (FK)         │     POST   /                      │
│  │     • value (text)                    │     PATCH  /:id                   │
│  │     • sort_index (int)                │     DELETE /:id                   │
│  │     • options (text) - JSON           │                                   │
│  │                                       │                                   │
│  └─ ConfigurationAttribValOverride       │  AttribValOverrideController      │
│     └─ external.configuration_attrib_val_override                            │
│        • id (uuid, PK)                   │  └─ /api/attrib-val-overrides     │
│        • configuration_attrib_val_id (FK)│     GET    /                      │
│        • attrib_access_priority_id (FK)  │     GET    /:id                   │
│        • value (text)                    │     POST   /                      │
│        • is_enabled (boolean)            │     PATCH  /:id                   │
│        • created_at, updated_at          │     DELETE /:id                   │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  MODULE 3: PRIORITY                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 ENTITIES (3)                          🎮 CONTROLLERS                     │
│  ├─ PriorityRank                          ├─ PriorityRankController          │
│  │  └─ external.priority_rank            │  └─ /api/priority-ranks          │
│  │     • id (uuid, PK)                   │     GET    /                      │
│  │     • name (varchar, unique)          │     GET    /:id                   │
│  │     • code (varchar, unique)          │     POST   /                      │
│  │     • rank (int) - 0=highest          │     PATCH  /:id                   │
│  │     • description (text)              │     DELETE /:id                   │
│  │     • created_at, updated_at          │                                   │
│  │                                       │                                   │
│  ├─ ConfigurationAccessPriority          │  ConfigAccessPriorityController   │
│  │  └─ external.configuration_access_priority                                │
│  │     • id (uuid, PK)                   │  └─ /api/config-access-priorities │
│  │     • configuration_id (FK)           │     GET    /                      │
│  │     • priority_rank_id (FK)           │     GET    /:id                   │
│  │     • code (varchar) - filter key     │     POST   /                      │
│  │     • name (varchar)                  │     PATCH  /:id                   │
│  │     • created_at, updated_at          │     DELETE /:id                   │
│  │                                       │                                   │
│  └─ AttribAccessPriority                 │  AttribAccessPriorityController   │
│     └─ external.attrib_access_priority   │  └─ /api/attrib-access-priorities │
│        • id (uuid, PK)                   │     GET    /                      │
│        • attrib_template_id (FK)         │     GET    /:id                   │
│        • priority_rank_id (FK)           │     POST   /                      │
│        • code (varchar) - filter key     │     PATCH  /:id                   │
│        • name (varchar)                  │     DELETE /:id                   │
│        • created_at, updated_at          │                                   │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  MODULE 4: MEDIA                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 ENTITIES (1)                          🎮 CONTROLLERS                     │
│  └─ ConfigurationMedia                    └─ ConfigurationMediaController    │
│     └─ external.configuration_media          └─ /api/configuration-media     │
│        • id (uuid, PK)                          GET    /                     │
│        • configuration_id (FK)                  GET    /:id                  │
│        • url (text)                             POST   /                     │
│        • media_type (varchar)                   DELETE /:id                  │
│        • created_at, updated_at                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  MODULE 5: CONFIGURATION DATA (Special - Stored Procedure Replacement)       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 VIEW ENTITY (1)                       🎮 CONTROLLERS                     │
│  └─ ConfigurationDataView                 └─ ConfigurationDataController     │
│     └─ external.vw_configuration_data        └─ /api/configuration-data     │
│        • config_id                              GET /configurations          │
│        • config_name                            GET /attributes              │
│        • config_desc                                                         │
│        • config_is_enabled                   Query Params:                   │
│        • attrib_name                         • groupId (required)            │
│        • attrib_value                        • configId (optional)           │
│        • attrib_val_type                     • regionId (optional)           │
│        • attrib_ovr_enabled                  • locationId (optional)         │
│        • config_updated_date                 • userId (optional)             │
│        • ... (20+ computed columns)          • maxRows (optional)            │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  ENTITY RELATIONSHIPS                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ConfigurationType (1) ──────┐                                              │
│                               │                                              │
│                               ▼                                              │
│  ConfigurationTemplate (N) ──┬──────┐                                       │
│                               │      │                                       │
│                               ▼      ▼                                       │
│  Configuration (N)         AttribTemplate (N) ──┐                           │
│       │                         │               │                           │
│       │                         ▼               ▼                           │
│       │              ConfigurationAttribVal  AttribValType                  │
│       │                         │                                           │
│       │                         ▼                                           │
│       │              ConfigurationAttribValOverride                         │
│       │                         │                                           │
│       │                         ▼                                           │
│       │              AttribAccessPriority ──┐                               │
│       │                                     │                               │
│       ▼                                     ▼                               │
│  ConfigurationAccessPriority ──────> PriorityRank                          │
│       │                                                                      │
│       ▼                                                                      │
│  ConfigurationMedia                                                         │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  API ENDPOINT SUMMARY                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Base URL: http://localhost:4003/api                                        │
│                                                                              │
│  📁 Configuration Management                                                 │
│     GET    /configurations                    - List all configurations     │
│     GET    /configurations/:id                - Get one configuration       │
│     GET    /configurations/:id/metadata       - Get with resolved overrides │
│     POST   /configurations                    - Create configuration        │
│     PATCH  /configurations/:id                - Update configuration        │
│     DELETE /configurations/:id                - Soft delete configuration   │
│                                                                              │
│  📁 Template Management                                                      │
│     GET    /configuration-templates           - List all templates          │
│     POST   /configuration-templates           - Create template             │
│     GET    /configuration-types               - List all types              │
│     POST   /configuration-types               - Create type                 │
│                                                                              │
│  📁 Attribute Management                                                     │
│     GET    /attrib-templates                  - List attribute templates    │
│     POST   /attrib-templates                  - Create attribute template   │
│     GET    /attrib-val-types                  - List value types            │
│     GET    /configuration-attrib-vals         - List attribute values       │
│     POST   /configuration-attrib-vals         - Create attribute value      │
│     POST   /attrib-val-overrides              - Create override             │
│                                                                              │
│  📁 Priority Management                                                      │
│     GET    /priority-ranks                    - List priority ranks         │
│     POST   /priority-ranks                    - Create priority rank        │
│     GET    /config-access-priorities          - List config access rules    │
│     POST   /config-access-priorities          - Create access rule          │
│     GET    /attrib-access-priorities          - List attrib access rules    │
│                                                                              │
│  📁 Media Management                                                         │
│     GET    /configuration-media               - List media                  │
│     POST   /configuration-media               - Upload media                │
│     DELETE /configuration-media/:id           - Delete media                │
│                                                                              │
│  📁 Configuration Data (Stored Proc Replacement)                             │
│     GET    /configuration-data/configurations - Get configs with access     │
│     GET    /configuration-data/attributes     - Get attributes with overrides│
│                                                                              │
│  Query Parameters for Data Endpoints:                                       │
│     • groupId      - Configuration group (required)                         │
│     • configId     - Specific config (optional)                             │
│     • regionId     - Region context (optional)                              │
│     • locationId   - Location context (optional)                            │
│     • userId       - User context (optional)                                │
│     • maxRows      - Result limit (optional, default 2000)                  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  TOTAL COUNT                                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 Entities:     11 (+ 1 view entity)                                       │
│  🎮 Controllers:  11                                                         │
│  📍 Endpoints:    ~55 REST endpoints                                         │
│  🗄️  Tables:      11 database tables + 1 view                                │
│  📂 Modules:      5 feature modules                                          │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Quick Reference

### Entity → Table Mapping
```
Configuration                    → external.configuration
ConfigurationTemplate            → external.configuration_template
ConfigurationType                → external.configuration_type
AttribTemplate                   → external.attrib_template
AttribValType                    → external.attrib_val_type
ConfigurationAttribVal           → external.configuration_attrib_val
ConfigurationAttribValOverride   → external.configuration_attrib_val_override
PriorityRank                     → external.priority_rank
ConfigurationAccessPriority      → external.configuration_access_priority
AttribAccessPriority             → external.attrib_access_priority
ConfigurationMedia               → external.configuration_media
ConfigurationDataView            → external.vw_configuration_data (VIEW)
```

### Controller → Route Mapping
```
ConfigurationController              → /api/configurations
ConfigurationTemplateController      → /api/configuration-templates
ConfigurationTypeController          → /api/configuration-types
AttribTemplateController             → /api/attrib-templates
AttribValTypeController              → /api/attrib-val-types
ConfigurationAttribValController     → /api/configuration-attrib-vals
AttribValOverrideController          → /api/attrib-val-overrides
PriorityRankController               → /api/priority-ranks
ConfigAccessPriorityController       → /api/config-access-priorities
AttribAccessPriorityController       → /api/attrib-access-priorities
ConfigurationMediaController         → /api/configuration-media
ConfigurationDataController          → /api/configuration-data
```

---

## 🔗 Key Relationships

1. **ConfigurationType** → **ConfigurationTemplate** (1:N)
2. **ConfigurationTemplate** → **Configuration** (1:N)
3. **ConfigurationTemplate** → **AttribTemplate** (1:N)
4. **AttribTemplate** → **ConfigurationAttribVal** (1:N)
5. **ConfigurationAttribVal** → **ConfigurationAttribValOverride** (1:N)
6. **PriorityRank** → **ConfigurationAccessPriority** (1:N)
7. **PriorityRank** → **AttribAccessPriority** (1:N)
8. **Configuration** → **ConfigurationMedia** (1:N)

---

## 📊 Database Schema: `external`

All tables will be created in the **`external`** schema on Supabase:
- Host: `aws-1-us-east-2.pooler.supabase.com`
- Database: `postgres`
- Schema: `external`
- Port: `5432`

This matches your auth API pattern! ✅
