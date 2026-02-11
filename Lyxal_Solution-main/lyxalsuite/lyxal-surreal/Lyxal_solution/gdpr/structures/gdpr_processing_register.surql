-- Registre de traitement GDPR
DEFINE TABLE gdpr_processing_register SCHEMAFULL;
DEFINE FIELD name ON gdpr_processing_register TYPE string ASSERT $value != NONE;
DEFINE FIELD description ON gdpr_processing_register TYPE string;
DEFINE FIELD purpose ON gdpr_processing_register TYPE string ASSERT $value != NONE;
DEFINE FIELD legal_basis_select ON gdpr_processing_register TYPE int DEFAULT 1; -- 1:Consent, 2:Contract, 3:Legal Obligation, 4:Vital Interests, 5:Public Task, 6:Legitimate Interest
DEFINE FIELD legal_basis_description ON gdpr_processing_register TYPE string;
DEFINE FIELD data_controller ON gdpr_processing_register TYPE string ASSERT $value != NONE;
DEFINE FIELD data_controller_contact ON gdpr_processing_register TYPE string;
DEFINE FIELD data_processor ON gdpr_processing_register TYPE string;
DEFINE FIELD data_processor_contact ON gdpr_processing_register TYPE string;
DEFINE FIELD data_protection_officer ON gdpr_processing_register TYPE string;
DEFINE FIELD data_categories ON gdpr_processing_register TYPE array<string>; -- Catégories de données
DEFINE FIELD special_categories ON gdpr_processing_register TYPE array<string>; -- Données sensibles
DEFINE FIELD data_subjects_categories ON gdpr_processing_register TYPE array<string>; -- Catégories de personnes
DEFINE FIELD recipients_categories ON gdpr_processing_register TYPE array<string>; -- Destinataires
DEFINE FIELD international_transfers ON gdpr_processing_register TYPE bool DEFAULT false;
DEFINE FIELD transfer_countries ON gdpr_processing_register TYPE array<string>;
DEFINE FIELD transfer_safeguards ON gdpr_processing_register TYPE string;
DEFINE FIELD retention_period ON gdpr_processing_register TYPE string;
DEFINE FIELD retention_criteria ON gdpr_processing_register TYPE string;
DEFINE FIELD security_measures ON gdpr_processing_register TYPE string;
DEFINE FIELD technical_measures ON gdpr_processing_register TYPE string;
DEFINE FIELD organizational_measures ON gdpr_processing_register TYPE string;
DEFINE FIELD data_source ON gdpr_processing_register TYPE string;
DEFINE FIELD automated_decision_making ON gdpr_processing_register TYPE bool DEFAULT false;
DEFINE FIELD profiling_activities ON gdpr_processing_register TYPE bool DEFAULT false;
DEFINE FIELD profiling_description ON gdpr_processing_register TYPE string;
DEFINE FIELD data_minimization ON gdpr_processing_register TYPE bool DEFAULT true;
DEFINE FIELD accuracy_measures ON gdpr_processing_register TYPE string;
DEFINE FIELD storage_limitation ON gdpr_processing_register TYPE string;
DEFINE FIELD integrity_confidentiality ON gdpr_processing_register TYPE string;
DEFINE FIELD accountability_measures ON gdpr_processing_register TYPE string;
DEFINE FIELD status_select ON gdpr_processing_register TYPE int DEFAULT 1; -- 1:Active, 2:Inactive, 3:Under Review, 4:Archived
DEFINE FIELD responsible_user ON gdpr_processing_register TYPE record<user>;
DEFINE FIELD company ON gdpr_processing_register TYPE record<company>;
DEFINE FIELD created_date ON gdpr_processing_register TYPE date DEFAULT date::now();
DEFINE FIELD last_review_date ON gdpr_processing_register TYPE date;
DEFINE FIELD next_review_date ON gdpr_processing_register TYPE date;
DEFINE FIELD review_frequency ON gdpr_processing_register TYPE int DEFAULT 12; -- Mois
DEFINE FIELD gdpr_processing_register_rule_list ON gdpr_processing_register TYPE array<record<gdpr_processing_register_rule>>;
DEFINE FIELD gdpr_processing_register_log_list ON gdpr_processing_register TYPE array<record<gdpr_processing_register_log>>;
DEFINE FIELD created_at ON gdpr_processing_register TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON gdpr_processing_register TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_processing_register TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_gdpr_processing_register_name ON gdpr_processing_register FIELDS name;
DEFINE INDEX idx_gdpr_processing_register_legal_basis ON gdpr_processing_register FIELDS legal_basis_select;
DEFINE INDEX idx_gdpr_processing_register_status ON gdpr_processing_register FIELDS status_select;
DEFINE INDEX idx_gdpr_processing_register_responsible ON gdpr_processing_register FIELDS responsible_user;
DEFINE INDEX idx_gdpr_processing_register_company ON gdpr_processing_register FIELDS company;
DEFINE INDEX idx_gdpr_processing_register_review_date ON gdpr_processing_register FIELDS next_review_date;
DEFINE INDEX idx_gdpr_processing_register_international ON gdpr_processing_register FIELDS international_transfers;
DEFINE INDEX idx_gdpr_processing_register_automated ON gdpr_processing_register FIELDS automated_decision_making;