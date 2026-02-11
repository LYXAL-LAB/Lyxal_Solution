-- Table: bunny_abuse_case_url_model
-- Source: AbuseCaseUrlModel
-- Description: Table pour AbuseCaseUrlModel

DEFINE TABLE IF NOT EXISTS bunny_abuse_case_url_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour AbuseCaseUrlModel';

DEFINE FIELD IF NOT EXISTS url ON bunny_abuse_case_url_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS status ON bunny_abuse_case_url_model
  TYPE option<record<abuse_url_status>>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_abuse_case_url_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_abuse_case_url_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
