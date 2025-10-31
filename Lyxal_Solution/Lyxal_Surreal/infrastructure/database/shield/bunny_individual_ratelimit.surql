-- Table: bunny_individual_ratelimit
-- Source: IndividualRatelimit
-- Description: Table pour IndividualRatelimit

DEFINE TABLE IF NOT EXISTS bunny_individual_ratelimit TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour IndividualRatelimit';

DEFINE FIELD IF NOT EXISTS total_breaches ON bunny_individual_ratelimit
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS logged_breaches ON bunny_individual_ratelimit
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS challenged_breaches ON bunny_individual_ratelimit
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS blocked_breaches ON bunny_individual_ratelimit
  TYPE option<int>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_individual_ratelimit
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_individual_ratelimit
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
