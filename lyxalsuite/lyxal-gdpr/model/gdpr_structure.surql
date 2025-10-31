-- Structure SurrealDB pour le module GDPR

-- ============================
-- Table: gdpr_request
-- ============================
DEFINE TABLE gdpr_request SCHEMAFUL;
DEFINE FIELD typeSelect ON gdpr_request TYPE int;
DEFINE FIELD gdprRequestOrigin ON gdpr_request TYPE record<gdpr_request_origin>;
DEFINE FIELD requestDateT ON gdpr_request TYPE datetime;
DEFINE FIELD dueSendingDateT ON gdpr_request TYPE datetime;
DEFINE FIELD statusSelect ON gdpr_request TYPE int;
DEFINE FIELD modelId ON gdpr_request TYPE int;
DEFINE FIELD modelSelect ON gdpr_request TYPE string;
DEFINE FIELD requestComment ON gdpr_request TYPE string;
DEFINE FIELD label ON gdpr_request TYPE string;
DEFINE FIELD gdprResponse ON gdpr_request TYPE record<gdpr_response>;

-- ============================
-- Table: gdpr_response
-- ============================
DEFINE TABLE gdpr_response SCHEMAFUL;
DEFINE FIELD typeSelect ON gdpr_response TYPE int;
DEFINE FIELD sendingDateT ON gdpr_response TYPE datetime;
DEFINE FIELD responseEmailAddress ON gdpr_response TYPE string;
DEFINE FIELD responseMessage ON gdpr_response TYPE record<message>;
DEFINE FIELD dataFile ON gdpr_response TYPE record<meta_file>;
DEFINE FIELD anonymizationResult ON gdpr_response TYPE string;

-- ============================
-- Table: gdpr_erasure_log
-- ============================
DEFINE TABLE gdpr_erasure_log SCHEMAFUL;
DEFINE FIELD modelLog ON gdpr_erasure_log TYPE record<meta_model>;
DEFINE FIELD numberOfrecords ON gdpr_erasure_log TYPE int;
DEFINE FIELD gdprResponse ON gdpr_erasure_log TYPE record<gdpr_response>;

-- ============================
-- Table: gdpr_processing_register
-- ============================
DEFINE TABLE gdpr_processing_register SCHEMAFUL;
DEFINE FIELD name ON gdpr_processing_register TYPE string;
DEFINE FIELD code ON gdpr_processing_register TYPE string;
DEFINE FIELD retentionPeriod ON gdpr_processing_register TYPE int;
DEFINE FIELD description ON gdpr_processing_register TYPE string;
DEFINE FIELD status ON gdpr_processing_register TYPE int;
DEFINE FIELD anonymizer ON gdpr_processing_register TYPE record<anonymizer>;
DEFINE FIELD isArchiveData ON gdpr_processing_register TYPE bool;

-- ============================
-- Table: gdpr_processing_register_rule
-- ============================
DEFINE TABLE gdpr_processing_register_rule SCHEMAFUL;
DEFINE FIELD gdprProcessingRegister ON gdpr_processing_register_rule TYPE record<gdpr_processing_register>;
DEFINE FIELD metaModel ON gdpr_processing_register_rule TYPE record<meta_model>;
DEFINE FIELD rule ON gdpr_processing_register_rule TYPE string;

-- ============================
-- Table: gdpr_processing_register_log
-- ============================
DEFINE TABLE gdpr_processing_register_log SCHEMAFUL;
DEFINE FIELD gdprProcessingRegister ON gdpr_processing_register_log TYPE record<gdpr_processing_register>;
DEFINE FIELD processingDateT ON gdpr_processing_register_log TYPE datetime;
DEFINE FIELD nbProcessed ON gdpr_processing_register_log TYPE int;

-- ============================
-- Table: gdpr_search_config
-- ============================
DEFINE TABLE gdpr_search_config SCHEMAFUL;
DEFINE FIELD metaModel ON gdpr_search_config TYPE record<meta_model>;
DEFINE FIELD appGdpr ON gdpr_search_config TYPE record<app_gdpr>;

-- ============================
-- Table: gdpr_search_config_line
-- ============================
DEFINE TABLE gdpr_search_config_line SCHEMAFUL;
DEFINE FIELD searchConfig ON gdpr_search_config_line TYPE record<gdpr_search_config>;
DEFINE FIELD key ON gdpr_search_config_line TYPE string;
DEFINE FIELD query ON gdpr_search_config_line TYPE string;
DEFINE FIELD mapping ON gdpr_search_config_line TYPE string;

-- ============================
-- Table: gdpr_data_to_exclude_config
-- ============================
DEFINE TABLE gdpr_data_to_exclude_config SCHEMAFUL;
DEFINE FIELD metaModel ON gdpr_data_to_exclude_config TYPE record<meta_model>;
DEFINE FIELD metaFields ON gdpr_data_to_exclude_config TYPE array;
DEFINE FIELD appGdpr ON gdpr_data_to_exclude_config TYPE record<app_gdpr>;

-- ============================
-- Table: relationship_anonymizer
-- ============================
DEFINE TABLE relationship_anonymizer SCHEMAFUL;
DEFINE FIELD model ON relationship_anonymizer TYPE record<meta_model>;
DEFINE FIELD modelId ON relationship_anonymizer TYPE int;
DEFINE FIELD appGdpr ON relationship_anonymizer TYPE record<app_gdpr>;

-- ============================
-- Table: gdpr_request_origin
-- ============================
DEFINE TABLE gdpr_request_origin SCHEMAFUL;
DEFINE FIELD name ON gdpr_request_origin TYPE string;
DEFINE FIELD code ON gdpr_request_origin TYPE string;
DEFINE FIELD appGdpr ON gdpr_request_origin TYPE record<app_gdpr>;

-- ============================
-- Table: app_gdpr
-- ============================
DEFINE TABLE app_gdpr SCHEMAFUL;
DEFINE FIELD app ON app_gdpr TYPE record<app>;
DEFINE FIELD maxRespondingDays ON app_gdpr TYPE int DEFAULT 30;
DEFINE FIELD anonymizer ON app_gdpr TYPE record<anonymizer>;
DEFINE FIELD accessResponseTemplate ON app_gdpr TYPE record<template>;
DEFINE FIELD erasureResponseTemplate ON app_gdpr TYPE record<template>;

-- ============================
-- Table: app
-- ============================
DEFINE TABLE app SCHEMAFUL;
DEFINE FIELD appGdpr ON app TYPE record<app_gdpr>;

-- ============================
-- Table: gdpr_audit_log
-- ============================
DEFINE TABLE gdpr_audit_log SCHEMAFUL;
DEFINE FIELD event      ON gdpr_audit_log TYPE string;
DEFINE FIELD user       ON gdpr_audit_log TYPE string;
DEFINE FIELD workspace  ON gdpr_audit_log TYPE string;
DEFINE FIELD payload    ON gdpr_audit_log TYPE object;
DEFINE FIELD timestamp  ON gdpr_audit_log TYPE datetime;

