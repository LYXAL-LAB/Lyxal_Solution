-- Table: bunny_moment_model
-- Source: MomentModel
-- Description: Table pour MomentModel

DEFINE TABLE IF NOT EXISTS bunny_moment_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour MomentModel';

DEFINE FIELD IF NOT EXISTS label ON bunny_moment_model
  TYPE string
  ASSERT $value != NONE
  COMMENT 'The text description label for the chapter';

DEFINE FIELD IF NOT EXISTS timestamp ON bunny_moment_model
  TYPE option<int>
  COMMENT 'The timestamp of the moment in seconds';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_moment_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_moment_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
