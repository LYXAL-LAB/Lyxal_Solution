-- Table: bunny_config_variable_value_minimal
-- Source: ConfigVariableValueMinimal
-- Description: Table pour ConfigVariableValueMinimal

DEFINE TABLE IF NOT EXISTS bunny_config_variable_value_minimal TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour ConfigVariableValueMinimal';

DEFINE FIELD IF NOT EXISTS name ON bunny_config_variable_value_minimal
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS value_encoded ON bunny_config_variable_value_minimal
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_config_variable_value_minimal
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_config_variable_value_minimal
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
