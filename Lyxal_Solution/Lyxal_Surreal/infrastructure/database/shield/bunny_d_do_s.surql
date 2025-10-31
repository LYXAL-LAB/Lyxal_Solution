-- Table: bunny_d_do_s
-- Source: DDoS
-- Description: Table pour DDoS

DEFINE TABLE IF NOT EXISTS bunny_d_do_s TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour DDoS';

DEFINE FIELD IF NOT EXISTS logged_requests ON bunny_d_do_s
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS verified_requests ON bunny_d_do_s
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS blocked_requests ON bunny_d_do_s
  TYPE option<int>
;

DEFINE FIELD IF NOT EXISTS challenged_requests ON bunny_d_do_s
  TYPE option<int>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_d_do_s
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_d_do_s
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
