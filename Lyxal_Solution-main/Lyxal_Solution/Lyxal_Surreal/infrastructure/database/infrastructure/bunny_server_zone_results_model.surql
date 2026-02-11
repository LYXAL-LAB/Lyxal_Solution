-- Table: bunny_server_zone_results_model
-- Source: ServerZoneResultsModel
-- Description: Table pour ServerZoneResultsModel

DEFINE TABLE IF NOT EXISTS bunny_server_zone_results_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour ServerZoneResultsModel';

DEFINE FIELD IF NOT EXISTS server_zone_id ON bunny_server_zone_results_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS results ON bunny_server_zone_results_model
  TYPE option<object>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_server_zone_results_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_server_zone_results_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
