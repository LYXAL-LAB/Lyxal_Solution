-- Lignes AFB120 (format français)
DEFINE TABLE bank_statement_line_afb120 SCHEMAFULL;
DEFINE FIELD bank_statement_line ON bank_statement_line_afb120 TYPE record<bank_statement_line>;
DEFINE FIELD operation_code ON bank_statement_line_afb120 TYPE string;
DEFINE FIELD additional_information ON bank_statement_line_afb120 TYPE string;
DEFINE FIELD internal_operation_code ON bank_statement_line_afb120 TYPE string;
DEFINE FIELD bank_reference ON bank_statement_line_afb120 TYPE string;
DEFINE FIELD sequence ON bank_statement_line_afb120 TYPE int;
DEFINE FIELD created_at ON bank_statement_line_afb120 TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_statement_line_afb120 TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_statement_line_afb120 TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_bank_statement_line_afb120_line ON bank_statement_line_afb120 FIELDS bank_statement_line;
DEFINE INDEX idx_bank_statement_line_afb120_sequence ON bank_statement_line_afb120 FIELDS sequence;