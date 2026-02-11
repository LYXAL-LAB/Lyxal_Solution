DEFINE TABLE IF NOT EXISTS partner_company TYPE NORMAL SCHEMAFULL 
COMMENT 'Extension entreprise pour les partenaires - données légales et commerciales spécifiques aux entités juridiques' 
PERMISSIONS FULL;

-- ------------------------------
-- FIELDS
-- ------------------------------ 

-- Identité commerciale
DEFINE FIELD name ON partner_company TYPE string 
COMMENT "Nom commercial de l'entreprise";
DEFINE FIELD tradingNameSet ON partner_company TYPE array<record<trading_name>> 
COMMENT "Ensemble des noms commerciaux utilisés par l'entreprise";

-- Références & rattachements
DEFINE FIELD partner ON partner_company TYPE record<partner> 
COMMENT 'Référence au partenaire principal (obligatoire)';
DEFINE FIELD company ON partner_company TYPE record<company> 
COMMENT "Référence à l'entité company associée";

-- Légal / statut
DEFINE FIELD legalCategory ON partner_company TYPE record<legal_form> 
COMMENT "Forme juridique de l'entreprise (SARL, SA, SAS, etc.)";
DEFINE FIELD registrationCode ON partner_company TYPE option<string> 
COMMENT "Code d'enregistrement légal de l'entreprise";
DEFINE FIELD siren ON partner_company TYPE option<string> 
COMMENT 'Numéro SIREN (9 chiffres) - identifiant unique entreprise française';
DEFINE FIELD nic ON partner_company TYPE option<string> 
COMMENT "Numéro NIC (5 chiffres) - complément du SIREN pour identifier l'établissement";
DEFINE FIELD taxNbr ON partner_company TYPE option<string> 
COMMENT 'Numéro de TVA intracommunautaire';

-- Activité / chiffre d'affaires
DEFINE FIELD mainActivity ON partner_company TYPE array<record<system_tag>> DEFAULT [] 
COMMENT "Tags d'activités (principal/secondaires) attendus: activity_* / industry_*";
DEFINE FIELD saleTurnover ON partner_company TYPE option<int> 
COMMENT "Chiffre d'affaires annuel en unité monétaire de base";

-- Tags généraux
DEFINE FIELD tags ON partner_company TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de la société (ex: industry_*, activity_*, status_*)';
-- Audit
DEFINE FIELD created_at ON partner_company TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON partner_company TYPE option<record<user>>;
DEFINE FIELD updated_at ON partner_company TYPE datetime DEFAULT time::now();

-- ------------------------------
-- INDEXES
-- ------------------------------ 

DEFINE INDEX idx_partner_company_legal_category ON partner_company FIELDS legalCategory;
DEFINE INDEX idx_partner_company_name ON partner_company FIELDS name;
DEFINE INDEX idx_partner_company_partner ON partner_company FIELDS partner UNIQUE;
DEFINE INDEX idx_partner_company_siren ON partner_company FIELDS siren;
DEFINE INDEX idx_partner_company_taxNbr ON partner_company FIELDS taxNbr;
DEFINE INDEX idx_partner_company_registration ON partner_company FIELDS registrationCode;
DEFINE INDEX idx_partner_company_nic ON partner_company FIELDS nic;

DEFINE INDEX idx_partner_company_mainActivity ON partner_company FIELDS mainActivity;