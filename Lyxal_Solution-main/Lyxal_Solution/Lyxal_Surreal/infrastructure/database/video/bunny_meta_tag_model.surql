-- Table: bunny_meta_tag_model
-- Source: MetaTagModel
-- Description: Table pour MetaTagModel

DEFINE TABLE IF NOT EXISTS bunny_meta_tag_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour MetaTagModel';

DEFINE FIELD IF NOT EXISTS property ON bunny_meta_tag_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS value ON bunny_meta_tag_model
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_meta_tag_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_meta_tag_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
