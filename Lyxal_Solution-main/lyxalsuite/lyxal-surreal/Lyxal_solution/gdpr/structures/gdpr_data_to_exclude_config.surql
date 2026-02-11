-- Configuration de données à exclure GDPR
DEFINE TABLE gdpr_data_to_exclude_config SCHEMAFULL;
DEFINE FIELD name ON gdpr_data_to_exclude_config TYPE string ASSERT $value != NONE;
DEFINE FIELD model_name ON gdpr_data_to_exclude_config TYPE string ASSERT $value != NONE;
DEFINE FIELD field_name ON gdpr_data_to_exclude_config TYPE string ASSERT $value != NONE;
DEFINE FIELD exclusion_reason ON gdpr_data_to_exclude_config TYPE string;
DEFINE FIELD exclusion_type_select ON gdpr_data_to_exclude_config TYPE int DEFAULT 1; -- 1:Legal Requirement, 2:Technical Constraint, 3:Security, 4:Business Rule
DEFINE FIELD is_active ON gdpr_data_to_exclude_config TYPE bool DEFAULT true;
DEFINE FIELD applies_to_request_type ON gdpr_data_to_exclude_config TYPE array<int>; -- Types de demandes concernées
DEFINE FIELD alternative_action ON gdpr_data_to_exclude_config TYPE string;
DEFINE FIELD legal_basis ON gdpr_data_to_exclude_config TYPE string;
DEFINE FIELD retention_period ON gdpr_data_to_exclude_config TYPE string;
DEFINE FIELD review_date ON gdpr_data_to_exclude_config TYPE date;
DEFINE FIELD created_by ON gdpr_data_to_exclude_config TYPE record<user>;
DEFINE FIELD approved_by ON gdpr_data_to_exclude_config TYPE record<user>;
DEFINE FIELD approval_date ON gdpr_data_to_exclude_config TYPE datetime;
DEFINE FIELD notes ON gdpr_data_to_exclude_config TYPE string;
DEFINE FIELD created_at ON gdpr_data_to_exclude_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON gdpr_data_to_exclude_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_data_to_exclude_config TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_gdpr_exclude_config_model ON gdpr_data_to_exclude_config FIELDS model_name;
DEFINE INDEX idx_gdpr_exclude_config_field ON gdpr_data_to_exclude_config FIELDS field_name;
DEFINE INDEX idx_gdpr_exclude_config_active ON gdpr_data_to_exclude_config FIELDS is_active;
DEFINE INDEX idx_gdpr_exclude_config_type ON gdpr_data_to_exclude_config FIELDS exclusion_type_select;