-- Table: bunny_storage_zone_model
-- Source: StorageZoneModel
-- Description: Table pour StorageZoneModel

DEFINE TABLE IF NOT EXISTS bunny_storage_zone_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour StorageZoneModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_storage_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The ID of the storage zone';

DEFINE FIELD IF NOT EXISTS user_id ON bunny_storage_zone_model
  TYPE option<string>
  COMMENT 'The ID of the user that owns the storage zone';

DEFINE FIELD IF NOT EXISTS name ON bunny_storage_zone_model
  TYPE option<string>
  COMMENT 'The name of the storage zone';

DEFINE FIELD IF NOT EXISTS password ON bunny_storage_zone_model
  TYPE option<string>
  COMMENT 'The API access key or FTP password';

DEFINE FIELD IF NOT EXISTS date_modified ON bunny_storage_zone_model
  TYPE datetime
  ASSERT $value != NONE
  COMMENT 'The date when the zone was last modified';

DEFINE FIELD IF NOT EXISTS deleted ON bunny_storage_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the zone was deleted or not';

DEFINE FIELD IF NOT EXISTS storage_used ON bunny_storage_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The total amount of storage used by this zone';

DEFINE FIELD IF NOT EXISTS files_stored ON bunny_storage_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The total number of files stored by this zone';

DEFINE FIELD IF NOT EXISTS region ON bunny_storage_zone_model
  TYPE option<string>
  COMMENT 'The main region used by the storage zone';

DEFINE FIELD IF NOT EXISTS replication_regions ON bunny_storage_zone_model
  TYPE option<array<option<string>>>
  COMMENT 'The replication regions enabled for this storage zone';

DEFINE FIELD IF NOT EXISTS pull_zones ON bunny_storage_zone_model
  TYPE option<array<option<record<pull_zone_model>>>>
  COMMENT 'The list of pull zones connected to this storage zone';

DEFINE FIELD IF NOT EXISTS read_only_password ON bunny_storage_zone_model
  TYPE option<string>
  COMMENT 'The read-only API access key or FTP password';

DEFINE FIELD IF NOT EXISTS rewrite404_to200 ON bunny_storage_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the storage zone will rewrite 404 status codes to 200 status codes';

DEFINE FIELD IF NOT EXISTS custom404_file_path ON bunny_storage_zone_model
  TYPE option<string>
  COMMENT 'The custom 404 error path that will be returned in case of a missing file.';

DEFINE FIELD IF NOT EXISTS storage_hostname ON bunny_storage_zone_model
  TYPE option<string>
  COMMENT 'Determines the storage hostname for this zone';

DEFINE FIELD IF NOT EXISTS zone_tier ON bunny_storage_zone_model
  TYPE option<string>
  COMMENT 'Determines the storage zone tier that is storing the data';

DEFINE FIELD IF NOT EXISTS replication_change_in_progress ON bunny_storage_zone_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the storage zone is currently enabling a new replication region';

DEFINE FIELD IF NOT EXISTS price_override ON bunny_storage_zone_model
  TYPE float
  ASSERT $value != NONE
  COMMENT 'The custom price override for this zone. Unit is $/TB/month.';

DEFINE FIELD IF NOT EXISTS discount ON bunny_storage_zone_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The Storage Zone specific pricing discount.';

DEFINE FIELD IF NOT EXISTS storage_zone_type ON bunny_storage_zone_model
  TYPE option<string>
  COMMENT 'The Storage Zone S3 support type';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_storage_zone_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_storage_zone_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
