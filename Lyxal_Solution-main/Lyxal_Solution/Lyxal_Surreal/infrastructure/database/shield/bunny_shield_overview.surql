-- Table: bunny_shield_overview
-- Source: ShieldOverview
-- Description: Table pour ShieldOverview

DEFINE TABLE IF NOT EXISTS bunny_shield_overview TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour ShieldOverview';

DEFINE FIELD IF NOT EXISTS d_do_s_mitigated ON bunny_shield_overview
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS waf_triggered_rules ON bunny_shield_overview
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS ratelimit_breaches ON bunny_shield_overview
  TYPE option<int>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_shield_overview
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_shield_overview
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
