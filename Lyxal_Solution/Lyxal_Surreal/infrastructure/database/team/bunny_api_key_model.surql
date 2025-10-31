-- Table: bunny_api_key_model
-- Source: ApiKeyModel
-- Description: Table pour ApiKeyModel

DEFINE TABLE IF NOT EXISTS bunny_api_key_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour ApiKeyModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_api_key_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS key ON bunny_api_key_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS roles ON bunny_api_key_model
  TYPE option<array<option<string>>>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_api_key_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_api_key_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
