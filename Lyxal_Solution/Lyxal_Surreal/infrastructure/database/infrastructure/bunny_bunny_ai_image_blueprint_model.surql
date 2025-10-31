-- Table: bunny_bunny_ai_image_blueprint_model
-- Source: BunnyAiImageBlueprintModel
-- Description: Table pour BunnyAiImageBlueprintModel

DEFINE TABLE IF NOT EXISTS bunny_bunny_ai_image_blueprint_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour BunnyAiImageBlueprintModel';

DEFINE FIELD IF NOT EXISTS name ON bunny_bunny_ai_image_blueprint_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS properties ON bunny_bunny_ai_image_blueprint_model
  TYPE option<object>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_bunny_ai_image_blueprint_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_bunny_ai_image_blueprint_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
