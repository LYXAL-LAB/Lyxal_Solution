-- Règles de relevé bancaire
DEFINE TABLE bank_statement_rule SCHEMAFULL;
DEFINE FIELD name ON bank_statement_rule TYPE string;
DEFINE FIELD rule_type_select ON bank_statement_rule TYPE int;
DEFINE FIELD search_text_list ON bank_statement_rule TYPE array<string>;
DEFINE FIELD partner ON bank_statement_rule TYPE record<partner>;
DEFINE FIELD account ON bank_statement_rule TYPE record<account>;
DEFINE FIELD counter_part_account ON bank_statement_rule TYPE record<account>;
DEFINE FIELD is_reconcile_invoice ON bank_statement_rule TYPE bool DEFAULT false;
DEFINE FIELD tax_list ON bank_statement_rule TYPE array<record<tax>>;
DEFINE FIELD amount_range_from ON bank_statement_rule TYPE decimal;
DEFINE FIELD amount_range_to ON bank_statement_rule TYPE decimal;
DEFINE FIELD description_regex ON bank_statement_rule TYPE string;
DEFINE FIELD reference_regex ON bank_statement_rule TYPE string;
DEFINE FIELD is_active ON bank_statement_rule TYPE bool DEFAULT true;
DEFINE FIELD sequence ON bank_statement_rule TYPE int;
DEFINE FIELD company ON bank_statement_rule TYPE record<company>;
DEFINE FIELD bank_details ON bank_statement_rule TYPE record<bank_details>;
DEFINE FIELD journal ON bank_statement_rule TYPE record<journal>;
DEFINE FIELD created_at ON bank_statement_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_statement_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_statement_rule TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_bank_statement_rule_company ON bank_statement_rule FIELDS company;
DEFINE INDEX idx_bank_statement_rule_active ON bank_statement_rule FIELDS is_active;
DEFINE INDEX idx_bank_statement_rule_sequence ON bank_statement_rule FIELDS sequence;
DEFINE INDEX idx_bank_statement_rule_type ON bank_statement_rule FIELDS rule_type_select;