-- Table: bunny_google_widevine_drm
-- Source: GoogleWidevineDrm
-- Description: Table pour GoogleWidevineDrm

DEFINE TABLE IF NOT EXISTS bunny_google_widevine_drm TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour GoogleWidevineDrm';

DEFINE FIELD IF NOT EXISTS enabled ON bunny_google_widevine_drm
  TYPE bool
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS certificate_id ON bunny_google_widevine_drm
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS certificate_expiration_date ON bunny_google_widevine_drm
  TYPE option<datetime>
;

DEFINE FIELD IF NOT EXISTS provider ON bunny_google_widevine_drm
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS sd_only_for_l3 ON bunny_google_widevine_drm
  TYPE bool
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS min_client_security_level ON bunny_google_widevine_drm
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_google_widevine_drm
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_google_widevine_drm
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
