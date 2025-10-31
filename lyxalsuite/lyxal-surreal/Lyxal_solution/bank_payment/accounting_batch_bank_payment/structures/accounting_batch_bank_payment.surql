-- Batch comptable pour bank payment
DEFINE TABLE accounting_batch_bank_payment SCHEMAFULL;
DEFINE FIELD action_select ON accounting_batch_bank_payment TYPE int;
DEFINE FIELD due_date_from ON accounting_batch_bank_payment TYPE date;
DEFINE FIELD due_date_to ON accounting_batch_bank_payment TYPE date;
DEFINE FIELD company ON accounting_batch_bank_payment TYPE record<company>;
DEFINE FIELD currency ON accounting_batch_bank_payment TYPE record<currency>;
DEFINE FIELD payment_mode ON accounting_batch_bank_payment TYPE record<payment_mode_bank_payment>;
DEFINE FIELD bank_details ON accounting_batch_bank_payment TYPE record<bank_details>;
DEFINE FIELD include_other_bank_details ON accounting_batch_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD update_customer_account_ok ON accounting_batch_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD update_due_date_ok ON accounting_batch_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD partner_type_select ON accounting_batch_bank_payment TYPE int;
DEFINE FIELD journal ON accounting_batch_bank_payment TYPE record<journal>;
DEFINE FIELD bank_payment_config ON accounting_batch_bank_payment TYPE record<bank_payment_config>;
DEFINE FIELD bank_order_date ON accounting_batch_bank_payment TYPE date;
DEFINE FIELD status_select ON accounting_batch_bank_payment TYPE int DEFAULT 1;
DEFINE FIELD start_date ON accounting_batch_bank_payment TYPE datetime;
DEFINE FIELD end_date ON accounting_batch_bank_payment TYPE datetime;
DEFINE FIELD done ON accounting_batch_bank_payment TYPE int DEFAULT 0;
DEFINE FIELD anomaly ON accounting_batch_bank_payment TYPE int DEFAULT 0;
DEFINE FIELD created_at ON accounting_batch_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_batch_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_batch_bank_payment TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_accounting_batch_bank_payment_company ON accounting_batch_bank_payment FIELDS company;
DEFINE INDEX idx_accounting_batch_bank_payment_action ON accounting_batch_bank_payment FIELDS action_select;
DEFINE INDEX idx_accounting_batch_bank_payment_status ON accounting_batch_bank_payment FIELDS status_select;
