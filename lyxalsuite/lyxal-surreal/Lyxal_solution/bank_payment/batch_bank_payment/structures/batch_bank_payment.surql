-- Traitements par lot bancaires
DEFINE TABLE batch_bank_payment SCHEMAFULL;
DEFINE FIELD code ON batch_bank_payment TYPE string;
DEFINE FIELD description ON batch_bank_payment TYPE string;
DEFINE FIELD action_select ON batch_bank_payment TYPE int;
DEFINE FIELD company ON batch_bank_payment TYPE record<company>;
DEFINE FIELD bank_payment_config ON batch_bank_payment TYPE record<bank_payment_config>;
DEFINE FIELD payment_mode ON batch_bank_payment TYPE record<payment_mode_bank_payment>;
DEFINE FIELD due_date_from ON batch_bank_payment TYPE date;
DEFINE FIELD due_date_to ON batch_bank_payment TYPE date;
DEFINE FIELD currency ON batch_bank_payment TYPE record<currency>;
DEFINE FIELD bank_details ON batch_bank_payment TYPE record<bank_details>;
DEFINE FIELD include_other_bank_details ON batch_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD update_customer_account_ok ON batch_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD update_due_date_ok ON batch_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD partner_type_select ON batch_bank_payment TYPE int;
DEFINE FIELD journal ON batch_bank_payment TYPE record<journal>;
DEFINE FIELD accounting_trigger_select ON batch_bank_payment TYPE int;
DEFINE FIELD bank_order_date ON batch_bank_payment TYPE date;
DEFINE FIELD bank_statement_file_format ON batch_bank_payment TYPE record<bank_statement_file_format>;
DEFINE FIELD import_folder_path ON batch_bank_payment TYPE string;
DEFINE FIELD status_select ON batch_bank_payment TYPE int DEFAULT 1;
DEFINE FIELD start_date ON batch_bank_payment TYPE datetime;
DEFINE FIELD end_date ON batch_bank_payment TYPE datetime;
DEFINE FIELD anomaly ON batch_bank_payment TYPE string;
DEFINE FIELD created_at ON batch_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON batch_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON batch_bank_payment TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_batch_bank_payment_company ON batch_bank_payment FIELDS company;
DEFINE INDEX idx_batch_bank_payment_action ON batch_bank_payment FIELDS action_select;
DEFINE INDEX idx_batch_bank_payment_status ON batch_bank_payment FIELDS status_select;
DEFINE INDEX idx_batch_bank_payment_date ON batch_bank_payment FIELDS due_date_from, due_date_to;