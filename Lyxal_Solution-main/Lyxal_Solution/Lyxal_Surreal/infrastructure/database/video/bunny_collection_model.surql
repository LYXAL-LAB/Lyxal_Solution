-- Table: bunny_collection_model
-- Source: CollectionModel
-- Description: Table pour CollectionModel

DEFINE TABLE IF NOT EXISTS bunny_collection_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour CollectionModel';

DEFINE FIELD IF NOT EXISTS video_library_id ON bunny_collection_model
  TYPE option<int>
  COMMENT 'The video library ID that contains the collection';

DEFINE FIELD IF NOT EXISTS guid ON bunny_collection_model
  TYPE option<string>
  COMMENT 'The unique ID of the collection';

DEFINE FIELD IF NOT EXISTS name ON bunny_collection_model
  TYPE option<string>
  COMMENT 'The name of the collection';

DEFINE FIELD IF NOT EXISTS video_count ON bunny_collection_model
  TYPE option<int>
  COMMENT 'The number of videos that the collection contains';

DEFINE FIELD IF NOT EXISTS total_size ON bunny_collection_model
  TYPE option<int>
  COMMENT 'The total storage size of the collection';

DEFINE FIELD IF NOT EXISTS preview_video_ids ON bunny_collection_model
  TYPE option<string>
  COMMENT 'The IDs of videos to be used as preview icons';

DEFINE FIELD IF NOT EXISTS preview_image_urls ON bunny_collection_model
  TYPE option<array<option<string>>>
  COMMENT 'The URLs of preview images of videos in the collection';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_collection_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_collection_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
