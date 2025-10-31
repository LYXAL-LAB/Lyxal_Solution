-- Table: bunny_github_repository_branch_model
-- Source: GithubRepositoryBranchModel
-- Description: Table pour GithubRepositoryBranchModel

DEFINE TABLE IF NOT EXISTS bunny_github_repository_branch_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour GithubRepositoryBranchModel';

DEFINE FIELD IF NOT EXISTS name ON bunny_github_repository_branch_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS protected ON bunny_github_repository_branch_model
  TYPE bool
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS default ON bunny_github_repository_branch_model
  TYPE bool
  ASSERT $value != NONE
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_github_repository_branch_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_github_repository_branch_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
