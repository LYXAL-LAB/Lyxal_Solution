-- Table: bunny_video_resolutions_info_model
-- Source: VideoResolutionsInfoModel
-- Description: Table pour VideoResolutionsInfoModel

DEFINE TABLE IF NOT EXISTS bunny_video_resolutions_info_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour VideoResolutionsInfoModel';

DEFINE FIELD IF NOT EXISTS video_id ON bunny_video_resolutions_info_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS video_library_id ON bunny_video_resolutions_info_model
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS available_resolutions ON bunny_video_resolutions_info_model
  TYPE option<array<option<string>>>
;

DEFINE FIELD IF NOT EXISTS configured_resolutions ON bunny_video_resolutions_info_model
  TYPE option<array<option<string>>>
;

DEFINE FIELD IF NOT EXISTS playlist_resolutions ON bunny_video_resolutions_info_model
  TYPE option<array<option<record<resolution_reference>>>>
;

DEFINE FIELD IF NOT EXISTS storage_resolutions ON bunny_video_resolutions_info_model
  TYPE option<array<option<record<resolution_reference>>>>
;

DEFINE FIELD IF NOT EXISTS mp4_resolutions ON bunny_video_resolutions_info_model
  TYPE option<array<option<record<resolution_reference>>>>
;

DEFINE FIELD IF NOT EXISTS storage_objects ON bunny_video_resolutions_info_model
  TYPE option<array<option<record<storage_object_model>>>>
;

DEFINE FIELD IF NOT EXISTS old_resolutions ON bunny_video_resolutions_info_model
  TYPE option<array<option<record<storage_object_model>>>>
;

DEFINE FIELD IF NOT EXISTS has_both_old_and_new_resolution_format ON bunny_video_resolutions_info_model
  TYPE option<bool>
;

DEFINE FIELD IF NOT EXISTS has_original ON bunny_video_resolutions_info_model
  TYPE option<bool>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_video_resolutions_info_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_video_resolutions_info_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
