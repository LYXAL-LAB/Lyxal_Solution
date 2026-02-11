-- Lignes de relevé bancaire
DEFINE TABLE bank_statement_line SCHEMAFULL;
DEFINE FIELD bank_statement ON bank_statement_line TYPE record<bank_statement>;
DEFINE FIELD sequence ON bank_statement_line TYPE int;
DEFINE FIELD operation_date ON bank_statement_line TYPE date;
DEFINE FIELD value_date ON bank_statement_line TYPE date;
DEFINE FIELD description ON bank_statement_line TYPE string;
DEFINE FIELD reference ON bank_statement_line TYPE string;
DEFINE FIELD debit ON bank_statement_line TYPE decimal;
DEFINE FIELD credit ON bank_statement_line TYPE decimal;
DEFINE FIELD amount_remaining_reconciled ON bank_statement_line TYPE decimal;
DEFINE FIELD bank_statement_line_afb120_list ON bank_statement_line TYPE array<record<bank_statement_line_afb120>>;
DEFINE FIELD move_line ON bank_statement_line TYPE record<move_line>;
DEFINE FIELD partner ON bank_statement_line TYPE record<partner>;
DEFINE FIELD currency ON bank_statement_line TYPE record<currency>;
DEFINE FIELD currency_amount ON bank_statement_line TYPE decimal;
DEFINE FIELD currency_rate ON bank_statement_line TYPE decimal;
DEFINE FIELD additional_information_list ON bank_statement_line TYPE array<string>;
DEFINE FIELD bank_statement_query ON bank_statement_line TYPE record<bank_statement_query>;
DEFINE FIELD is_reconciled ON bank_statement_line TYPE bool DEFAULT false;
DEFINE FIELD reject_import ON bank_statement_line TYPE bool DEFAULT false;
DEFINE FIELD reject_reason ON bank_statement_line TYPE string;
DEFINE FIELD unavailability_end_date ON bank_statement_line TYPE date;
DEFINE FIELD created_at ON bank_statement_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_statement_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_statement_line TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_bank_statement_line_statement ON bank_statement_line FIELDS bank_statement;
DEFINE INDEX idx_bank_statement_line_date ON bank_statement_line FIELDS operation_date;
DEFINE INDEX idx_bank_statement_line_value_date ON bank_statement_line FIELDS value_date;
DEFINE INDEX idx_bank_statement_line_partner ON bank_statement_line FIELDS partner;
DEFINE INDEX idx_bank_statement_line_reconciled ON bank_statement_line FIELDS is_reconciled;
DEFINE INDEX idx_bank_statement_line_sequence ON bank_statement_line FIELDS sequence;
