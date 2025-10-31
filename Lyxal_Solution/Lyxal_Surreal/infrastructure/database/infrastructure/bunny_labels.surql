-- Table: bunny_labels
-- Source: Labels
-- Description: Table pour Labels

DEFINE TABLE IF NOT EXISTS bunny_labels TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour Labels';

DEFINE FIELD IF NOT EXISTS asn ON bunny_labels
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS country ON bunny_labels
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_id ON bunny_labels
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS severity ON bunny_labels
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS method ON bunny_labels
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS rule_group ON bunny_labels
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS status ON bunny_labels
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS server_zone ON bunny_labels
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_labels
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_labels
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
