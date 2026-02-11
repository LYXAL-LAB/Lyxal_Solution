-- Table: bunny_waf_rule_metrics
-- Source: WafRuleMetrics
-- Description: Table pour WafRuleMetrics

DEFINE TABLE IF NOT EXISTS bunny_waf_rule_metrics TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour WafRuleMetrics';

DEFINE FIELD IF NOT EXISTS total_triggers ON bunny_waf_rule_metrics
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS blocked_requests ON bunny_waf_rule_metrics
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS logged_requests ON bunny_waf_rule_metrics
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS challenged_requests ON bunny_waf_rule_metrics
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS overview_past_twenty_eight_days ON bunny_waf_rule_metrics
  TYPE option<object>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_waf_rule_metrics
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_waf_rule_metrics
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
