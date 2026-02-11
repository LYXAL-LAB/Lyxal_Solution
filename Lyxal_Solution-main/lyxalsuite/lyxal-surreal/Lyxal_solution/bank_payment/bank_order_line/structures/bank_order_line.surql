
-- Lignes d'ordre bancaire
DEFINE TABLE bank_order_line SCHEMAFULL;
DEFINE FIELD sequence ON bank_order_line TYPE int;
DEFINE FIELD bank_order ON bank_order_line TYPE record<bank_order>;
DEFINE FIELD partner ON bank_order_line TYPE record<partner>;
DEFINE FIELD receiver_company ON bank_order_line TYPE record<company>;
DEFINE FIELD amount ON bank_order_line TYPE decimal;
DEFINE FIELD currency ON bank_order_line TYPE record<currency>;
DEFINE FIELD amount_currency ON bank_order_line TYPE decimal;
DEFINE FIELD bank_order_line_origin ON bank_order_line TYPE string;
DEFINE FIELD bank_order_date ON bank_order_line TYPE date;
DEFINE FIELD bank_order_execution_date ON bank_order_line TYPE date;
DEFINE FIELD receiver_label ON bank_order_line TYPE string;
DEFINE FIELD receiver_reference ON bank_order_line TYPE string;
DEFINE FIELD receiver_bank_details ON bank_order_line TYPE record<bank_details>;
DEFINE FIELD payment_mode ON bank_order_line TYPE record<payment_mode_bank_payment>;
DEFINE FIELD payment_mode_line ON bank_order_line TYPE record<payment_mode_line>;
DEFINE FIELD budget_distribution_sum_amount ON bank_order_line TYPE decimal;
DEFINE FIELD invoice ON bank_order_line TYPE record<invoice>;
DEFINE FIELD move_line ON bank_order_line TYPE record<move_line>;
DEFINE FIELD payment_reason ON bank_order_line TYPE string;
DEFINE FIELD status_select ON bank_order_line TYPE int DEFAULT 1;
DEFINE FIELD reject_reason ON bank_order_line TYPE string;
DEFINE FIELD fees_amount ON bank_order_line TYPE decimal;
DEFINE FIELD fees_currency_amount ON bank_order_line TYPE decimal;
DEFINE FIELD is_fees_imputed ON bank_order_line TYPE bool DEFAULT false;
DEFINE FIELD fees_move_generated ON bank_order_line TYPE bool DEFAULT false;
DEFINE FIELD fees_account ON bank_order_line TYPE record<account>;
DEFINE FIELD payment_schedule_line ON bank_order_line TYPE record<payment_schedule_line>;
DEFINE FIELD invoice_payment ON bank_order_line TYPE record<invoice_payment>;
DEFINE FIELD partner_bank_details ON bank_order_line TYPE record<bank_details>;
DEFINE FIELD is_treasury_management_ok ON bank_order_line TYPE bool DEFAULT false;
DEFINE FIELD treasury_management_amount ON bank_order_line TYPE decimal;
DEFINE FIELD created_at ON bank_order_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_order_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_order_line TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_bank_order_line_bank_order ON bank_order_line FIELDS bank_order;
DEFINE INDEX idx_bank_order_line_partner ON bank_order_line FIELDS partner;
DEFINE INDEX idx_bank_order_line_amount ON bank_order_line FIELDS amount;
DEFINE INDEX idx_bank_order_line_status ON bank_order_line FIELDS status_select;
DEFINE INDEX idx_bank_order_line_date ON bank_order_line FIELDS bank_order_date;
DEFINE INDEX idx_bank_order_line_sequence ON bank_order_line FIELDS sequence;