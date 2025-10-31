-- Table: bunny_pull_zone_purge_model
-- Source: PullZonePurgeModel
-- Description: Table pour PullZonePurgeModel

DEFINE TABLE IF NOT EXISTS bunny_pull_zone_purge_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour PullZonePurgeModel';

DEFINE FIELD IF NOT EXISTS cache_tag ON bunny_pull_zone_purge_model
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_pull_zone_purge_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_pull_zone_purge_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
