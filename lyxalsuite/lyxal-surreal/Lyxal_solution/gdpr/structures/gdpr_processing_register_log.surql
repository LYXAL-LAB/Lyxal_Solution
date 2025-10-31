-- Log de registre de traitement GDPR
DEFINE TABLE gdpr_processing_register_log SCHEMAFULL;
DEFINE FIELD gdpr_processing_register ON gdpr_processing_register_log TYPE record<gdpr_processing_register> ASSERT $value != NONE;
DEFINE FIELD log_date ON gdpr_processing_register_log TYPE datetime DEFAULT time::now();
DEFINE FIELD log_type_select ON gdpr_processing_register_log TYPE int DEFAULT 1; -- 1:Access, 2:Update, 3:Export, 4:Delete, 5:Anonymize, 6:Review
DEFINE FIELD user_action ON gdpr_processing_register_log TYPE record<user>;
DEFINE FIELD action_description ON gdpr_processing_register_log TYPE string ASSERT $value != NONE;
DEFINE FIELD affected_records_count ON gdpr_processing_register_log TYPE int DEFAULT 0;
DEFINE FIELD data_categories_affected ON gdpr_processing_register_log TYPE array<string>;
DEFINE FIELD legal_basis ON gdpr_processing_register_log TYPE string;
DEFINE FIELD purpose ON gdpr_processing_register_log TYPE string;
DEFINE FIELD ip_address ON gdpr_processing_register_log TYPE string;
DEFINE FIELD user_agent ON gdpr_processing_register_log TYPE string;
DEFINE FIELD session_id ON gdpr_processing_register_log TYPE string;
DEFINE FIELD request_id ON gdpr_processing_register_log TYPE string;
DEFINE FIELD processing_duration_ms ON gdpr_processing_register_log TYPE int;
DEFINE FIELD success_status ON gdpr_processing_register_log TYPE bool DEFAULT true;
DEFINE FIELD error_message ON gdpr_processing_register_log TYPE string;
DEFINE FIELD additional_metadata ON gdpr_processing_register_log TYPE string;
DEFINE FIELD created_at ON gdpr_processing_register_log TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_processing_register_log TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_gdpr_register_log_register ON gdpr_processing_register_log FIELDS gdpr_processing_register;
DEFINE INDEX idx_gdpr_register_log_date ON gdpr_processing_register_log FIELDS log_date;
DEFINE INDEX idx_gdpr_register_log_type ON gdpr_processing_register_log FIELDS log_type_select;
DEFINE INDEX idx_gdpr_register_log_user ON gdpr_processing_register_log FIELDS user_action;
DEFINE INDEX idx_gdpr_register_log_success ON gdpr_processing_register_log FIELDS success_status;