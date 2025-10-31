-- ============================================================================
-- BUNNY DNS RECORD - Records DNS
-- ============================================================================
-- Description : Table miroir de l'API Bunny.net pour les records DNS
-- API Docs    : https://docs.bunny.net/reference/dnszonepublic_addrecord
-- Version     : 2.0.0
-- Date        : 2025-10-25
-- ============================================================================

-- ============================================================================
-- TABLE : bunny_dns_record
-- ============================================================================
-- Description : Records DNS - Miroir exact de l'API Bunny.net
-- ============================================================================

DEFINE TABLE IF NOT EXISTS bunny_dns_record TYPE NORMAL SCHEMAFULL
  COMMENT 'Records DNS Bunny.net (miroir API)';

-- Champs API Bunny.net (structure exacte)

DEFINE FIELD IF NOT EXISTS bunny_id ON bunny_dns_record
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Id - ID unique Bunny.net du record';

DEFINE FIELD IF NOT EXISTS zone_id ON bunny_dns_record
  TYPE int
  ASSERT $value != NONE
  COMMENT 'Zone ID - Référence vers bunny_dns_zone.bunny_id';

-- Champs principaux

DEFINE FIELD IF NOT EXISTS type ON bunny_dns_record
  TYPE string
  ASSERT $value INSIDE ['A', 'AAAA', 'CNAME', 'TXT', 'MX', 'Redirect', 'Flatten', 'PullZone', 'SRV', 'CAA', 'PTR', 'Script', 'NS']
  COMMENT 'Type - Type de record DNS';

DEFINE FIELD IF NOT EXISTS name ON bunny_dns_record
  TYPE option<string>
  COMMENT 'Name - Nom du record (ex: www, @, mail)';

DEFINE FIELD IF NOT EXISTS value ON bunny_dns_record
  TYPE option<string>
  COMMENT 'Value - Valeur du record';

DEFINE FIELD IF NOT EXISTS ttl ON bunny_dns_record
  TYPE int
  DEFAULT 3600
  COMMENT 'Ttl - Time To Live en secondes';

-- Champs spécifiques (MX, SRV, CAA)

DEFINE FIELD IF NOT EXISTS priority ON bunny_dns_record
  TYPE option<int>
  COMMENT 'Priority - Priorité (pour MX, SRV)';

DEFINE FIELD IF NOT EXISTS weight ON bunny_dns_record
  TYPE option<int>
  COMMENT 'Weight - Poids (pour SRV)';

DEFINE FIELD IF NOT EXISTS port ON bunny_dns_record
  TYPE option<int>
  COMMENT 'Port - Port (pour SRV)';

DEFINE FIELD IF NOT EXISTS flags ON bunny_dns_record
  TYPE option<int>
  COMMENT 'Flags - Flags 0-255 (pour CAA)';

DEFINE FIELD IF NOT EXISTS tag ON bunny_dns_record
  TYPE option<string>
  COMMENT 'Tag - Tag (pour CAA)';

-- Accélération Bunny CDN

DEFINE FIELD IF NOT EXISTS accelerated ON bunny_dns_record
  TYPE bool
  DEFAULT false
  COMMENT 'Accelerated - Record accéléré via CDN Bunny';

DEFINE FIELD IF NOT EXISTS accelerated_pull_zone_id ON bunny_dns_record
  TYPE option<int>
  COMMENT 'AcceleratedPullZoneId - ID de la Pull Zone si accéléré';

DEFINE FIELD IF NOT EXISTS link_name ON bunny_dns_record
  TYPE option<string>
  COMMENT 'LinkName - Nom du lien';

-- Pull Zone et Script

DEFINE FIELD IF NOT EXISTS pull_zone_id ON bunny_dns_record
  TYPE option<int>
  COMMENT 'PullZoneId - ID Pull Zone (pour type PullZone)';

DEFINE FIELD IF NOT EXISTS script_id ON bunny_dns_record
  TYPE option<int>
  COMMENT 'ScriptId - ID Script (pour type Script)';

-- Géolocalisation IP

DEFINE FIELD IF NOT EXISTS ip_geo_location_info ON bunny_dns_record
  TYPE option<object>
  COMMENT 'IPGeoLocationInfo - Informations géolocalisation IP';

DEFINE FIELD IF NOT EXISTS ip_geo_location_info.country_code ON bunny_dns_record
  TYPE option<string>
  COMMENT 'Code ISO du pays';

DEFINE FIELD IF NOT EXISTS ip_geo_location_info.country ON bunny_dns_record
  TYPE option<string>
  COMMENT 'Nom du pays';

DEFINE FIELD IF NOT EXISTS ip_geo_location_info.asn ON bunny_dns_record
  TYPE option<int>
  COMMENT 'ASN de l\'organisation IP';

DEFINE FIELD IF NOT EXISTS ip_geo_location_info.organization_name ON bunny_dns_record
  TYPE option<string>
  COMMENT 'Nom de l\'organisation propriétaire de l\'IP';

DEFINE FIELD IF NOT EXISTS ip_geo_location_info.city ON bunny_dns_record
  TYPE option<string>
  COMMENT 'Ville de localisation';

-- Géolocalisation pour routing

DEFINE FIELD IF NOT EXISTS geolocation_info ON bunny_dns_record
  TYPE option<object>
  COMMENT 'GeolocationInfo - Informations géolocalisation pour routing';

DEFINE FIELD IF NOT EXISTS geolocation_info.country ON bunny_dns_record
  TYPE option<string>
  COMMENT 'Pays';

DEFINE FIELD IF NOT EXISTS geolocation_info.city ON bunny_dns_record
  TYPE option<string>
  COMMENT 'Ville';

DEFINE FIELD IF NOT EXISTS geolocation_info.latitude ON bunny_dns_record
  TYPE option<float>
  COMMENT 'Latitude';

DEFINE FIELD IF NOT EXISTS geolocation_info.longitude ON bunny_dns_record
  TYPE option<float>
  COMMENT 'Longitude';

DEFINE FIELD IF NOT EXISTS geolocation_latitude ON bunny_dns_record
  TYPE option<float>
  COMMENT 'GeolocationLatitude - Latitude (champ direct)';

DEFINE FIELD IF NOT EXISTS geolocation_longitude ON bunny_dns_record
  TYPE option<float>
  COMMENT 'GeolocationLongitude - Longitude (champ direct)';

-- Smart Routing

DEFINE FIELD IF NOT EXISTS latency_zone ON bunny_dns_record
  TYPE option<string>
  COMMENT 'LatencyZone - Zone de latence';

DEFINE FIELD IF NOT EXISTS smart_routing_type ON bunny_dns_record
  TYPE option<string>
  ASSERT $value == NONE OR $value INSIDE ['None', 'Latency', 'Geolocation']
  COMMENT 'SmartRoutingType - Type de routing intelligent';

-- Monitoring

DEFINE FIELD IF NOT EXISTS monitor_type ON bunny_dns_record
  TYPE string
  ASSERT $value INSIDE ['None', 'Ping', 'Http', 'Monitor']
  DEFAULT 'None'
  COMMENT 'MonitorType - Type de monitoring';

DEFINE FIELD IF NOT EXISTS monitor_status ON bunny_dns_record
  TYPE string
  ASSERT $value INSIDE ['Unknown', 'Online', 'Offline']
  DEFAULT 'Unknown'
  COMMENT 'MonitorStatus - Statut du monitoring';

-- Variables d'environnement

DEFINE FIELD IF NOT EXISTS enviromental_variables ON bunny_dns_record
  TYPE option<array<object>>
  COMMENT 'EnviromentalVariables - Variables d\'environnement';

-- État et commentaire

DEFINE FIELD IF NOT EXISTS disabled ON bunny_dns_record
  TYPE bool
  DEFAULT false
  COMMENT 'Disabled - Record désactivé';

DEFINE FIELD IF NOT EXISTS comment ON bunny_dns_record
  TYPE option<string>
  COMMENT 'Comment - Commentaire / description';

-- SSL automatique

DEFINE FIELD IF NOT EXISTS auto_ssl_issuance ON bunny_dns_record
  TYPE bool
  DEFAULT false
  COMMENT 'AutoSslIssuance - Émission automatique SSL';

-- Métadonnées locales (ajout Lyxal)

DEFINE FIELD IF NOT EXISTS metadata ON bunny_dns_record
  TYPE object
  COMMENT 'Métadonnées locales (hors API Bunny)';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_dns_record
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation depuis l\'API';

DEFINE FIELD IF NOT EXISTS metadata.status ON bunny_dns_record
  TYPE string
  ASSERT $value INSIDE ['active', 'disabled', 'deleted']
  DEFAULT 'active'
  COMMENT 'Statut local (active, disabled, deleted)';

-- Index

DEFINE INDEX IF NOT EXISTS bunny_id_unique ON bunny_dns_record
  FIELDS bunny_id UNIQUE;

DEFINE INDEX IF NOT EXISTS zone_id_idx ON bunny_dns_record
  FIELDS zone_id;

DEFINE INDEX IF NOT EXISTS zone_name_type_idx ON bunny_dns_record
  FIELDS zone_id, name, type;

DEFINE INDEX IF NOT EXISTS type_idx ON bunny_dns_record
  FIELDS type;

DEFINE INDEX IF NOT EXISTS status_idx ON bunny_dns_record
  FIELDS metadata.status;


-- ============================================================================
-- NOTES
-- ============================================================================

-- Types de records supportés par Bunny.net :
-- - A : IPv4 address
-- - AAAA : IPv6 address
-- - CNAME : Canonical name
-- - TXT : Text record
-- - MX : Mail exchange
-- - Redirect : HTTP redirect
-- - Flatten : CNAME flattening
-- - PullZone : Bunny CDN Pull Zone
-- - SRV : Service record
-- - CAA : Certification Authority Authorization
-- - PTR : Pointer record
-- - Script : Edge Script
-- - NS : Name server

-- Enum MonitorType:
-- - None (0) : Pas de monitoring
-- - Ping (1) : Monitoring par ping
-- - Http (2) : Monitoring HTTP
-- - Monitor (3) : Monitoring avancé

-- Enum SmartRoutingType:
-- - None (0) : Pas de routing intelligent
-- - Latency (1) : Routing basé sur la latence
-- - Geolocation (2) : Routing basé sur la géolocalisation

