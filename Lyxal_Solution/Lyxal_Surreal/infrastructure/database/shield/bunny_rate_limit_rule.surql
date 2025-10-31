-- Table: bunny_rate_limit_rule
-- Source: RateLimitRule
-- Description: Table pour RateLimitRule

DEFINE TABLE IF NOT EXISTS bunny_rate_limit_rule TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour RateLimitRule';

DEFINE FIELD IF NOT EXISTS id ON bunny_rate_limit_rule
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS shield_zone_id ON bunny_rate_limit_rule
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS user_id ON bunny_rate_limit_rule
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_name ON bunny_rate_limit_rule
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_description ON bunny_rate_limit_rule
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_json ON bunny_rate_limit_rule
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_configuration ON bunny_rate_limit_rule
  TYPE option<record<create_waf_rate_limit_rule_model>>
;

DEFINE FIELD IF NOT EXISTS error_response ON bunny_rate_limit_rule
  TYPE option<record<generic_request_response>>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_rate_limit_rule
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_rate_limit_rule
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
