-- Table: bunny_waf_mapped_enum_list
-- Source: WafMappedEnumList
-- Description: Table pour WafMappedEnumList

DEFINE TABLE IF NOT EXISTS bunny_waf_mapped_enum_list TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour WafMappedEnumList';

DEFINE FIELD IF NOT EXISTS enum_name ON bunny_waf_mapped_enum_list
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS enum_values ON bunny_waf_mapped_enum_list
  TYPE option<array<option<record<waf_mapped_enum>>>>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_waf_mapped_enum_list
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_waf_mapped_enum_list
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
