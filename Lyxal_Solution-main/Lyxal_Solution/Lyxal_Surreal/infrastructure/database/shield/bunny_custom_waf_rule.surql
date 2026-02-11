-- Table: bunny_custom_waf_rule
-- Source: CustomWafRule
-- Description: Table pour CustomWafRule

DEFINE TABLE IF NOT EXISTS bunny_custom_waf_rule TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour CustomWafRule';

DEFINE FIELD IF NOT EXISTS id ON bunny_custom_waf_rule
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS shield_zone_id ON bunny_custom_waf_rule
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS user_id ON bunny_custom_waf_rule
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_name ON bunny_custom_waf_rule
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_description ON bunny_custom_waf_rule
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_json ON bunny_custom_waf_rule
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_configuration ON bunny_custom_waf_rule
  TYPE option<record<create_custom_waf_rule_model>>
;

DEFINE FIELD IF NOT EXISTS error_response ON bunny_custom_waf_rule
  TYPE option<record<generic_request_response>>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_custom_waf_rule
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_custom_waf_rule
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
