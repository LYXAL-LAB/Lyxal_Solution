-- Table: bunny_support_ticket_model
-- Source: SupportTicketModel
-- Description: Table pour SupportTicketModel

DEFINE TABLE IF NOT EXISTS bunny_support_ticket_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour SupportTicketModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_support_ticket_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS status ON bunny_support_ticket_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS comments ON bunny_support_ticket_model
  TYPE option<array<option<record<support_ticket_comment_model>>>>
;

DEFINE FIELD IF NOT EXISTS subject ON bunny_support_ticket_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS created_at ON bunny_support_ticket_model
  TYPE datetime
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS last_updated_at ON bunny_support_ticket_model
  TYPE datetime
  ASSERT $value != NONE
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_support_ticket_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_support_ticket_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
