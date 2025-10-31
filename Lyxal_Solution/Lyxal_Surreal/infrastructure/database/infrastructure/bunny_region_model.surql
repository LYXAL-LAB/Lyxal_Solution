-- Table: bunny_region_model
-- Source: RegionModel
-- Description: Table pour RegionModel

DEFINE TABLE IF NOT EXISTS bunny_region_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour RegionModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_region_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The unique ID of the region';

DEFINE FIELD IF NOT EXISTS name ON bunny_region_model
  TYPE option<string>
  COMMENT 'The display name of the region';

DEFINE FIELD IF NOT EXISTS price_per_gigabyte ON bunny_region_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'The traffic pricing per gigabyte for the region';

DEFINE FIELD IF NOT EXISTS region_code ON bunny_region_model
  TYPE option<string>
  COMMENT 'The region short code';

DEFINE FIELD IF NOT EXISTS continent_code ON bunny_region_model
  TYPE option<string>
  COMMENT 'The continent code of the region';

DEFINE FIELD IF NOT EXISTS country_code ON bunny_region_model
  TYPE option<string>
  COMMENT 'The country code of the region';

DEFINE FIELD IF NOT EXISTS latitude ON bunny_region_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'The latitude coordinate for this region';

DEFINE FIELD IF NOT EXISTS longitude ON bunny_region_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'The longitude coordinate for this region';

DEFINE FIELD IF NOT EXISTS allow_latency_routing ON bunny_region_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines weather this region can be selected as a DNS latency routing region';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_region_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_region_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
