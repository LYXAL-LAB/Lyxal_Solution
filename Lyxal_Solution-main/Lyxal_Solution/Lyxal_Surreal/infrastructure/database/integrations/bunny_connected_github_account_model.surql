-- Table: bunny_connected_github_account_model
-- Source: ConnectedGithubAccountModel
-- Description: Table pour ConnectedGithubAccountModel

DEFINE TABLE IF NOT EXISTS bunny_connected_github_account_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour ConnectedGithubAccountModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_connected_github_account_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS name ON bunny_connected_github_account_model
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_connected_github_account_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_connected_github_account_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
