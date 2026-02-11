-- Configuration Application GDPR
DEFINE TABLE app_gdpr SCHEMAFULL;
DEFINE FIELD app ON app_gdpr TYPE record<app> UNIQUE;
DEFINE FIELD is_enable_data_backup ON app_gdpr TYPE bool DEFAULT false;
DEFINE FIELD data_backup_path ON app_gdpr TYPE string;
DEFINE FIELD anonymization_log_duration ON app_gdpr TYPE int DEFAULT 365; -- Jours
DEFINE FIELD erasure_log_duration ON app_gdpr TYPE int DEFAULT 365; -- Jours
DEFINE FIELD request_response_duration ON app_gdpr TYPE int DEFAULT 30; -- Jours
DEFINE FIELD is_enable_auto_anonymization ON app_gdpr TYPE bool DEFAULT false;
DEFINE FIELD anonymization_frequency ON app_gdpr TYPE int DEFAULT 1; -- 1:Daily, 2:Weekly, 3:Monthly
DEFINE FIELD is_enable_email_notification ON app_gdpr TYPE bool DEFAULT true;
DEFINE FIELD notification_email ON app_gdpr TYPE string;
DEFINE FIELD privacy_policy_url ON app_gdpr TYPE string;
DEFINE FIELD data_protection_officer_email ON app_gdpr TYPE string;
DEFINE FIELD data_protection_officer_name ON app_gdpr TYPE string;
DEFINE FIELD company_address ON app_gdpr TYPE string;
DEFINE FIELD is_enable_consent_management ON app_gdpr TYPE bool DEFAULT false;
DEFINE FIELD default_consent_duration ON app_gdpr TYPE int DEFAULT 730; -- Jours
DEFINE FIELD is_log_processing_activities ON app_gdpr TYPE bool DEFAULT true;
DEFINE FIELD max_request_per_subject ON app_gdpr TYPE int DEFAULT 10;
DEFINE FIELD request_cooldown_period ON app_gdpr TYPE int DEFAULT 30; -- Jours
DEFINE FIELD created_at ON app_gdpr TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_gdpr TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_gdpr TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_app_gdpr_app ON app_gdpr FIELDS app;
DEFINE INDEX idx_app_gdpr_backup ON app_gdpr FIELDS is_enable_data_backup;
DEFINE INDEX idx_app_gdpr_auto_anon ON app_gdpr FIELDS is_enable_auto_anonymization;
DEFINE INDEX idx_app_gdpr_email_notif ON app_gdpr FIELDS is_enable_email_notification;