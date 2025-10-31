-- Formats de fichier de relevé bancaire
DEFINE TABLE bank_statement_file_format SCHEMAFULL;
DEFINE FIELD name ON bank_statement_file_format TYPE string;
DEFINE FIELD static_import_type ON bank_statement_file_format TYPE string;
DEFINE FIELD file_extension ON bank_statement_file_format TYPE string;
DEFINE FIELD description ON bank_statement_file_format TYPE string;
DEFINE FIELD data_meta_file ON bank_statement_file_format TYPE record<meta_file>;
DEFINE FIELD sequence ON bank_statement_file_format TYPE int;
DEFINE FIELD separator_char ON bank_statement_file_format TYPE string DEFAULT ";";
DEFINE FIELD encoding_select ON bank_statement_file_format TYPE string DEFAULT "UTF-8";
DEFINE FIELD header_line_count ON bank_statement_file_format TYPE int DEFAULT 0;
DEFINE FIELD footer_line_count ON bank_statement_file_format TYPE int DEFAULT 0;
DEFINE FIELD statement_header_line_count ON bank_statement_file_format TYPE int DEFAULT 1;
DEFINE FIELD line_header_line_count ON bank_statement_file_format TYPE int DEFAULT 0;
DEFINE FIELD date_format ON bank_statement_file_format TYPE string DEFAULT "dd/MM/yyyy";
DEFINE FIELD decimal_separator ON bank_statement_file_format TYPE string DEFAULT ".";
DEFINE FIELD statement_name_col ON bank_statement_file_format TYPE int;
DEFINE FIELD statement_reference_col ON bank_statement_file_format TYPE int;
DEFINE FIELD statement_date_col ON bank_statement_file_format TYPE int;
DEFINE FIELD statement_balance_col ON bank_statement_file_format TYPE int;
DEFINE FIELD line_date_col ON bank_statement_file_format TYPE int;
DEFINE FIELD line_description_col ON bank_statement_file_format TYPE int;
DEFINE FIELD line_reference_col ON bank_statement_file_format TYPE int;
DEFINE FIELD line_debit_col ON bank_statement_file_format TYPE int;
DEFINE FIELD line_credit_col ON bank_statement_file_format TYPE int;
DEFINE FIELD created_at ON bank_statement_file_format TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_statement_file_format TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_statement_file_format TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_bank_statement_file_format_name ON bank_statement_file_format FIELDS name;
DEFINE INDEX idx_bank_statement_file_format_type ON bank_statement_file_format FIELDS static_import_type;