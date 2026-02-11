DEFINE TABLE IF NOT EXISTS partner_bank TYPE NORMAL SCHEMAFULL 
COMMENT 'Coordonnées bancaires d\'un partenaire' 
PERMISSIONS FULL;

-- ------------------------------
-- FIELDS
-- ------------------------------ 

DEFINE FIELD partner ON partner_bank TYPE record<partner>
COMMENT 'Partenaire concerné';
DEFINE FIELD bankName ON partner_bank TYPE option<string>
COMMENT 'Nom de la banque';
DEFINE FIELD iban ON partner_bank TYPE option<string>
COMMENT 'IBAN';
DEFINE FIELD bic ON partner_bank TYPE option<string>
COMMENT 'BIC/SWIFT';
DEFINE FIELD tags ON partner_bank TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de la coordonnée bancaire (ex: bank_main)';

DEFINE FIELD created_at ON partner_bank TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON partner_bank TYPE option<record<user>>;
DEFINE FIELD updated_at ON partner_bank TYPE datetime DEFAULT time::now();

-- ------------------------------
-- INDEXES
-- ------------------------------ 

DEFINE INDEX idx_partner_bank_partner ON partner_bank FIELDS partner;
DEFINE INDEX idx_partner_bank_iban ON partner_bank FIELDS iban;