-- Réponse GDPR
DEFINE TABLE gdpr_response SCHEMAFULL;
DEFINE FIELD gdpr_request ON gdpr_response TYPE record<gdpr_request> ASSERT $value != NONE;
DEFINE FIELD response_type_select ON gdpr_response TYPE int DEFAULT 1; -- 1:Data Export, 2:Confirmation, 3:Rejection, 4:Partial Response
DEFINE FIELD response_date ON gdpr_response TYPE datetime DEFAULT time::now();
DEFINE FIELD response_content ON gdpr_response TYPE string;
DEFINE FIELD response_format_select ON gdpr_response TYPE int DEFAULT 1; -- 1:JSON, 2:XML, 3:CSV, 4:PDF, 5:Email
DEFINE FIELD exported_file ON gdpr_response TYPE record<meta_file>;
DEFINE FIELD file_password ON gdpr_response TYPE string;
DEFINE FIELD encryption_method ON gdpr_response TYPE string;
DEFINE FIELD delivery_method_select ON gdpr_response TYPE int DEFAULT 1; -- 1:Email, 2:Secure Download, 3:Postal, 4:Portal
DEFINE FIELD delivery_status_select ON gdpr_response TYPE int DEFAULT 1; -- 1:Pending, 2:Sent, 3:Delivered, 4:Failed
DEFINE FIELD delivery_date ON gdpr_response TYPE datetime;
DEFINE FIELD delivery_confirmation ON gdpr_response TYPE string;
DEFINE FIELD recipient_email ON gdpr_response TYPE string;
DEFINE FIELD recipient_address ON gdpr_response TYPE string;
DEFINE FIELD download_expiry_date ON gdpr_response TYPE datetime;
DEFINE FIELD download_count ON gdpr_response TYPE int DEFAULT 0;
DEFINE FIELD max_download_count ON gdpr_response TYPE int DEFAULT 3;
DEFINE FIELD security_questions ON gdpr_response TYPE string;
DEFINE FIELD verification_code ON gdpr_response TYPE string;
DEFINE FIELD is_secure_delivery ON gdpr_response TYPE bool DEFAULT true;
DEFINE FIELD data_categories_included ON gdpr_response TYPE array<string>;
DEFINE FIELD records_count ON gdpr_response TYPE int DEFAULT 0;
DEFINE FIELD file_size_mb ON gdpr_response TYPE decimal DEFAULT 0.0;
DEFINE FIELD processing_time_minutes ON gdpr_response TYPE int DEFAULT 0;
DEFINE FIELD notes ON gdpr_response TYPE string;
DEFINE FIELD created_at ON gdpr_response TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON gdpr_response TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_response TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_gdpr_response_request ON gdpr_response FIELDS gdpr_request;
DEFINE INDEX idx_gdpr_response_type ON gdpr_response FIELDS response_type_select;
DEFINE INDEX idx_gdpr_response_date ON gdpr_response FIELDS response_date;
DEFINE INDEX idx_gdpr_response_format ON gdpr_response FIELDS response_format_select;
DEFINE INDEX idx_gdpr_response_delivery_method ON gdpr_response FIELDS delivery_method_select;
DEFINE INDEX idx_gdpr_response_delivery_status ON gdpr_response FIELDS delivery_status_select;
DEFINE INDEX idx_gdpr_response_delivery_date ON gdpr_response FIELDS delivery_date;
DEFINE INDEX idx_gdpr_response_email ON gdpr_response FIELDS recipient_email;