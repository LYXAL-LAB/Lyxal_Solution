# 🏢 Architecture Multi-Tenancy : n8n vs Lyxal

> **Contexte** : Analyse du modèle de multi-tenancy de n8n et proposition d'architecture pour Lyxal

---

## 1. Modèle n8n : Single Database Multi-Tenancy

n8n utilise **une seule base de données partagée** avec isolation au niveau des **Projets**.

### Architecture n8n

```
┌─────────────────────────────────────────────────────────┐
│               BASE DE DONNÉES UNIQUE                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐         │
│  │  Project A │  │  Project B │  │  Project C │         │
│  │  (Team 1)  │  │  (Team 2)  │  │ (Personal) │         │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘         │
│        │               │               │                 │
│        ▼               ▼               ▼                 │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Tables partagées (toutes les entités ensemble) │    │
│  │  - workflow_entity     (TOUS les workflows)     │    │
│  │  - credentials_entity  (TOUS les credentials)   │    │
│  │  - execution_entity    (TOUTES les exécutions)  │    │
│  │  - user               (TOUS les users)          │    │
│  └─────────────────────────────────────────────────┘    │
│                          │                               │
│                          ▼                               │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Tables de liaison (isolation par projectId)    │    │
│  │  - shared_workflow      (workflowId + projectId)│    │
│  │  - shared_credentials   (credId + projectId)    │    │
│  │  - project_relation     (userId + projectId)    │    │
│  │  - folder               (projectId)             │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  L'isolation se fait via WHERE projectId = 'xxx'        │
└─────────────────────────────────────────────────────────┘
```

### Mécanisme d'isolation n8n

| Aspect | Implémentation |
|--------|---------------|
| **Isolation** | Via tables de jonction (`shared_workflow`, `shared_credentials`) |
| **Accès** | Un workflow appartient à UN projet via `shared_workflow` |
| **Partage** | Un workflow peut être partagé avec PLUSIEURS projets |
| **Permissions** | `role` dans la table de jonction (`workflow:owner`, `workflow:editor`) |
| **Users** | Un user peut appartenir à PLUSIEURS projets (`project_relation`) |

### Tables NON isolées par projet

| Table | Scope |
|-------|-------|
| `user` | Globale (tous les users de l'instance) |
| `role`, `scope` | Globales (définitions système) |
| `settings` | Globale (config instance) |
| `execution_entity` | Via `workflowId` indirect |
| `webhook_entity` | Globale (paths uniques) |

### Tables isolées par projet

| Table | Mécanisme |
|-------|-----------|
| `workflow_entity` | Via `shared_workflow.projectId` |
| `credentials_entity` | Via `shared_credentials.projectId` |
| `folder` | Colonne `projectId` directe |
| `variables` | Colonne `projectId` (null = global) |
| `data_table` | Colonne `projectId` directe |

---

## 2. Modèle Lyxal : Namespace Native Multi-Tenancy

Lyxal utilise une **isolation physique par namespace** - bien plus propre.

### Architecture Lyxal

```
┌─────────────────────────────────────────────────────────┐
│                    LYXAL KERNEL                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────┐  ┌──────────────────────┐    │
│  │   NS: company_a      │  │   NS: company_b      │    │
│  │   ─────────────────  │  │   ─────────────────  │    │
│  │   company_a::flow    │  │   company_b::flow    │    │
│  │   company_a::cred    │  │   company_b::cred    │    │
│  │   company_a::exec    │  │   company_b::exec    │    │
│  │   company_a::folder  │  │   company_b::folder  │    │
│  └──────────────────────┘  └──────────────────────┘    │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │   NS: _system (tables globales kernel)           │  │
│  │   ─────────────────────────────────              │  │
│  │   _system::user                                  │  │
│  │   _system::role                                  │  │
│  │   _system::scope                                 │  │
│  │   _system::settings                              │  │
│  │   _system::installed_package                     │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  Isolation PHYSIQUE via namespace Lyxal                │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Tables par namespace (tenant)

Seulement **~10 tables** par namespace, pas les 50 de n8n :

```
{namespace}::flow              -- Définitions des workflows
{namespace}::flow_version      -- Historique versions
{namespace}::flow_execution    -- Exécutions
{namespace}::flow_execution_data -- Données d'exécution
{namespace}::credential        -- Identifiants chiffrés
{namespace}::variable          -- Variables d'environnement
{namespace}::folder            -- Organisation
{namespace}::webhook           -- Points d'entrée HTTP
{namespace}::data_table        -- Tables de données custom
{namespace}::data_table_column -- Colonnes des data tables
```

---

## 4. Tables système (globales)

Une seule fois dans `_system::` :

```
_system::user                  -- Tous les utilisateurs
_system::role                  -- Définitions de rôles
_system::scope                 -- Permissions atomiques
_system::settings              -- Configuration globale
_system::installed_package     -- Extensions installées
```

---

## 5. Avantage de l'approche Lyxal

### Isolation automatique

Avec LyxalQL natif, l'isolation est **automatique** :

```sql
-- Dans le contexte du namespace "company_a"
USE NS company_a;

-- Cette requête ne voit QUE les flows de company_a
SELECT * FROM flow;

-- Pas besoin de WHERE projectId = 'xxx' comme dans n8n !
```

### Comparaison

| Critère | n8n | Lyxal |
|---------|-----|-------|
| **Type d'isolation** | Logique (WHERE clause) | Physique (namespace) |
| **Risque de fuite** | Possible (bug dans query) | Impossible |
| **Performance** | Index sur projectId | Partition native |
| **Complexité** | Tables de jonction | Namespace direct |
| **Partage cross-tenant** | Via `shared_*` tables | Via références explicites |
| **Backup par tenant** | Complexe | Trivial (dump namespace) |

---

## 6. Schéma des tables Flow pour Lyxal

### `{ns}::flow`

```rust
DEFINE TABLE flow SCHEMAFULL;

DEFINE FIELD id          ON flow TYPE string;
DEFINE FIELD name        ON flow TYPE string;
DEFINE FIELD description ON flow TYPE option<string>;
DEFINE FIELD nodes       ON flow TYPE array;      // INode[]
DEFINE FIELD connections ON flow TYPE object;     // IConnections
DEFINE FIELD settings    ON flow TYPE option<object>;
DEFINE FIELD active      ON flow TYPE bool DEFAULT false;
DEFINE FIELD version_id  ON flow TYPE string;
DEFINE FIELD trigger_count ON flow TYPE int DEFAULT 0;
DEFINE FIELD folder_id   ON flow TYPE option<record<folder>>;
DEFINE FIELD created_at  ON flow TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at  ON flow TYPE datetime DEFAULT time::now();

DEFINE INDEX flow_name ON flow COLUMNS name UNIQUE;
```

### `{ns}::flow_execution`

```rust
DEFINE TABLE flow_execution SCHEMAFULL;

DEFINE FIELD id          ON flow_execution TYPE string;
DEFINE FIELD flow_id     ON flow_execution TYPE record<flow>;
DEFINE FIELD status      ON flow_execution TYPE string; // new, running, success, error
DEFINE FIELD mode        ON flow_execution TYPE string; // trigger, manual, webhook
DEFINE FIELD started_at  ON flow_execution TYPE option<datetime>;
DEFINE FIELD stopped_at  ON flow_execution TYPE option<datetime>;
DEFINE FIELD wait_till   ON flow_execution TYPE option<datetime>;
DEFINE FIELD created_at  ON flow_execution TYPE datetime DEFAULT time::now();

DEFINE INDEX exec_flow ON flow_execution COLUMNS flow_id;
DEFINE INDEX exec_status ON flow_execution COLUMNS status;
```

### `{ns}::credential`

```rust
DEFINE TABLE credential SCHEMAFULL;

DEFINE FIELD id          ON credential TYPE string;
DEFINE FIELD name        ON credential TYPE string;
DEFINE FIELD type        ON credential TYPE string;  // slackApi, etc.
DEFINE FIELD data        ON credential TYPE string;  // Chiffré
DEFINE FIELD created_at  ON credential TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at  ON credential TYPE datetime DEFAULT time::now();

DEFINE INDEX cred_type ON credential COLUMNS type;
```

---

## 7. Conclusion

L'approche **Namespace Native** de Lyxal est supérieure à celle de n8n car :

1. ✅ Isolation vraie (pas juste au niveau query)
2. ✅ Pas de tables de jonction complexes
3. ✅ Backup/restore par tenant trivial
4. ✅ Performance (pas de filtre WHERE systématique)
5. ✅ LyxalQL natif = moins de code
6. ✅ Sécurité renforcée (pas de risque de fuite cross-tenant)
