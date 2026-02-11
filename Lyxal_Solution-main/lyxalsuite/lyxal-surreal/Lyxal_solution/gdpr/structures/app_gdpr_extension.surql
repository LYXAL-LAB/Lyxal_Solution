-- Extension App
DEFINE TABLE app_gdpr_extension SCHEMAFULL;
DEFINE FIELD app ON app_gdpr_extension TYPE record<app>;
DEFINE FIELD gdpr_module_version ON app_gdpr_extension TYPE string DEFAULT "1.0.0";
DEFINE FIELD is_gdpr_enabled ON app_gdpr_extension TYPE bool DEFAULT false;
DEFINE FIELD compliance_level ON app_gdpr_extension TYPE int DEFAULT 1; -- 1:Basic, 2:Standard, 3:Advanced
DEFINE FIELD last_compliance_check ON app_gdpr_extension TYPE datetime;
DEFINE FIELD compliance_score ON app_gdpr_extension TYPE decimal DEFAULT 0.0;
DEFINE FIELD certification_status ON app_gdpr_extension TYPE string;
DEFINE FIELD created_at ON app_gdpr_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_gdpr_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_gdpr_extension TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_app_gdpr_ext_app ON app_gdpr_extension FIELDS app;
DEFINE INDEX idx_app_gdpr_ext_enabled ON app_gdpr_extension FIELDS is_gdpr_enabled;
DEFINE INDEX idx_app_gdpr_ext_compliance ON app_gdpr_extension FIELDS compliance_level;