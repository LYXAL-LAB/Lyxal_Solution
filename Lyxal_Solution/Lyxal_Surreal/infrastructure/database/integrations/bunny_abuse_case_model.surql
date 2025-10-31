-- Table: bunny_abuse_case_model
-- Source: AbuseCaseModel
-- Description: Table pour AbuseCaseModel

DEFINE TABLE IF NOT EXISTS bunny_abuse_case_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour AbuseCaseModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_abuse_case_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS actual_url ON bunny_abuse_case_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS date_created ON bunny_abuse_case_model
  TYPE datetime
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS date_updated ON bunny_abuse_case_model
  TYPE datetime
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS deadline ON bunny_abuse_case_model
  TYPE datetime
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS pull_zone_id ON bunny_abuse_case_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS pull_zone_name ON bunny_abuse_case_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS path ON bunny_abuse_case_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS message ON bunny_abuse_case_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS status ON bunny_abuse_case_model
  TYPE option<string>
  COMMENT 'Determines if the Pull Zone is currently enabled, active and running';

DEFINE FIELD IF NOT EXISTS urls ON bunny_abuse_case_model
  TYPE option<array<option<record<abuse_case_url_model>>>>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_abuse_case_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_abuse_case_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
