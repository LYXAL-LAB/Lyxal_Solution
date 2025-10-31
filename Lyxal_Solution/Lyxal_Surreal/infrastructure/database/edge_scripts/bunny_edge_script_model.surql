-- Table: bunny_edge_script_model
-- Source: EdgeScriptModel
-- Description: Table pour EdgeScriptModel

DEFINE TABLE IF NOT EXISTS bunny_edge_script_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour EdgeScriptModel';

DEFINE FIELD IF NOT EXISTS script_i_d ON bunny_edge_script_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS version ON bunny_edge_script_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS script ON bunny_edge_script_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS port ON bunny_edge_script_model
  TYPE int
  ASSERT $value != NONE
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_edge_script_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_edge_script_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
