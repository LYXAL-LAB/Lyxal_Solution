-- Relevés bancaires
DEFINE TABLE bank_statement SCHEMAFULL;
DEFINE FIELD name ON bank_statement TYPE string;
DEFINE FIELD company ON bank_statement TYPE record<company>;
DEFINE FIELD bank_details ON bank_statement TYPE record<bank_details>;
DEFINE FIELD from_date ON bank_statement TYPE date;
DEFINE FIELD to_date ON bank_statement TYPE date;
DEFINE FIELD balance_start ON bank_statement TYPE decimal;
DEFINE FIELD balance_end ON bank_statement TYPE decimal;
DEFINE FIELD total_payment_fees ON bank_statement TYPE decimal;
DEFINE FIELD status_select ON bank_statement TYPE int DEFAULT 1;
DEFINE FIELD bank_statement_line_list ON bank_statement TYPE array<record<bank_statement_line>>;
DEFINE FIELD currency ON bank_statement TYPE record<currency>;
DEFINE FIELD reference ON bank_statement TYPE reference;
DEFINE FIELD electronic_import ON bank_statement TYPE bool DEFAULT false;
DEFINE FIELD import_id ON bank_statement TYPE string;
DEFINE FIELD import_date ON bank_statement TYPE datetime;
DEFINE FIELD imported_file_name ON bank_statement TYPE string;
DEFINE FIELD bank_statement_file_format ON bank_statement TYPE record<bank_statement_file_format>;
DEFINE FIELD created_at ON bank_statement TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_statement TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_statement TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_bank_statement_company ON bank_statement FIELDS company;
DEFINE INDEX idx_bank_statement_bank_details ON bank_statement FIELDS bank_details;
DEFINE INDEX idx_bank_statement_date ON bank_statement FIELDS from_date, to_date;
DEFINE INDEX idx_bank_statement_status ON bank_statement FIELDS status_select;
DEFINE INDEX idx_bank_statement_reference ON bank_statement FIELDS reference;