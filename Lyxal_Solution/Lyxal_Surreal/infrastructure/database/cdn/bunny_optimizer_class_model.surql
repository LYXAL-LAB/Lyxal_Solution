-- Table: bunny_optimizer_class_model
-- Source: OptimizerClassModel
-- Description: Table pour OptimizerClassModel

DEFINE TABLE IF NOT EXISTS bunny_optimizer_class_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour OptimizerClassModel';

DEFINE FIELD IF NOT EXISTS name ON bunny_optimizer_class_model
  TYPE option<string>
  COMMENT 'The name of the optimizer class that will be used in the query string';

DEFINE FIELD IF NOT EXISTS properties ON bunny_optimizer_class_model
  TYPE option<object>
  COMMENT 'The list of settings and values the class will send to the optimizer';

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_optimizer_class_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_optimizer_class_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
