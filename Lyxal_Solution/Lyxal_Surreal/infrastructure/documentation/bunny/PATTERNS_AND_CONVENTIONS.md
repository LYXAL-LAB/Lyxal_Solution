# 📐 Patterns et Conventions - Infrastructure Bunny

**Module** : `infrastructure`  
**Référence** : Patterns standards Lyxal (knowledge, studio)

---

## 🎯 Objectif

Ce document définit les **standards officiels Lyxal** pour structurer, nommer et maintenir les tables du module Infrastructure Bunny.  
Il garantit une cohérence maximale avec les autres modules Lyxal (`knowledge`, `studio`).

---

## 🧱 Principes Fondateurs

| Principe | Description |
|----------|-------------|
| **Cohérence** | Suivre les patterns établis dans `knowledge` et `studio` |
| **Compatibilité** | Conserver la compatibilité avec l'API Bunny |
| **Clarté** | Chaque élément doit être compréhensible immédiatement |
| **Modularité** | Le système doit rester extensible sans casse |
| **IA-Friendly** | Optimisé pour compréhension et génération par IA |
| **I18N Ready** | Tous les contenus affichables sont internationalisables |

---

## 🏗️ Structure Standard des Tables

### Pattern Général

```sql
DEFINE TABLE IF NOT EXISTS bunny_<resource> TYPE NORMAL SCHEMAFULL
    COMMENT 'Description de la table'
    PERMISSIONS 
        FOR SELECT WHERE metadata.is_active = true
        FOR CREATE, UPDATE, DELETE NONE;

-- ============================================================================
-- BLOC IDENTITY : Identité de la ressource
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE bunny_<resource>
    TYPE object
    COMMENT 'Bloc identité : identification unique de la ressource';

    DEFINE FIELD IF NOT EXISTS identity.code ON TABLE bunny_<resource>
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::uppercase($value) = $value
        COMMENT 'Code unique au format UPPER_SNAKE_CASE';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE bunny_<resource>
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::matches($value, '^[a-z0-9-]+$')
        COMMENT 'Slug URL-friendly au format lowercase-kebab-case';

    DEFINE FIELD IF NOT EXISTS identity.label_key ON TABLE bunny_<resource>
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : nom de la ressource (pour UI)';

    DEFINE FIELD IF NOT EXISTS identity.description_key ON TABLE bunny_<resource>
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Clé i18n : description de la ressource';

-- ============================================================================
-- BLOC SYNC : Synchronisation avec Bunny API
-- ============================================================================

DEFINE FIELD IF NOT EXISTS sync ON TABLE bunny_<resource>
    TYPE object
    COMMENT 'Bloc synchronisation : état de sync avec Bunny API';

    DEFINE FIELD IF NOT EXISTS sync.bunny_id ON TABLE bunny_<resource>
        TYPE option<int>
        COMMENT 'ID Bunny.net de la ressource';

    DEFINE FIELD IF NOT EXISTS sync.last_sync_at ON TABLE bunny_<resource>
        TYPE option<datetime>
        COMMENT 'Date de dernière synchronisation';

    DEFINE FIELD IF NOT EXISTS sync.sync_status ON TABLE bunny_<resource>
        TYPE string
        ASSERT $value INSIDE ['synced', 'pending', 'error', 'never']
        DEFAULT 'never'
        COMMENT 'Statut de synchronisation';

    DEFINE FIELD IF NOT EXISTS sync.sync_error ON TABLE bunny_<resource>
        TYPE option<string>
        COMMENT 'Message d\'erreur dernière synchronisation';

-- ============================================================================
-- BLOC METADATA : Métadonnées techniques
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE bunny_<resource>
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.version_label ON TABLE bunny_<resource>
        TYPE string
        DEFAULT "1.0.0"
        COMMENT 'Version fonctionnelle de la configuration';

    DEFINE FIELD IF NOT EXISTS metadata.is_active ON TABLE bunny_<resource>
        TYPE bool
        DEFAULT true
        COMMENT 'La ressource est active et visible';

    DEFINE FIELD IF NOT EXISTS metadata.display_order ON TABLE bunny_<resource>
        TYPE int
        DEFAULT 0
        COMMENT 'Ordre d\'affichage (positif = prioritaire)';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE bunny_<resource>
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE bunny_<resource>
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

    DEFINE FIELD IF NOT EXISTS metadata.created_by ON TABLE bunny_<resource>
        TYPE option<record<identity>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Créé par (utilisateur)';

    DEFINE FIELD IF NOT EXISTS metadata.synced_at ON TABLE bunny_<resource>
        TYPE option<datetime>
        COMMENT 'Date de dernière synchronisation avec Bunny';

-- ============================================================================
-- BLOC STATUS : État opérationnel (si applicable)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE bunny_<resource>
    TYPE option<object>
    COMMENT 'Bloc statut : état opérationnel de la ressource';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE bunny_<resource>
        TYPE bool
        DEFAULT true
        COMMENT 'Ressource active';

    DEFINE FIELD IF NOT EXISTS status.status ON TABLE bunny_<resource>
        TYPE string
        ASSERT $value INSIDE ['active', 'suspended', 'deleted', 'pending']
        DEFAULT 'active'
        COMMENT 'Statut opérationnel';

    DEFINE FIELD IF NOT EXISTS status.health ON TABLE bunny_<resource>
        TYPE option<string>
        ASSERT $value == NONE OR $value INSIDE ['healthy', 'degraded', 'down']
        COMMENT 'État de santé de la ressource';

-- ============================================================================
-- BLOC USAGE : Statistiques d'utilisation (si applicable)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS usage ON TABLE bunny_<resource>
    TYPE option<object>
    COMMENT 'Bloc usage : statistiques d\'utilisation';

    DEFINE FIELD IF NOT EXISTS usage.bandwidth_month ON TABLE bunny_<resource>
        TYPE option<float>
        DEFAULT 0.0
        COMMENT 'Bandwidth du mois (GB)';

    DEFINE FIELD IF NOT EXISTS usage.requests_month ON TABLE bunny_<resource>
        TYPE option<int>
        DEFAULT 0
        COMMENT 'Nombre de requêtes du mois';

    DEFINE FIELD IF NOT EXISTS usage.last_updated ON TABLE bunny_<resource>
        TYPE option<datetime>
        COMMENT 'Dernière mise à jour des statistiques';

-- ============================================================================
-- BLOC COST : Estimation des coûts (si applicable)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS cost ON TABLE bunny_<resource>
    TYPE option<object>
    COMMENT 'Bloc coût : estimation des coûts mensuels';

    DEFINE FIELD IF NOT EXISTS cost.bandwidth_cost ON TABLE bunny_<resource>
        TYPE option<float>
        COMMENT 'Coût bandwidth ($)';

    DEFINE FIELD IF NOT EXISTS cost.requests_cost ON TABLE bunny_<resource>
        TYPE option<float>
        COMMENT 'Coût requêtes ($)';

    DEFINE FIELD IF NOT EXISTS cost.total_month ON TABLE bunny_<resource>
        TYPE option<float>
        COMMENT 'Coût total du mois ($)';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_<resource>_code ON bunny_<resource>
    FIELDS identity.code UNIQUE
    COMMENT 'Index unique sur le code';

DEFINE INDEX IF NOT EXISTS idx_<resource>_slug ON bunny_<resource>
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_<resource>_active ON bunny_<resource>
    FIELDS metadata.is_active
    COMMENT 'Index sur le statut actif';

DEFINE INDEX IF NOT EXISTS idx_<resource>_bunny_id ON bunny_<resource>
    FIELDS sync.bunny_id
    COMMENT 'Index sur l\'ID Bunny';
```

---

## 📋 Règles de Nommage

### Tables

| Type | Format | Exemple |
|------|--------|---------|
| Table principale | `bunny_<resource>` | `bunny_cdn_zone` |
| Table modèle API | `bunny_<resource>_model` | `bunny_pull_zone_model` |
| Table relationnelle | `bunny_<resource>_<relation>` | `bunny_cdn_purge` |

### Champs Identity

| Champ | Format | Exemple |
|-------|--------|---------|
| `identity.code` | `UPPER_SNAKE_CASE` | `PRODUCTION_CDN_ZONE` |
| `identity.slug` | `lowercase-kebab-case` | `production-cdn-zone` |
| `identity.label_key` | `record<i18n_key>` | `i18n_key:bunny_cdn_zone_prod_label` |

### Champs Métier

| Type | Format | Exemple |
|------|--------|---------|
| Bloc | `lowercase` | `sync`, `metadata`, `status` |
| Champs internes | `snake_case` | `last_sync_at`, `is_active` |
| Enum code | `UPPER_SNAKE_CASE` | `SYNCED`, `PENDING` |

---

## 🌍 Internationalisation (i18n)

### Règle Générale

**Tous les textes affichables** doivent pointer vers un `i18n_key`, pas de texte direct dans les records.

### Structure Standard

```sql
-- Créer les clés i18n d'abord
CREATE i18n_key:bunny_cdn_zone_prod_label SET
    key = "bunny_cdn_zone_prod_label",
    translations.fr = "Zone CDN Production",
    translations.en = "Production CDN Zone";

CREATE i18n_key:bunny_cdn_zone_prod_description SET
    key = "bunny_cdn_zone_prod_description",
    translations.fr = "Zone CDN principale pour la production",
    translations.en = "Main CDN zone for production";

-- Utiliser dans la table
CREATE bunny_cdn_zone:PRODUCTION_CDN_ZONE SET
    identity.code = "PRODUCTION_CDN_ZONE",
    identity.slug = "production-cdn-zone",
    identity.label_key = i18n_key:bunny_cdn_zone_prod_label,
    identity.description_key = i18n_key:bunny_cdn_zone_prod_description,
    ...
```

### Quand Utiliser i18n ?

✅ **À utiliser** :
- Labels pour UI (`identity.label_key`)
- Descriptions (`identity.description_key`)
- Messages d'erreur affichables
- Noms de ressources visibles par l'utilisateur

❌ **À éviter** :
- IDs techniques (`bunny_id`)
- Codes techniques (`identity.code`)
- Valeurs de configuration techniques
- Données métier non affichables

---

## 🔄 Synchronisation avec Bunny API

### Pattern de Synchronisation

```sql
-- Structure sync standard
sync: {
    bunny_id: int,              // ID Bunny.net
    last_sync_at: datetime,     // Dernière sync
    sync_status: string,        // synced | pending | error | never
    sync_error: string          // Erreur si sync_status = error
}
```

### États de Synchronisation

| État | Description |
|------|-------------|
| `never` | Jamais synchronisé (défaut) |
| `pending` | Synchronisation en cours |
| `synced` | Dernière sync réussie |
| `error` | Erreur lors de la dernière sync |

### Métadonnées de Sync

```sql
metadata: {
    synced_at: datetime,        // Date dernière sync réussie
    created_by: record<identity>, // Créateur (si création manuelle)
    ...
}
```

---

## 🏷️ Tags et Catégorisation

### Tags Structurés

```sql
DEFINE FIELD IF NOT EXISTS tags ON TABLE bunny_<resource>
    TYPE option<array<record<tag>>>
    DEFAULT []
    COMMENT 'Tags structurés pour catégorisation';
```

### Utilisation

```sql
CREATE bunny_cdn_zone:PRODUCTION_CDN_ZONE SET
    tags = [tag:production, tag:cdn, tag:critical],
    ...
```

---

## 📊 Patterns par Type de Ressource

### 1. Ressources CDN

**Tables** : `bunny_cdn_zone`, `bunny_pull_zone_model`

**Blocs spécifiques** :
- `origin` : Configuration origin
- `cache` : Configuration cache
- `security` : Configuration sécurité
- `performance` : Optimisations performance
- `ssl` : Configuration SSL/TLS

**Exemple** :
```sql
CREATE bunny_cdn_zone:PRODUCTION_CDN_ZONE SET
    identity.code = "PRODUCTION_CDN_ZONE",
    identity.slug = "production-cdn-zone",
    sync.bunny_id = 12345,
    origin.url = "https://example.com",
    cache.ttl_default = 3600,
    security.waf_enabled = true,
    ...
```

### 2. Ressources Storage

**Tables** : `bunny_storage_zone_model`

**Blocs spécifiques** :
- `storage` : Configuration storage
- `replication` : Réplication
- `access` : Configuration accès

### 3. Ressources DNS

**Tables** : `bunny_dns_zone`, `bunny_dns_record`

**Blocs spécifiques** :
- `dns` : Configuration DNS
- `records` : Records DNS

### 4. Ressources Shield

**Tables** : `bunny_waf`, `bunny_ratelimit`

**Blocs spécifiques** :
- `shield` : Configuration Shield
- `waf` : Configuration WAF
- `ratelimit` : Rate Limiting

---

## ✅ Checklist de Validation

### Avant de créer une nouvelle table

- [ ] Structure suit le pattern standard (`identity`, `metadata`, `sync`)
- [ ] `identity.code` en `UPPER_SNAKE_CASE`
- [ ] `identity.slug` en `lowercase-kebab-case`
- [ ] Clés i18n créées avant le CREATE (si nécessaire)
- [ ] Index créés sur `identity.code`, `identity.slug`, `metadata.is_active`
- [ ] Permissions définies selon les besoins
- [ ] Commentaires ajoutés sur tous les champs

### Avant de créer un record

- [ ] `identity.code` unique et descriptif
- [ ] `identity.slug` unique et URL-friendly
- [ ] Clés i18n créées (si utilisation de `label_key`/`description_key`)
- [ ] `metadata.version_label` défini
- [ ] `sync.bunny_id` défini si synchronisé avec Bunny
- [ ] `metadata.is_active` défini (DEFAULT true)

---

## ⚠️ Pièges Courants

### Piège 1 : Oublier la synchronisation

❌ **INCORRECT** :
```sql
CREATE bunny_cdn_zone:PRODUCTION SET
    identity.code = "PRODUCTION",
    -- Pas de sync.bunny_id
    ...
```

✅ **CORRECT** :
```sql
CREATE bunny_cdn_zone:PRODUCTION SET
    identity.code = "PRODUCTION",
    sync.bunny_id = 12345,
    sync.sync_status = "synced",
    sync.last_sync_at = time::now(),
    ...
```

### Piège 2 : Texte direct au lieu de i18n

❌ **INCORRECT** :
```sql
CREATE bunny_cdn_zone:PRODUCTION SET
    identity.code = "PRODUCTION",
    name = "Zone CDN Production",  -- ❌ Texte direct
    ...
```

✅ **CORRECT** :
```sql
-- Créer clé i18n d'abord
CREATE i18n_key:bunny_cdn_zone_prod_label SET
    key = "bunny_cdn_zone_prod_label",
    translations.fr = "Zone CDN Production",
    translations.en = "Production CDN Zone";

-- Utiliser dans le record
CREATE bunny_cdn_zone:PRODUCTION SET
    identity.code = "PRODUCTION",
    identity.label_key = i18n_key:bunny_cdn_zone_prod_label,  -- ✅ i18n
    ...
```

### Piège 3 : Code non standardisé

❌ **INCORRECT** :
```sql
CREATE bunny_cdn_zone:production SET  -- ❌ lowercase
    identity.code = "production",
    ...
```

✅ **CORRECT** :
```sql
CREATE bunny_cdn_zone:PRODUCTION SET  -- ✅ UPPER_SNAKE_CASE
    identity.code = "PRODUCTION",
    identity.slug = "production",  -- ✅ lowercase pour slug
    ...
```

---

## 📚 Références

- **Patterns Knowledge** : `knowledge/documentation/📄 11_Conventions_and_Rules.md`
- **Patterns Studio** : `studio/documentation/README.md`
- **Architecture Infrastructure** : `infrastructure/documentation/bunny/ARCHITECTURE.md`

---

**Ces patterns garantissent la cohérence du système Infrastructure avec les autres modules Lyxal** 📐✨

