-- Configuration de recherche GDPR
DEFINE TABLE gdpr_search_config SCHEMAFULL;
DEFINE FIELD name ON gdpr_search_config TYPE string ASSERT $value != NONE;
DEFINE FIELD model_name ON gdpr_search_config TYPE string ASSERT $value != NONE;
DEFINE FIELD description ON gdpr_search_config TYPE string;
DEFINE FIELD is_active ON gdpr_search_config TYPE bool DEFAULT true;
DEFINE FIELD search_method_select ON gdpr_search_config TYPE int DEFAULT 1; -- 1:Field Search, 2:Custom Query, 3:Relationship Search
DEFINE FIELD primary_search_field ON gdpr_search_config TYPE string;
DEFINE FIELD custom_query ON gdpr_search_config TYPE string;
DEFINE FIELD includes_personal_data ON gdpr_search_config TYPE bool DEFAULT true;
DEFINE FIELD data_sensitivity_level ON gdpr_search_config TYPE int DEFAULT 2; -- 1:Low, 2:Medium, 3:High, 4:Critical
DEFINE FIELD retention_period_days ON gdpr_search_config TYPE int DEFAULT 365;
DEFINE FIELD auto_anonymization ON gdpr_search_config TYPE bool DEFAULT false;
DEFINE FIELD anonymization_delay_days ON gdpr_search_config TYPE int DEFAULT 30;
DEFINE FIELD requires_approval ON gdpr_search_config TYPE bool DEFAULT false;
DEFINE FIELD approval_user ON gdpr_search_config TYPE record<user>;
DEFINE FIELD search_config_line_list ON gdpr_search_config TYPE array<record<gdpr_search_config_line>>;
DEFINE FIELD created_at ON gdpr_search_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON gdpr_search_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_search_config TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_gdpr_search_config_name ON gdpr_search_config FIELDS name;
DEFINE INDEX idx_gdpr_search_config_model ON gdpr_search_config FIELDS model_name;
DEFINE INDEX idx_gdpr_search_config_active ON gdpr_search_config FIELDS is_active;
DEFINE INDEX idx_gdpr_search_config_sensitivity ON gdpr_search_config FIELDS data_sensitivity_level;
DEFINE INDEX idx_gdpr_search_config_auto_anon ON gdpr_search_config FIELDS auto_anonymization;