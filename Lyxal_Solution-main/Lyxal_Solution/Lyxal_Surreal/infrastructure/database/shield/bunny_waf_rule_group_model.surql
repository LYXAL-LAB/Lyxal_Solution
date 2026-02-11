-- Table: bunny_waf_rule_group_model
-- Source: WafRuleGroupModel
-- Description: Table pour WafRuleGroupModel

DEFINE TABLE IF NOT EXISTS bunny_waf_rule_group_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour WafRuleGroupModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_waf_rule_group_model
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS name ON bunny_waf_rule_group_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS code ON bunny_waf_rule_group_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS file_name ON bunny_waf_rule_group_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS main_group ON bunny_waf_rule_group_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS ruleset ON bunny_waf_rule_group_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS description ON bunny_waf_rule_group_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rules ON bunny_waf_rule_group_model
  TYPE option<array<option<record<waf_rule_model>>>>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_waf_rule_group_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_waf_rule_group_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
