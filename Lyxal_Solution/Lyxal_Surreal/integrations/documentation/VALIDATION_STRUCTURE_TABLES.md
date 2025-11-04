# 📋 Validation Structure Tables - Module Integrations

**Date** : 2025-01-27  
**Objectif** : Valider ensemble la structure complète des tables avant création/intégration Bunny

---

## ✅ Tables EXISTANTES (8 tables)

### 1. **provider** ✅
**Fichier** : `integrations/database/provider/provider.surql`  
**Statut** : ✅ Complète et conforme Lyxal

**Structure** :
- `identity` : name, slug, display_name_i18n, description_i18n
- `presentation` : logo_light, logo_dark, color, color_daisy, display_order, tooltip_i18n
- `config` : urls (website, documentation, api_base, status_page), capabilities (supports_oauth2, supports_api_key, supports_basic_auth, supports_webhooks, supports_rate_limiting), api_version
- `metadata` : founded_year, headquarters, industry, company_size, stock_symbol, tags
- `documentation` : getting_started_url, api_reference_url, sdk_urls, community_url
- `etag`, `created_at`, `updated_at`
- `is_active`

**Index** : name (unique), slug (unique), is_active

---

### 2. **service** ✅
**Fichier** : `integrations/database/service/service.surql`  
**Statut** : ✅ Complète et conforme Lyxal

**Structure** :
- `identity` : name, slug, display_name_i18n, description_i18n, aliases
- `presentation` : icon, color, display_order, category_slug, tooltip_i18n, badge_text, badge_color
- `config` : version (current, is_default_version, supported_versions), capabilities (is_trigger, is_polling, is_webhook, is_action, supports_batch), api (base_url, version, protocol), rate_limits
- `documentation` : main_url, api_reference_url, credential_setup_url, video_tutorial_url, changelog_url
- `metadata` : tags, popularity_score, last_updated_by, custom_data
- `provider_id` : record<provider>
- `category_id` : option<record<category>>
- `is_active`
- `ETag`, `created_at`, `updated_at`

**Index** : slug (unique), name, provider_id, is_active, category_slug

---

### 3. **resource** ✅
**Fichier** : `integrations/database/resource/resource.surql`  
**Statut** : ✅ Complète et conforme Lyxal

**Structure** :
- `identity` : name, slug, display_name_i18n, description_i18n, aliases
- `presentation` : icon, color, display_order, tooltip_i18n, badge_text, badge_color
- `config` : operation_types (supports_create, supports_read, supports_update, supports_delete, supports_list, supports_search), capabilities (supports_bulk_operations, supports_pagination, supports_filtering, supports_sorting, requires_authentication, is_real_time), api (base_path, id_field, list_endpoint)
- `documentation` : main_url, examples_url, video_tutorial_url, common_use_cases
- `metadata` : common_fields, relationships, popularity_score, custom_data
- `service_id` : record<service>
- `is_active`
- `ETag`, `created_at`, `updated_at`

**Index** : slug + service_id (unique), name, service_id, is_active

---

### 4. **tool** ✅
**Fichier** : `integrations/database/tool/tool.surql`  
**Statut** : ✅ Complète et conforme Lyxal

**Structure** :
- `identity` : name, slug, display_name_i18n, description_i18n, operation_type, aliases
- `presentation` : icon, color, display_order, tooltip_i18n, badge_text, badge_color, success_message_i18n, error_message_i18n, confirmation_required, confirmation_message_i18n, estimated_duration, is_destructive
- `config` :
  - `request` : method, endpoint, body_template, headers_template, query_params_template, path_params, authentication_required
  - `response` : success_codes, data_path, pagination_path, transform
  - `capabilities` : supports_pagination, supports_filtering, supports_sorting, supports_batch, is_idempotent, requires_confirmation
  - `rate_limiting` : max_requests, period, burst_allowed
- `documentation` : main_url, examples_url, video_tutorial_url, common_use_cases, prerequisites
- `metadata` : usage_count, average_duration, success_rate, custom_data
- `resource_id` : record<resource>
- `is_active`
- `ETag`, `created_at`, `updated_at`

**Index** : slug + resource_id (unique), name, resource_id, operation_type, is_active

---

### 5. **parameter** ✅
**Fichier** : `integrations/database/parameter/parameter.surql`  
**Statut** : ✅ Complète et conforme Lyxal

**Structure** :
- `identity` : name, parameter_key, display_name_i18n, description_i18n
- `presentation` : icon, display_order, placeholder_i18n, help_text_i18n, error_message_i18n, is_sensitive, display_conditions
- `config` : parameter_type, sub_type, default_value, options, resource_locator_config
- `validation` : is_required, min_value, max_value, min_length, max_length, pattern, format, allowed_values
- `documentation` : examples, related_fields
- `metadata` : usage_count, custom_data
- `tool_id` : record<tool>
- `is_active`
- `ETag`, `created_at`, `updated_at`

**Index** : parameter_key + tool_id (unique), tool_id, is_active

---

### 6. **error_mapping** ✅
**Fichier** : `integrations/database/error_mapping/error_mapping.surql`  
**Statut** : ✅ Complète et conforme Lyxal

**Structure** :
- `identity` : http_code, error_code, error_category, service_id (optionnel), tool_id (optionnel)
- `presentation` : user_message_i18n, technical_message_i18n, severity, icon, color
- `config` : is_retryable, retry_after_seconds, max_retries, backoff_strategy, should_log, should_notify_admin
- `suggested_action` : action_message_i18n, action_type, help_url, support_contact
- `documentation` : description_i18n, common_causes, example_request, example_response
- `metadata` : created_at, updated_at, created_by, updated_by, version
- `is_active`

**Index** : http_code (unique), error_category, service_id, tool_id, is_active, service_id + http_code

---

### 7. **credentials** (4 tables) ✅
**Fichiers** :
- `integrations/database/credentials/auth_type.surql`
- `integrations/database/credentials/credential_type.surql`
- `integrations/database/credentials/transmission_method.surql`
- `integrations/database/credentials/uses_credential.surql`

**Statut** : ✅ Complètes et conformes Lyxal

---

## ❌ Tables MANQUANTES (4 tables)

### 8. **user_service_credential** ❌
**Fichier** : `integrations/database/credentials/user_service_credential.surql`  
**Statut** : ❌ À créer  
**Nécessaire pour** : `fn::execute_tool` (stockage credentials utilisateurs)

**Structure proposée** : Voir section détaillée ci-dessous

**Points à valider** :
- [ ] Structure des credentials (OAuth2, API Key, Basic Auth)
- [ ] Chiffrement des données sensibles (à gérer côté application)
- [ ] Gestion de l'expiration (automatique vs manuelle)
- [ ] Permissions (utilisateur peut-il voir/modifier ses propres credentials ?)

---

### 9. **integration_log** ❌
**Fichier** : `integrations/database/integration_log/integration_log.surql`  
**Statut** : ❌ À créer  
**Nécessaire pour** : `fn::execute_tool` (logs d'appels API)

**Structure proposée** : Voir section détaillée ci-dessous

**Points à valider** :
- [ ] Champs de request/response (suffisants ?)
- [ ] Gestion de la taille des logs (rotation ? archivage ?)
- [ ] Anonymisation des données sensibles (credentials, tokens)
- [ ] Permissions (utilisateur peut-il voir ses propres logs ?)

---

### 10. **response_mapping** ❌
**Fichier** : `integrations/database/response_mapping/response_mapping.surql`  
**Statut** : ❌ À créer  
**Nécessaire pour** : Transformation des réponses API (optionnel mais recommandé)

**Structure proposée** : Voir section détaillée ci-dessous

**Points à valider** :
- [ ] Types de mapping (suffisants ?)
- [ ] Structure des transformations (flexible ?)
- [ ] Gestion de la pagination (complète ?)

---

### 11. **webhook_config** ❌
**Fichier** : `integrations/database/webhook_config/webhook_config.surql`  
**Statut** : ❌ À créer  
**Nécessaire pour** : Configuration des webhooks avec DEFINE API SurrealDB

**Structure proposée** : Voir section détaillée ci-dessous

**Points à valider** :
- [ ] Structure external_config (complète ?)
- [ ] Structure surreal_api (correspond à DEFINE API ?)
- [ ] Gestion de la signature (flexible ?)

---

## 🔗 Relations Entre Tables

```
provider (1) ──→ (N) service
service (1) ──→ (N) resource
resource (1) ──→ (N) tool
tool (1) ──→ (N) parameter
tool (1) ──→ (1) response_mapping (optionnel)
service (1) ──→ (N) error_mapping
tool (1) ──→ (N) error_mapping (optionnel)
service (1) ──→ (N) webhook_config
user (1) ──→ (N) user_service_credential
service (1) ──→ (N) user_service_credential
credential_type (1) ──→ (N) user_service_credential
user (1) ──→ (N) integration_log
service (1) ──→ (N) integration_log
tool (1) ──→ (N) integration_log (optionnel)
```

---

## ✅ Checklist de Validation

### Tables Existantes
- [x] **provider** : Structure complète, conforme Lyxal
- [x] **service** : Structure complète, conforme Lyxal
- [x] **resource** : Structure complète, conforme Lyxal
- [x] **tool** : Structure complète, conforme Lyxal
- [x] **parameter** : Structure complète, conforme Lyxal
- [x] **error_mapping** : Structure complète, conforme Lyxal
- [x] **credentials** (4 tables) : Structures complètes, conformes Lyxal

### Tables à Créer
- [ ] **user_service_credential** : Structure proposée à valider
- [ ] **integration_log** : Structure proposée à valider
- [ ] **response_mapping** : Structure proposée à valider
- [ ] **webhook_config** : Structure proposée à valider

---

## 📝 Notes Importantes

1. **Chiffrement** : Les credentials sensibles doivent être chiffrés côté application avant stockage. SurrealDB ne chiffre pas automatiquement.

2. **ETag** : Toutes les tables utilisent `rand::uuid::v7()` pour optimistic locking et Live Queries.

3. **i18n** : Tous les textes affichables utilisent `record<i18n_key>` pour multilinguisme.

4. **Permissions** : Pattern standard :
   - SELECT : Utilisateur voit ses propres données + admins voient tout
   - CREATE/UPDATE/DELETE : Utilisateur modifie ses propres données + admins modifient tout

5. **Index** : Optimisés pour les requêtes fréquentes (user_id + timestamp, service_id + timestamp, etc.)

---

**Prochaine étape** : Valider ensemble les structures proposées avant création ! 🎯

