-- Demande GDPR
DEFINE TABLE gdpr_request SCHEMAFULL;
DEFINE FIELD type_select ON gdpr_request TYPE int DEFAULT 1; -- 1:Access, 2:Rectification, 3:Erasure, 4:Portability, 5:Objection, 6:Restriction
DEFINE FIELD gdpr_request_origin ON gdpr_request TYPE record<gdpr_request_origin>;
DEFINE FIELD request_date_t ON gdpr_request TYPE datetime ASSERT $value != NONE;
DEFINE FIELD due_sending_date_t ON gdpr_request TYPE datetime;
DEFINE FIELD status_select ON gdpr_request TYPE int DEFAULT 1; -- 1:Draft, 2:In Progress, 3:Completed, 4:Rejected, 5:Cancelled
DEFINE FIELD model_id ON gdpr_request TYPE string; -- ID de l'entité concernée
DEFINE FIELD model_name ON gdpr_request TYPE string; -- Nom du modèle concerné
DEFINE FIELD subject_email ON gdpr_request TYPE string;
DEFINE FIELD subject_name ON gdpr_request TYPE string;
DEFINE FIELD subject_phone ON gdpr_request TYPE string;
DEFINE FIELD subject_address ON gdpr_request TYPE string;
DEFINE FIELD request_description ON gdpr_request TYPE string;
DEFINE FIELD processing_notes ON gdpr_request TYPE string;
DEFINE FIELD assigned_user ON gdpr_request TYPE record<user>;
DEFINE FIELD company ON gdpr_request TYPE record<company>;
DEFINE FIELD priority_select ON gdpr_request TYPE int DEFAULT 2; -- 1:Low, 2:Medium, 3:High, 4:Urgent
DEFINE FIELD source_select ON gdpr_request TYPE int DEFAULT 1; -- 1:Email, 2:Web Form, 3:Phone, 4:Letter, 5:In Person
DEFINE FIELD verification_status ON gdpr_request TYPE int DEFAULT 1; -- 1:Pending, 2:Verified, 3:Rejected
DEFINE FIELD verification_date ON gdpr_request TYPE datetime;
DEFINE FIELD verification_method ON gdpr_request TYPE string;
DEFINE FIELD completion_date ON gdpr_request TYPE datetime;
DEFINE FIELD response_sent_date ON gdpr_request TYPE datetime;
DEFINE FIELD reminder_sent_count ON gdpr_request TYPE int DEFAULT 0;
DEFINE FIELD last_reminder_date ON gdpr_request TYPE datetime;
DEFINE FIELD legal_basis ON gdpr_request TYPE string;
DEFINE FIELD estimated_completion_date ON gdpr_request TYPE datetime;
DEFINE FIELD actual_effort_hours ON gdpr_request TYPE decimal DEFAULT 0.0;
DEFINE FIELD estimated_effort_hours ON gdpr_request TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_complex_request ON gdpr_request TYPE bool DEFAULT false;
DEFINE FIELD extension_reason ON gdpr_request TYPE string;
DEFINE FIELD extension_period ON gdpr_request TYPE int; -- Jours
DEFINE FIELD related_requests ON gdpr_request TYPE array<record<gdpr_request>>;
DEFINE FIELD gdpr_response_list ON gdpr_request TYPE array<record<gdpr_response>>;
DEFINE FIELD created_at ON gdpr_request TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON gdpr_request TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_request TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_gdpr_request_type ON gdpr_request FIELDS type_select;
DEFINE INDEX idx_gdpr_request_status ON gdpr_request FIELDS status_select;
DEFINE INDEX idx_gdpr_request_date ON gdpr_request FIELDS request_date_t;
DEFINE INDEX idx_gdpr_request_due_date ON gdpr_request FIELDS due_sending_date_t;
DEFINE INDEX idx_gdpr_request_email ON gdpr_request FIELDS subject_email;
DEFINE INDEX idx_gdpr_request_assigned ON gdpr_request FIELDS assigned_user;
DEFINE INDEX idx_gdpr_request_company ON gdpr_request FIELDS company;
DEFINE INDEX idx_gdpr_request_priority ON gdpr_request FIELDS priority_select;
DEFINE INDEX idx_gdpr_request_source ON gdpr_request FIELDS source_select;
DEFINE INDEX idx_gdpr_request_verification ON gdpr_request FIELDS verification_status;
DEFINE INDEX idx_gdpr_request_completion ON gdpr_request FIELDS completion_date;
DEFINE INDEX idx_gdpr_request_model ON gdpr_request FIELDS model_name;