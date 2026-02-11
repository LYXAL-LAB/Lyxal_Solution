-- Ordres bancaires
DEFINE TABLE bank_order SCHEMAFULL;
DEFINE FIELD bank_order_seq ON bank_order TYPE string;
DEFINE FIELD name ON bank_order TYPE string;
DEFINE FIELD company ON bank_order TYPE record<company>;
DEFINE FIELD payment_mode ON bank_order TYPE record<payment_mode_bank_payment>;
DEFINE FIELD partner_type_select ON bank_order TYPE int;
DEFINE FIELD bank_order_date ON bank_order TYPE date;
DEFINE FIELD bank_order_execution_date ON bank_order TYPE date;
DEFINE FIELD status_select ON bank_order TYPE int DEFAULT 1;
DEFINE FIELD reject_status_select ON bank_order TYPE int DEFAULT 0;
DEFINE FIELD file_generated_status_select ON bank_order TYPE int DEFAULT 1;
DEFINE FIELD accounting_trigger_select ON bank_order TYPE int;
DEFINE FIELD bank_order_total_amount ON bank_order TYPE decimal;
DEFINE FIELD arithmetic_total ON bank_order TYPE decimal;
DEFINE FIELD nb_of_lines ON bank_order TYPE int;
DEFINE FIELD bank_order_line_list ON bank_order TYPE array<record<bank_order_line>>;
DEFINE FIELD signatory_user ON bank_order TYPE record<user>;
DEFINE FIELD signatory_e_banking_user ON bank_order TYPE record<user>;
DEFINE FIELD is_multidate ON bank_order TYPE bool DEFAULT false;
DEFINE FIELD is_multi_currency ON bank_order TYPE bool DEFAULT false;
DEFINE FIELD bank_order_currency ON bank_order TYPE record<currency>;
DEFINE FIELD generated_file_name ON bank_order TYPE string;
DEFINE FIELD file_generation_date_time ON bank_order TYPE datetime;
DEFINE FIELD signed_file_name ON bank_order TYPE string;
DEFINE FIELD signing_date_time ON bank_order TYPE datetime;
DEFINE FIELD transmitted_date_time ON bank_order TYPE datetime;
DEFINE FIELD is_transmitted ON bank_order TYPE bool DEFAULT false;
DEFINE FIELD bank_order_file_format ON bank_order TYPE string;
DEFINE FIELD sender_reference ON bank_order TYPE string;
DEFINE FIELD sender_label ON bank_order TYPE string;
DEFINE FIELD budget_distribution_sum_amount ON bank_order TYPE decimal;
DEFINE FIELD send_email_on_file_generation ON bank_order TYPE bool DEFAULT false;
DEFINE FIELD send_email_on_reject ON bank_order TYPE bool DEFAULT false;
DEFINE FIELD send_email_on_validation ON bank_order TYPE bool DEFAULT false;
DEFINE FIELD order_type_select ON bank_order TYPE int;
DEFINE FIELD created_at ON bank_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_order TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_order TYPE int DEFAULT 0;

-- Index pour BankOrder

DEFINE INDEX idx_bank_order_company ON bank_order FIELDS company;
DEFINE INDEX idx_bank_order_status ON bank_order FIELDS status_select;
DEFINE INDEX idx_bank_order_date ON bank_order FIELDS bank_order_date;
DEFINE INDEX idx_bank_order_seq ON bank_order FIELDS bank_order_seq;
DEFINE INDEX idx_bank_order_payment_mode ON bank_order FIELDS payment_mode;