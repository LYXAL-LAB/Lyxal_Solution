-- Table: bunny_transcribe_settings
-- Source: TranscribeSettings
-- Description: Table pour TranscribeSettings

DEFINE TABLE IF NOT EXISTS bunny_transcribe_settings TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour TranscribeSettings';

DEFINE FIELD IF NOT EXISTS target_languages ON bunny_transcribe_settings
  TYPE option<array<option<string>>>
  COMMENT 'List of languages that will be used as target languages, use ISO 639-1 language codes.';

DEFINE FIELD IF NOT EXISTS generate_title ON bunny_transcribe_settings
  TYPE option<bool>
  COMMENT 'Whether video title should be automatically generated.';

DEFINE FIELD IF NOT EXISTS generate_description ON bunny_transcribe_settings
  TYPE option<bool>
  COMMENT 'Whether video description should be automatically generated.';

DEFINE FIELD IF NOT EXISTS generate_chapters ON bunny_transcribe_settings
  TYPE option<bool>
  COMMENT 'Whether video chapters should be automatically generated.';

DEFINE FIELD IF NOT EXISTS generate_moments ON bunny_transcribe_settings
  TYPE option<bool>
  COMMENT 'Whether video moments should be automatically generated.';

DEFINE FIELD IF NOT EXISTS source_language ON bunny_transcribe_settings
  TYPE option<string>
  COMMENT 'Video source language, use ISO 639-1 language code.';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_transcribe_settings
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_transcribe_settings
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
