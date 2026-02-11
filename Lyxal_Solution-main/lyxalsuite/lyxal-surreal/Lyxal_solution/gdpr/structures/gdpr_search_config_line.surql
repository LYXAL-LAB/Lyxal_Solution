-- Ligne de configuration de recherche GDPR
DEFINE TABLE gdpr_search_config_line SCHEMAFULL;
DEFINE FIELD gdpr_search_config ON gdpr_search_config_line TYPE record<gdpr_search_config> ASSERT $value != NONE;
DEFINE FIELD sequence ON gdpr_search_config_line TYPE int DEFAULT 0;
DEFINE FIELD field_name ON gdpr_search_config_line TYPE string ASSERT $value != NONE;
DEFINE FIELD field_label ON gdpr_search_config_line TYPE string;
DEFINE FIELD field_type ON gdpr_search_config_line TYPE string;
DEFINE FIELD is_searchable ON gdpr_search_config_line TYPE bool DEFAULT true;
DEFINE FIELD is_exportable ON gdpr_search_config_line TYPE bool DEFAULT true;
DEFINE FIELD is_anonymizable ON gdpr_search_config_line TYPE bool DEFAULT false;
DEFINE FIELD anonymization_method ON gdpr_search_config_line TYPE string;
DEFINE FIELD is_personal_data ON gdpr_search_config_line TYPE bool DEFAULT false;
DEFINE FIELD data_category ON gdpr_search_config_line TYPE string;
DEFINE FIELD sensitivity_level ON gdpr_search_config_line TYPE int DEFAULT 1; -- 1:Low, 2:Medium, 3:High, 4:Critical
DEFINE FIELD retention_criteria ON gdpr_search_config_line TYPE string;
DEFINE FIELD legal_basis ON gdpr_search_config_line TYPE string;
DEFINE FIELD processing_purpose ON gdpr_search_config_line TYPE string;
DEFINE FIELD notes ON gdpr_search_config_line TYPE string;
DEFINE FIELD created_at ON gdpr_search_config_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON gdpr_search_config_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_search_config_line TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_gdpr_search_config_line_config ON gdpr_search_config_line FIELDS gdpr_search_config;
DEFINE INDEX idx_gdpr_search_config_line_field ON gdpr_search_config_line FIELDS field_name;
DEFINE INDEX idx_gdpr_search_config_line_personal ON gdpr_search_config_line FIELDS is_personal_data;
DEFINE INDEX idx_gdpr_search_config_line_sensitivity ON gdpr_search_config_line FIELDS sensitivity_level;