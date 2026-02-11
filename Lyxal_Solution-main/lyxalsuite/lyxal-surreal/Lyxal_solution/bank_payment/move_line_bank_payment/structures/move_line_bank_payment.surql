-- Lignes d'écriture étendues pour bank payment
DEFINE TABLE move_line_bank_payment SCHEMAFULL;
DEFINE FIELD move ON move_line_bank_payment TYPE record<move>;
DEFINE FIELD partner ON move_line_bank_payment TYPE record<partner>;
DEFINE FIELD account ON move_line_bank_payment TYPE record<account>;
DEFINE FIELD debit ON move_line_bank_payment TYPE decimal;
DEFINE FIELD credit ON move_line_bank_payment TYPE decimal;
DEFINE FIELD amount_remaining ON move_line_bank_payment TYPE decimal;
DEFINE FIELD currency_amount ON move_line_bank_payment TYPE decimal;
DEFINE FIELD currency_rate ON move_line_bank_payment TYPE decimal;
DEFINE FIELD currency ON move_line_bank_payment TYPE record<currency>;
DEFINE FIELD date ON move_line_bank_payment TYPE date;
DEFINE FIELD due_date ON move_line_bank_payment TYPE date;
DEFINE FIELD description ON move_line_bank_payment TYPE string;
DEFINE FIELD origin ON move_line_bank_payment TYPE string;
DEFINE FIELD reconcile_group ON move_line_bank_payment TYPE record<reconcile_group>;
DEFINE FIELD bank_reconciliation_line ON move_line_bank_payment TYPE record<bank_reconciliation_line>;
DEFINE FIELD bank_order_line ON move_line_bank_payment TYPE record<bank_order_line>;
DEFINE FIELD payment_session ON move_line_bank_payment TYPE record<payment_session_bank_payment>;
DEFINE FIELD is_selected_bank_reconciliation ON move_line_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD bank_statement_query ON move_line_bank_payment TYPE record<bank_statement_query>;
DEFINE FIELD created_at ON move_line_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move_line_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move_line_bank_payment TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_move_line_bank_payment_move ON move_line_bank_payment FIELDS move;
DEFINE INDEX idx_move_line_bank_payment_partner ON move_line_bank_payment FIELDS partner;
DEFINE INDEX idx_move_line_bank_payment_account ON move_line_bank_payment FIELDS account;
DEFINE INDEX idx_move_line_bank_payment_date ON move_line_bank_payment FIELDS date;
DEFINE INDEX idx_move_line_bank_payment_due_date ON move_line_bank_payment FIELDS due_date;