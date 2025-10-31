-- Table: bunny_edge_script_variable_model
-- Source: EdgeScriptVariableModel
-- Description: Table pour EdgeScriptVariableModel

DEFINE TABLE IF NOT EXISTS bunny_edge_script_variable_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour EdgeScriptVariableModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_edge_script_variable_model
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS name ON bunny_edge_script_variable_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS required ON bunny_edge_script_variable_model
  TYPE option<bool>
;

DEFINE FIELD IF NOT EXISTS default_value ON bunny_edge_script_variable_model
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_edge_script_variable_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_edge_script_variable_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
