-- Table: bunny_source_code_integration_model
-- Source: SourceCodeIntegrationModel
-- Description: Table pour SourceCodeIntegrationModel

DEFINE TABLE IF NOT EXISTS bunny_source_code_integration_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour SourceCodeIntegrationModel';

DEFINE FIELD IF NOT EXISTS integration_id ON bunny_source_code_integration_model
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS repository_settings ON bunny_source_code_integration_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS deploy_configuration ON bunny_source_code_integration_model
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_source_code_integration_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_source_code_integration_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
