-- Table: bunny_edge_script_secret_model
-- Source: EdgeScriptSecretModel
-- Description: Table pour EdgeScriptSecretModel

DEFINE TABLE IF NOT EXISTS bunny_edge_script_secret_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour EdgeScriptSecretModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_edge_script_secret_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS name ON bunny_edge_script_secret_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS last_modified ON bunny_edge_script_secret_model
  TYPE datetime
  ASSERT $value != NONE
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_edge_script_secret_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_edge_script_secret_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
