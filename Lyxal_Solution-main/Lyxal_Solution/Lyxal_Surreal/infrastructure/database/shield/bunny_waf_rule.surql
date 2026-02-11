-- Table: bunny_waf_rule
-- Source: WafRule
-- Description: Table pour WafRule

DEFINE TABLE IF NOT EXISTS bunny_waf_rule TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour WafRule';

DEFINE FIELD IF NOT EXISTS total_triggers ON bunny_waf_rule
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS blocked_requests ON bunny_waf_rule
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS logged_requests ON bunny_waf_rule
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS challenged_requests ON bunny_waf_rule
  TYPE option<int>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_waf_rule
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_waf_rule
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
