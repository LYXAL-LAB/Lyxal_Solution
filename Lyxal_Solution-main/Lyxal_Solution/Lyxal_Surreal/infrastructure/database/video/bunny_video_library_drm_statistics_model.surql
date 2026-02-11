-- Table: bunny_video_library_drm_statistics_model
-- Source: VideoLibraryDrmStatisticsModel
-- Description: Table pour VideoLibraryDrmStatisticsModel

DEFINE TABLE IF NOT EXISTS bunny_video_library_drm_statistics_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour VideoLibraryDrmStatisticsModel';

DEFINE FIELD IF NOT EXISTS total_licenses_issued ON bunny_video_library_drm_statistics_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS licenses_issued_chart ON bunny_video_library_drm_statistics_model
  TYPE option<object>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_video_library_drm_statistics_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_video_library_drm_statistics_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
