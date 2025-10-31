-- Table: bunny_github_repository_model
-- Source: GithubRepositoryModel
-- Description: Table pour GithubRepositoryModel

DEFINE TABLE IF NOT EXISTS bunny_github_repository_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour GithubRepositoryModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_github_repository_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS name ON bunny_github_repository_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS private ON bunny_github_repository_model
  TYPE bool
  ASSERT $value != NONE
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_github_repository_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_github_repository_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
