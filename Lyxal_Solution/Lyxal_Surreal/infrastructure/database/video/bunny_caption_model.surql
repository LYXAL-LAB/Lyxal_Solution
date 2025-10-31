-- Table: bunny_caption_model
-- Source: CaptionModel
-- Description: Table pour CaptionModel

DEFINE TABLE IF NOT EXISTS bunny_caption_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour CaptionModel';

DEFINE FIELD IF NOT EXISTS srclang ON bunny_caption_model
  TYPE option<string>
  COMMENT 'The unique srclang shortcode for the caption';

DEFINE FIELD IF NOT EXISTS label ON bunny_caption_model
  TYPE option<string>
  COMMENT 'The text description label for the caption';

DEFINE FIELD IF NOT EXISTS version ON bunny_caption_model
  TYPE option<int>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_caption_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_caption_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
