-- Table: bunny_shield_zone_metrics
-- Source: ShieldZoneMetrics
-- Description: Table pour ShieldZoneMetrics

DEFINE TABLE IF NOT EXISTS bunny_shield_zone_metrics TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour ShieldZoneMetrics';

DEFINE FIELD IF NOT EXISTS overview ON bunny_shield_zone_metrics
  TYPE option<record<shield_overview>>
;

DEFINE FIELD IF NOT EXISTS waf ON bunny_shield_zone_metrics
  TYPE option<record<waf>>
;

DEFINE FIELD IF NOT EXISTS overview_past_twenty_eight_days ON bunny_shield_zone_metrics
  TYPE option<object>
;

DEFINE FIELD IF NOT EXISTS d_do_s ON bunny_shield_zone_metrics
  TYPE option<record<d_do_s>>
;

DEFINE FIELD IF NOT EXISTS d_do_s_overview_past_twenty_eight_days ON bunny_shield_zone_metrics
  TYPE option<object>
;

DEFINE FIELD IF NOT EXISTS ratelimit ON bunny_shield_zone_metrics
  TYPE option<record<ratelimit>>
;

DEFINE FIELD IF NOT EXISTS ratelimit_overview_past_twenty_eight_days ON bunny_shield_zone_metrics
  TYPE option<object>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_shield_zone_metrics
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_shield_zone_metrics
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
