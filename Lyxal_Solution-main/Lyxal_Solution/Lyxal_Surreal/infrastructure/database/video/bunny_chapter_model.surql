-- Table: bunny_chapter_model
-- Source: ChapterModel
-- Description: Table pour ChapterModel

DEFINE TABLE IF NOT EXISTS bunny_chapter_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour ChapterModel';

DEFINE FIELD IF NOT EXISTS title ON bunny_chapter_model
  TYPE string
  ASSERT $value != NONE
  COMMENT 'The title of the chapter';

DEFINE FIELD IF NOT EXISTS start ON bunny_chapter_model
  TYPE option<int>
  COMMENT 'The start time of the chapter in seconds';

DEFINE FIELD IF NOT EXISTS end ON bunny_chapter_model
  TYPE option<int>
  COMMENT 'The end time of the chapter in seconds';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_chapter_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_chapter_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
