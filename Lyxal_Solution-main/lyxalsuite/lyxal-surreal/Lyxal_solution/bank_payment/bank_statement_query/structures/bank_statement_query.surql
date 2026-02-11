-- Requêtes de relevé bancaire
DEFINE TABLE bank_statement_query SCHEMAFULL;
DEFINE FIELD name ON bank_statement_query TYPE string;
DEFINE FIELD company ON bank_statement_query TYPE record<company>;
DEFINE FIELD cash_account ON bank_statement_query TYPE record<account>;
DEFINE FIELD bank_details ON bank_statement_query TYPE record<bank_details>;
DEFINE FIELD from_date ON bank_statement_query TYPE date;
DEFINE FIELD to_date ON bank_statement_query TYPE date;
DEFINE FIELD amount_from ON bank_statement_query TYPE decimal;
DEFINE FIELD amount_to ON bank_statement_query TYPE decimal;
DEFINE FIELD description ON bank_statement_query TYPE string;
DEFINE FIELD reference ON bank_statement_query TYPE string;
DEFINE FIELD bank_statement_line_type_select ON bank_statement_query TYPE int;
DEFINE FIELD include_reconciled_lines ON bank_statement_query TYPE bool DEFAULT false;
DEFINE FIELD sequence ON bank_statement_query TYPE int;
DEFINE FIELD created_at ON bank_statement_query TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_statement_query TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_statement_query TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_bank_statement_query_company ON bank_statement_query FIELDS company;
DEFINE INDEX idx_bank_statement_query_account ON bank_statement_query FIELDS cash_account;
DEFINE INDEX idx_bank_statement_query_date ON bank_statement_query FIELDS from_date, to_date;
