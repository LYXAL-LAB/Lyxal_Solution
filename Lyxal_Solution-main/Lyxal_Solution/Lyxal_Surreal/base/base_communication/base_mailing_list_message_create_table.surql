-- ================================================================================
-- MODULE: BASE SOUS MODULE : COMMUNICATION
-- TABLE: base_mailing_list_message (MailingListMessage)
-- MESSAGES DE LISTE DE DIFFUSION
-- ================================================================================

-- Messages de liste de diffusion
DEFINE TABLE IF NOT EXISTS base_mailing_list_message TYPE NORMAL SCHEMAFULL
COMMENT "Messages de liste de diffusion"
PERMISSIONS FULL;

-- Identification
DEFINE FIELD subject ON base_mailing_list_message TYPE string
COMMENT "Sujet du message";
DEFINE FIELD content ON base_mailing_list_message TYPE string
COMMENT "Contenu du message";
DEFINE FIELD sender ON base_mailing_list_message TYPE record<base_user>
COMMENT "Expéditeur du message";
DEFINE FIELD recipient_list ON base_mailing_list_message TYPE array<record<base_partner>>
COMMENT "Liste des destinataires";
DEFINE FIELD sent_date ON base_mailing_list_message TYPE datetime
COMMENT "Date d'envoi";
DEFINE FIELD created_at ON base_mailing_list_message TYPE datetime DEFAULT time::now()
COMMENT "Date de création";
DEFINE FIELD updated_at ON base_mailing_list_message TYPE datetime DEFAULT time::now()
COMMENT "Date de mise à jour";