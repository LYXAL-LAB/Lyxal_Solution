-- Table: bunny_linked_pull_zone
-- Source: LinkedPullZone
-- Description: Table pour LinkedPullZone

DEFINE TABLE IF NOT EXISTS bunny_linked_pull_zone TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour LinkedPullZone';

DEFINE FIELD IF NOT EXISTS id ON bunny_linked_pull_zone
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS pull_zone_name ON bunny_linked_pull_zone
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS default_hostname ON bunny_linked_pull_zone
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_linked_pull_zone
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_linked_pull_zone
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
