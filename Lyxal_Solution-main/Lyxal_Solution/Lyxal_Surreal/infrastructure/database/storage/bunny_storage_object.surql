-- Table: bunny_storage_object
-- Source: StorageObject
-- Description: Table pour StorageObject

DEFINE TABLE IF NOT EXISTS bunny_storage_object TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour StorageObject';

DEFINE FIELD IF NOT EXISTS guid ON bunny_storage_object
  TYPE option<string>
  COMMENT 'The unique Guid that represents the file';

DEFINE FIELD IF NOT EXISTS storage_zone_name ON bunny_storage_object
  TYPE option<string>
  COMMENT 'The full hostname domain value';

DEFINE FIELD IF NOT EXISTS path ON bunny_storage_object
  TYPE option<string>
  COMMENT 'True directory path where the object is located';

DEFINE FIELD IF NOT EXISTS object_name ON bunny_storage_object
  TYPE option<string>
  COMMENT 'The name of the object, file or directory name';

DEFINE FIELD IF NOT EXISTS length ON bunny_storage_object
  TYPE option<int>
  COMMENT 'The size of the file';

DEFINE FIELD IF NOT EXISTS last_changed ON bunny_storage_object
  TYPE option<string>
  COMMENT 'The time when the file was last changed';

DEFINE FIELD IF NOT EXISTS is_directory ON bunny_storage_object
  TYPE option<bool>
  COMMENT 'True if this is a directory object, false if it\'s a file';

DEFINE FIELD IF NOT EXISTS server_id ON bunny_storage_object
  TYPE option<int>
  COMMENT 'The ID of the physical server that holds the file';

DEFINE FIELD IF NOT EXISTS user_id ON bunny_storage_object
  TYPE option<string>
  COMMENT 'The ID of the user that holds the file';

DEFINE FIELD IF NOT EXISTS date_created ON bunny_storage_object
  TYPE option<string>
  COMMENT 'The date and time when the object was first created';

DEFINE FIELD IF NOT EXISTS storage_zone_id ON bunny_storage_object
  TYPE option<int>
  COMMENT 'The storage zone ID to which the file belongs';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_storage_object
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_storage_object
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
