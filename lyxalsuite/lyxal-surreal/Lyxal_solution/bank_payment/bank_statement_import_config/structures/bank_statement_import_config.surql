-- Paramètres d'import de relevé
DEFINE TABLE bank_statement_import_config SCHEMAFULL;
DEFINE FIELD name ON bank_statement_import_config TYPE string;
DEFINE FIELD company ON bank_statement_import_config TYPE record<company>;
DEFINE FIELD bank_details ON bank_statement_import_config TYPE record<bank_details>;
DEFINE FIELD bank_statement_file_format ON bank_statement_import_config TYPE record<bank_statement_file_format>;
DEFINE FIELD import_folder_path ON bank_statement_import_config TYPE string;
DEFINE FIELD temp_import_folder_path ON bank_statement_import_config TYPE string;
DEFINE FIELD imported_folder_path ON bank_statement_import_config TYPE string;
DEFINE FIELD error_folder_path ON bank_statement_import_config TYPE string;
DEFINE FIELD auto_reconcile_on_import ON bank_statement_import_config TYPE bool DEFAULT false;
DEFINE FIELD reconcile_threshold ON bank_statement_import_config TYPE decimal DEFAULT 0.0;
DEFINE FIELD is_active ON bank_statement_import_config TYPE bool DEFAULT true;
DEFINE FIELD created_at ON bank_statement_import_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_statement_import_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_statement_import_config TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_bank_statement_import_config_company ON bank_statement_import_config FIELDS company;
DEFINE INDEX idx_bank_statement_import_config_active ON bank_statement_import_config FIELDS is_active; 