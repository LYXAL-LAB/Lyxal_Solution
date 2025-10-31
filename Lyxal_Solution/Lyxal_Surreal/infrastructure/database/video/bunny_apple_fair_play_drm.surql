-- Table: bunny_apple_fair_play_drm
-- Source: AppleFairPlayDrm
-- Description: Table pour AppleFairPlayDrm

DEFINE TABLE IF NOT EXISTS bunny_apple_fair_play_drm TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour AppleFairPlayDrm';

DEFINE FIELD IF NOT EXISTS enabled ON bunny_apple_fair_play_drm
  TYPE bool
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS certificate_id ON bunny_apple_fair_play_drm
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS certificate_expiration_date ON bunny_apple_fair_play_drm
  TYPE option<datetime>
;

DEFINE FIELD IF NOT EXISTS provider ON bunny_apple_fair_play_drm
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_apple_fair_play_drm
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_apple_fair_play_drm
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
