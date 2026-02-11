# 📋 Analyse de la table `tool`

**Date** : 2025-10-30  
**Statut** : ⚠️ **20% CONFORME** - Refactoring critique requis

---

## 🔍 État Actuel

### Définition actuelle (integration_schema.surql)

```sql
DEFINE TABLE tool SCHEMAFULL;

DEFINE FIELD name ON tool TYPE string
    ASSERT $value != NONE;

DEFINE FIELD display_name ON tool TYPE string
    ASSERT $value != NONE;

DEFINE FIELD slug ON tool TYPE string
    ASSERT $value != NONE;

DEFINE FIELD description ON tool TYPE option<string>;

-- Référence à la ressource parent
DEFINE FIELD resource_id ON tool TYPE record<resource>
    ASSERT $value != NONE;

-- Type d'opération (create, read, update, delete, list, search, etc.)
DEFINE FIELD operation_type ON tool TYPE string
    ASSERT $value IN ["create", "read", "update", "delete", "list", "search", "upload", "download", "execute", "custom"];

-- Méthode HTTP utilisée
DEFINE FIELD http_method ON tool TYPE option<string>
    ASSERT $value == NONE OR $value IN ["GET", "POST", "PUT", "PATCH", "DELETE"];

-- Endpoint API (peut contenir des variables: /api/v1/users/{userId})
DEFINE FIELD api_endpoint ON tool TYPE option<string>;

-- Template du corps de la requête
DEFINE FIELD request_body_template ON tool TYPE option<object>;

DEFINE FIELD is_active ON tool TYPE bool DEFAULT true;

-- Configuration avancée
DEFINE FIELD supports_pagination ON tool TYPE bool DEFAULT false;
DEFINE FIELD supports_filtering ON tool TYPE bool DEFAULT false;
DEFINE FIELD supports_sorting ON tool TYPE bool DEFAULT false;
DEFINE FIELD supports_batch ON tool TYPE bool DEFAULT false;

-- Limites de taux (rate limiting)
DEFINE FIELD rate_limit_requests ON tool TYPE option<int>;
DEFINE FIELD rate_limit_period ON tool TYPE option<string>;

DEFINE FIELD metadata ON tool TYPE option<object>;

DEFINE FIELD created_at ON tool TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON tool TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX tool_slug_resource_idx ON tool FIELDS slug, resource_id UNIQUE;
DEFINE INDEX tool_resource_idx ON tool FIELDS resource_id;
DEFINE INDEX tool_operation_idx ON tool FIELDS operation_type;
```

---

## ❌ Problèmes Identifiés

### 1. **Architecture Non Conforme (CRITIQUE)**

#### 1.1 Absence de structure groupée
- ❌ Pas de bloc `identity` (name, slug, display_name_i18n, description_i18n)
- ❌ Pas de bloc `presentation` (icon, color, display_order, badge, etc.)
- ❌ Pas de bloc `config` (http_method, api_endpoint, request_template, etc.)
- ❌ Pas de bloc `capabilities` (pagination, filtering, sorting, batch, etc.)
- ❌ Pas de bloc `documentation` (urls, examples, tutorials)
- ❌ Champs éparpillés sans organisation logique (17 champs plats)

#### 1.2 Internationalisation manquante
- ❌ `display_name` en string direct au lieu de `record<i18n_key>`
- ❌ `description` en string direct au lieu de `record<i18n_key>`
- ❌ Impossible de supporter plusieurs langues

#### 1.3 Présentation UI inadéquate
- ❌ Pas d'`icon` pour représenter visuellement le tool
- ❌ Pas de `color` pour différenciation visuelle
- ❌ Pas de `display_order` pour tri
- ❌ Pas de `tooltip_i18n` pour aide contextuelle
- ❌ Pas de `badge` pour indiquer le statut (Recommended, Beta, Premium, etc.)

---

### 2. **Temps Réel et Synchronisation**

- ❌ Pas de champ `ETag` pour optimistic locking
- ❌ UI ne peut pas détecter les changements en temps réel
- ❌ Risques de conflits lors de mises à jour concurrentes

---

### 3. **Timestamps Incorrects**

```sql
❌ DEFINE FIELD created_at ON tool TYPE datetime DEFAULT time::now();
❌ DEFINE FIELD updated_at ON tool TYPE datetime DEFAULT time::now();
```

**Problème** :
- `created_at` doit être `READONLY` et `VALUE $before OR time::now()`
- `updated_at` doit être `READONLY` et `DEFAULT ALWAYS time::now()`

---

### 4. **Permissions Manquantes**

- ❌ Pas de `PERMISSIONS` définis
- ❌ Tous les utilisateurs peuvent potentiellement modifier la table
- ❌ Pas de contrôle d'accès granulaire

---

### 5. **Documentation Inline Absente**

- ❌ Pas de `COMMENT` sur la table
- ❌ Pas de `COMMENT` sur les champs
- ❌ Code non auto-documenté

---

### 6. **Champs Manquants Critiques**

#### 6.1 Configuration de la requête API
**Problème** : Configuration API trop basique
```sql
❌ DEFINE FIELD api_endpoint ON tool TYPE option<string>;
❌ DEFINE FIELD request_body_template ON tool TYPE option<object>;
```

Devrait inclure :
- `config.request.method` (GET, POST, PUT, PATCH, DELETE)
- `config.request.endpoint` (avec variables: `/api/v1/users/{userId}`)
- `config.request.body_template` (template du corps de requête)
- `config.request.headers_template` (headers personnalisés)
- `config.request.query_params_template` (paramètres query)
- `config.request.path_params` (liste des paramètres de chemin)
- `config.request.authentication_required` (auth requise ?)

#### 6.2 Configuration de la réponse
**Problème** : Pas de configuration de la réponse
```sql
❌ Pas de config.response
```

Devrait inclure :
- `config.response.success_codes` (codes HTTP de succès: [200, 201, 204])
- `config.response.data_path` (chemin JSON de la données: "data.items")
- `config.response.pagination_path` (chemin de pagination: "data.pagination")
- `config.response.transform` (transformation de la réponse)

#### 6.3 Métadonnées UX enrichies
**Problème** : Pas d'informations UX pour guider l'utilisateur
```sql
❌ Pas de presentation.success_message_i18n
❌ Pas de presentation.confirmation_required
❌ Pas de presentation.confirmation_message_i18n
❌ Pas de presentation.estimated_duration
```

Devrait inclure :
- `presentation.success_message_i18n` : Message de succès après exécution
- `presentation.error_message_i18n` : Message d'erreur générique
- `presentation.confirmation_required` : Confirmation avant exécution ?
- `presentation.confirmation_message_i18n` : Message de confirmation
- `presentation.estimated_duration` : Durée estimée (en secondes)
- `presentation.is_destructive` : Action destructive (ex: Delete) ?

---

## 📊 Exemples Concrets

### Slack Service → Channel Resource

**Tools** :
- `Create Channel` : Crée un nouveau canal
- `Get Channel` : Récupère les infos d'un canal
- `List Channels` : Liste tous les canaux
- `Archive Channel` : Archive un canal (pas delete !)
- `Invite to Channel` : Invite des utilisateurs
- `Set Channel Topic` : Définit le sujet du canal

**Problème actuel** : Ces tools seraient créés sans structure, sans i18n, sans configuration UX.

### Google Sheets Service → Sheet Resource

**Tools** :
- `Append Row` : Ajoute une ligne
- `Get Row(s)` : Récupère une ou plusieurs lignes
- `Update Row` : Modifie une ligne
- `Delete Row` : Supprime une ligne
- `Clear Sheet` : Vide la feuille
- `Create Sheet` : Crée une nouvelle feuille

**Problème actuel** : Impossible de savoir quels sont les paramètres requis, les codes de succès, les messages à afficher.

---

## ✅ Ce qui Fonctionne

1. ✅ `SCHEMAFULL` activé
2. ✅ `slug` avec index UNIQUE (combiné avec resource_id)
3. ✅ `resource_id` en `record<resource>` avec ASSERT
4. ✅ `operation_type` avec ENUM (create, read, update, delete, etc.)
5. ✅ `http_method` avec ENUM (GET, POST, PUT, PATCH, DELETE)
6. ✅ Index sur `resource_id` et `operation_type`
7. ✅ `is_active` pour activation/désactivation
8. ✅ Champs de capabilities (`supports_pagination`, `supports_filtering`, etc.)

---

## 🎯 Architecture Cible (Lyxal Standards)

### Structure complète conforme

```
tool
├── identity
│   ├── name (string, technique)
│   ├── slug (string, unique par resource)
│   ├── display_name_i18n (record<i18n_key>)
│   ├── description_i18n (record<i18n_key>)
│   ├── operation_type (enum: create, read, update, delete, list, search, upload, download, execute, custom)
│   └── aliases (array<string>)
│
├── presentation
│   ├── icon (record<icon>)
│   ├── color (string, hex)
│   ├── display_order (int)
│   ├── tooltip_i18n (record<i18n_key>)
│   ├── badge_text (string, ex: "Beta", "Premium")
│   ├── badge_color (string)
│   ├── success_message_i18n (record<i18n_key>)
│   ├── error_message_i18n (record<i18n_key>)
│   ├── confirmation_required (bool)
│   ├── confirmation_message_i18n (record<i18n_key>)
│   ├── estimated_duration (int, en secondes)
│   └── is_destructive (bool)
│
├── config
│   ├── request
│   │   ├── method (string: GET, POST, PUT, PATCH, DELETE)
│   │   ├── endpoint (string, avec variables: /api/v1/users/{userId})
│   │   ├── body_template (object)
│   │   ├── headers_template (object)
│   │   ├── query_params_template (object)
│   │   ├── path_params (array<string>)
│   │   └── authentication_required (bool)
│   │
│   ├── response
│   │   ├── success_codes (array<int>)
│   │   ├── data_path (string)
│   │   ├── pagination_path (string)
│   │   └── transform (object)
│   │
│   ├── capabilities
│   │   ├── supports_pagination (bool)
│   │   ├── supports_filtering (bool)
│   │   ├── supports_sorting (bool)
│   │   ├── supports_batch (bool)
│   │   ├── is_idempotent (bool)
│   │   └── requires_confirmation (bool)
│   │
│   └── rate_limiting
│       ├── max_requests (int)
│       ├── period (string: "minute", "hour", "day")
│       └── burst_allowed (bool)
│
├── documentation
│   ├── main_url (string)
│   ├── examples_url (string)
│   ├── video_tutorial_url (string)
│   ├── common_use_cases (array<string>)
│   └── prerequisites (array<string>)
│
├── metadata
│   ├── usage_count (int)
│   ├── average_duration (int, en ms)
│   ├── success_rate (float)
│   └── custom_data (object)
│
├── Relations
│   └── resource_id (record<resource>, REQUIRED)
│
├── État
│   ├── is_active (bool)
│   ├── ETag (uuid)
│   ├── created_at (datetime, READONLY)
│   └── updated_at (datetime, READONLY)
│
└── Permissions
    ├── SELECT: WHERE is_active = true
    ├── CREATE: WHERE $auth.role = "admin"
    ├── UPDATE: WHERE $auth.role IN ["admin", "editor"]
    └── DELETE: WHERE $auth.role = "admin"
```

---

## 📊 Comparaison : Avant / Après

| Critère | Avant | Après | Amélioration |
|---------|-------|-------|--------------|
| **Structure** | 17 champs plats | 7 blocs groupés (45+ champs) | +165% |
| **i18n** | ❌ String direct | ✅ i18n_key (5 clés/tool) | 100% |
| **Présentation** | ❌ Aucune | ✅ icon + color + badges + messages | 100% |
| **Config Request** | ⚠️ Basique (3 champs) | ✅ Complète (7 champs) | +133% |
| **Config Response** | ❌ Absente | ✅ Complète (4 champs) | 100% |
| **Temps Réel** | ❌ Pas d'ETag | ✅ ETag + Live Queries | 100% |
| **Permissions** | ❌ Absentes | ✅ Granulaires | 100% |
| **Documentation** | ❌ Pas de COMMENT | ✅ Inline docs (45+) | 100% |
| **Timestamps** | ⚠️ Incorrects | ✅ READONLY | 100% |
| **UX Metadata** | ❌ Absente | ✅ Messages + confirmation + durée | 100% |
| **UI-Ready** | 20% | 100% | +400% |
| **AI-Ready** | 25% | 100% | +300% |

---

## 🚨 Impact sur l'écosystème

**CRITIQUE** : La table `tool` est le **cœur de l'intégration** !

### Dépendances

```
service (419 services)
    ↓
resource (1,091 ressources)
    ↓
tool (~5,000-10,000 tools) ← VOUS ÊTES ICI
    ↓
parameter (dizaines de milliers)
```

**Si `tool` n'est pas conforme** :
- ❌ L'UI ne peut pas afficher les actions correctement
- ❌ Pas de traduction des noms d'actions
- ❌ Impossible de savoir quels paramètres sont requis
- ❌ Pas de messages de succès/erreur personnalisés
- ❌ Pas de confirmation pour les actions destructives
- ❌ Les `parameter` (prochaine table) ne peuvent pas être créés proprement

---

## ✅ Plan de Refactoring

### Phase 1 : Refactorer la table ✅ PRIORITÉ
1. Créer `tool.surql` conforme à 100%
2. Ajouter structure groupée (identity, presentation, config, etc.)
3. Intégrer i18n_key pour multilinguisme (5 clés: name, desc, tooltip, success_msg, error_msg)
4. Ajouter ETag et permissions
5. Corriger timestamps
6. Enrichir config (request, response, capabilities, rate_limiting)
7. Ajouter métadonnées UX (confirmation, durée estimée, is_destructive)

### Phase 2 : Créer les seeds
1. Extraire les tools depuis n8n (~5,000-10,000 tools)
2. Générer les i18n_key pour chaque tool (5 clés/tool)
3. Créer les seeds par batches (ex: 50 tools/batch)
4. Générer les traductions (FR, EN, IT, DE, ES)

### Phase 3 : Valider l'écosystème
1. Vérifier que tous les `resource_id` existent
2. Préparer la création des `parameter`
3. Tester l'import complet

---

## 🎯 Conformité Finale

**Objectif** : Passer de **20%** à **100%** de conformité

**Après refactoring** :
- ✅ Structure groupée (7 blocs)
- ✅ i18n complet (5 clés: name, desc, tooltip, success, error)
- ✅ icon pour représentation visuelle
- ✅ ETag pour temps réel
- ✅ Permissions granulaires
- ✅ Documentation inline (45+ COMMENT)
- ✅ Timestamps corrects
- ✅ Config Request complète (7 champs)
- ✅ Config Response complète (4 champs)
- ✅ Métadonnées UX (confirmation, durée, is_destructive)
- ✅ Prêt pour UI dynamique
- ✅ Prêt pour AI/agents

---

**🚀 Prêt pour le refactoring !**

