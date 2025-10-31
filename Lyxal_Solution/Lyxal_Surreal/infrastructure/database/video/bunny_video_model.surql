-- Table: bunny_video_model
-- Source: VideoModel
-- Description: Table pour VideoModel

DEFINE TABLE IF NOT EXISTS bunny_video_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour VideoModel';

DEFINE FIELD IF NOT EXISTS video_library_id ON bunny_video_model
  TYPE option<int>
  COMMENT 'The ID of the video library that the video belongs to';

DEFINE FIELD IF NOT EXISTS guid ON bunny_video_model
  TYPE option<string>
  COMMENT 'The unique ID of the video';

DEFINE FIELD IF NOT EXISTS title ON bunny_video_model
  TYPE option<string>
  COMMENT 'The title of the video';

DEFINE FIELD IF NOT EXISTS description ON bunny_video_model
  TYPE option<string>
  COMMENT 'The description of the video';

DEFINE FIELD IF NOT EXISTS date_uploaded ON bunny_video_model
  TYPE option<datetime>
  COMMENT 'The date when the video was uploaded';

DEFINE FIELD IF NOT EXISTS views ON bunny_video_model
  TYPE option<int>
  COMMENT 'The number of views the video received';

DEFINE FIELD IF NOT EXISTS is_public ON bunny_video_model
  TYPE option<bool>
  COMMENT 'Determines if the video is publically accessible';

DEFINE FIELD IF NOT EXISTS length ON bunny_video_model
  TYPE option<int>
  COMMENT 'The duration of the video in seconds';

DEFINE FIELD IF NOT EXISTS status ON bunny_video_model
  TYPE option<string>
  COMMENT 'The status of the video. See VideoModelStatus.';

DEFINE FIELD IF NOT EXISTS framerate ON bunny_video_model
  TYPE option<float>
  COMMENT 'The framerate of the video';

DEFINE FIELD IF NOT EXISTS rotation ON bunny_video_model
  TYPE option<int>
  COMMENT 'The rotation of the video';

DEFINE FIELD IF NOT EXISTS width ON bunny_video_model
  TYPE option<int>
  COMMENT 'The width of the original video file';

DEFINE FIELD IF NOT EXISTS height ON bunny_video_model
  TYPE option<int>
  COMMENT 'The height of the original video file';

DEFINE FIELD IF NOT EXISTS available_resolutions ON bunny_video_model
  TYPE option<string>
  COMMENT 'The available resolutions of the video';

DEFINE FIELD IF NOT EXISTS output_codecs ON bunny_video_model
  TYPE option<string>
  COMMENT 'Encoded output codecs of the video';

DEFINE FIELD IF NOT EXISTS thumbnail_count ON bunny_video_model
  TYPE option<int>
  COMMENT 'The number of thumbnails generated for this video';

DEFINE FIELD IF NOT EXISTS encode_progress ON bunny_video_model
  TYPE option<int>
  COMMENT 'The current encode progress of the video';

DEFINE FIELD IF NOT EXISTS storage_size ON bunny_video_model
  TYPE option<int>
  COMMENT 'The amount of storage used by this video';

DEFINE FIELD IF NOT EXISTS captions ON bunny_video_model
  TYPE option<array<option<record<caption_model>>>>
  COMMENT 'The list of captions available for the video';

DEFINE FIELD IF NOT EXISTS has_m_p4_fallback ON bunny_video_model
  TYPE option<bool>
  COMMENT 'Determines if the video has MP4 fallback files generated';

DEFINE FIELD IF NOT EXISTS collection_id ON bunny_video_model
  TYPE option<string>
  COMMENT 'The ID of the collection where the video belongs';

DEFINE FIELD IF NOT EXISTS thumbnail_file_name ON bunny_video_model
  TYPE option<string>
  COMMENT 'The file name of the thumbnail inside of the storage';

DEFINE FIELD IF NOT EXISTS thumbnail_blurhash ON bunny_video_model
  TYPE option<string>
  COMMENT 'Thumbnail blurhash to show while the actual thumbnail is being loaded';

DEFINE FIELD IF NOT EXISTS average_watch_time ON bunny_video_model
  TYPE option<int>
  COMMENT 'The average watch time of the video in seconds';

DEFINE FIELD IF NOT EXISTS total_watch_time ON bunny_video_model
  TYPE option<int>
  COMMENT 'The total video watch time in seconds';

DEFINE FIELD IF NOT EXISTS category ON bunny_video_model
  TYPE option<string>
  COMMENT 'The automatically detected category of the video';

DEFINE FIELD IF NOT EXISTS chapters ON bunny_video_model
  TYPE option<array<option<record<chapter_model>>>>
  COMMENT 'The list of chapters available for the video';

DEFINE FIELD IF NOT EXISTS moments ON bunny_video_model
  TYPE option<array<option<record<moment_model>>>>
  COMMENT 'The list of moments available for the video';

DEFINE FIELD IF NOT EXISTS meta_tags ON bunny_video_model
  TYPE option<array<option<record<meta_tag_model>>>>
  COMMENT 'The list of meta tags that have been added to the video';

DEFINE FIELD IF NOT EXISTS transcoding_messages ON bunny_video_model
  TYPE option<array<option<record<transcoding_message_model>>>>
  COMMENT 'The list of transcoding messages that describe potential issues while the video was transcoding';

DEFINE FIELD IF NOT EXISTS jit_encoding_enabled ON bunny_video_model
  TYPE option<bool>
;

DEFINE FIELD IF NOT EXISTS smart_generate_status ON bunny_video_model
  TYPE option<string>
  COMMENT 'The status of smart generate action (if triggered)';

DEFINE FIELD IF NOT EXISTS has_original ON bunny_video_model
  TYPE option<bool>
  COMMENT 'Determines if video has the original file available in storage';

DEFINE FIELD IF NOT EXISTS original_hash ON bunny_video_model
  TYPE option<string>
  COMMENT 'Original uploaded file SHA256 hash';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_video_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_video_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
