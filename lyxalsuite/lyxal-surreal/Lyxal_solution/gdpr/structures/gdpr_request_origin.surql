-- Origine de demande GDPR
DEFINE TABLE gdpr_request_origin SCHEMAFULL;
DEFINE FIELD name ON gdpr_request_origin TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON gdpr_request_origin TYPE string UNIQUE;
DEFINE FIELD description ON gdpr_request_origin TYPE string;
DEFINE FIELD is_active ON gdpr_request_origin TYPE bool DEFAULT true;
DEFINE FIELD default_response_time ON gdpr_request_origin TYPE int DEFAULT 30; -- Jours
DEFINE FIELD requires_verification ON gdpr_request_origin TYPE bool DEFAULT true;
DEFINE FIELD verification_method ON gdpr_request_origin TYPE string;
DEFINE FIELD notification_template ON gdpr_request_origin TYPE string;
DEFINE FIELD auto_assign_user ON gdpr_request_origin TYPE record<user>;
DEFINE FIELD priority_level ON gdpr_request_origin TYPE int DEFAULT 2; -- 1:Low, 2:Medium, 3:High
DEFINE FIELD created_at ON gdpr_request_origin TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON gdpr_request_origin TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_request_origin TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_gdpr_request_origin_name ON gdpr_request_origin FIELDS name;
DEFINE INDEX idx_gdpr_request_origin_code ON gdpr_request_origin FIELDS code;
DEFINE INDEX idx_gdpr_request_origin_active ON gdpr_request_origin FIELDS is_active;
DEFINE INDEX idx_gdpr_request_origin_verification ON gdpr_request_origin FIELDS requires_verification;
DEFINE INDEX idx_gdpr_request_origin_auto_assign ON gdpr_request_origin FIELDS auto_assign_user; 