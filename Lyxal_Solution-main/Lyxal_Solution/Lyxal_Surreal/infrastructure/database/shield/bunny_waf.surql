-- Table: bunny_waf
-- Source: Waf
-- Description: Table pour Waf

DEFINE TABLE IF NOT EXISTS bunny_waf TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour Waf';

DEFINE FIELD IF NOT EXISTS total_triggered_rules ON bunny_waf
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS blocked_requests ON bunny_waf
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS logged_requests ON bunny_waf
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS challenged_requests ON bunny_waf
  TYPE option<int>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_waf
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_waf
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
