# 📊 État des Lieux - Module Integrations

**Date** : 2025-01-27  
**Objectif** : Analyse complète du module `integrations` avant intégration de Bunny.net

---

## 🎯 Vue d'Ensemble

Le module `integrations` est un système **AI-ready** de gestion d'intégrations API, conçu pour permettre à l'IA Lyxal d'utiliser intelligemment 419 services API (Slack, Google, GitHub, etc.) avec leurs 2,436 outils et 74,466 paramètres.

### Architecture Principale

```
Provider (ex: Google)
    └─ Service (ex: Google Sheets)
        └─ Resource (ex: Sheet)
            └─ Tool (ex: Create, Read, Update, Delete)
                └─ Parameter (ex: documentId, sheetName)
```

---

## ✅ Modules COMPLÉTÉS (10/12 = 83%)

### 1. **Credentials** (4 modules) ✅

| Module | Schéma | Seeds | i18n | Total |
|--------|--------|-------|------|-------|
| `auth_type` | ✅ | ✅ | ✅ | 7 types |
| `credential_type` | ✅ | ✅ | ✅ | 282 types |
| `transmission_method` | ✅ | ✅ | ✅ | 4 méthodes |
| `uses_credential` | ✅ | ✅ | ✅ | 429 relations |

**Localisation** :
- Schémas : `integrations/database/credentials/`
- Seeds : `integrations/reference/credentials/`

**Fonctionnalités** :
- Gestion des types d'authentification (OAuth2, API Key, Basic Auth)
- Relations services ↔ credentials
- Métadonnées de transmission

---

### 2. **Provider** ✅

| Module | Schéma | Seeds | i18n | Total |
|--------|--------|-------|------|-------|
| `provider` | ✅ | ✅ | ✅ | **205 providers** |

**Schéma** : `integrations/database/provider/provider.surql`

**Structure** :
- `identity` : name, slug, display_name_i18n, description_i18n
- `presentation` : logo_light, logo_dark, color, color_daisy, display_order
- `config` : urls (website, documentation, api_base, status_page), capabilities
- `metadata` : founded_year, headquarters, industry, tags

**Seeds** : 9 batches dans `integrations/reference/Provider/`

**Exemples** : Google, Stripe, Slack, GitHub, Facebook, Microsoft, etc.

---

### 3. **Service** ✅

| Module | Schéma | Seeds | i18n | Total |
|--------|--------|-------|------|-------|
| `service` | ✅ | ✅ | ✅ | **419 services** |

**Schéma** : `integrations/database/service/service.surql`

**Structure** :
- `identity` : name, slug, display_name_i18n, description_i18n, aliases
- `presentation` : icon, color, display_order, category_slug, tooltip_i18n, badge_text
- `config` : version, capabilities (is_trigger, is_polling, is_webhook, is_action, supports_batch), api (base_url, version, protocol), rate_limits
- `documentation` : main_url, api_reference_url, credential_setup_url, video_tutorial_url
- `metadata` : tags, popularity_score, custom_data
- `provider_id` : relation vers provider

**Seeds** : 14 batches dans `integrations/reference/service/`

**Exemples** : Google Sheets, Slack Messages, GitHub Issues, etc.

---

### 4. **Resource** ✅

| Module | Schéma | Seeds | i18n | Total |
|--------|--------|-------|------|-------|
| `resource` | ✅ | ✅ | ✅ | **1,091 resources** |

**Schéma** : `integrations/database/resource/resource.surql`

**Structure** :
- `identity` : name, slug, display_name_i18n, description_i18n, aliases
- `presentation` : icon, color, display_order, tooltip_i18n, badge_text
- `config` : operation_types (supports_create, supports_read, supports_update, supports_delete, supports_list, supports_search), capabilities (supports_bulk, supports_pagination, supports_filtering, supports_sorting, requires_authentication, is_real_time), api (base_path, id_field, list_endpoint)
- `documentation` : main_url, examples_url, video_tutorial_url, common_use_cases
- `metadata` : common_fields, relationships, popularity_score
- `service_id` : relation vers service

**Seeds** : 22 batches dans `integrations/reference/resource/`

**Exemples** : Channel (Slack), Sheet (Google Sheets), Issue (GitHub)

---

### 5. **Tool** ✅

| Module | Schéma | Seeds | i18n | Total |
|--------|--------|-------|------|-------|
| `tool` | ✅ | ✅ | ✅ | **2,436 tools** |

**Schéma** : `integrations/database/tool/tool.surql`

**Structure** :
- `identity` : name, slug, display_name_i18n, description_i18n, operation_type, aliases
- `presentation` : icon, color, display_order, tooltip_i18n, badge_text, success_message_i18n, error_message_i18n, confirmation_required, confirmation_message_i18n, estimated_duration, is_destructive
- `config` :
  - `request` : method, endpoint, body_template, headers_template, query_params_template, path_params, authentication_required
  - `response` : success_codes, data_path, pagination_path, transform
  - `capabilities` : supports_pagination, supports_filtering, supports_sorting, supports_batch, is_idempotent, requires_confirmation
  - `rate_limiting` : max_requests, period, burst_allowed
- `documentation` : main_url, examples_url, video_tutorial_url, common_use_cases, prerequisites
- `metadata` : usage_count, average_duration, success_rate, custom_data
- `resource_id` : relation vers resource

**Seeds** : 25 batches dans `integrations/reference/tool/`

**Exemples** : Create Channel, Post Message, Get Issue, Append Row

---

### 6. **Parameter** ✅

| Module | Schéma | Seeds | i18n | Total |
|--------|--------|-------|------|-------|
| `parameter` | ✅ | ✅ | ✅ | **74,466 paramètres** |

**Schéma** : `integrations/database/parameter/parameter.surql`

**Structure** :
- `identity` : name, display_name_i18n, description_i18n, parameter_type, sub_type
- `presentation` : display_order, placeholder_i18n, help_text_i18n, is_sensitive, is_hidden
- `validation` : is_required, min_value, max_value, min_length, max_length, pattern, format, allowed_values
- `config` : default_value, options, display_conditions
- `documentation` : examples, related_fields
- `metadata` : usage_count, custom_data
- `tool_id` : relation vers tool

**Seeds** : 25 batches dans `integrations/reference/parameter/`

---

### 7. **Error Mapping** ✅

| Module | Schéma | Seeds | i18n | Total |
|--------|--------|-------|------|-------|
| `error_mapping` | ✅ | ✅ | ✅ | **683 erreurs** |

**Schéma** : `integrations/database/error_mapping/error_mapping.surql`

**Types d'erreurs extraites** :
1. Validation (`errorMessage` dans `*Description.ts`)
2. Opération (`NodeOperationError` dans `.node.ts`)
3. API (`NodeApiError` avec messages personnalisés)
4. Application (`ApplicationError`)
5. Constants (`ERROR_MESSAGES` dans `constants.ts`)
6. HTTP (`errorMapping` dans `GenericFunctions.ts`)

**Couverture** : 190 services (45% du total)

**Scripts** : `extract_errors.py`, `generate_seeds.py`

---

## ⚠️ Modules NON EXTRACTIBLES / PARTIELS (2/12)

### 8. **Response Mapping** ⚠️

**Statut** : ❌ Extraction 1:1 impossible

**Raison** : La logique de transformation des réponses API est **hardcodée en TypeScript** dans n8n.

**Patterns identifiés** (documentés) :
1. Extraction d'un sous-objet (~25%)
2. Extraction d'un tableau (~25%)
3. Transformation de tableau (~10%)
4. Renommage de champs (~5%)
5. Réponse inventée (~3%)
6. Retour brut (~30%)

**Recommandation** :
- ✅ Créer le schéma `response_mapping` conforme Lyxal
- ❌ Ne pas créer de seeds (impossible d'extraire)
- 💡 Remplir manuellement au fur et à mesure

**Documentation** :
- `integrations/reference/response_mapping/ANALYSE_N8N.md`
- `integrations/reference/response_mapping/EXEMPLES_REELS_N8N.md`

---

### 9. **Webhook Config** ⚠️

**Statut** : ⚠️ Extraction partielle possible (~40%)

**Données extractibles** ✅ :
- Noms des événements (`message.channels`, `app_mention`, etc.)
- Descriptions des événements
- Méthodes HTTP (`POST`)
- Mode de réponse (`onReceived`)

**Données NON extractibles** ❌ :
- Endpoints API pour créer/supprimer les webhooks
- Structure des body de création
- Logique de vérification de signature
- Filtres et transformations

**Estimation** :
- ~50 services avec webhooks (12% des 419 services)
- ~300-500 événements webhook au total
- **40% extractible** (noms + descriptions)

**🚀 NOUVEAUTÉ : SurrealDB DEFINE API**
- Support natif des endpoints HTTP dans SurrealDB v2.2.0+
- Permet de créer des webhooks sans serveur Node.js
- Middleware natif pour vérification de signature

**Documentation** :
- `integrations/reference/webhook_config/EXPLICATION_WEBHOOKS.md`

---

## 🔧 Fonction Principale : `fn::execute_tool`

### Localisation
`integrations/reference/fn_execute_tool.surql`

### Fonctionnalités

**1. Lecture de configuration depuis SQL** :
- Lit `tool`, `service`, `resource` depuis les tables
- Pas de code hardcodé

**2. Gestion des credentials** :
- Récupère `user_service_credential` pour l'utilisateur
- Support OAuth2, API Key, Basic Auth
- Vérifie expiration automatiquement

**3. Construction dynamique** :
- URL : remplace variables dans endpoint (`{userId}`, `{{domain}}`)
- Body : template avec remplacement de variables
- Headers : authentification + headers custom

**4. Appel API** :
- Utilise `fetch()` natif SurrealDB
- Gestion des erreurs HTTP
- Logging automatique dans `integration_log`

**5. Extraction des données** :
- Support `data_path` pour extraire sous-objet
- Support `fields_to_extract` pour filtrer
- Pagination supportée

**6. Gestion d'erreurs** :
- Consulte `error_mapping` pour messages traduits
- Retourne `is_retryable`, `solution`
- Logs dans `integration_log`

### Exemple d'utilisation

```surql
LET $result = fn::execute_tool(
  tool:slack_message_post,
  {
    channel: 'C123456',
    text: 'Hello from Lyxal!'
  },
  user:john_doe
);

RETURN $result;
```

### Tables nécessaires

✅ **Existantes** :
- `tool`
- `service`
- `provider`
- `resource`
- `parameter`
- `error_mapping`

❌ **À créer** :
- `user_service_credential` (stockage credentials utilisateurs)
- `integration_log` (logs d'appels API)

---

## 📊 Statistiques Globales

| Métrique | Valeur |
|----------|--------|
| **Total tables** | 10 |
| **Total seeds** | 79,940 |
| **Total clés i18n** | 318,158 |
| **Total traductions** | 1,595,790 (5 langues) |
| **Taux d'extraction** | 100% (1:1 depuis n8n) |
| **Services couverts** | 419 |
| **Providers couverts** | 205 |

---

## 🏗️ Patterns Lyxal Appliqués

### 1. Structure Groupée

Tous les modules utilisent des blocs groupés :
- `identity` : Identification (name, slug, i18n)
- `presentation` : UI (icon, color, display_order)
- `config` : Configuration technique
- `metadata` : Données additionnelles
- `documentation` : URLs et ressources

### 2. i18n Complète

- Tous les textes affichables utilisent `record<i18n_key>`
- 5 langues supportées : FR, EN, IT, DE, ES
- Pas de hardcoded strings

### 3. SCHEMAFULL + ASSERT

- Tables strictement typées
- Contraintes de validation avec `ASSERT`
- Relations explicites avec `REFERENCE`

### 4. ETag + Timestamps

- `ETag` : UUID v7 pour optimistic locking
- `created_at` : READONLY, défini à la création
- `updated_at` : READONLY, auto-update

### 5. Permissions Granulaires

```surql
PERMISSIONS
    FOR select WHERE is_active = true OR $auth.role IN ["admin", "editor"]
    FOR create WHERE $auth.role IN ["admin"]
    FOR update WHERE $auth.role IN ["admin", "editor"]
    FOR delete WHERE $auth.role = "admin";
```

### 6. Index Optimisés

- Index sur `slug` (unique)
- Index sur `is_active` (filtrage rapide)
- Index sur relations (`provider_id`, `service_id`, `resource_id`)

---

## 📁 Structure des Dossiers

```
integrations/
├── database/                    # Schémas SurrealDB
│   ├── credentials/             ✅ (4 tables)
│   ├── provider/                 ✅ (1 table)
│   ├── service/                 ✅ (1 table)
│   ├── resource/                ✅ (1 table)
│   ├── tool/                    ✅ (1 table)
│   ├── parameter/               ✅ (1 table)
│   ├── error_mapping/            ✅ (1 table)
│   ├── response_mapping/         ⚠️ (schéma à créer)
│   └── webhook_config/           ⚠️ (schéma à créer)
│
├── reference/                   # Seeds + Scripts
│   ├── credentials/             ✅ (4 modules)
│   ├── Provider/                ✅ (9 batches)
│   ├── service/                 ✅ (14 batches)
│   ├── resource/                ✅ (22 batches)
│   ├── tool/                    ✅ (25 batches)
│   ├── parameter/               ✅ (25 batches)
│   ├── error_mapping/            ✅ (seeds + scripts)
│   ├── response_mapping/         ⚠️ (documentation seulement)
│   ├── webhook_config/           ⚠️ (documentation seulement)
│   └── fn_execute_tool.surql    ✅ (fonction générique)
│
├── resources/                    # Fonctions ressources génériques
│   └── Provider/                 ✅ (CRUD providers)
│
├── schema/                       # Documentation architecture
│   ├── INTEGRATION_ARCHITECTURE.md
│   ├── integration_schema.surql
│   └── example_queries.surql
│
└── documentation/                # Documentation modules
    └── credential/
```

---

## 🔍 Points d'Attention

### 1. Tables Manquantes

**`user_service_credential`** :
- Nécessaire pour `fn::execute_tool`
- Stocke credentials OAuth2/API Key/Basic Auth par utilisateur
- Relation `user_id` + `service_id`

**`integration_log`** :
- Nécessaire pour `fn::execute_tool`
- Logs tous les appels API
- Métriques d'utilisation

**Recommandation** : Créer ces 2 tables avant d'utiliser `fn::execute_tool` en production.

---

### 2. Limitations de `fn::execute_tool`

**Documentation** : `integrations/reference/fn_execute_tool_LIMITATIONS.md`

**Limites identifiées** :
- Pas de gestion de retry automatique (même si `is_retryable` est retourné)
- Pas de cache de réponses
- Pas de rate limiting côté client
- Transformation de réponses limitée (besoin de `response_mapping`)

**Améliorations possibles** :
- Ajouter retry avec backoff exponentiel
- Implémenter cache avec TTL
- Rate limiting côté client basé sur `config.rate_limiting`
- Utiliser `response_mapping` pour transformations avancées

---

### 3. Response Mapping Manquant

**Impact** : ~70% des tools filtrent/transforment les réponses, mais ces transformations ne sont pas configurées.

**Solution** :
- Créer le schéma `response_mapping`
- Remplir manuellement au fur et à mesure des besoins
- Utiliser les patterns documentés dans `ANALYSE_N8N.md`

---

### 4. Webhook Config Incomplet

**Impact** : ~50 services avec webhooks, mais configuration technique manquante.

**Solution** :
- Créer le schéma `webhook_config` avec champ `surreal_api` pour DEFINE API
- Extraire les ~500 noms d'événements depuis n8n
- Documenter comment générer les `DEFINE API` automatiquement

---

## 🎯 Intégration Bunny.net

### Ce qui est Prêt ✅

1. **Structure complète** :
   - Provider → Service → Resource → Tool → Parameter
   - Fonction générique `fn::execute_tool`
   - Gestion d'erreurs via `error_mapping`

2. **Patterns Lyxal** :
   - Structure groupée (identity, presentation, config, metadata)
   - i18n complète
   - ETag + timestamps
   - Permissions granulaires

3. **Extractibilité** :
   - JSON API Bunny disponibles
   - Scripts Python réutilisables pour extraction
   - Processus d'extraction documenté

### Ce qui est à Faire pour Bunny

#### Phase 1 : Créer Provider Bunny

**Fichier** : `integrations/reference/Provider/provider_bunny_seeds.surql`

**Contenu** :
```surql
CREATE provider:bunny SET
  name = "bunny",
  slug = "bunny",
  identity = {
    display_name_i18n: i18n_key:provider_bunny_name,
    description_i18n: i18n_key:provider_bunny_description
  },
  presentation = {
    logo_light: logo_brand:bunny_light,
    logo_dark: logo_brand:bunny_dark,
    color: "#FF6B35",
    color_daisy: "warning",
    display_order: 100
  },
  config = {
    urls: {
      website: url:bunny_net,
      documentation: url:bunny_docs,
      api_base: "https://api.bunny.net",
      status_page: "https://status.bunny.net"
    },
    capabilities: {
      supports_oauth2: false,
      supports_api_key: true,
      supports_basic_auth: false,
      supports_webhooks: false,
      supports_rate_limiting: true
    },
    api_version: NONE
  },
  metadata = {
    founded_year: 2015,
    headquarters: "Valletta, Malta",
    industry: "CDN, Storage, Edge Computing",
    company_size: "medium",
    tags: ["cdn", "storage", "edge", "infrastructure"]
  };
```

#### Phase 2 : Créer Services Bunny

**5 Services principaux** (basés sur les JSON API) :

1. **`bunny_main`** : API principale (DNS Zone, Pull Zone, Storage Zone, etc.)
2. **`bunny_edge_scripting`** : Edge Scripting API
3. **`bunny_stream`** : Stream API (Video)
4. **`bunny_edge_storage`** : Edge Storage API
5. **`bunny_shield`** : Shield API (WAF, Rate Limiting, DDoS)

**Fichiers** : `integrations/reference/service/service_bunny_*.surql`

#### Phase 3 : Créer Resources Bunny

**Exemples** :
- `dns_zone` (service: bunny_main)
- `pull_zone` (service: bunny_main)
- `storage_zone` (service: bunny_main)
- `edge_script` (service: bunny_edge_scripting)
- `waf_profile` (service: bunny_shield)

**Fichiers** : `integrations/reference/resource/resource_bunny_*.surql`

#### Phase 4 : Créer Tools Bunny

**Extraction depuis JSON API** :
- `bunnynet-api-1.json` → Tools pour DNS Zone, Pull Zone, Storage Zone, etc.
- `edge-scripting-api.json` → Tools pour Edge Scripts
- `stream-api.json` → Tools pour Video
- `bunnynet-edge-storage-api.json` → Tools pour Edge Storage
- `bunny-shield-api.json` → Tools pour WAF, Rate Limiting, DDoS

**Fichiers** : `integrations/reference/tool/tool_bunny_*.surql`

**Processus** :
1. Parser les JSON OpenAPI
2. Extraire les endpoints (`operationId`, `method`, `path`, `parameters`)
3. Générer les seeds avec scripts Python
4. Créer les i18n keys et traductions

#### Phase 5 : Créer Parameters Bunny

**Extraction depuis JSON API** :
- Parser `parameters` de chaque endpoint
- Créer les seeds avec validations
- Générer les i18n keys

**Fichiers** : `integrations/reference/parameter/parameter_bunny_*.surql`

#### Phase 6 : Créer Error Mapping Bunny

**Extraction depuis documentation Bunny** :
- Messages d'erreur standards
- Codes HTTP avec messages traduits
- Solutions recommandées

**Fichier** : `integrations/reference/error_mapping/error_mapping_bunny_*.surql`

---

## 📈 Plan d'Action Recommandé

### Étape 1 : Préparer l'Infrastructure (2-3 jours)

1. ✅ Créer `user_service_credential` et `integration_log`
2. ✅ Tester `fn::execute_tool` avec un service existant (ex: Slack)
3. ✅ Documenter le processus d'extraction depuis JSON API

### Étape 2 : Créer Provider Bunny (1 jour)

1. ✅ Créer `provider:bunny`
2. ✅ Créer i18n keys (FR, EN)
3. ✅ Créer logos (light/dark)

### Étape 3 : Créer Services Bunny (1 jour)

1. ✅ Créer 5 services (main, edge_scripting, stream, edge_storage, shield)
2. ✅ Créer i18n keys
3. ✅ Configurer URLs API

### Étape 4 : Créer Resources Bunny (2-3 jours)

1. ✅ Identifier toutes les resources depuis les JSON
2. ✅ Créer les seeds
3. ✅ Créer les i18n keys

### Étape 5 : Créer Tools Bunny (5-7 jours)

1. ✅ Parser les 5 JSON OpenAPI
2. ✅ Extraire tous les endpoints
3. ✅ Générer les seeds avec scripts Python
4. ✅ Créer les i18n keys

### Étape 6 : Créer Parameters Bunny (5-7 jours)

1. ✅ Extraire parameters depuis JSON
2. ✅ Créer les seeds avec validations
3. ✅ Créer les i18n keys

### Étape 7 : Créer Error Mapping Bunny (1-2 jours)

1. ✅ Documenter les erreurs Bunny standards
2. ✅ Créer les seeds
3. ✅ Créer les i18n keys

**Total estimé** : 17-24 jours de travail

---

## ✅ Checklist Pré-Intégration Bunny

- [ ] Créer `user_service_credential` et `integration_log`
- [ ] Tester `fn::execute_tool` avec un service existant
- [ ] Créer scripts Python pour extraction depuis JSON OpenAPI
- [ ] Documenter le processus d'extraction
- [ ] Créer `provider:bunny`
- [ ] Créer les 5 services Bunny
- [ ] Parser les 5 JSON OpenAPI
- [ ] Créer les resources Bunny
- [ ] Créer les tools Bunny
- [ ] Créer les parameters Bunny
- [ ] Créer l'error mapping Bunny

---

## 🎓 Conclusion

**État actuel** : Module integrations **très mature** (83% complété)

**Points forts** :
- ✅ Structure complète et bien organisée
- ✅ Patterns Lyxal appliqués à 100%
- ✅ Fonction générique `fn::execute_tool` opérationnelle
- ✅ Extraction depuis n8n documentée et automatisée
- ✅ i18n complète (5 langues)

**Points d'amélioration** :
- ⚠️ Créer `user_service_credential` et `integration_log`
- ⚠️ Implémenter `response_mapping` (schéma + seeds manuels)
- ⚠️ Compléter `webhook_config` avec DEFINE API

**Prêt pour Bunny** : ✅ Oui, avec création des tables manquantes et extraction depuis JSON API.

---

**Date de mise à jour** : 2025-01-27  
**Prochaines étapes** : Créer Provider Bunny et extraire les endpoints depuis les JSON API

