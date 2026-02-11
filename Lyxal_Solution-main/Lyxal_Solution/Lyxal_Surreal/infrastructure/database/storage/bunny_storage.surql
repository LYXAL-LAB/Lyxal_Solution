-- ============================================================================
-- BUNNY STORAGE - Gestion des Storage Zones et Fichiers
-- ============================================================================
-- Description : Tables pour gérer Bunny Storage (zones, fichiers, usage)
-- Version     : 1.0.0
-- Date        : 2025-01-24
-- ============================================================================

-- ============================================================================
-- TABLE : bunny_storage_zone
-- ============================================================================
-- Description : Configuration des Storage Zones Bunny
-- ============================================================================

DEFINE TABLE IF NOT EXISTS bunny_storage_zone SCHEMAFULL
  COMMENT 'Storage Zones Bunny.net';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS bunny_id ON bunny_storage_zone
  TYPE int
  COMMENT 'ID Bunny.net de la zone';

DEFINE FIELD IF NOT EXISTS name ON bunny_storage_zone
  TYPE string
  ASSERT $value != NONE AND string::len($value) > 0
  COMMENT 'Nom de la zone (ex: lyxal-production)';

DEFINE FIELD IF NOT EXISTS region ON bunny_storage_zone
  TYPE string
  ASSERT $value INSIDE ['EU', 'US', 'ASIA', 'OCEANIA', 'SA', 'AF']
  COMMENT 'Région géographique';

DEFINE FIELD IF NOT EXISTS replication ON bunny_storage_zone
  TYPE bool
  DEFAULT false
  COMMENT 'Réplication activée';

-- Configuration

DEFINE FIELD IF NOT EXISTS config ON bunny_storage_zone
  TYPE object
  COMMENT 'Configuration de la zone';

DEFINE FIELD IF NOT EXISTS config.api_key ON bunny_storage_zone
  TYPE string
  COMMENT 'API key pour accès (encryptée)';

DEFINE FIELD IF NOT EXISTS config.hostname ON bunny_storage_zone
  TYPE string
  COMMENT 'Hostname storage (ex: storage.bunnycdn.com)';

DEFINE FIELD IF NOT EXISTS config.cdn_url ON bunny_storage_zone
  TYPE string
  COMMENT 'URL CDN associée';

DEFINE FIELD IF NOT EXISTS config.custom_domain ON bunny_storage_zone
  TYPE option<string>
  COMMENT 'Domaine custom (ex: cdn.lyxal.com)';

-- Usage et coûts

DEFINE FIELD IF NOT EXISTS usage ON bunny_storage_zone
  TYPE object
  COMMENT 'Statistiques d\'usage';

DEFINE FIELD IF NOT EXISTS usage.storage_used_gb ON bunny_storage_zone
  TYPE float
  DEFAULT 0.0
  COMMENT 'Storage utilisé (GB)';

DEFINE FIELD IF NOT EXISTS usage.bandwidth_gb_month ON bunny_storage_zone
  TYPE float
  DEFAULT 0.0
  COMMENT 'Bandwidth du mois (GB)';

DEFINE FIELD IF NOT EXISTS usage.files_count ON bunny_storage_zone
  TYPE int
  DEFAULT 0
  COMMENT 'Nombre de fichiers';

DEFINE FIELD IF NOT EXISTS usage.last_sync ON bunny_storage_zone
  TYPE datetime
  COMMENT 'Dernière synchro usage';

-- Coût estimé

DEFINE FIELD IF NOT EXISTS cost_estimate ON bunny_storage_zone
  TYPE object
  COMMENT 'Estimation coûts mensuels';

DEFINE FIELD IF NOT EXISTS cost_estimate.storage_cost ON bunny_storage_zone
  TYPE float
  COMMENT 'Coût storage ($)';

DEFINE FIELD IF NOT EXISTS cost_estimate.bandwidth_cost ON bunny_storage_zone
  TYPE float
  COMMENT 'Coût bandwidth ($)';

DEFINE FIELD IF NOT EXISTS cost_estimate.total_month ON bunny_storage_zone
  TYPE float
  COMMENT 'Coût total du mois ($)';

-- Relations

DEFINE FIELD IF NOT EXISTS tenant ON bunny_storage_zone
  TYPE option<record<tenant>>
  COMMENT 'Tenant propriétaire (pour multi-tenant)';

-- Métadonnées

DEFINE FIELD IF NOT EXISTS metadata ON bunny_storage_zone
  TYPE object
  COMMENT 'Métadonnées de traçabilité';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON bunny_storage_zone
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON bunny_storage_zone
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Dernière mise à jour';

DEFINE FIELD IF NOT EXISTS metadata.created_by ON bunny_storage_zone
  TYPE option<record<identity>>
  COMMENT 'Créé par (user)';

DEFINE FIELD IF NOT EXISTS metadata.status ON bunny_storage_zone
  TYPE string
  ASSERT $value INSIDE ['active', 'suspended', 'deleted']
  DEFAULT 'active'
  COMMENT 'Statut de la zone';

-- Index

DEFINE INDEX IF NOT EXISTS bunny_id_unique ON bunny_storage_zone
  FIELDS bunny_id UNIQUE;

DEFINE INDEX IF NOT EXISTS name_idx ON bunny_storage_zone
  FIELDS name;

DEFINE INDEX IF NOT EXISTS tenant_idx ON bunny_storage_zone
  FIELDS tenant;

DEFINE INDEX IF NOT EXISTS status_idx ON bunny_storage_zone
  FIELDS metadata.status;


-- ============================================================================
-- TABLE : bunny_storage_file
-- ============================================================================
-- Description : Fichiers stockés sur Bunny Storage
-- ============================================================================

DEFINE TABLE IF NOT EXISTS bunny_storage_file SCHEMAFULL
  COMMENT 'Fichiers sur Bunny Storage';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS zone ON bunny_storage_file
  TYPE record<bunny_storage_zone>
  ASSERT $value != NONE
  COMMENT 'Zone de storage';

DEFINE FIELD IF NOT EXISTS path ON bunny_storage_file
  TYPE string
  ASSERT $value != NONE AND string::len($value) > 0
  COMMENT 'Path du fichier (ex: /assets/logo.png)';

DEFINE FIELD IF NOT EXISTS filename ON bunny_storage_file
  TYPE string
  COMMENT 'Nom du fichier';

DEFINE FIELD IF NOT EXISTS url ON bunny_storage_file
  TYPE string
  COMMENT 'URL complète du fichier';

DEFINE FIELD IF NOT EXISTS cdn_url ON bunny_storage_file
  TYPE string
  COMMENT 'URL CDN du fichier';

-- Métadonnées fichier

DEFINE FIELD IF NOT EXISTS file_info ON bunny_storage_file
  TYPE object
  COMMENT 'Informations sur le fichier';

DEFINE FIELD IF NOT EXISTS file_info.size_bytes ON bunny_storage_file
  TYPE int
  COMMENT 'Taille en bytes';

DEFINE FIELD IF NOT EXISTS file_info.mime_type ON bunny_storage_file
  TYPE string
  COMMENT 'Type MIME (ex: image/png)';

DEFINE FIELD IF NOT EXISTS file_info.checksum ON bunny_storage_file
  TYPE string
  COMMENT 'Checksum SHA256';

DEFINE FIELD IF NOT EXISTS file_info.last_modified ON bunny_storage_file
  TYPE datetime
  COMMENT 'Dernière modification';

-- Lifecycle

DEFINE FIELD IF NOT EXISTS lifecycle ON bunny_storage_file
  TYPE object
  COMMENT 'Gestion du cycle de vie';

DEFINE FIELD IF NOT EXISTS lifecycle.expires_at ON bunny_storage_file
  TYPE option<datetime>
  COMMENT 'Date d\'expiration (auto-delete)';

DEFINE FIELD IF NOT EXISTS lifecycle.archive_after ON bunny_storage_file
  TYPE option<datetime>
  COMMENT 'Date d\'archivage';

DEFINE FIELD IF NOT EXISTS lifecycle.is_archived ON bunny_storage_file
  TYPE bool
  DEFAULT false
  COMMENT 'Fichier archivé';

-- Relations

DEFINE FIELD IF NOT EXISTS tenant ON bunny_storage_file
  TYPE option<record<tenant>>
  COMMENT 'Tenant propriétaire';

DEFINE FIELD IF NOT EXISTS owner ON bunny_storage_file
  TYPE option<record<identity>>
  COMMENT 'Utilisateur propriétaire';

-- Tags et catégories

DEFINE FIELD IF NOT EXISTS tags ON bunny_storage_file
  TYPE option<array<string>>
  COMMENT 'Tags pour organisation';

DEFINE FIELD IF NOT EXISTS category ON bunny_storage_file
  TYPE option<string>
  COMMENT 'Catégorie (ex: avatar, document, asset)';

-- Métadonnées

DEFINE FIELD IF NOT EXISTS metadata ON bunny_storage_file
  TYPE object
  COMMENT 'Métadonnées de traçabilité';

DEFINE FIELD IF NOT EXISTS metadata.uploaded_at ON bunny_storage_file
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date d\'upload';

DEFINE FIELD IF NOT EXISTS metadata.uploaded_by ON bunny_storage_file
  TYPE option<record<identity>>
  COMMENT 'Uploadé par (user)';

DEFINE FIELD IF NOT EXISTS metadata.access_count ON bunny_storage_file
  TYPE int
  DEFAULT 0
  COMMENT 'Nombre d\'accès';

DEFINE FIELD IF NOT EXISTS metadata.last_accessed ON bunny_storage_file
  TYPE option<datetime>
  COMMENT 'Dernier accès';

-- Index

DEFINE INDEX IF NOT EXISTS zone_path_unique ON bunny_storage_file
  FIELDS zone, path UNIQUE;

DEFINE INDEX IF NOT EXISTS zone_idx ON bunny_storage_file
  FIELDS zone;

DEFINE INDEX IF NOT EXISTS tenant_idx ON bunny_storage_file
  FIELDS tenant;

DEFINE INDEX IF NOT EXISTS owner_idx ON bunny_storage_file
  FIELDS owner;

DEFINE INDEX IF NOT EXISTS category_idx ON bunny_storage_file
  FIELDS category;

DEFINE INDEX IF NOT EXISTS tags_idx ON bunny_storage_file
  FIELDS tags;

DEFINE INDEX IF NOT EXISTS expires_idx ON bunny_storage_file
  FIELDS lifecycle.expires_at;


-- ============================================================================
-- EVENTS : Auto-cleanup des fichiers expirés
-- ============================================================================

-- Event pour supprimer les fichiers expirés
-- (À implémenter selon besoins)

