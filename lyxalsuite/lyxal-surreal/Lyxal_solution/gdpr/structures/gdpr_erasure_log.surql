-- Log d'effacement GDPR
DEFINE TABLE gdpr_erasure_log SCHEMAFULL;
DEFINE FIELD gdpr_request ON gdpr_erasure_log TYPE record<gdpr_request> ASSERT $value != NONE;
DEFINE FIELD erasure_date ON gdpr_erasure_log TYPE datetime DEFAULT time::now();
DEFINE FIELD model_name ON gdpr_erasure_log TYPE string ASSERT $value != NONE;
DEFINE FIELD record_id ON gdpr_erasure_log TYPE string ASSERT $value != NONE;
DEFINE FIELD field_name ON gdpr_erasure_log TYPE string;
DEFINE FIELD original_value ON gdpr_erasure_log TYPE string;
DEFINE FIELD erasure_method_select ON gdpr_erasure_log TYPE int DEFAULT 1; -- 1:Delete, 2:Anonymize, 3:Pseudonymize, 4:Mask
DEFINE FIELD anonymized_value ON gdpr_erasure_log TYPE string;
DEFINE FIELD erasure_rule ON gdpr_erasure_log TYPE string;
DEFINE FIELD user_performed ON gdpr_erasure_log TYPE record<user>;
DEFINE FIELD is_reversible ON gdpr_erasure_log TYPE bool DEFAULT false;
DEFINE FIELD reversal_key ON gdpr_erasure_log TYPE string;
DEFINE FIELD backup_location ON gdpr_erasure_log TYPE string;
DEFINE FIELD verification_hash ON gdpr_erasure_log TYPE string;
DEFINE FIELD compliance_status ON gdpr_erasure_log TYPE int DEFAULT 1; -- 1:Compliant, 2:Partial, 3:Failed
DEFINE FIELD audit_trail ON gdpr_erasure_log TYPE string;
DEFINE FIELD related_records_affected ON gdpr_erasure_log TYPE int DEFAULT 0;
DEFINE FIELD notes ON gdpr_erasure_log TYPE string;
DEFINE FIELD created_at ON gdpr_erasure_log TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_erasure_log TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_gdpr_erasure_log_request ON gdpr_erasure_log FIELDS gdpr_request;
DEFINE INDEX idx_gdpr_erasure_log_date ON gdpr_erasure_log FIELDS erasure_date;
DEFINE INDEX idx_gdpr_erasure_log_model ON gdpr_erasure_log FIELDS model_name;
DEFINE INDEX idx_gdpr_erasure_log_record ON gdpr_erasure_log FIELDS record_id;
DEFINE INDEX idx_gdpr_erasure_log_method ON gdpr_erasure_log FIELDS erasure_method_select;
DEFINE INDEX idx_gdpr_erasure_log_user ON gdpr_erasure_log FIELDS user_performed;
DEFINE INDEX idx_gdpr_erasure_log_reversible ON gdpr_erasure_log FIELDS is_reversible;
DEFINE INDEX idx_gdpr_erasure_log_compliance ON gdpr_erasure_log FIELDS compliance_status;
