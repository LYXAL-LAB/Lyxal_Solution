-- =============================================================================
-- MODULE: BASE SOUS MODULE : COMMUNICATION
-- TABLE: base_message 
-- Messages et communications
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_message TYPE NORMAL SCHEMAFULL
COMMENT "Messages et communications"
PERMISSIONS FULL;

-- Champs principaux
DEFINE FIELD subject ON base_message TYPE string
COMMENT "Sujet du message";
DEFINE FIELD content ON base_message TYPE string
COMMENT "Contenu du message";
DEFINE FIELD media_type_select ON base_message TYPE int DEFAULT 1
COMMENT "Type de média"; -- 1:Email, 2:SMS, 3:Mail, 4:Fax, 5:Push
DEFINE FIELD status_select ON base_message TYPE int DEFAULT 1
COMMENT "Statut du message"; -- 1:Draft, 2:Sent, 3:Delivered, 4:Read, 5:Error

-- Expéditeur et destinataires
DEFINE FIELD sender_user ON base_message TYPE record<base_user>
COMMENT "Expéditeur du message";
DEFINE FIELD from_email_address ON base_message TYPE record<base_email_address>
COMMENT "Adresse email de l'expéditeur";
DEFINE FIELD reply_to_email_address_set ON base_message TYPE array<record<base_email_address>>
COMMENT "Adresses email de réponse";
DEFINE FIELD to_email_address_set ON base_message TYPE array<record<base_email_address>>
COMMENT "Adresses email des destinataires";
DEFINE FIELD cc_email_address_set ON base_message TYPE array<record<base_email_address>>
COMMENT "Adresses email en copie";
DEFINE FIELD bcc_email_address_set ON base_message TYPE array<record<base_email_address>>
COMMENT "Adresses email en copie cachée";

-- Dates et suivi
DEFINE FIELD sent_date_t ON base_message TYPE datetime
COMMENT "Date d'envoi";
DEFINE FIELD delivered_date_t ON base_message TYPE datetime
COMMENT "Date de livraison";
DEFINE FIELD read_date_t ON base_message TYPE datetime
COMMENT "Date de lecture";

-- Configuration mail
DEFINE FIELD mail_account ON base_message TYPE record<base_email_account>
COMMENT "Compte email";
DEFINE FIELD template ON base_message TYPE record<base_mail_template>
COMMENT "Template";

-- Pièces jointes et fichiers
DEFINE FIELD attachments ON base_message TYPE array<record<base_meta_file>>
COMMENT "Pièces jointes";

-- Entité liée (polymorphe)
DEFINE FIELD related_to ON base_message TYPE string
COMMENT "Nom de la classe/table";
DEFINE FIELD related_to_id ON base_message TYPE string
COMMENT "ID de l'enregistrement";

-- Suivi et logs
DEFINE FIELD message_id ON base_message TYPE string
COMMENT "ID unique du message";
DEFINE FIELD parent_message ON base_message TYPE record<base_message>
COMMENT "Message parent pour les réponses";
DEFINE FIELD root_message ON base_message TYPE record<base_message>
COMMENT "Message racine du thread";

-- Flags et options
DEFINE FIELD is_important ON base_message TYPE bool DEFAULT false
COMMENT "Est marqué comme important";
DEFINE FIELD is_read ON base_message TYPE bool DEFAULT false
COMMENT "Est lu";
DEFINE FIELD is_starred ON base_message TYPE bool DEFAULT false
COMMENT "Est marqué comme important";
DEFINE FIELD is_archived ON base_message TYPE bool DEFAULT false
COMMENT "Est archivé";

-- Métadonnées
DEFINE FIELD company ON base_message TYPE record<base_company>;
COMMENT "Entreprise";
DEFINE FIELD created_at ON base_message TYPE datetime DEFAULT time::now()
COMMENT "Date de création";
DEFINE FIELD updated_at ON base_message TYPE datetime DEFAULT time::now()
COMMENT "Date de mise à jour";
DEFINE FIELD created_by ON base_message TYPE record<base_user>;
DEFINE FIELD updated_by ON base_message TYPE record<base_user>;
DEFINE FIELD version ON base_message TYPE int DEFAULT 0;

-- Index pour performance
DEFINE INDEX idx_message_subject ON base_message FIELDS subject;
DEFINE INDEX idx_message_sender ON base_message FIELDS sender_user;
DEFINE INDEX idx_message_media_type ON base_message FIELDS media_type_select;
DEFINE INDEX idx_message_status ON base_message FIELDS status_select;
DEFINE INDEX idx_message_sent_date ON base_message FIELDS sent_date_t;
DEFINE INDEX idx_message_related ON base_message FIELDS related_to, related_to_id;
DEFINE INDEX idx_message_company ON base_message FIELDS company;
DEFINE INDEX idx_message_created ON base_message FIELDS created_at;