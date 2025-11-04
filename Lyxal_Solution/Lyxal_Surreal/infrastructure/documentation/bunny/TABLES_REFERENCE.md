# 📊 Référence Complète des Tables - Infrastructure Bunny

**Module** : `infrastructure`  
**Date** : 2025-01-27

---

## 📋 Vue d'Ensemble

Ce document liste toutes les tables du module Infrastructure Bunny avec leur structure, leurs relations et leurs usages.

---

## 🗂️ Organisation par Domaine

### 1. CDN (`database/cdn/`)

#### `bunny_cdn_zone`

**Description** : Configuration Pull Zones CDN (structure Lyxal standardisée)

**Structure** :
```sql
bunny_cdn_zone {
    identity: {
        code: "UPPER_SNAKE_CASE",
        slug: "lowercase-kebab-case",
        label_key: i18n_key:...,
        description_key: i18n_key:...
    },
    sync: {
        bunny_id: int,
        last_sync_at: datetime,
        sync_status: "synced" | "pending" | "error" | "never"
    },
    metadata: {
        version_label: "1.0.0",
        is_active: true,
        display_order: 0,
        created_at: datetime,
        updated_at: datetime,
        synced_at: datetime
    },
    origin: {
        url: string,
        type: "storage" | "url" | "volume",
        shield: bool,
        shield_region: string
    },
    cache: {
        ttl_default: int,
        browser_cache: int,
        query_string_caching: bool,
        ignore_query_strings: array<string>,
        vary: array<string>
    },
    security: {
        waf_enabled: bool,
        ddos_protection: bool,
        geo_blocking: {...},
        token_auth: bool,
        ip_whitelist: array<string>
    },
    performance: {
        compression: bool,
        minify_css: bool,
        minify_js: bool,
        image_optimization: bool
    },
    ssl: {
        enabled: bool,
        type: "letsencrypt" | "custom" | "none",
        force_https: bool
    },
    usage: {
        bandwidth_gb_month: float,
        requests_month: int,
        cache_hit_rate: float,
        last_sync: datetime
    },
    cost_estimate: {
        bandwidth_cost: float,
        requests_cost: float,
        total_month: float
    },
    storage_zone: record<bunny_storage_zone_model>,
    tenant: record<tenant>
}
```

**Relations** :
- `storage_zone` → `bunny_storage_zone_model`
- `tenant` → `tenant`

**Usage** : Table principale pour gestion Pull Zones CDN avec structure Lyxal standardisée.

---

#### `bunny_pull_zone_model`

**Description** : Modèle complet Pull Zone (mapping direct API Bunny)

**Structure** : Structure complète de l'API Bunny (voir fichier source)

**Relations** :
- Via `sync.bunny_id` → `bunny_cdn_zone`

**Usage** : Mapping direct de l'API Bunny pour compatibilité. Table technique.

---

#### `bunny_edge_rule_v2_model`

**Description** : Edge Rules v2 pour Pull Zones

**Structure** :
```sql
bunny_edge_rule_v2_model {
    id: int,
    enabled: bool,
    description: string,
    condition: {
        type: "url_match" | "header_match" | ...,
        pattern: string
    },
    actions: array<{
        type: "redirect" | "rewrite" | "set_header" | ...,
        target: string,
        status: int
    }>
}
```

**Relations** :
- Via `bunny_cdn_zone.edge_rules` → `bunny_cdn_zone`

**Usage** : Configuration Edge Rules pour routing, redirects, headers, etc.

---

#### `bunny_cdn_purge`

**Description** : Historique des purges de cache CDN

**Structure** :
```sql
bunny_cdn_purge {
    zone: record<bunny_cdn_zone>,
    purge_type: "full" | "url" | "pattern",
    urls: array<string>,
    pattern: string,
    status: "pending" | "success" | "failed",
    bunny_purge_id: string,
    error_message: string,
    metadata: {
        requested_at: datetime,
        requested_by: record<identity>,
        completed_at: datetime
    }
}
```

**Relations** :
- `zone` → `bunny_cdn_zone`

**Usage** : Traçabilité des purges de cache CDN.

---

#### `bunny_hostname_model`

**Description** : Hostnames associés aux Pull Zones

**Structure** :
```sql
bunny_hostname_model {
    id: int,
    value: string,
    force_ssl: bool,
    certificate_id: int,
    certificate_status: string
}
```

**Relations** :
- Via `bunny_cdn_zone.hostnames` → `bunny_cdn_zone`

**Usage** : Gestion des domaines custom pour Pull Zones.

---

#### `bunny_optimizer_class_model`

**Description** : Classes d'optimisation pour Bunny Optimizer

**Structure** :
```sql
bunny_optimizer_class_model {
    id: int,
    name: string,
    width: int,
    height: int,
    quality: int
}
```

**Relations** :
- Via `bunny_pull_zone_model.optimizer_classes` → `bunny_pull_zone_model`

**Usage** : Configuration classes d'optimisation images.

---

### 2. Storage (`database/storage/`)

#### `bunny_storage_zone_model`

**Description** : Configuration Storage Zones

**Structure** :
```sql
bunny_storage_zone_model {
    id: int,
    name: string,
    password: string,
    password_hash: string,
    date_created: datetime,
    storage_hostname: string,
    storage_zone_id: int,
    replication_regions: array<string>,
    replication_enabled: bool,
    origin_url: string,
    origin_type: string,
    cname_domain: string,
    custom_domain: string,
    ...
}
```

**Relations** :
- Via `bunny_cdn_zone.storage_zone` → `bunny_cdn_zone`

**Usage** : Configuration zones de storage Bunny.

---

#### `bunny_storage_object`

**Description** : Fichiers stockés dans Storage Zones

**Structure** :
```sql
bunny_storage_object {
    path: string,
    object_name: string,
    guid: string,
    is_directory: bool,
    last_changed: datetime,
    length: int,
    content_type: string,
    ...
}
```

**Relations** :
- Via `storage_zone` → `bunny_storage_zone_model`

**Usage** : Inventaire des fichiers dans Storage Zones.

---

### 3. DNS (`database/dns/`)

#### `bunny_dns_zone`

**Description** : Zones DNS gérées

**Structure** :
```sql
bunny_dns_zone {
    id: int,
    domain: string,
    nameservers: array<string>,
    custom_ns_enabled: bool,
    soa_email: string,
    ...
}
```

**Relations** :
- `bunny_dns_record` → `bunny_dns_zone` (1 → N)

**Usage** : Gestion zones DNS.

---

#### `bunny_dns_record`

**Description** : Records DNS (A, AAAA, CNAME, MX, TXT, etc.)

**Structure** :
```sql
bunny_dns_record {
    id: int,
    zone_id: int,
    type: "A" | "AAAA" | "CNAME" | "MX" | "TXT" | ...,
    name: string,
    value: string,
    ttl: int,
    priority: int,
    ...
}
```

**Relations** :
- `zone` → `bunny_dns_zone`

**Usage** : Gestion records DNS.

---

### 4. Shield (`database/shield/`)

#### `bunny_shield_overview`

**Description** : Vue d'ensemble Shield

**Structure** :
```sql
bunny_shield_overview {
    zone_id: int,
    waf_enabled: bool,
    ddos_enabled: bool,
    ratelimit_enabled: bool,
    ...
}
```

**Relations** :
- Via `zone_id` → `bunny_cdn_zone`

**Usage** : Configuration générale Shield par zone.

---

#### `bunny_waf`

**Description** : Configuration WAF (Web Application Firewall)

**Structure** :
```sql
bunny_waf {
    id: int,
    zone_id: int,
    enabled: bool,
    rules: array<record<bunny_waf_rule>>,
    ...
}
```

**Relations** :
- `rules` → `bunny_waf_rule`
- Via `zone_id` → `bunny_cdn_zone`

**Usage** : Configuration WAF.

---

#### `bunny_waf_rule`

**Description** : Règles WAF individuelles

**Structure** :
```sql
bunny_waf_rule {
    id: int,
    waf_id: int,
    action: "allow" | "block" | "challenge",
    condition: object,
    ...
}
```

**Relations** :
- Via `waf_id` → `bunny_waf`

**Usage** : Règles WAF individuelles.

---

#### `bunny_ratelimit`

**Description** : Configuration Rate Limiting

**Structure** :
```sql
bunny_ratelimit {
    id: int,
    zone_id: int,
    enabled: bool,
    limit: int,
    period: int,
    ...
}
```

**Relations** :
- Via `zone_id` → `bunny_cdn_zone`

**Usage** : Configuration rate limiting.

---

#### `bunny_d_do_s`

**Description** : Protection DDoS

**Structure** :
```sql
bunny_d_do_s {
    id: int,
    zone_id: int,
    enabled: bool,
    threshold: int,
    ...
}
```

**Relations** :
- Via `zone_id` → `bunny_cdn_zone`

**Usage** : Configuration protection DDoS.

---

### 5. Edge Scripts (`database/edge_scripts/`)

#### `bunny_edge_script_model`

**Description** : Scripts Edge

**Structure** :
```sql
bunny_edge_script_model {
    id: int,
    name: string,
    version: int,
    enabled: bool,
    ...
}
```

**Relations** :
- `releases` → `bunny_edge_script_release_model`
- `variables` → `bunny_edge_script_variable_model`
- `secrets` → `bunny_edge_script_secret_model`
- Via `edge_script_id` → `bunny_cdn_zone`

**Usage** : Gestion Edge Scripts.

---

#### `bunny_edge_script_release_model`

**Description** : Releases d'Edge Scripts

**Structure** :
```sql
bunny_edge_script_release_model {
    id: int,
    script_id: int,
    version: int,
    code: string,
    ...
}
```

**Relations** :
- Via `script_id` → `bunny_edge_script_model`

**Usage** : Versions des Edge Scripts.

---

#### `bunny_edge_script_variable_model`

**Description** : Variables d'Edge Scripts

**Structure** :
```sql
bunny_edge_script_variable_model {
    id: int,
    script_id: int,
    name: string,
    value: string,
    ...
}
```

**Relations** :
- Via `script_id` → `bunny_edge_script_model`

**Usage** : Variables configurables pour Edge Scripts.

---

#### `bunny_edge_script_secret_model`

**Description** : Secrets d'Edge Scripts

**Structure** :
```sql
bunny_edge_script_secret_model {
    id: int,
    script_id: int,
    name: string,
    value: string,
    ...
}
```

**Relations** :
- Via `script_id` → `bunny_edge_script_model`

**Usage** : Secrets sécurisés pour Edge Scripts.

---

### 6. Video (`database/video/`)

#### `bunny_video_library_model`

**Description** : Video Libraries

**Structure** :
```sql
bunny_video_library_model {
    id: int,
    name: string,
    ...
}
```

**Relations** :
- `videos` → `bunny_video_model` (1 → N)

**Usage** : Gestion Video Libraries.

---

#### `bunny_video_model`

**Description** : Vidéos individuelles

**Structure** :
```sql
bunny_video_model {
    id: int,
    library_id: int,
    title: string,
    ...
}
```

**Relations** :
- Via `library_id` → `bunny_video_library_model`

**Usage** : Gestion vidéos individuelles.

---

### 7. Infrastructure (`database/infrastructure/`)

#### `bunny_containers`

**Description** : Magic Containers

**Structure** :
```sql
bunny_containers {
    id: string,
    name: string,
    image: string,
    regions: array<string>,
    resources: {
        cpu: int,
        ram: int
    },
    status: "running" | "stopped" | "error",
    ...
}
```

**Relations** :
- Via `regions` → `bunny_region_model`

**Usage** : Gestion Magic Containers.

---

#### `infrastructure_logs`

**Description** : Logs d'audit infrastructure

**Structure** :
```sql
infrastructure_logs {
    resource_type: string,
    resource_id: string,
    action: "create" | "update" | "delete" | "sync",
    user: record<identity>,
    timestamp: datetime,
    before: object,
    after: object,
    status: "success" | "failed",
    error: string
}
```

**Relations** :
- `user` → `identity`
- Via `resource_id` → Toutes ressources `bunny_*`

**Usage** : Traçabilité complète des changements infrastructure.

---

#### `bunny_country`

**Description** : Référentiel pays

**Structure** :
```sql
bunny_country {
    code: string,  -- ISO 3166-1 alpha-2
    name: string,
    ...
}
```

**Usage** : Référentiel pays pour geo-blocking, routing, etc.

---

#### `bunny_region_model`

**Description** : Régions Bunny

**Structure** :
```sql
bunny_region_model {
    code: string,
    name: string,
    ...
}
```

**Usage** : Référentiel régions Bunny (US, EU, ASIA, etc.).

---

### 8. Team & Billing (`database/team/`)

#### `bunny_api_key_model`

**Description** : Clés API Bunny

**Structure** :
```sql
bunny_api_key_model {
    id: int,
    key: string,
    name: string,
    permissions: array<string>,
    ...
}
```

**Usage** : Gestion clés API.

---

#### `bunny_team_member_model`

**Description** : Membres équipe

**Structure** :
```sql
bunny_team_member_model {
    id: int,
    email: string,
    role: string,
    ...
}
```

**Usage** : Gestion membres équipe.

---

#### `bunny_billing_record_model`

**Description** : Factures

**Structure** :
```sql
bunny_billing_record_model {
    id: int,
    date: datetime,
    amount: float,
    status: "paid" | "pending" | "failed",
    ...
}
```

**Usage** : Historique facturation.

---

### 9. Support (`database/support/`)

#### `bunny_support_ticket_model`

**Description** : Tickets support

**Structure** :
```sql
bunny_support_ticket_model {
    id: int,
    subject: string,
    status: "open" | "closed" | "pending",
    ...
}
```

**Relations** :
- `comments` → `bunny_support_ticket_comment_model`
- `attachments` → `bunny_support_ticket_attachment_model`

**Usage** : Gestion tickets support.

---

### 10. Integrations (`database/integrations/`)

#### `bunny_github_repository_model`

**Description** : Repositories GitHub

**Structure** :
```sql
bunny_github_repository_model {
    id: int,
    name: string,
    owner: string,
    ...
}
```

**Relations** :
- `branches` → `bunny_github_repository_branch_model`
- Via `account_id` → `bunny_connected_github_account_model`

**Usage** : Intégration GitHub pour Edge Scripts.

---

#### `bunny_connected_github_account_model`

**Description** : Comptes GitHub connectés

**Structure** :
```sql
bunny_connected_github_account_model {
    id: int,
    username: string,
    ...
}
```

**Relations** :
- `repositories` → `bunny_github_repository_model`

**Usage** : Comptes GitHub connectés pour intégration source code.

---

## 📊 Tableau Récapitulatif

| Domaine | Table Principale | Type | Relations |
|---------|------------------|------|-----------|
| CDN | `bunny_cdn_zone` | Métier Lyxal | `storage_zone`, `tenant` |
| CDN | `bunny_pull_zone_model` | Modèle API | Via `sync.bunny_id` |
| Storage | `bunny_storage_zone_model` | Modèle API | Via `cdn_zone` |
| DNS | `bunny_dns_zone` | Métier | `dns_record` |
| Shield | `bunny_shield_overview` | Métier | Via `zone_id` |
| Edge Scripts | `bunny_edge_script_model` | Modèle API | `releases`, `variables` |
| Video | `bunny_video_library_model` | Modèle API | `videos` |
| Infrastructure | `infrastructure_logs` | Métier | Toutes ressources |
| Team | `bunny_api_key_model` | Modèle API | `team_member` |
| Support | `bunny_support_ticket_model` | Modèle API | `comments` |

---

## 🔗 Relations Principales

### Hiérarchie CDN

```
bunny_cdn_zone (Lyxal)
    ↓ sync.bunny_id
bunny_pull_zone_model (API Bunny)
    ↓ storage_zone
bunny_storage_zone_model
    ↓ edge_script_id
bunny_edge_script_model
```

### Hiérarchie DNS

```
bunny_dns_zone
    ↓ (1 → N)
bunny_dns_record
    ↓ linked_pull_zone
bunny_cdn_zone
```

### Hiérarchie Shield

```
bunny_shield_overview
    ↓ waf
bunny_waf
    ↓ rules
bunny_waf_rule
```

---

## 📚 Références

- **Patterns** : `PATTERNS_AND_CONVENTIONS.md`
- **Architecture** : `ARCHITECTURE.md`
- **README** : `README.md`

---

**Référence complète des tables Infrastructure Bunny** 📊✨

