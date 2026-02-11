-- Table: bunny_support_ticket_comment_model
-- Source: SupportTicketCommentModel
-- Description: Table pour SupportTicketCommentModel

DEFINE TABLE IF NOT EXISTS bunny_support_ticket_comment_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour SupportTicketCommentModel';

DEFINE FIELD IF NOT EXISTS id ON bunny_support_ticket_comment_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS type ON bunny_support_ticket_comment_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS body ON bunny_support_ticket_comment_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS html_body ON bunny_support_ticket_comment_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS public ON bunny_support_ticket_comment_model
  TYPE bool
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS author_id ON bunny_support_ticket_comment_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS created_at ON bunny_support_ticket_comment_model
  TYPE datetime
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS user ON bunny_support_ticket_comment_model
  TYPE option<record<support_ticket_user_model>>
;

DEFINE FIELD IF NOT EXISTS attachments ON bunny_support_ticket_comment_model
  TYPE option<array<option<record<support_ticket_attachment_model>>>>
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_support_ticket_comment_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_support_ticket_comment_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
