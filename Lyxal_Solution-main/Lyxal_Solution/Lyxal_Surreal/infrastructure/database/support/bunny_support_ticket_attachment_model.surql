-- Table: bunny_support_ticket_attachment_model
-- Source: SupportTicketAttachmentModel
-- Description: Table pour SupportTicketAttachmentModel

DEFINE TABLE IF NOT EXISTS bunny_support_ticket_attachment_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Table pour SupportTicketAttachmentModel';

DEFINE FIELD IF NOT EXISTS content_url ON bunny_support_ticket_attachment_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS content_type ON bunny_support_ticket_attachment_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS size ON bunny_support_ticket_attachment_model
  TYPE int
  ASSERT $value != NONE
;

DEFINE FIELD IF NOT EXISTS thumbnails ON bunny_support_ticket_attachment_model
  TYPE option<array<option<string>>>
;

DEFINE FIELD IF NOT EXISTS file_name ON bunny_support_ticket_attachment_model
  TYPE option<string>
;

DEFINE FIELD IF NOT EXISTS id ON bunny_support_ticket_attachment_model
  TYPE int
  ASSERT $value != NONE
;

-- Métadonnées de synchronisation
DEFINE FIELD IF NOT EXISTS metadata ON bunny_support_ticket_attachment_model
  TYPE object
  COMMENT 'Métadonnées de synchronisation Lyxal';

DEFINE FIELD IF NOT EXISTS metadata.synced_at ON bunny_support_ticket_attachment_model
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de dernière synchronisation';
