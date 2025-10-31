-- Table: bunny_resolution_reference
-- Source: ResolutionReference
-- Description: Table pour ResolutionReference

DEFINE TABLE IF NOT EXISTS bunny_resolution_reference TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour ResolutionReference';

DEFINE FIELD IF NOT EXISTS resolution ON bunny_resolution_reference
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS path ON bunny_resolution_reference
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_resolution_reference
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_resolution_reference
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
