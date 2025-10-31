-- Lignes de réconciliation bancaire
DEFINE TABLE bank_reconciliation_line SCHEMAFULL;
DEFINE FIELD bank_reconciliation ON bank_reconciliation_line TYPE record<bank_reconciliation>;
DEFINE FIELD name ON bank_reconciliation_line TYPE string;
DEFINE FIELD reference ON bank_reconciliation_line TYPE string;
DEFINE FIELD is_reconciled ON bank_reconciliation_line TYPE bool DEFAULT false;
DEFINE FIELD is_selected ON bank_reconciliation_line TYPE bool DEFAULT false;
DEFINE FIELD effect_date ON bank_reconciliation_line TYPE date;
DEFINE FIELD debit ON bank_reconciliation_line TYPE decimal;
DEFINE FIELD credit ON bank_reconciliation_line TYPE decimal;
DEFINE FIELD bank_statement_line ON bank_reconciliation_line TYPE record<bank_statement_line>;
DEFINE FIELD move_line ON bank_reconciliation_line TYPE record<move_line>;
DEFINE FIELD line_type_select ON bank_reconciliation_line TYPE int;
DEFINE FIELD confidence_index ON bank_reconciliation_line TYPE int;
DEFINE FIELD is_poste ON bank_reconciliation_line TYPE bool DEFAULT false;
DEFINE FIELD is_unreconcile_ok ON bank_reconciliation_line TYPE bool DEFAULT false;
DEFINE FIELD partner ON bank_reconciliation_line TYPE record<partner>;
DEFINE FIELD description ON bank_reconciliation_line TYPE string;
DEFINE FIELD amount_remaining ON bank_reconciliation_line TYPE decimal;
DEFINE FIELD currency_amount ON bank_reconciliation_line TYPE decimal;
DEFINE FIELD currency_amount_remaining ON bank_reconciliation_line TYPE decimal;
DEFINE FIELD sequence ON bank_reconciliation_line TYPE int;
DEFINE FIELD move_line_pointer ON bank_reconciliation_line TYPE int;
DEFINE FIELD bank_statement_line_pointer ON bank_reconciliation_line TYPE int;
DEFINE FIELD created_at ON bank_reconciliation_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_reconciliation_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_reconciliation_line TYPE int DEFAULT 0;

-- Index 

DEFINE INDEX idx_bank_reconciliation_line_reconciliation ON bank_reconciliation_line FIELDS bank_reconciliation;
DEFINE INDEX idx_bank_reconciliation_line_reconciled ON bank_reconciliation_line FIELDS is_reconciled;
DEFINE INDEX idx_bank_reconciliation_line_date ON bank_reconciliation_line FIELDS effect_date;
DEFINE INDEX idx_bank_reconciliation_line_selected ON bank_reconciliation_line FIELDS is_selected;
DEFINE INDEX idx_bank_reconciliation_line_type ON bank_reconciliation_line FIELDS line_type_select;
DEFINE INDEX idx_bank_reconciliation_line_move_line ON bank_reconciliation_line FIELDS move_line;
DEFINE INDEX idx_bank_reconciliation_line_statement_line ON bank_reconciliation_line FIELDS bank_statement_line;
