-- MODULE: BASE SOUS MODULE : COMMUNICATION
-- TABLE: base_mail_template_association (MailTemplateAssociation)
-- Associations de template de mail  
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_mail_template_association TYPE NORMAL SCHEMAFULL
COMMENT "Associations de template de mail"
PERMISSIONS FULL;

-- Identification
DEFINE FIELD model_name ON base_mail_template_association TYPE string
COMMENT "Nom du modèle";
DEFINE FIELD field_name ON base_mail_template_association TYPE string
COMMENT "Nom du champ";
DEFINE FIELD template ON base_mail_template_association TYPE record<base_mail_template>
COMMENT "Template associé";
DEFINE FIELD created_at ON base_mail_template_association TYPE datetime DEFAULT time::now()
COMMENT "Date de création";
DEFINE FIELD updated_at ON base_mail_template_association TYPE datetime DEFAULT time::now()
COMMENT "Date de mise à jour";