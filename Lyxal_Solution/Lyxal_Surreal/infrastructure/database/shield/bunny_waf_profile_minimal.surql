-- Table: bunny_waf_profile_minimal
-- Source: WafProfileMinimal
-- Description: Table pour WafProfileMinimal

DEFINE TABLE IF NOT EXISTS bunny_waf_profile_minimal TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour WafProfileMinimal';

DEFINE FIELD IF NOT EXISTS id ON bunny_waf_profile_minimal
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS name ON bunny_waf_profile_minimal
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS is_premium ON bunny_waf_profile_minimal
  TYPE option<bool>
;

DEFINE FIELD IF NOT EXISTS profile_category ON bunny_waf_profile_minimal
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS image_url ON bunny_waf_profile_minimal
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS description ON bunny_waf_profile_minimal
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS features ON bunny_waf_profile_minimal
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_waf_profile_minimal
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_waf_profile_minimal
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
