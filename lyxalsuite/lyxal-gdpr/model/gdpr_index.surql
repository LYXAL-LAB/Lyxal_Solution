--  Unicité sur les codes
DEFINE INDEX gdpr_request_origin_code_idx ON gdpr_request_origin FIELDS code UNIQUE;
DEFINE INDEX gdpr_processing_register_code_idx ON gdpr_processing_register FIELDS code UNIQUE;
DEFINE INDEX gdpr_search_config_model_idx ON gdpr_search_config FIELDS metaModel UNIQUE;
DEFINE INDEX relationship_anonymizer_model_idx ON relationship_anonymizer FIELDS model UNIQUE;

--  Optimisations supplémentaires (accès courant)
DEFINE INDEX gdpr_request_type_status_idx ON gdpr_request FIELDS typeSelect, statusSelect;
DEFINE INDEX gdpr_response_date_idx ON gdpr_response FIELDS sendingDateT;
DEFINE INDEX gdpr_processing_register_status_idx ON gdpr_processing_register FIELDS status;
DEFINE INDEX gdpr_erasure_log_model_idx ON gdpr_erasure_log FIELDS modelLog;
DEFINE INDEX gdpr_data_exclude_model_idx ON gdpr_data_to_exclude_config FIELDS metaModel;
DEFINE INDEX gdpr_search_line_key_idx ON gdpr_search_config_line FIELDS key;
