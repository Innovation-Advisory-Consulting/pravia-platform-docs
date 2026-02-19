# Configuration API - Clean Architecture (No Prefix)

## 🗄️ Database: `external` schema on Supabase

---

## 📊 Complete Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CONFIGURATION API ARCHITECTURE                       │
│                         Schema: external (Supabase)                          │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  MODULE 1: CONFIGURATION                                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 ENTITIES                              🎮 CONTROLLERS                     │
│  ├─ Configuration                         ├─ ConfigurationController         │
│  │  └─ external.configuration            │  └─ /api/configurations          │
│  │                                       │     GET    /                      │
│  ├─ ConfigurationTemplate                │     GET    /:id                   │
│  │  └─ external.configuration_template   │     GET    /:id/metadata          │
│  │                                       │     POST   /                      │
│  └─ ConfigurationType                    │     PATCH  /:id                   │
│     └─ external.configuration_type       │     DELETE /:id                   │
│                                          │                                   │
│                                          │  ConfigurationTemplateController  │
│                                          │  └─ /api/configuration-templates  │
│                                          │     GET    /                      │
│                                          │     POST   /                      │
│                                          │     PATCH  /:id                   │
│                                          │     DELETE /:id                   │
│                                          │                                   │
│                                          │  ConfigurationTypeController      │
│                                          │  └─ /api/configuration-types      │
│                                          │     GET    /                      │
│                                          │     POST   /                      │
│                                          │     PATCH  /:id                   │
│                                          │     DELETE /:id                   │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  MODULE 2: ATTRIBUTE                                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 ENTITIES                              🎮 CONTROLLERS                     │
│  ├─ AttribTemplate                        ├─ AttribTemplateController        │
│  │  └─ external.attrib_template          │  └─ /api/attrib-templates        │
│  │                                       │     GET    /                      │
│  ├─ AttribValType                        │     POST   /                      │
│  │  └─ external.attrib_val_type         │     PATCH  /:id                   │
│  │                                       │     DELETE /:id                   │
│  ├─ ConfigurationAttribVal               │                                   │
│  │  └─ external.configuration_attrib_val│  AttribValTypeController          │
│  │                                       │  └─ /api/attrib-val-types         │
│  └─ ConfigurationAttribValOverride       │     GET    /                      │
│     └─ external.configuration_attrib_val_override                            │
│                                          │     POST   /                      │
│                                          │     PATCH  /:id                   │
│                                          │     DELETE /:id                   │
│                                          │                                   │
│                                          │  ConfigurationAttribValController │
│                                          │  └─ /api/configuration-attrib-vals│
│                                          │     GET    /                      │
│                                          │     POST   /                      │
│                                          │     PATCH  /:id                   │
│                                          │     DELETE /:id                   │
│                                          │                                   │
│                                          │  AttribValOverrideController      │
│                                          │  └─ /api/attrib-val-overrides     │
│                                          │     GET    /                      │
│                                          │     POST   /                      │
│                                          │     PATCH  /:id                   │
│                                          │     DELETE /:id                   │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  MODULE 3: PRIORITY                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 ENTITIES                              🎮 CONTROLLERS                     │
│  ├─ PriorityRank                          ├─ PriorityRankController          │
│  │  └─ external.priority_rank            │  └─ /api/priority-ranks          │
│  │                                       │     GET    /                      │
│  ├─ ConfigurationAccessPriority          │     POST   /                      │
│  │  └─ external.configuration_access_priority                                │
│  │                                       │     PATCH  /:id                   │
│  └─ AttribAccessPriority                 │     DELETE /:id                   │
│     └─ external.attrib_access_priority   │                                   │
│                                          │  ConfigAccessPriorityController   │
│                                          │  └─ /api/config-access-priorities │
│                                          │     GET    /                      │
│                                          │     POST   /                      │
│                                          │     PATCH  /:id                   │
│                                          │     DELETE /:id                   │
│                                          │                                   │
│                                          │  AttribAccessPriorityController   │
│                                          │  └─ /api/attrib-access-priorities │
│                                          │     GET    /                      │
│                                          │     POST   /                      │
│                                          │     PATCH  /:id                   │
│                                          │     DELETE /:id                   │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  MODULE 4: MEDIA                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 ENTITIES                              🎮 CONTROLLERS                     │
│  └─ ConfigurationMedia                    └─ ConfigurationMediaController    │
│     └─ external.configuration_media          └─ /api/configuration-media     │
│                                                 GET    /                     │
│                                                 POST   /                     │
│                                                 DELETE /:id                  │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  MODULE 5: CONFIGURATION DATA (Stored Procedure Replacement)                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 VIEW ENTITY                           🎮 CONTROLLERS                     │
│  └─ ConfigurationDataView                 └─ ConfigurationDataController     │
│     └─ external.vw_configuration_data        └─ /api/configuration-data     │
│                                                 GET /configurations          │
│                                                 GET /attributes              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  DATABASE TABLES (11 + 1 VIEW)                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  external.configuration                                                      │
│  external.configuration_template                                             │
│  external.configuration_type                                                 │
│  external.attrib_template                                                    │
│  external.attrib_val_type                                                    │
│  external.configuration_attrib_val                                           │
│  external.configuration_attrib_val_override                                  │
│  external.priority_rank                                                      │
│  external.configuration_access_priority                                      │
│  external.attrib_access_priority                                             │
│  external.configuration_media                                                │
│  external.vw_configuration_data (VIEW)                                       │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  API ENDPOINTS (~55 total)                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Base: http://localhost:4003/api                                            │
│                                                                              │
│  /configurations                          - Configuration CRUD               │
│  /configuration-templates                 - Template CRUD                    │
│  /configuration-types                     - Type CRUD                        │
│  /attrib-templates                        - Attribute template CRUD          │
│  /attrib-val-types                        - Value type CRUD                  │
│  /configuration-attrib-vals               - Attribute value CRUD             │
│  /attrib-val-overrides                    - Override CRUD                    │
│  /priority-ranks                          - Priority rank CRUD               │
│  /config-access-priorities                - Config access CRUD               │
│  /attrib-access-priorities                - Attrib access CRUD               │
│  /configuration-media                     - Media CRUD                       │
│  /configuration-data/configurations       - Get configs with context         │
│  /configuration-data/attributes           - Get attributes with overrides    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  ENTITY RELATIONSHIPS                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  configuration_type (1)                                                      │
│         ↓                                                                    │
│  configuration_template (N)                                                  │
│         ↓                           ↓                                        │
│  configuration (N)          attrib_template (N)                              │
│         ↓                           ↓                                        │
│  configuration_media        configuration_attrib_val (N)                     │
│  configuration_access_priority      ↓                                        │
│                             configuration_attrib_val_override (N)            │
│                                     ↓                                        │
│                             attrib_access_priority                           │
│                                     ↓                                        │
│                             priority_rank                                    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  SUMMARY                                                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📦 Entities:      11 + 1 view                                               │
│  🎮 Controllers:   11                                                        │
│  📍 Endpoints:     ~55                                                       │
│  🗄️  Tables:       11 + 1 view                                               │
│  📂 Modules:       5                                                         │
│  🔗 Schema:        external                                                  │
│  🏷️  Prefix:       none (clean names)                                        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## 🎯 Clean Table Names

```sql
-- Core Configuration
external.configuration
external.configuration_template
external.configuration_type

-- Attributes
external.attrib_template
external.attrib_val_type
external.configuration_attrib_val
external.configuration_attrib_val_override

-- Priority System
external.priority_rank
external.configuration_access_priority
external.attrib_access_priority

-- Media
external.configuration_media

-- View
external.vw_configuration_data
```

## 🚀 Example Queries

```sql
-- Get all configurations
SELECT * FROM external.configuration;

-- Get configuration with template
SELECT c.*, ct.name as template_name
FROM external.configuration c
JOIN external.configuration_template ct ON c.configuration_template_id = ct.id;

-- Get attributes for a configuration
SELECT * FROM external.configuration_attrib_val
WHERE configuration_id = 'some-uuid';
```

Clean, simple, professional! ✨
