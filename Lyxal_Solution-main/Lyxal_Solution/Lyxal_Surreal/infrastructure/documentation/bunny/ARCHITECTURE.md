# 🏛️ Architecture - Infrastructure Bunny

**Module** : `infrastructure`  
**Date** : 2025-01-27

---

## 📋 Vue d'Ensemble Architecturale

Le module Infrastructure Bunny suit une architecture **"Infrastructure as Data"** où toute la configuration Bunny.net est stockée et gérée dans SurrealDB selon les patterns standards Lyxal.

---

## 🎯 Principes Architecturaux

### 1. **Single Source of Truth**

SurrealDB est la source de vérité unique pour toute la configuration infrastructure. L'API Bunny devient un système de synchronisation, pas la source principale.

### 2. **Bidirectional Sync**

Synchronisation bidirectionnelle entre SurrealDB et Bunny API :
- **Import** : Bunny API → SurrealDB (sync automatique)
- **Export** : SurrealDB → Bunny API (via fonctions/triggers)

### 3. **Pattern Standardisé**

Toutes les tables suivent les patterns Lyxal :
- Bloc `identity` : Identification unique
- Bloc `metadata` : Métadonnées système
- Bloc `sync` : Synchronisation Bunny
- Blocs métier : Configuration spécifique

### 4. **Multi-Tenant Ready**

Architecture prête pour multi-tenancy avec support de `tenant` records.

---

## 🗂️ Structure des Domaines

### 1. CDN (`database/cdn/`)

**Responsabilité** : Gestion Pull Zones, Edge Rules, Optimizer, Cache

**Tables principales** :
- `bunny_cdn_zone` : Configuration Pull Zones (structure Lyxal)
- `bunny_pull_zone_model` : Modèle complet API Bunny (mapping direct)
- `bunny_edge_rule_v2_model` : Edge Rules v2
- `bunny_cdn_purge` : Historique purges cache
- `bunny_hostname_model` : Hostnames associés
- `bunny_linked_pull_zone` : Zones liées

**Relations** :
```
bunny_cdn_zone → bunny_pull_zone_model (via sync.bunny_id)
bunny_cdn_zone → bunny_storage_zone_model (via storage_zone)
bunny_cdn_zone → bunny_edge_rule_v2_model (via edge_rules)
```

### 2. Storage (`database/storage/`)

**Responsabilité** : Gestion Storage Zones et fichiers

**Tables principales** :
- `bunny_storage_zone_model` : Configuration Storage Zones
- `bunny_storage_object` : Fichiers stockés
- `bunny_storage` : Métadonnées storage

**Relations** :
```
bunny_storage_zone_model → bunny_cdn_zone (via linked pull zones)
bunny_storage_object → bunny_storage_zone_model
```

### 3. DNS (`database/dns/`)

**Responsabilité** : Gestion zones DNS et records

**Tables principales** :
- `bunny_dns_zone` : Zones DNS
- `bunny_dns_record` : Records DNS (A, AAAA, CNAME, MX, TXT, etc.)

**Relations** :
```
bunny_dns_zone → bunny_dns_record (1 → N)
bunny_dns_record → bunny_cdn_zone (via linked pull zones)
```

### 4. Shield (`database/shield/`)

**Responsabilité** : Gestion Shield, WAF, Rate Limiting, DDoS

**Tables principales** :
- `bunny_shield_overview` : Vue d'ensemble Shield
- `bunny_waf` : Configuration WAF
- `bunny_waf_rule` : Règles WAF
- `bunny_ratelimit` : Rate Limiting
- `bunny_d_do_s` : Protection DDoS
- `bunny_shield_zone_metrics` : Métriques Shield par zone

**Relations** :
```
bunny_shield_overview → bunny_waf
bunny_waf → bunny_waf_rule
bunny_shield_overview → bunny_cdn_zone
```

### 5. Edge Scripts (`database/edge_scripts/`)

**Responsabilité** : Gestion Edge Scripts et déploiements

**Tables principales** :
- `bunny_edge_script_model` : Scripts Edge
- `bunny_edge_script_release_model` : Releases
- `bunny_edge_script_variable_model` : Variables
- `bunny_edge_script_secret_model` : Secrets
- `bunny_deploy_configuration_model` : Configuration déploiement
- `bunny_source_code_integration_model` : Intégrations source code

**Relations** :
```
bunny_edge_script_model → bunny_edge_script_release_model
bunny_edge_script_model → bunny_edge_script_variable_model
bunny_edge_script_model → bunny_edge_script_secret_model
bunny_edge_script_model → bunny_cdn_zone (via edge_script_id)
```

### 6. Video (`database/video/`)

**Responsabilité** : Gestion Video Libraries et vidéos

**Tables principales** :
- `bunny_video_library_model` : Video Libraries
- `bunny_video_model` : Vidéos individuelles
- `bunny_collection_model` : Collections vidéos
- `bunny_caption_model` : Sous-titres
- `bunny_chapter_model` : Chapitres
- `bunny_moment_model` : Moments

**Relations** :
```
bunny_video_library_model → bunny_video_model
bunny_video_model → bunny_collection_model
bunny_video_model → bunny_caption_model
bunny_video_model → bunny_chapter_model
```

### 7. Infrastructure (`database/infrastructure/`)

**Responsabilité** : Tables infrastructure générales

**Tables principales** :
- `bunny_containers` : Magic Containers
- `infrastructure_logs` : Logs d'audit
- `bunny_country` : Référentiel pays
- `bunny_region_model` : Régions Bunny
- `bunny_labels` : Labels infrastructure
- `bunny_server_zone_results_model` : Résultats serveurs

**Relations** :
```
infrastructure_logs → bunny_* (toutes ressources)
bunny_containers → bunny_region_model
```

### 8. Team & Billing (`database/team/`)

**Responsabilité** : Gestion équipe et facturation

**Tables principales** :
- `bunny_api_key_model` : Clés API
- `bunny_team_member_model` : Membres équipe
- `bunny_billing_record_model` : Factures
- `bunny_billing_saved_payment_method` : Méthodes de paiement

**Relations** :
```
bunny_team_member_model → bunny_api_key_model
bunny_billing_record_model → bunny_* (toutes ressources)
```

### 9. Support (`database/support/`)

**Responsabilité** : Gestion tickets support

**Tables principales** :
- `bunny_support_ticket_model` : Tickets support
- `bunny_support_ticket_comment_model` : Commentaires tickets
- `bunny_support_ticket_attachment_model` : Pièces jointes
- `bunny_support_ticket_user_model` : Utilisateurs tickets

**Relations** :
```
bunny_support_ticket_model → bunny_support_ticket_comment_model
bunny_support_ticket_model → bunny_support_ticket_attachment_model
```

### 10. Integrations (`database/integrations/`)

**Responsabilité** : Intégrations externes

**Tables principales** :
- `bunny_github_repository_model` : Repositories GitHub
- `bunny_github_repository_branch_model` : Branches GitHub
- `bunny_connected_github_account_model` : Comptes GitHub connectés
- `bunny_abuse_case_model` : Cas d'abus
- `bunny_abuse_case_url_model` : URLs abus

**Relations** :
```
bunny_connected_github_account_model → bunny_github_repository_model
bunny_github_repository_model → bunny_github_repository_branch_model
```

---

## 🔄 Flux de Synchronisation

### Import (Bunny API → SurrealDB)

```
┌─────────────┐
│ Bunny API   │
└──────┬──────┘
       │
       │ Fetch ressources
       ▼
┌─────────────────┐
│ Sync Worker     │
│ (Go/Node/etc)   │
└──────┬──────────┘
       │
       │ Transform + Validate
       ▼
┌─────────────────┐
│ SurrealDB       │
│ infrastructure  │
└─────────────────┘
```

**Étapes** :
1. Worker fetch toutes les ressources Bunny via API
2. Transformation selon patterns Lyxal
3. Insert/Update dans SurrealDB
4. Mise à jour `sync.*` et `metadata.synced_at`

### Export (SurrealDB → Bunny API)

```
┌─────────────────┐
│ SurrealDB       │
│ infrastructure  │
└──────┬──────────┘
       │
       │ INSERT/UPDATE
       ▼
┌─────────────────┐
│ Function/Trigger│
│ SurrealDB       │
└──────┬──────────┘
       │
       │ Call API
       ▼
┌─────────────┐
│ Bunny API   │
└─────────────┘
```

**Étapes** :
1. INSERT/UPDATE d'une ressource dans SurrealDB
2. Trigger/Function SurrealDB détecte le changement
3. Appel API Bunny pour créer/modifier
4. Stockage `sync.bunny_id` dans SurrealDB
5. Log dans `infrastructure_logs`

---

## 📊 Modèle de Données

### Structure Standard d'une Ressource

```sql
bunny_<resource>:<ID> {
    -- BLOC IDENTITY
    identity: {
        code: "UPPER_SNAKE_CASE",
        slug: "lowercase-kebab-case",
        label_key: i18n_key:...,
        description_key: i18n_key:...
    },
    
    -- BLOC SYNC
    sync: {
        bunny_id: 12345,
        last_sync_at: datetime,
        sync_status: "synced",
        sync_error: null
    },
    
    -- BLOC METADATA
    metadata: {
        version_label: "1.0.0",
        is_active: true,
        display_order: 0,
        created_at: datetime,
        updated_at: datetime,
        created_by: identity:...,
        synced_at: datetime
    },
    
    -- BLOCS MÉTIER SPÉCIFIQUES
    origin: {...},
    cache: {...},
    security: {...},
    ...
}
```

### Relations Entre Ressources

```sql
-- CDN Zone → Storage Zone
bunny_cdn_zone:PRODUCTION {
    storage_zone: bunny_storage_zone_model:12345
}

-- DNS Record → CDN Zone
bunny_dns_record:example_com {
    linked_pull_zone: bunny_cdn_zone:PRODUCTION
}

-- Edge Script → CDN Zone
bunny_edge_script_model:123 {
    linked_zones: [bunny_cdn_zone:PRODUCTION, bunny_cdn_zone:STAGING]
}
```

---

## 🔐 Permissions et Sécurité

### Pattern Standard de Permissions

```sql
DEFINE TABLE bunny_<resource> TYPE NORMAL SCHEMAFULL
    PERMISSIONS 
        FOR SELECT WHERE metadata.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;
```

### Permissions Multi-Tenant (si applicable)

```sql
DEFINE TABLE bunny_<resource> TYPE NORMAL SCHEMAFULL
    PERMISSIONS 
        FOR SELECT WHERE metadata.is_active = true 
            AND tenant = $auth.tenant
        FOR CREATE WHERE tenant = $auth.tenant
        FOR UPDATE WHERE tenant = $auth.tenant
        FOR DELETE WHERE tenant = $auth.tenant;
```

---

## 📈 Monitoring et Métriques

### Logs d'Audit

Tous les changements sont loggés dans `infrastructure_logs` :

```sql
infrastructure_logs {
    resource_type: "bunny_cdn_zone",
    resource_id: bunny_cdn_zone:PRODUCTION,
    action: "create" | "update" | "delete" | "sync",
    user: identity:...,
    timestamp: datetime,
    before: object,
    after: object,
    status: "success" | "failed",
    error: string
}
```

### Métriques par Ressource

Chaque ressource peut avoir un bloc `usage` :

```sql
usage: {
    bandwidth_month: float,
    requests_month: int,
    cache_hit_rate: float,
    last_updated: datetime
}
```

### Estimation des Coûts

Chaque ressource peut avoir un bloc `cost` :

```sql
cost: {
    bandwidth_cost: float,
    requests_cost: float,
    total_month: float
}
```

---

## 🚀 Déploiement et Migration

### Ordre de Création des Tables

1. **Tables référentielles** :
   - `bunny_country`
   - `bunny_region_model`
   - `bunny_labels`

2. **Tables principales** :
   - `bunny_storage_zone_model`
   - `bunny_cdn_zone`
   - `bunny_dns_zone`

3. **Tables dépendantes** :
   - `bunny_storage_object`
   - `bunny_dns_record`
   - `bunny_edge_rule_v2_model`

4. **Tables de support** :
   - `infrastructure_logs`
   - `bunny_shield_overview`

### Migration Progressive

1. **Phase 1** : Créer les tables avec structure minimale
2. **Phase 2** : Importer données existantes Bunny
3. **Phase 3** : Ajouter blocs `identity`, `metadata`, `sync`
4. **Phase 4** : Harmoniser avec patterns Lyxal complets

---

## 🔗 Intégrations

### Modules Lyxal

- **Knowledge** : Patterns standards (identity, metadata)
- **Studio** : Patterns UI (presentation, status)
- **Identity** : Utilisateurs et permissions

### Systèmes Externes

- **Bunny.net API** : Synchronisation bidirectionnelle
- **GitHub** : Intégration source code (Edge Scripts)
- **Monitoring** : Prometheus, Grafana
- **Logging** : ELK Stack, CloudWatch

---

## 📚 Références

- **Patterns** : `PATTERNS_AND_CONVENTIONS.md`
- **Tables** : `TABLES_REFERENCE.md`
- **README** : `README.md`

---

**Architecture Infrastructure as Data : Gérez Bunny comme une base de données** 🏛️📊

