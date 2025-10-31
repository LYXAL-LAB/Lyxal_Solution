-- ============================================================================
-- INFRASTRUCTURE LOGS - Audit Trail et Monitoring
-- ============================================================================
-- Description : Logs et audit trail de toutes les actions infrastructure
-- Version     : 1.0.0
-- Date        : 2025-01-24
-- ============================================================================

-- ============================================================================
-- TABLE : infrastructure_log
-- ============================================================================
-- Description : Audit log de toutes les actions infrastructure
-- ============================================================================

DEFINE TABLE IF NOT EXISTS infrastructure_log SCHEMAFULL
  COMMENT 'Audit log infrastructure';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS action ON infrastructure_log
  TYPE string
  ASSERT $value != NONE
  COMMENT 'Action effectuée';

-- Actions possibles :
-- Storage : storage_zone_create, storage_zone_update, storage_zone_delete, file_upload, file_delete
-- CDN : cdn_zone_create, cdn_zone_update, cdn_zone_delete, cdn_purge
-- Containers : container_create, container_deploy, container_update, container_delete, container_restart
-- DNS : dns_zone_create, dns_zone_update, dns_zone_delete, dns_record_create, dns_record_update, dns_record_delete

DEFINE FIELD IF NOT EXISTS resource_type ON infrastructure_log
  TYPE string
  ASSERT $value INSIDE ['storage_zone', 'storage_file', 'cdn_zone', 'container', 'dns_zone', 'dns_record']
  COMMENT 'Type de ressource';

DEFINE FIELD IF NOT EXISTS resource_id ON infrastructure_log
  TYPE string
  COMMENT 'ID de la ressource (record ID SurrealDB)';

DEFINE FIELD IF NOT EXISTS resource_name ON infrastructure_log
  TYPE string
  COMMENT 'Nom de la ressource';

-- Détails de l'action

DEFINE FIELD IF NOT EXISTS details ON infrastructure_log
  TYPE object
  COMMENT 'Détails de l\'action';

DEFINE FIELD IF NOT EXISTS details.before ON infrastructure_log
  TYPE option<object>
  COMMENT 'État avant (pour update/delete)';

DEFINE FIELD IF NOT EXISTS details.after ON infrastructure_log
  TYPE option<object>
  COMMENT 'État après (pour create/update)';

DEFINE FIELD IF NOT EXISTS details.diff ON infrastructure_log
  TYPE option<array<object>>
  COMMENT 'Différences (champs modifiés)';

-- Exemple diff :
-- [
--   {
--     "field": "resources.cpu_max",
--     "old": 1.0,
--     "new": 2.0
--   }
-- ]

DEFINE FIELD IF NOT EXISTS details.parameters ON infrastructure_log
  TYPE option<object>
  COMMENT 'Paramètres de l\'action';

-- Résultat

DEFINE FIELD IF NOT EXISTS status ON infrastructure_log
  TYPE string
  ASSERT $value INSIDE ['success', 'failed', 'partial']
  COMMENT 'Statut de l\'action';

DEFINE FIELD IF NOT EXISTS error_message ON infrastructure_log
  TYPE option<string>
  COMMENT 'Message d\'erreur (si failed)';

DEFINE FIELD IF NOT EXISTS error_code ON infrastructure_log
  TYPE option<string>
  COMMENT 'Code d\'erreur';

-- Bunny API

DEFINE FIELD IF NOT EXISTS bunny_api ON infrastructure_log
  TYPE option<object>
  COMMENT 'Info sur l\'appel API Bunny';

DEFINE FIELD IF NOT EXISTS bunny_api.endpoint ON infrastructure_log
  TYPE option<string>
  COMMENT 'Endpoint API appelé';

DEFINE FIELD IF NOT EXISTS bunny_api.method ON infrastructure_log
  TYPE option<string>
  COMMENT 'Méthode HTTP (GET, POST, PUT, DELETE)';

DEFINE FIELD IF NOT EXISTS bunny_api.status_code ON infrastructure_log
  TYPE option<int>
  COMMENT 'Code HTTP retourné';

DEFINE FIELD IF NOT EXISTS bunny_api.response_time_ms ON infrastructure_log
  TYPE option<int>
  COMMENT 'Temps de réponse (ms)';

-- Contexte utilisateur

DEFINE FIELD IF NOT EXISTS user ON infrastructure_log
  TYPE option<record<identity>>
  COMMENT 'Utilisateur ayant effectué l\'action';

DEFINE FIELD IF NOT EXISTS tenant ON infrastructure_log
  TYPE option<record<tenant>>
  COMMENT 'Tenant concerné';

DEFINE FIELD IF NOT EXISTS ip_address ON infrastructure_log
  TYPE option<string>
  COMMENT 'Adresse IP de l\'utilisateur';

DEFINE FIELD IF NOT EXISTS user_agent ON infrastructure_log
  TYPE option<string>
  COMMENT 'User agent';

-- Contexte CI/CD

DEFINE FIELD IF NOT EXISTS ci_cd ON infrastructure_log
  TYPE option<object>
  COMMENT 'Info CI/CD (si action via pipeline)';

DEFINE FIELD IF NOT EXISTS ci_cd.provider ON infrastructure_log
  TYPE option<string>
  COMMENT 'Provider (github_actions, gitlab_ci, etc.)';

DEFINE FIELD IF NOT EXISTS ci_cd.workflow ON infrastructure_log
  TYPE option<string>
  COMMENT 'Nom du workflow';

DEFINE FIELD IF NOT EXISTS ci_cd.commit_sha ON infrastructure_log
  TYPE option<string>
  COMMENT 'SHA du commit';

DEFINE FIELD IF NOT EXISTS ci_cd.branch ON infrastructure_log
  TYPE option<string>
  COMMENT 'Branche Git';

DEFINE FIELD IF NOT EXISTS ci_cd.run_id ON infrastructure_log
  TYPE option<string>
  COMMENT 'ID du run CI/CD';

-- Métadonnées

DEFINE FIELD IF NOT EXISTS metadata ON infrastructure_log
  TYPE object
  COMMENT 'Métadonnées';

DEFINE FIELD IF NOT EXISTS metadata.timestamp ON infrastructure_log
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Timestamp de l\'action';

DEFINE FIELD IF NOT EXISTS metadata.duration_ms ON infrastructure_log
  TYPE option<int>
  COMMENT 'Durée de l\'action (ms)';

DEFINE FIELD IF NOT EXISTS metadata.trace_id ON infrastructure_log
  TYPE option<string>
  COMMENT 'Trace ID (pour correlation)';

-- Index

DEFINE INDEX IF NOT EXISTS timestamp_idx ON infrastructure_log
  FIELDS metadata.timestamp;

DEFINE INDEX IF NOT EXISTS action_idx ON infrastructure_log
  FIELDS action;

DEFINE INDEX IF NOT EXISTS resource_type_idx ON infrastructure_log
  FIELDS resource_type;

DEFINE INDEX IF NOT EXISTS resource_id_idx ON infrastructure_log
  FIELDS resource_id;

DEFINE INDEX IF NOT EXISTS user_idx ON infrastructure_log
  FIELDS user;

DEFINE INDEX IF NOT EXISTS tenant_idx ON infrastructure_log
  FIELDS tenant;

DEFINE INDEX IF NOT EXISTS status_idx ON infrastructure_log
  FIELDS status;

DEFINE INDEX IF NOT EXISTS trace_id_idx ON infrastructure_log
  FIELDS metadata.trace_id;


-- ============================================================================
-- TABLE : infrastructure_metric
-- ============================================================================
-- Description : Métriques temps réel de l'infrastructure
-- ============================================================================

DEFINE TABLE IF NOT EXISTS infrastructure_metric SCHEMAFULL
  COMMENT 'Métriques infrastructure';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS resource_type ON infrastructure_metric
  TYPE string
  ASSERT $value INSIDE ['storage_zone', 'cdn_zone', 'container', 'dns_zone', 'global']
  COMMENT 'Type de ressource';

DEFINE FIELD IF NOT EXISTS resource_id ON infrastructure_metric
  TYPE option<string>
  COMMENT 'ID de la ressource (null = global)';

DEFINE FIELD IF NOT EXISTS metric_name ON infrastructure_metric
  TYPE string
  COMMENT 'Nom de la métrique';

-- Métriques possibles :
-- Storage : storage_used_gb, files_count, bandwidth_gb
-- CDN : bandwidth_gb, requests_count, cache_hit_rate
-- Container : cpu_usage_percent, ram_usage_percent, requests_count, error_rate
-- DNS : queries_count, response_time_ms
-- Global : total_cost_usd, total_bandwidth_gb

DEFINE FIELD IF NOT EXISTS value ON infrastructure_metric
  TYPE float
  COMMENT 'Valeur de la métrique';

DEFINE FIELD IF NOT EXISTS unit ON infrastructure_metric
  TYPE string
  COMMENT 'Unité (gb, percent, count, ms, usd)';

-- Dimensions

DEFINE FIELD IF NOT EXISTS dimensions ON infrastructure_metric
  TYPE option<object>
  COMMENT 'Dimensions additionnelles';

-- Exemple :
-- {
--   "region": "paris",
--   "pod_id": "pod-123",
--   "status_code": 200
-- }

-- Timestamp

DEFINE FIELD IF NOT EXISTS timestamp ON infrastructure_metric
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Timestamp de la métrique';

DEFINE FIELD IF NOT EXISTS interval ON infrastructure_metric
  TYPE string
  ASSERT $value INSIDE ['1m', '5m', '15m', '1h', '6h', '24h']
  DEFAULT '5m'
  COMMENT 'Intervalle d\'agrégation';

-- Index

DEFINE INDEX IF NOT EXISTS timestamp_idx ON infrastructure_metric
  FIELDS timestamp;

DEFINE INDEX IF NOT EXISTS resource_metric_idx ON infrastructure_metric
  FIELDS resource_type, resource_id, metric_name, timestamp;

DEFINE INDEX IF NOT EXISTS metric_name_idx ON infrastructure_metric
  FIELDS metric_name;


-- ============================================================================
-- TABLE : infrastructure_alert
-- ============================================================================
-- Description : Alertes sur l'infrastructure
-- ============================================================================

DEFINE TABLE IF NOT EXISTS infrastructure_alert SCHEMAFULL
  COMMENT 'Alertes infrastructure';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS alert_type ON infrastructure_alert
  TYPE string
  ASSERT $value INSIDE ['cost_threshold', 'high_cpu', 'high_ram', 'high_error_rate', 'container_down', 'dns_failure', 'cdn_error', 'storage_quota']
  COMMENT 'Type d\'alerte';

DEFINE FIELD IF NOT EXISTS severity ON infrastructure_alert
  TYPE string
  ASSERT $value INSIDE ['info', 'warning', 'error', 'critical']
  COMMENT 'Sévérité';

DEFINE FIELD IF NOT EXISTS title ON infrastructure_alert
  TYPE string
  COMMENT 'Titre de l\'alerte';

DEFINE FIELD IF NOT EXISTS message ON infrastructure_alert
  TYPE string
  COMMENT 'Message détaillé';

-- Ressource concernée

DEFINE FIELD IF NOT EXISTS resource_type ON infrastructure_alert
  TYPE string
  COMMENT 'Type de ressource';

DEFINE FIELD IF NOT EXISTS resource_id ON infrastructure_alert
  TYPE option<string>
  COMMENT 'ID de la ressource';

DEFINE FIELD IF NOT EXISTS resource_name ON infrastructure_alert
  TYPE option<string>
  COMMENT 'Nom de la ressource';

-- Contexte

DEFINE FIELD IF NOT EXISTS context ON infrastructure_alert
  TYPE option<object>
  COMMENT 'Contexte de l\'alerte';

-- Exemple :
-- {
--   "current_value": 95.5,
--   "threshold": 80,
--   "metric": "cpu_usage_percent"
-- }

-- Statut

DEFINE FIELD IF NOT EXISTS status ON infrastructure_alert
  TYPE string
  ASSERT $value INSIDE ['open', 'acknowledged', 'resolved', 'ignored']
  DEFAULT 'open'
  COMMENT 'Statut de l\'alerte';

DEFINE FIELD IF NOT EXISTS acknowledged_by ON infrastructure_alert
  TYPE option<record<identity>>
  COMMENT 'Acknowledge par (user)';

DEFINE FIELD IF NOT EXISTS acknowledged_at ON infrastructure_alert
  TYPE option<datetime>
  COMMENT 'Date d\'acknowledgement';

DEFINE FIELD IF NOT EXISTS resolved_at ON infrastructure_alert
  TYPE option<datetime>
  COMMENT 'Date de résolution';

-- Notifications

DEFINE FIELD IF NOT EXISTS notifications_sent ON infrastructure_alert
  TYPE array<object>
  COMMENT 'Notifications envoyées';

-- Exemple :
-- [
--   {
--     "channel": "email",
--     "recipient": "admin@lyxal.com",
--     "sent_at": "2025-01-24T10:30:00Z",
--     "status": "sent"
--   }
-- ]

-- Métadonnées

DEFINE FIELD IF NOT EXISTS metadata ON infrastructure_alert
  TYPE object
  COMMENT 'Métadonnées';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON infrastructure_alert
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON infrastructure_alert
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Dernière mise à jour';

-- Index

DEFINE INDEX IF NOT EXISTS created_at_idx ON infrastructure_alert
  FIELDS metadata.created_at;

DEFINE INDEX IF NOT EXISTS alert_type_idx ON infrastructure_alert
  FIELDS alert_type;

DEFINE INDEX IF NOT EXISTS severity_idx ON infrastructure_alert
  FIELDS severity;

DEFINE INDEX IF NOT EXISTS status_idx ON infrastructure_alert
  FIELDS status;

DEFINE INDEX IF NOT EXISTS resource_idx ON infrastructure_alert
  FIELDS resource_type, resource_id;

