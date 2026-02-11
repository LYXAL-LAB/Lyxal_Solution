-- Table: bunny_support_ticket_user_model
-- Source: SupportTicketUserModel
-- Description: Table pour SupportTicketUserModel

DEFINE TABLE IF NOT EXISTS bunny_support_ticket_user_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour SupportTicketUserModel';

DEFINE FIELD IF NOT EXISTS name ON bunny_support_ticket_user_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS external_id ON bunny_support_ticket_user_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS alias ON bunny_support_ticket_user_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS verified ON bunny_support_ticket_user_model
  TYPE bool
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS signature ON bunny_support_ticket_user_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS role ON bunny_support_ticket_user_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS photo_url ON bunny_support_ticket_user_model
  TYPE option<string>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_support_ticket_user_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_support_ticket_user_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
