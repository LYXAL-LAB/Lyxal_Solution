-- Extension MetaModel
DEFINE TABLE meta_model_gdpr SCHEMAFULL;
DEFINE FIELD meta_model ON meta_model_gdpr TYPE record<meta_model>;
DEFINE FIELD has_personal_data ON meta_model_gdpr TYPE bool DEFAULT false;
DEFINE FIELD data_sensitivity_level ON meta_model_gdpr TYPE int DEFAULT 1; -- 1:Low, 2:Medium, 3:High, 4:Critical
DEFINE FIELD default_retention_period ON meta_model_gdpr TYPE int DEFAULT 365; -- Jours
DEFINE FIELD auto_anonymization_enabled ON meta_model_gdpr TYPE bool DEFAULT false;
DEFINE FIELD gdpr_search_config ON meta_model_gdpr TYPE record<gdpr_search_config>;
DEFINE FIELD compliance_notes ON meta_model_gdpr TYPE string;
DEFINE FIELD created_at ON meta_model_gdpr TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON meta_model_gdpr TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON meta_model_gdpr TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_meta_model_gdpr_model ON meta_model_gdpr FIELDS meta_model;
DEFINE INDEX idx_meta_model_gdpr_personal ON meta_model_gdpr FIELDS has_personal_data;
DEFINE INDEX idx_meta_model_gdpr_sensitivity ON meta_model_gdpr FIELDS data_sensitivity_level;
DEFINE INDEX idx_meta_model_gdpr_auto_anon ON meta_model_gdpr FIELDS auto_anonymization_enabled; 