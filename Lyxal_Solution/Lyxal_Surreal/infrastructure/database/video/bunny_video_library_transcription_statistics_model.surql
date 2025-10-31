-- Table: bunny_video_library_transcription_statistics_model
-- Source: VideoLibraryTranscriptionStatisticsModel
-- Description: Table pour VideoLibraryTranscriptionStatisticsModel

DEFINE TABLE IF NOT EXISTS bunny_video_library_transcription_statistics_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour VideoLibraryTranscriptionStatisticsModel';

DEFINE FIELD IF NOT EXISTS total_transcription_seconds ON bunny_video_library_transcription_statistics_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS transcription_seconds_chart ON bunny_video_library_transcription_statistics_model
  TYPE option<object>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_video_library_transcription_statistics_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_video_library_transcription_statistics_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
