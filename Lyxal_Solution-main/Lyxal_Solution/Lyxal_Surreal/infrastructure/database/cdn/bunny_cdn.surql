-- ============================================================================
-- BUNNY CDN - Gestion des Pull Zones et Configuration CDN
-- ============================================================================
-- Description : Tables pour gérer Bunny CDN (pull zones, cache, edge rules)
-- Version     : 1.0.0
-- Date        : 2025-01-24
-- ============================================================================

-- ============================================================================
-- TABLE : bunny_cdn_zone
-- ============================================================================
-- Description : Configuration des Pull Zones CDN
-- ============================================================================

DEFINE TABLE IF NOT EXISTS bunny_cdn_zone SCHEMAFULL
  COMMENT 'Pull Zones CDN Bunny.net';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS bunny_id ON bunny_cdn_zone
  TYPE int
  COMMENT 'ID Bunny.net de la pull zone';

DEFINE FIELD IF NOT EXISTS name ON bunny_cdn_zone
  TYPE string
  ASSERT $value != NONE AND string::len($value) > 0
  COMMENT 'Nom de la pull zone';

DEFINE FIELD IF NOT EXISTS hostname ON bunny_cdn_zone
  TYPE string
  COMMENT 'Hostname CDN (ex: lyxal.b-cdn.net)';

DEFINE FIELD IF NOT EXISTS custom_hostnames ON bunny_cdn_zone
  TYPE option<array<string>>
  COMMENT 'Domaines customs (ex: cdn.lyxal.com)';

-- Origin Configuration

DEFINE FIELD IF NOT EXISTS origin ON bunny_cdn_zone
  TYPE object
  COMMENT 'Configuration origin';

DEFINE FIELD IF NOT EXISTS origin.url ON bunny_cdn_zone
  TYPE string
  COMMENT 'URL origin (ex: https://storage.bunnycdn.com/zone)';

DEFINE FIELD IF NOT EXISTS origin.type ON bunny_cdn_zone
  TYPE string
  ASSERT $value INSIDE ['storage', 'url', 'volume']
  COMMENT 'Type d\'origin';

DEFINE FIELD IF NOT EXISTS origin.shield ON bunny_cdn_zone
  TYPE bool
  DEFAULT false
  COMMENT 'Origin Shield activé';

DEFINE FIELD IF NOT EXISTS origin.shield_region ON bunny_cdn_zone
  TYPE option<string>
  COMMENT 'Région du shield';

-- Cache Configuration

DEFINE FIELD IF NOT EXISTS cache ON bunny_cdn_zone
  TYPE object
  COMMENT 'Configuration cache';

DEFINE FIELD IF NOT EXISTS cache.ttl_default ON bunny_cdn_zone
  TYPE int
  DEFAULT 3600
  COMMENT 'TTL par défaut (secondes)';

DEFINE FIELD IF NOT EXISTS cache.browser_cache ON bunny_cdn_zone
  TYPE int
  DEFAULT 86400
  COMMENT 'Cache navigateur (secondes)';

DEFINE FIELD IF NOT EXISTS cache.query_string_caching ON bunny_cdn_zone
  TYPE bool
  DEFAULT true
  COMMENT 'Cache avec query strings';

DEFINE FIELD IF NOT EXISTS cache.ignore_query_strings ON bunny_cdn_zone
  TYPE option<array<string>>
  COMMENT 'Query strings à ignorer';

DEFINE FIELD IF NOT EXISTS cache.vary ON bunny_cdn_zone
  TYPE option<array<string>>
  COMMENT 'Headers Vary (ex: Accept-Encoding)';

-- Edge Rules

DEFINE FIELD IF NOT EXISTS edge_rules ON bunny_cdn_zone
  TYPE array<object>
  COMMENT 'Edge rules (routing, redirects, etc.)';

-- Exemple edge_rule :
-- {
--   "enabled": true,
--   "description": "Redirect old URL",
--   "condition": {
--     "type": "url_match",
--     "pattern": "/old-path/*"
--   },
--   "actions": [
--     {
--       "type": "redirect",
--       "target": "/new-path/$1",
--       "status": 301
--     }
--   ]
-- }

-- Security

DEFINE FIELD IF NOT EXISTS security ON bunny_cdn_zone
  TYPE object
  COMMENT 'Configuration sécurité';

DEFINE FIELD IF NOT EXISTS security.waf_enabled ON bunny_cdn_zone
  TYPE bool
  DEFAULT false
  COMMENT 'WAF (Web Application Firewall) activé';

DEFINE FIELD IF NOT EXISTS security.ddos_protection ON bunny_cdn_zone
  TYPE bool
  DEFAULT true
  COMMENT 'Protection DDoS';

DEFINE FIELD IF NOT EXISTS security.geo_blocking ON bunny_cdn_zone
  TYPE option<object>
  COMMENT 'Blocage géographique';

DEFINE FIELD IF NOT EXISTS security.geo_blocking.type ON bunny_cdn_zone
  TYPE option<string>
  ASSERT $value == NONE OR $value INSIDE ['allow', 'block']
  COMMENT 'Type : allow (whitelist) ou block (blacklist)';

DEFINE FIELD IF NOT EXISTS security.geo_blocking.countries ON bunny_cdn_zone
  TYPE option<array<string>>
  COMMENT 'Codes pays ISO (ex: ["FR", "US"])';

DEFINE FIELD IF NOT EXISTS security.token_auth ON bunny_cdn_zone
  TYPE bool
  DEFAULT false
  COMMENT 'Token authentication activée';

DEFINE FIELD IF NOT EXISTS security.ip_whitelist ON bunny_cdn_zone
  TYPE option<array<string>>
  COMMENT 'IPs autorisées';

-- Performance

DEFINE FIELD IF NOT EXISTS performance ON bunny_cdn_zone
  TYPE object
  COMMENT 'Optimisations performance';

DEFINE FIELD IF NOT EXISTS performance.compression ON bunny_cdn_zone
  TYPE bool
  DEFAULT true
  COMMENT 'Compression Gzip/Brotli';

DEFINE FIELD IF NOT EXISTS performance.minify_css ON bunny_cdn_zone
  TYPE bool
  DEFAULT false
  COMMENT 'Minification CSS';

DEFINE FIELD IF NOT EXISTS performance.minify_js ON bunny_cdn_zone
  TYPE bool
  DEFAULT false
  COMMENT 'Minification JavaScript';

DEFINE FIELD IF NOT EXISTS performance.image_optimization ON bunny_cdn_zone
  TYPE bool
  DEFAULT false
  COMMENT 'Optimisation images automatique';

-- SSL/TLS

DEFINE FIELD IF NOT EXISTS ssl ON bunny_cdn_zone
  TYPE object
  COMMENT 'Configuration SSL/TLS';

DEFINE FIELD IF NOT EXISTS ssl.enabled ON bunny_cdn_zone
  TYPE bool
  DEFAULT true
  COMMENT 'SSL activé';

DEFINE FIELD IF NOT EXISTS ssl.type ON bunny_cdn_zone
  TYPE string
  ASSERT $value INSIDE ['letsencrypt', 'custom', 'none']
  DEFAULT 'letsencrypt'
  COMMENT 'Type de certificat';

DEFINE FIELD IF NOT EXISTS ssl.force_https ON bunny_cdn_zone
  TYPE bool
  DEFAULT true
  COMMENT 'Forcer HTTPS';

-- Usage et coûts

DEFINE FIELD IF NOT EXISTS usage ON bunny_cdn_zone
  TYPE object
  COMMENT 'Statistiques d\'usage';

DEFINE FIELD IF NOT EXISTS usage.bandwidth_gb_month ON bunny_cdn_zone
  TYPE float
  DEFAULT 0.0
  COMMENT 'Bandwidth du mois (GB)';

DEFINE FIELD IF NOT EXISTS usage.requests_month ON bunny_cdn_zone
  TYPE int
  DEFAULT 0
  COMMENT 'Nombre de requêtes du mois';

DEFINE FIELD IF NOT EXISTS usage.cache_hit_rate ON bunny_cdn_zone
  TYPE float
  COMMENT 'Taux de cache hit (%)';

DEFINE FIELD IF NOT EXISTS usage.last_sync ON bunny_cdn_zone
  TYPE datetime
  COMMENT 'Dernière synchro usage';

-- Coût estimé

DEFINE FIELD IF NOT EXISTS cost_estimate ON bunny_cdn_zone
  TYPE object
  COMMENT 'Estimation coûts mensuels';

DEFINE FIELD IF NOT EXISTS cost_estimate.bandwidth_cost ON bunny_cdn_zone
  TYPE float
  COMMENT 'Coût bandwidth ($)';

DEFINE FIELD IF NOT EXISTS cost_estimate.requests_cost ON bunny_cdn_zone
  TYPE float
  COMMENT 'Coût requêtes ($)';

DEFINE FIELD IF NOT EXISTS cost_estimate.total_month ON bunny_cdn_zone
  TYPE float
  COMMENT 'Coût total du mois ($)';

-- Relations

DEFINE FIELD IF NOT EXISTS storage_zone ON bunny_cdn_zone
  TYPE option<record<bunny_storage_zone>>
  COMMENT 'Storage zone associée';

DEFINE FIELD IF NOT EXISTS tenant ON bunny_cdn_zone
  TYPE option<record<tenant>>
  COMMENT 'Tenant propriétaire';

-- Métadonnées

DEFINE FIELD IF NOT EXISTS metadata ON bunny_cdn_zone
  TYPE object
  COMMENT 'Métadonnées de traçabilité';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON bunny_cdn_zone
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON bunny_cdn_zone
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Dernière mise à jour';

DEFINE FIELD IF NOT EXISTS metadata.created_by ON bunny_cdn_zone
  TYPE option<record<identity>>
  COMMENT 'Créé par (user)';

DEFINE FIELD IF NOT EXISTS metadata.status ON bunny_cdn_zone
  TYPE string
  ASSERT $value INSIDE ['active', 'suspended', 'deleted']
  DEFAULT 'active'
  COMMENT 'Statut de la zone';

-- Index

DEFINE INDEX IF NOT EXISTS bunny_id_unique ON bunny_cdn_zone
  FIELDS bunny_id UNIQUE;

DEFINE INDEX IF NOT EXISTS hostname_idx ON bunny_cdn_zone
  FIELDS hostname;

DEFINE INDEX IF NOT EXISTS tenant_idx ON bunny_cdn_zone
  FIELDS tenant;

DEFINE INDEX IF NOT EXISTS status_idx ON bunny_cdn_zone
  FIELDS metadata.status;


-- ============================================================================
-- TABLE : bunny_cdn_purge
-- ============================================================================
-- Description : Historique des purges de cache CDN
-- ============================================================================

DEFINE TABLE IF NOT EXISTS bunny_cdn_purge SCHEMAFULL
  COMMENT 'Historique purges cache CDN';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS zone ON bunny_cdn_purge
  TYPE record<bunny_cdn_zone>
  ASSERT $value != NONE
  COMMENT 'Pull zone purgée';

DEFINE FIELD IF NOT EXISTS purge_type ON bunny_cdn_purge
  TYPE string
  ASSERT $value INSIDE ['full', 'url', 'pattern']
  COMMENT 'Type de purge';

DEFINE FIELD IF NOT EXISTS urls ON bunny_cdn_purge
  TYPE option<array<string>>
  COMMENT 'URLs purgées (si type = url)';

DEFINE FIELD IF NOT EXISTS pattern ON bunny_cdn_purge
  TYPE option<string>
  COMMENT 'Pattern purgé (si type = pattern)';

-- Résultat

DEFINE FIELD IF NOT EXISTS status ON bunny_cdn_purge
  TYPE string
  ASSERT $value INSIDE ['pending', 'success', 'failed']
  DEFAULT 'pending'
  COMMENT 'Statut de la purge';

DEFINE FIELD IF NOT EXISTS bunny_purge_id ON bunny_cdn_purge
  TYPE option<string>
  COMMENT 'ID de la purge chez Bunny';

DEFINE FIELD IF NOT EXISTS error_message ON bunny_cdn_purge
  TYPE option<string>
  COMMENT 'Message d\'erreur (si failed)';

-- Métadonnées

DEFINE FIELD IF NOT EXISTS metadata ON bunny_cdn_purge
  TYPE object
  COMMENT 'Métadonnées';

DEFINE FIELD IF NOT EXISTS metadata.requested_at ON bunny_cdn_purge
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de demande';

DEFINE FIELD IF NOT EXISTS metadata.requested_by ON bunny_cdn_purge
  TYPE option<record<identity>>
  COMMENT 'Demandé par (user)';

DEFINE FIELD IF NOT EXISTS metadata.completed_at ON bunny_cdn_purge
  TYPE option<datetime>
  COMMENT 'Date de complétion';

-- Index

DEFINE INDEX IF NOT EXISTS zone_idx ON bunny_cdn_purge
  FIELDS zone;

DEFINE INDEX IF NOT EXISTS status_idx ON bunny_cdn_purge
  FIELDS status;

DEFINE INDEX IF NOT EXISTS requested_at_idx ON bunny_cdn_purge
  FIELDS metadata.requested_at;

