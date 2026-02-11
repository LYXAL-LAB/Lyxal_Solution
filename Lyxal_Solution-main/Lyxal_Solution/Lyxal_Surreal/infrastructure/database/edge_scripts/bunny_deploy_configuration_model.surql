-- Table: bunny_deploy_configuration_model
-- Source: DeployConfigurationModel
-- Description: Table pour DeployConfigurationModel

DEFINE TABLE IF NOT EXISTS bunny_deploy_configuration_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour DeployConfigurationModel';

DEFINE FIELD IF NOT EXISTS branch ON bunny_deploy_configuration_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS install_command ON bunny_deploy_configuration_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS build_command ON bunny_deploy_configuration_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS entry_file ON bunny_deploy_configuration_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS create_workflow ON bunny_deploy_configuration_model
  TYPE option<bool>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_deploy_configuration_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_deploy_configuration_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
