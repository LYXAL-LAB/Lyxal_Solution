-- Table: bunny_edge_script_release_model
-- Source: EdgeScriptReleaseModel
-- Description: Table pour EdgeScriptReleaseModel

DEFINE TABLE IF NOT EXISTS bunny_edge_script_release_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour EdgeScriptReleaseModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_edge_script_release_model
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS deleted ON bunny_edge_script_release_model
  TYPE option<bool>
;

DEFINE FIELD IF NOT EXISTS code ON bunny_edge_script_release_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS uuid ON bunny_edge_script_release_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS note ON bunny_edge_script_release_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS author ON bunny_edge_script_release_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS author_email ON bunny_edge_script_release_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS commit_sha ON bunny_edge_script_release_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS status ON bunny_edge_script_release_model
  TYPE option<record<edge_script_release_status>>
;

DEFINE FIELD IF NOT EXISTS date_released ON bunny_edge_script_release_model
  TYPE option<datetime>
;

DEFINE FIELD IF NOT EXISTS date_published ON bunny_edge_script_release_model
  TYPE option<datetime>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_edge_script_release_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_edge_script_release_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
