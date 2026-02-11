-- ============================================================================
-- BUNNY MAGIC CONTAINERS - Gestion des Applications Déployées
-- ============================================================================
-- Description : Tables pour gérer Magic Containers (apps, déploiements)
-- Version     : 1.0.0
-- Date        : 2025-01-24
-- ============================================================================

-- ============================================================================
-- TABLE : bunny_container
-- ============================================================================
-- Description : Applications déployées sur Magic Containers
-- ============================================================================

DEFINE TABLE IF NOT EXISTS bunny_container SCHEMAFULL
  COMMENT 'Applications Magic Containers';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS bunny_id ON bunny_container
  TYPE string
  COMMENT 'ID Bunny.net du container';

DEFINE FIELD IF NOT EXISTS name ON bunny_container
  TYPE string
  ASSERT $value != NONE AND string::len($value) > 0
  COMMENT 'Nom du container (ex: lyxal-mail-worker)';

DEFINE FIELD IF NOT EXISTS description ON bunny_container
  TYPE option<string>
  COMMENT 'Description du service';

DEFINE FIELD IF NOT EXISTS service_type ON bunny_container
  TYPE string
  ASSERT $value INSIDE ['mail_worker', 'image_processor', 'pdf_generator', 'analytics', 'backup', 'webhooks', 'icons_uploader', 'custom']
  COMMENT 'Type de service';

-- Docker Image

DEFINE FIELD IF NOT EXISTS image ON bunny_container
  TYPE object
  COMMENT 'Configuration Docker image';

DEFINE FIELD IF NOT EXISTS image.repository ON bunny_container
  TYPE string
  COMMENT 'Repository (ex: lyxal/mail-worker)';

DEFINE FIELD IF NOT EXISTS image.tag ON bunny_container
  TYPE string
  DEFAULT 'latest'
  COMMENT 'Tag de l\'image (ex: latest, v1.2.3)';

DEFINE FIELD IF NOT EXISTS image.registry ON bunny_container
  TYPE string
  DEFAULT 'docker.io'
  COMMENT 'Registry (docker.io, ghcr.io, etc.)';

DEFINE FIELD IF NOT EXISTS image.sha256 ON bunny_container
  TYPE option<string>
  COMMENT 'SHA256 de l\'image déployée';

-- Configuration réseau

DEFINE FIELD IF NOT EXISTS network ON bunny_container
  TYPE object
  COMMENT 'Configuration réseau';

DEFINE FIELD IF NOT EXISTS network.port ON bunny_container
  TYPE int
  DEFAULT 3000
  COMMENT 'Port exposé';

DEFINE FIELD IF NOT EXISTS network.protocol ON bunny_container
  TYPE string
  ASSERT $value INSIDE ['http', 'https', 'tcp', 'udp']
  DEFAULT 'http'
  COMMENT 'Protocole';

DEFINE FIELD IF NOT EXISTS network.hostname ON bunny_container
  TYPE string
  COMMENT 'Hostname (ex: lyxal-mail.b-cdn.net)';

DEFINE FIELD IF NOT EXISTS network.custom_domains ON bunny_container
  TYPE option<array<string>>
  COMMENT 'Domaines customs';

DEFINE FIELD IF NOT EXISTS network.anycast_ip ON bunny_container
  TYPE option<string>
  COMMENT 'IP Anycast (si activé)';

-- Ressources

DEFINE FIELD IF NOT EXISTS resources ON bunny_container
  TYPE object
  COMMENT 'Allocation ressources';

DEFINE FIELD IF NOT EXISTS resources.cpu_min ON bunny_container
  TYPE float
  DEFAULT 0.1
  COMMENT 'CPU minimum (vCPU)';

DEFINE FIELD IF NOT EXISTS resources.cpu_max ON bunny_container
  TYPE float
  DEFAULT 2.0
  COMMENT 'CPU maximum (vCPU)';

DEFINE FIELD IF NOT EXISTS resources.ram_min ON bunny_container
  TYPE int
  DEFAULT 128
  COMMENT 'RAM minimum (MB)';

DEFINE FIELD IF NOT EXISTS resources.ram_max ON bunny_container
  TYPE int
  DEFAULT 2048
  COMMENT 'RAM maximum (MB)';

DEFINE FIELD IF NOT EXISTS resources.storage_gb ON bunny_container
  TYPE float
  DEFAULT 1.0
  COMMENT 'Storage éphémère (GB)';

-- Usage actuel

DEFINE FIELD IF NOT EXISTS resources.cpu_usage_current ON bunny_container
  TYPE option<float>
  COMMENT 'Usage CPU actuel (%)';

DEFINE FIELD IF NOT EXISTS resources.ram_usage_current ON bunny_container
  TYPE option<float>
  COMMENT 'Usage RAM actuel (%)';

-- Auto-Scaling

DEFINE FIELD IF NOT EXISTS scaling ON bunny_container
  TYPE object
  COMMENT 'Configuration auto-scaling';

DEFINE FIELD IF NOT EXISTS scaling.enabled ON bunny_container
  TYPE bool
  DEFAULT true
  COMMENT 'Auto-scaling activé';

DEFINE FIELD IF NOT EXISTS scaling.min_pods ON bunny_container
  TYPE int
  DEFAULT 1
  COMMENT 'Nombre minimum de pods';

DEFINE FIELD IF NOT EXISTS scaling.max_pods ON bunny_container
  TYPE int
  DEFAULT 10
  COMMENT 'Nombre maximum de pods';

DEFINE FIELD IF NOT EXISTS scaling.current_pods ON bunny_container
  TYPE int
  DEFAULT 1
  COMMENT 'Nombre actuel de pods';

DEFINE FIELD IF NOT EXISTS scaling.target_cpu ON bunny_container
  TYPE int
  DEFAULT 70
  COMMENT 'Target CPU pour scaling (%)';

-- Régions

DEFINE FIELD IF NOT EXISTS regions ON bunny_container
  TYPE object
  COMMENT 'Configuration régions';

DEFINE FIELD IF NOT EXISTS regions.auto ON bunny_container
  TYPE bool
  DEFAULT true
  COMMENT 'Sélection automatique par AI';

DEFINE FIELD IF NOT EXISTS regions.active ON bunny_container
  TYPE array<string>
  COMMENT 'Régions actives (codes)';

DEFINE FIELD IF NOT EXISTS regions.preferred ON bunny_container
  TYPE option<array<string>>
  COMMENT 'Régions préférées (ex: ["paris", "new-york"])';

-- Variables d'environnement

DEFINE FIELD IF NOT EXISTS environment ON bunny_container
  TYPE option<array<object>>
  COMMENT 'Variables d\'environnement';

-- Exemple :
-- [
--   {
--     "name": "SURREALDB_URL",
--     "value": "wss://cloud.surrealdb.com:443/rpc",
--     "secret": false
--   },
--   {
--     "name": "SMTP_PASSWORD",
--     "value": "encrypted_value_here",
--     "secret": true
--   }
-- ]

-- Health Check

DEFINE FIELD IF NOT EXISTS health ON bunny_container
  TYPE object
  COMMENT 'Configuration health check';

DEFINE FIELD IF NOT EXISTS health.endpoint ON bunny_container
  TYPE string
  DEFAULT '/health'
  COMMENT 'Endpoint health check';

DEFINE FIELD IF NOT EXISTS health.interval ON bunny_container
  TYPE int
  DEFAULT 30
  COMMENT 'Intervalle (secondes)';

DEFINE FIELD IF NOT EXISTS health.timeout ON bunny_container
  TYPE int
  DEFAULT 5
  COMMENT 'Timeout (secondes)';

DEFINE FIELD IF NOT EXISTS health.unhealthy_threshold ON bunny_container
  TYPE int
  DEFAULT 3
  COMMENT 'Seuil unhealthy';

DEFINE FIELD IF NOT EXISTS health.status ON bunny_container
  TYPE string
  ASSERT $value INSIDE ['healthy', 'unhealthy', 'unknown']
  DEFAULT 'unknown'
  COMMENT 'Statut actuel';

DEFINE FIELD IF NOT EXISTS health.last_check ON bunny_container
  TYPE option<datetime>
  COMMENT 'Dernier health check';

-- Usage et coûts

DEFINE FIELD IF NOT EXISTS usage ON bunny_container
  TYPE object
  COMMENT 'Statistiques d\'usage';

DEFINE FIELD IF NOT EXISTS usage.requests_month ON bunny_container
  TYPE int
  DEFAULT 0
  COMMENT 'Requêtes du mois';

DEFINE FIELD IF NOT EXISTS usage.cpu_hours_month ON bunny_container
  TYPE float
  DEFAULT 0.0
  COMMENT 'vCPU heures du mois';

DEFINE FIELD IF NOT EXISTS usage.ram_gb_hours_month ON bunny_container
  TYPE float
  DEFAULT 0.0
  COMMENT 'RAM GB-heures du mois';

DEFINE FIELD IF NOT EXISTS usage.bandwidth_gb_month ON bunny_container
  TYPE float
  DEFAULT 0.0
  COMMENT 'Bandwidth du mois (GB)';

DEFINE FIELD IF NOT EXISTS usage.last_sync ON bunny_container
  TYPE datetime
  COMMENT 'Dernière synchro usage';

-- Coût estimé

DEFINE FIELD IF NOT EXISTS cost_estimate ON bunny_container
  TYPE object
  COMMENT 'Estimation coûts mensuels';

DEFINE FIELD IF NOT EXISTS cost_estimate.cpu_cost ON bunny_container
  TYPE float
  COMMENT 'Coût CPU ($)';

DEFINE FIELD IF NOT EXISTS cost_estimate.ram_cost ON bunny_container
  TYPE float
  COMMENT 'Coût RAM ($)';

DEFINE FIELD IF NOT EXISTS cost_estimate.storage_cost ON bunny_container
  TYPE float
  COMMENT 'Coût storage ($)';

DEFINE FIELD IF NOT EXISTS cost_estimate.bandwidth_cost ON bunny_container
  TYPE float
  COMMENT 'Coût bandwidth ($)';

DEFINE FIELD IF NOT EXISTS cost_estimate.total_month ON bunny_container
  TYPE float
  COMMENT 'Coût total du mois ($)';

-- Relations

DEFINE FIELD IF NOT EXISTS tenant ON bunny_container
  TYPE option<record<tenant>>
  COMMENT 'Tenant propriétaire';

-- Métadonnées

DEFINE FIELD IF NOT EXISTS metadata ON bunny_container
  TYPE object
  COMMENT 'Métadonnées de traçabilité';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON bunny_container
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON bunny_container
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Dernière mise à jour';

DEFINE FIELD IF NOT EXISTS metadata.deployed_at ON bunny_container
  TYPE option<datetime>
  COMMENT 'Date de déploiement';

DEFINE FIELD IF NOT EXISTS metadata.deployed_by ON bunny_container
  TYPE option<record<identity>>
  COMMENT 'Déployé par (user)';

DEFINE FIELD IF NOT EXISTS metadata.status ON bunny_container
  TYPE string
  ASSERT $value INSIDE ['running', 'stopped', 'failed', 'deploying']
  DEFAULT 'stopped'
  COMMENT 'Statut du container';

-- Index

DEFINE INDEX IF NOT EXISTS bunny_id_unique ON bunny_container
  FIELDS bunny_id UNIQUE;

DEFINE INDEX IF NOT EXISTS name_idx ON bunny_container
  FIELDS name;

DEFINE INDEX IF NOT EXISTS service_type_idx ON bunny_container
  FIELDS service_type;

DEFINE INDEX IF NOT EXISTS tenant_idx ON bunny_container
  FIELDS tenant;

DEFINE INDEX IF NOT EXISTS status_idx ON bunny_container
  FIELDS metadata.status;

DEFINE INDEX IF NOT EXISTS health_idx ON bunny_container
  FIELDS health.status;


-- ============================================================================
-- TABLE : bunny_container_deployment
-- ============================================================================
-- Description : Historique des déploiements
-- ============================================================================

DEFINE TABLE IF NOT EXISTS bunny_container_deployment SCHEMAFULL
  COMMENT 'Historique déploiements containers';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS container ON bunny_container_deployment
  TYPE record<bunny_container>
  ASSERT $value != NONE
  COMMENT 'Container déployé';

DEFINE FIELD IF NOT EXISTS version ON bunny_container_deployment
  TYPE string
  COMMENT 'Version déployée (tag ou SHA)';

DEFINE FIELD IF NOT EXISTS image_full ON bunny_container_deployment
  TYPE string
  COMMENT 'Image complète (ex: lyxal/mail:v1.2.3)';

-- Changements

DEFINE FIELD IF NOT EXISTS changes ON bunny_container_deployment
  TYPE option<object>
  COMMENT 'Changements de config';

DEFINE FIELD IF NOT EXISTS changes.environment ON bunny_container_deployment
  TYPE option<array<string>>
  COMMENT 'Env vars modifiées';

DEFINE FIELD IF NOT EXISTS changes.resources ON bunny_container_deployment
  TYPE option<bool>
  COMMENT 'Ressources modifiées';

DEFINE FIELD IF NOT EXISTS changes.regions ON bunny_container_deployment
  TYPE option<bool>
  COMMENT 'Régions modifiées';

-- Résultat

DEFINE FIELD IF NOT EXISTS status ON bunny_container_deployment
  TYPE string
  ASSERT $value INSIDE ['pending', 'deploying', 'success', 'failed', 'rolled_back']
  DEFAULT 'pending'
  COMMENT 'Statut du déploiement';

DEFINE FIELD IF NOT EXISTS error_message ON bunny_container_deployment
  TYPE option<string>
  COMMENT 'Message d\'erreur (si failed)';

DEFINE FIELD IF NOT EXISTS rollback_from ON bunny_container_deployment
  TYPE option<record<bunny_container_deployment>>
  COMMENT 'Rollback depuis ce déploiement';

-- Métadonnées

DEFINE FIELD IF NOT EXISTS metadata ON bunny_container_deployment
  TYPE object
  COMMENT 'Métadonnées';

DEFINE FIELD IF NOT EXISTS metadata.started_at ON bunny_container_deployment
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de début';

DEFINE FIELD IF NOT EXISTS metadata.completed_at ON bunny_container_deployment
  TYPE option<datetime>
  COMMENT 'Date de fin';

DEFINE FIELD IF NOT EXISTS metadata.duration_seconds ON bunny_container_deployment
  TYPE option<int>
  COMMENT 'Durée (secondes)';

DEFINE FIELD IF NOT EXISTS metadata.deployed_by ON bunny_container_deployment
  TYPE option<record<identity>>
  COMMENT 'Déployé par (user)';

DEFINE FIELD IF NOT EXISTS metadata.ci_cd ON bunny_container_deployment
  TYPE option<object>
  COMMENT 'Info CI/CD';

DEFINE FIELD IF NOT EXISTS metadata.ci_cd.provider ON bunny_container_deployment
  TYPE option<string>
  COMMENT 'Provider (github_actions, gitlab_ci, etc.)';

DEFINE FIELD IF NOT EXISTS metadata.ci_cd.commit_sha ON bunny_container_deployment
  TYPE option<string>
  COMMENT 'SHA du commit';

DEFINE FIELD IF NOT EXISTS metadata.ci_cd.branch ON bunny_container_deployment
  TYPE option<string>
  COMMENT 'Branche Git';

-- Index

DEFINE INDEX IF NOT EXISTS container_idx ON bunny_container_deployment
  FIELDS container;

DEFINE INDEX IF NOT EXISTS status_idx ON bunny_container_deployment
  FIELDS status;

DEFINE INDEX IF NOT EXISTS started_at_idx ON bunny_container_deployment
  FIELDS metadata.started_at;

