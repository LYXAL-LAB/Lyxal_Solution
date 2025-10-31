-- Paiements de facture étendus pour bank payment
DEFINE TABLE invoice_payment_bank_payment SCHEMAFULL;
DEFINE FIELD invoice ON invoice_payment_bank_payment TYPE record<invoice>;
DEFINE FIELD payment_mode ON invoice_payment_bank_payment TYPE record<payment_mode_bank_payment>;
DEFINE FIELD company_bank_details ON invoice_payment_bank_payment TYPE record<bank_details>;
DEFINE FIELD amount ON invoice_payment_bank_payment TYPE decimal;
DEFINE FIELD currency ON invoice_payment_bank_payment TYPE record<currency>;
DEFINE FIELD payment_date ON invoice_payment_bank_payment TYPE date;
DEFINE FIELD bank_order_line ON invoice_payment_bank_payment TYPE record<bank_order_line>;
DEFINE FIELD bank_order ON invoice_payment_bank_payment TYPE record<bank_order>;
DEFINE FIELD bank_statement_line ON invoice_payment_bank_payment TYPE record<bank_statement_line>;
DEFINE FIELD type_select ON invoice_payment_bank_payment TYPE int;
DEFINE FIELD status_select ON invoice_payment_bank_payment TYPE int DEFAULT 1;
DEFINE FIELD description ON invoice_payment_bank_payment TYPE string;
DEFINE FIELD currency_amount ON invoice_payment_bank_payment TYPE decimal;
DEFINE FIELD currency_rate ON invoice_payment_bank_payment TYPE decimal;
DEFINE FIELD payment_move ON invoice_payment_bank_payment TYPE record<move>;
DEFINE FIELD reconcile ON invoice_payment_bank_payment TYPE record<reconcile>;
DEFINE FIELD created_at ON invoice_payment_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_payment_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_payment_bank_payment TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_invoice_payment_bank_payment_invoice ON invoice_payment_bank_payment FIELDS invoice;
DEFINE INDEX idx_invoice_payment_bank_payment_payment_mode ON invoice_payment_bank_payment FIELDS payment_mode;
DEFINE INDEX idx_invoice_payment_bank_payment_status ON invoice_payment_bank_payment FIELDS status_select;
DEFINE INDEX idx_invoice_payment_bank_payment_date ON invoice_payment_bank_payment FIELDS payment_date;