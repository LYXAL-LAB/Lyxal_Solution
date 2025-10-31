-- Table: bunny_pull_zone_waf_config_variable_model
-- Source: PullZoneWafConfigVariableModel
-- Description: Table pour PullZoneWafConfigVariableModel

DEFINE TABLE IF NOT EXISTS bunny_pull_zone_waf_config_variable_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour PullZoneWafConfigVariableModel';

DEFINE FIELD IF NOT EXISTS name ON bunny_pull_zone_waf_config_variable_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS value_encoded ON bunny_pull_zone_waf_config_variable_model
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_pull_zone_waf_config_variable_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_pull_zone_waf_config_variable_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
