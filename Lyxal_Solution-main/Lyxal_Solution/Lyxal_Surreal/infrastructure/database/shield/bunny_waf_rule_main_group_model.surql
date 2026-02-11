-- Table: bunny_waf_rule_main_group_model
-- Source: WafRuleMainGroupModel
-- Description: Table pour WafRuleMainGroupModel

DEFINE TABLE IF NOT EXISTS bunny_waf_rule_main_group_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour WafRuleMainGroupModel';

DEFINE FIELD IF NOT EXISTS name ON bunny_waf_rule_main_group_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS ruleset ON bunny_waf_rule_main_group_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_groups ON bunny_waf_rule_main_group_model
  TYPE option<array<option<record<waf_rule_group_model>>>>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_waf_rule_main_group_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_waf_rule_main_group_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
