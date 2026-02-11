# 🏗️ Infrastructure Bunny - Documentation Complète

**Module** : `infrastructure`  
**Version** : 1.0.0  
**Date** : 2025-01-27

---

## 📋 Vue d'Ensemble

Le module **Infrastructure Bunny** gère toute l'infrastructure Bunny.net (Storage, CDN, Containers, DNS, Shield, Video) via SurrealDB en suivant les patterns standards Lyxal.

### 🎯 Vision

**Infrastructure as Data** : Toute la configuration de l'infrastructure Bunny est stockée et gérée dans SurrealDB selon les conventions Lyxal.

### Avantages

✅ **Centralisé** : Une seule source de vérité pour toute l'infra  
✅ **Versionné** : Historique complet des changements  
✅ **Auditable** : Traçabilité totale (qui, quand, quoi)  
✅ **Automatisable** : Scripts/Workers lisent depuis SurrealDB  
✅ **Multi-tenant** : Gestion fine par namespace/tenant  
✅ **Synchronisé** : API Bunny ↔ SurrealDB bidirectionnel  
✅ **Conforme** : Suit les patterns standards Lyxal (identity, metadata, i18n)

---

## 🗂️ Structure du Module

```
infrastructure/
├── README.md                      (Vue d'ensemble)
├── database/                      (Schémas SurrealDB)
│   ├── cdn/                       (CDN Pull Zones)
│   ├── dns/                       (DNS Zones & Records)
│   ├── edge_scripts/              (Edge Scripts)
│   ├── infrastructure/            (Infrastructure générale)
│   ├── integrations/              (Intégrations GitHub, etc.)
│   ├── shield/                    (Shield & WAF)
│   ├── storage/                   (Storage Zones)
│   ├── support/                   (Support Tickets)
│   ├── team/                      (Team & Billing)
│   └── video/                     (Video Libraries)
├── documentation/                (Documentation)
│   └── bunny/                     (Documentation Bunny)
│       ├── README.md              (ce fichier)
│       ├── PATTERNS_AND_CONVENTIONS.md
│       ├── ARCHITECTURE.md
│       └── TABLES_REFERENCE.md
├── functions/                     (Fonctions SurrealDB)
└── workers/                       (Workers de synchronisation)
```

---

## 📊 Domaines Principaux

### 1. **CDN** (`database/cdn/`)
Gestion des Pull Zones CDN, Edge Rules, Optimizer, Purge

**Tables principales** :
- `bunny_cdn_zone` : Configuration Pull Zones
- `bunny_pull_zone_model` : Modèle complet Pull Zone
- `bunny_edge_rule_v2_model` : Edge Rules v2
- `bunny_cdn_purge` : Historique purges cache

### 2. **Storage** (`database/storage/`)
Gestion des Storage Zones et fichiers

**Tables principales** :
- `bunny_storage_zone_model` : Configuration Storage Zones
- `bunny_storage_object` : Fichiers stockés

### 3. **DNS** (`database/dns/`)
Gestion des zones DNS et records

**Tables principales** :
- `bunny_dns_zone` : Zones DNS
- `bunny_dns_record` : Records DNS (A, AAAA, CNAME, etc.)

### 4. **Shield** (`database/shield/`)
Gestion Shield, WAF, Rate Limiting, DDoS

**Tables principales** :
- `bunny_shield_overview` : Vue d'ensemble Shield
- `bunny_waf` : Configuration WAF
- `bunny_ratelimit` : Rate Limiting
- `bunny_d_do_s` : Protection DDoS

### 5. **Edge Scripts** (`database/edge_scripts/`)
Gestion des Edge Scripts et déploiements

**Tables principales** :
- `bunny_edge_script_model` : Scripts Edge
- `bunny_edge_script_release_model` : Releases
- `bunny_deploy_configuration_model` : Configuration déploiement

### 6. **Video** (`database/video/`)
Gestion des Video Libraries et vidéos

**Tables principales** :
- `bunny_video_library_model` : Video Libraries
- `bunny_video_model` : Vidéos individuelles

### 7. **Infrastructure** (`database/infrastructure/`)
Tables infrastructure générales

**Tables principales** :
- `bunny_containers` : Magic Containers
- `infrastructure_logs` : Logs d'audit
- `bunny_country` : Référentiel pays
- `bunny_region_model` : Régions Bunny

### 8. **Team & Billing** (`database/team/`)
Gestion équipe et facturation

**Tables principales** :
- `bunny_api_key_model` : Clés API
- `bunny_team_member_model` : Membres équipe
- `bunny_billing_record_model` : Factures

### 9. **Support** (`database/support/`)
Gestion tickets support

**Tables principales** :
- `bunny_support_ticket_model` : Tickets support

### 10. **Integrations** (`database/integrations/`)
Intégrations externes (GitHub, etc.)

**Tables principales** :
- `bunny_github_repository_model` : Repositories GitHub
- `bunny_connected_github_account_model` : Comptes GitHub connectés

---

## 🔄 Synchronisation Bunny ↔ SurrealDB

### Import (Bunny API → SurrealDB)

Worker de synchronisation qui :
1. Fetch toutes les ressources Bunny via API
2. Sync dans SurrealDB selon les patterns Lyxal
3. Met à jour les métadonnées de synchronisation
4. Run toutes les 5 minutes (configurable)

### Export (SurrealDB → Bunny API)

Fonctions SurrealDB qui :
1. Déclenchées sur INSERT/UPDATE de ressources
2. Appellent API Bunny pour créer/modifier
3. Stockent l'ID Bunny dans le record
4. Loggent dans `infrastructure_logs`

---

## 🎯 Patterns Lyxal Appliqués

Le module Infrastructure suit les **patterns standards Lyxal** identifiés dans les modules `knowledge` et `studio` :

### ✅ Patterns à Appliquer

1. **Bloc `identity`** :
   - `identity.code` : `UPPER_SNAKE_CASE` (ex: `PRODUCTION_CDN_ZONE`)
   - `identity.slug` : `lowercase-kebab-case` (ex: `production-cdn-zone`)
   - `identity.label_key` : `record<i18n_key>` (pour UI)
   - `identity.description_key` : `option<record<i18n_key>>`

2. **Bloc `metadata`** :
   - `metadata.version_label` : Version configuration (DEFAULT "1.0.0")
   - `metadata.is_active` : Statut actif (DEFAULT true)
   - `metadata.display_order` : Ordre d'affichage (DEFAULT 0)
   - `metadata.created_at` : Date création (READONLY)
   - `metadata.updated_at` : Date modification (READONLY)
   - `metadata.synced_at` : Date dernière sync Bunny

3. **Bloc `sync`** (spécifique infrastructure) :
   - `sync.bunny_id` : ID Bunny.net
   - `sync.last_sync_at` : Dernière synchronisation
   - `sync.sync_status` : Statut synchronisation
   - `sync.sync_error` : Erreur dernière sync

4. **Bloc `status`** (si applicable) :
   - `status.is_active` : Actif/inactif
   - `status.status` : Statut opérationnel
   - `status.health` : État de santé

5. **Bloc `usage`** (si applicable) :
   - `usage.bandwidth_month` : Bandwidth du mois
   - `usage.requests_month` : Requêtes du mois
   - `usage.last_updated` : Dernière mise à jour stats

6. **Bloc `cost`** (si applicable) :
   - `cost.bandwidth_cost` : Coût bandwidth
   - `cost.requests_cost` : Coût requêtes
   - `cost.total_month` : Coût total mensuel

### ⚠️ Compatibilité avec Modèles Bunny

Les tables **modèles Bunny** (`*_model.surql`) sont des mappings directs de l'API Bunny et conservent leur structure originale pour compatibilité.

Les tables **métier Lyxal** (`bunny_*.surql`) suivent les patterns Lyxal avec blocs `identity`, `metadata`, etc.

---

## 📖 Documentation

1. **[PATTERNS_AND_CONVENTIONS.md](./PATTERNS_AND_CONVENTIONS.md)** - Patterns et conventions détaillés
2. **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Architecture et structure
3. **[TABLES_REFERENCE.md](./TABLES_REFERENCE.md)** - Référence complète des tables

---

## 🚀 Démarrage Rapide

### 1. Créer les Tables

```bash
# Exécuter tous les schémas
surreal import --conn http://localhost:8000 \
  --user root --pass root \
  --ns lyxal_infrastructure --db main \
  infrastructure/database/**/*.surql
```

### 2. Vérifier les Tables

```sql
-- Lister toutes les tables infrastructure
SELECT * FROM info::tables() WHERE name LIKE 'bunny_%';
```

### 3. Synchroniser avec Bunny

```bash
# Lancer le sync worker (import Bunny → SurrealDB)
cd workers/bunny-sync-worker
go run main.go
```

---

## 🔗 Intégrations

- **Bunny.net API** : Sync bidirectionnel
- **Magic Containers** : Déploiement automatisé
- **Lyxal Central** : Dashboard infrastructure
- **Monitoring** : Prometheus metrics
- **Knowledge** : Patterns standards Lyxal
- **Studio** : Patterns UI/UX

---

## 📝 Notes Importantes

### Tables Modèles vs Tables Métier

- **Tables `*_model`** : Mapping direct API Bunny (structure originale)
- **Tables métier** : Structure Lyxal avec patterns `identity`, `metadata`

### Migration Progressive

Le module est en cours d'harmonisation avec les patterns Lyxal. Les nouvelles tables doivent suivre les patterns standards.

---

**Infrastructure as Data : Gérez Bunny comme une base de données** 🏗️📊

