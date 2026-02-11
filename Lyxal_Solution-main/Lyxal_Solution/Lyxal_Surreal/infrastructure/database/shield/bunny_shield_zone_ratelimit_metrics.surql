-- Table: bunny_shield_zone_ratelimit_metrics
-- Source: ShieldZoneRatelimitMetrics
-- Description: Table pour ShieldZoneRatelimitMetrics

DEFINE TABLE IF NOT EXISTS bunny_shield_zone_ratelimit_metrics TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour ShieldZoneRatelimitMetrics';

DEFINE FIELD IF NOT EXISTS ratelimit_id ON bunny_shield_zone_ratelimit_metrics
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS overview ON bunny_shield_zone_ratelimit_metrics
  TYPE option<record<shield_zone_ratelimit>>
;

DEFINE FIELD IF NOT EXISTS ratelimit_overview_past_twenty_eight_days ON bunny_shield_zone_ratelimit_metrics
  TYPE option<object>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_shield_zone_ratelimit_metrics
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_shield_zone_ratelimit_metrics
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
