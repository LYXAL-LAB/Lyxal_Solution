-- Table: bunny_waf_mapped_enum
-- Source: WafMappedEnum
-- Description: Table pour WafMappedEnum

DEFINE TABLE IF NOT EXISTS bunny_waf_mapped_enum TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour WafMappedEnum';

DEFINE FIELD IF NOT EXISTS optional_input ON bunny_waf_mapped_enum
  TYPE option<bool>
;

DEFINE FIELD IF NOT EXISTS is_premium ON bunny_waf_mapped_enum
  TYPE option<bool>
;

DEFINE FIELD IF NOT EXISTS name ON bunny_waf_mapped_enum
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS value ON bunny_waf_mapped_enum
  TYPE option<int>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_waf_mapped_enum
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_waf_mapped_enum
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
