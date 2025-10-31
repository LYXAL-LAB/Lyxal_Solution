-- Sessions de paiement avec extensions bank-payment
DEFINE TABLE payment_session_bank_payment SCHEMAFULL;
DEFINE FIELD name ON payment_session_bank_payment TYPE string;
DEFINE FIELD company ON payment_session_bank_payment TYPE record<company>;
DEFINE FIELD payment_mode ON payment_session_bank_payment TYPE record<payment_mode_bank_payment>;
DEFINE FIELD partner_type_select ON payment_session_bank_payment TYPE int;
DEFINE FIELD bank_order ON payment_session_bank_payment TYPE record<bank_order>;
DEFINE FIELD status_select ON payment_session_bank_payment TYPE int DEFAULT 1;
DEFINE FIELD session_date ON payment_session_bank_payment TYPE date;
DEFINE FIELD bank_order_date ON payment_session_bank_payment TYPE date;
DEFINE FIELD accounting_trigger_select ON payment_session_bank_payment TYPE int;
DEFINE FIELD currency ON payment_session_bank_payment TYPE record<currency>;
DEFINE FIELD assign_to_me_bank_order ON payment_session_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD email ON payment_session_bank_payment TYPE string;
DEFINE FIELD next_session_date ON payment_session_bank_payment TYPE date;
DEFINE FIELD invoice_set ON payment_session_bank_payment TYPE array<record<invoice>>;
DEFINE FIELD invoice_term_set ON payment_session_bank_payment TYPE array<record<invoice_term>>;
DEFINE FIELD move_line_set ON payment_session_bank_payment TYPE array<record<move_line>>;
DEFINE FIELD payment_schedule_line_set ON payment_session_bank_payment TYPE array<record<payment_schedule_line>>;
DEFINE FIELD bank_order_line_set ON payment_session_bank_payment TYPE array<record<bank_order_line>>;
DEFINE FIELD journal ON payment_session_bank_payment TYPE record<journal>;
DEFINE FIELD bankDetails ON payment_session_bank_payment TYPE record<bank_details>;
DEFINE FIELD created_at ON payment_session_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_session_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_session_bank_payment TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_payment_session_bank_payment_company ON payment_session_bank_payment FIELDS company;
DEFINE INDEX idx_payment_session_bank_payment_status ON payment_session_bank_payment FIELDS status_select;
DEFINE INDEX idx_payment_session_bank_payment_date ON payment_session_bank_payment FIELDS session_date;
DEFINE INDEX idx_payment_session_bank_payment_mode ON payment_session_bank_payment FIELDS payment_mode;
