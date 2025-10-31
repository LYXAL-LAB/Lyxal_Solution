-- Table: bunny_video_library_model
-- Source: VideoLibraryModel
-- Description: Table pour VideoLibraryModel

DEFINE TABLE IF NOT EXISTS bunny_video_library_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour VideoLibraryModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS name ON bunny_video_library_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS video_count ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The number of videos in the video library';

DEFINE FIELD IF NOT EXISTS traffic_usage ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The amount of traffic usage this month';

DEFINE FIELD IF NOT EXISTS storage_usage ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The total amount of storage used by the library';

DEFINE FIELD IF NOT EXISTS date_created ON bunny_video_library_model
  TYPE datetime
  ASSERT $value != NONE
  COMMENT 'The date when the video library was created';

DEFINE FIELD IF NOT EXISTS replication_regions ON bunny_video_library_model
  TYPE option<array<option<string>>>
  COMMENT 'The geo-replication regions of the underlying storage zone';

DEFINE FIELD IF NOT EXISTS api_key ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The API key used for authenticating with the video library';

DEFINE FIELD IF NOT EXISTS read_only_api_key ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The read-only API key used for authenticating with the video library';

DEFINE FIELD IF NOT EXISTS has_watermark ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the video library has a watermark configured';

DEFINE FIELD IF NOT EXISTS watermark_position_left ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The left offset of the watermark position (in %)';

DEFINE FIELD IF NOT EXISTS watermark_position_top ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The top offset of the watermark position (in %)';

DEFINE FIELD IF NOT EXISTS watermark_width ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The width of the watermark (in %)';

DEFINE FIELD IF NOT EXISTS pull_zone_id ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The ID of the connected underlying pull zone';

DEFINE FIELD IF NOT EXISTS storage_zone_id ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The ID of the connected underlying storage zone';

DEFINE FIELD IF NOT EXISTS watermark_height ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The height of the watermark (in %)';

DEFINE FIELD IF NOT EXISTS enabled_resolutions ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The comma separated list of enabled resolutions';

DEFINE FIELD IF NOT EXISTS vi_ai_publisher_id ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The vi.ai publisher id for advertising configuration';

DEFINE FIELD IF NOT EXISTS vast_tag_url ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The URL of the VAST tag endpoint for advertising configuration';

DEFINE FIELD IF NOT EXISTS webhook_url ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The webhook URL of the video library';

DEFINE FIELD IF NOT EXISTS captions_font_size ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The captions display font size';

DEFINE FIELD IF NOT EXISTS captions_font_color ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The captions display font color';

DEFINE FIELD IF NOT EXISTS captions_background ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The captions display background color';

DEFINE FIELD IF NOT EXISTS u_i_language ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The UI language of the player';

DEFINE FIELD IF NOT EXISTS allow_early_play ON bunny_video_library_model
  TYPE option<bool>
  COMMENT 'Determines if the Early-Play feature is enabled';

DEFINE FIELD IF NOT EXISTS player_token_authentication_enabled ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the player token authentication is enabled';

DEFINE FIELD IF NOT EXISTS allowed_referrers ON bunny_video_library_model
  TYPE option<array<option<string>>>
  COMMENT 'The list of allowed referrer domains allowed to access the library';

DEFINE FIELD IF NOT EXISTS blocked_referrers ON bunny_video_library_model
  TYPE option<array<option<string>>>
  COMMENT 'The list of blocked referrer domains blocked from accessing the library';

DEFINE FIELD IF NOT EXISTS block_none_referrer ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the requests without a referrer are blocked';

DEFINE FIELD IF NOT EXISTS enable_m_p4_fallback ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the MP4 fallback feature is enabled';

DEFINE FIELD IF NOT EXISTS keep_original_files ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the original video files should be stored after encoding';

DEFINE FIELD IF NOT EXISTS allow_direct_play ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines direct play URLs are enabled for the library';

DEFINE FIELD IF NOT EXISTS enable_d_r_m ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the DRM is enabled';

DEFINE FIELD IF NOT EXISTS drm_version ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'DRM version (basic or enterprise)';

DEFINE FIELD IF NOT EXISTS apple_fair_play_drm ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'Described Apple FairPlay DRM';

DEFINE FIELD IF NOT EXISTS google_widevine_drm ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'Describes Google Widevine DRM';

DEFINE FIELD IF NOT EXISTS bitrate240p ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The bitrate used for encoding 240p videos';

DEFINE FIELD IF NOT EXISTS bitrate360p ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The bitrate used for encoding 360p videos';

DEFINE FIELD IF NOT EXISTS bitrate480p ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The bitrate used for encoding 480p videos';

DEFINE FIELD IF NOT EXISTS bitrate720p ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The bitrate used for encoding 720p videos';

DEFINE FIELD IF NOT EXISTS bitrate1080p ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The bitrate used for encoding 1080p videos';

DEFINE FIELD IF NOT EXISTS bitrate1440p ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The bitrate used for encoding 1440p videos';

DEFINE FIELD IF NOT EXISTS bitrate2160p ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
  COMMENT 'The bitrate used for encoding 2160p videos';

DEFINE FIELD IF NOT EXISTS api_access_key ON bunny_video_library_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS show_heatmap ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the video watch heatmap should be displayed in the player.';

DEFINE FIELD IF NOT EXISTS enable_content_tagging ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if content tagging should be enabled for this library.';

DEFINE FIELD IF NOT EXISTS pull_zone_type ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The type of the pull zone attached. Premium = 0, Volume = 1';

DEFINE FIELD IF NOT EXISTS custom_h_t_m_l ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The custom HTMl that is added into the head of the HTML player.';

DEFINE FIELD IF NOT EXISTS controls ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The list of controls on the video player.';

DEFINE FIELD IF NOT EXISTS playback_speeds ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The list of playback speeds available in the video player.';

DEFINE FIELD IF NOT EXISTS player_key_color ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The key color of the player.';

DEFINE FIELD IF NOT EXISTS font_family ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'The captions font family.';

DEFINE FIELD IF NOT EXISTS watermark_version ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS enable_transcribing ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the automatic audio transcribing is currently enabled for this zone.';

DEFINE FIELD IF NOT EXISTS enable_transcribing_title_generation ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if automatic transcribing title generation is currently enabled.';

DEFINE FIELD IF NOT EXISTS enable_transcribing_description_generation ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if automatic transcribing description generation is currently enabled.';

DEFINE FIELD IF NOT EXISTS transcribing_caption_languages ON bunny_video_library_model
  TYPE option<array<option<string>>>
  COMMENT 'The list of languages that the captions will be automatically transcribed to.';

DEFINE FIELD IF NOT EXISTS remember_player_position ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if the player will automatically remember the playback position.';

DEFINE FIELD IF NOT EXISTS enable_multi_audio_track_support ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines if multiple output audio track support is enabled on video library.';

DEFINE FIELD IF NOT EXISTS use_separate_audio_stream ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines whether output audio stream should be split from video stream segments.';

DEFINE FIELD IF NOT EXISTS jit_encoding_enabled ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Determines whether JIT encoding should be used for the library. Supported in premium encoding only.';

DEFINE FIELD IF NOT EXISTS encoding_tier ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'Defines encoding tier to be used with video library. premium is a paid tier that offers either JIT encoding or prioritized encoding and extra codec support.';

DEFINE FIELD IF NOT EXISTS output_codecs ON bunny_video_library_model
  TYPE option<string>
  COMMENT 'Specifies which video codecs are used for encoding, provided as a comma-separated (CSV) string. Free encoding tier supports only x264. A premium encoding tier adds support for vp9, hevc, and av1.';

DEFINE FIELD IF NOT EXISTS drm_base_price_override ON bunny_video_library_model
  TYPE option<float>
  COMMENT 'DRM (enterprise) monthly base price for this video library if it differs from list price.';

DEFINE FIELD IF NOT EXISTS drm_cost_per_license_override ON bunny_video_library_model
  TYPE option<float>
  COMMENT 'DRM (enterprise) cost per license for this video library if it differs from list price.';

DEFINE FIELD IF NOT EXISTS transcribing_price_override ON bunny_video_library_model
  TYPE option<float>
;

DEFINE FIELD IF NOT EXISTS premium_encoding_price_override ON bunny_video_library_model
  TYPE option<float>
;

DEFINE FIELD IF NOT EXISTS monthly_charges_transcribing ON bunny_video_library_model
  TYPE float
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS monthly_charges_premium_encoding ON bunny_video_library_model
  TYPE float
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS monthly_charges_enterprise_drm ON bunny_video_library_model
  TYPE float
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS feature_flags ON bunny_video_library_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS player_version ON bunny_video_library_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS remove_metadata_from_fallback_videos ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Marks whether all potential video metadata should be removed from the fallback files. Default false.';

DEFINE FIELD IF NOT EXISTS scale_video_using_both_dimensions ON bunny_video_library_model
  TYPE bool
  ASSERT $value != NONE
  COMMENT 'Marks whether videos should be scaled using both dimensions. Prevents videos being upscaled or unexpected aspect ratio changes. Default true.';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_video_library_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_video_library_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
