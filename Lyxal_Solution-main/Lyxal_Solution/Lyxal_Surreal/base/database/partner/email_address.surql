DEFINE TABLE IF NOT EXISTS email_address TYPE NORMAL SCHEMAFULL 
COMMENT 'Adresse e-mail liée à un partenaire (primaire)'
PERMISSIONS FULL;

-- Champs
DEFINE FIELD partner ON email_address TYPE option<record<partner>>
COMMENT 'Partenaire lié (max 1)';
DEFINE FIELD address ON email_address TYPE string
COMMENT 'Adresse e-mail';
DEFINE FIELD name ON email_address TYPE option<string>
COMMENT 'Libellé d\'affichage';

-- Audit
DEFINE FIELD created_at ON email_address TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON email_address TYPE option<record<user>>;
DEFINE FIELD updated_at ON email_address TYPE datetime DEFAULT time::now();

-- Indexes
DEFINE INDEX idx_email_address_unique ON email_address FIELDS address UNIQUE;
DEFINE INDEX idx_email_address_partner ON email_address FIELDS partner;