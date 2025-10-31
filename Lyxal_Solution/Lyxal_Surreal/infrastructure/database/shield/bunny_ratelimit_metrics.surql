-- Table: bunny_ratelimit_metrics
-- Source: RatelimitMetrics
-- Description: Table pour RatelimitMetrics

DEFINE TABLE IF NOT EXISTS bunny_ratelimit_metrics TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour RatelimitMetrics';

DEFINE FIELD IF NOT EXISTS overview ON bunny_ratelimit_metrics
  TYPE option<record<individual_ratelimit>>
;

DEFINE FIELD IF NOT EXISTS ratelimit_overview_past_twenty_eight_days ON bunny_ratelimit_metrics
  TYPE option<object>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_ratelimit_metrics
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_ratelimit_metrics
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
