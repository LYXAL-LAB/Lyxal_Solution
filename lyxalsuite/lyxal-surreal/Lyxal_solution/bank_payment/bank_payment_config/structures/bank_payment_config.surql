-- Configuration des paiements bancaires
DEFINE TABLE bank_payment_config SCHEMAFULL;
DEFINE FIELD name ON bank_payment_config TYPE string;
DEFINE FIELD company ON bank_payment_config TYPE record<company>;
DEFINE FIELD bank_details ON bank_payment_config TYPE record<bank_details>;
DEFINE FIELD journal ON bank_payment_config TYPE record<journal>;
DEFINE FIELD is_multiple_partner_type_allowed ON bank_payment_config TYPE bool DEFAULT false;
DEFINE FIELD partner_type_on_order_select ON bank_payment_config TYPE int;
DEFINE FIELD default_signatory_user ON bank_payment_config TYPE record<user>;
DEFINE FIELD generate_bank_order_line_by_move_line ON bank_payment_config TYPE bool DEFAULT true;
DEFINE FIELD accounting_trigger_select ON bank_payment_config TYPE int;
DEFINE FIELD payment_mode_type_select ON bank_payment_config TYPE int;
DEFINE FIELD is_multidate_allowed ON bank_payment_config TYPE bool DEFAULT false;
DEFINE FIELD is_multi_currency_allowed ON bank_payment_config TYPE bool DEFAULT false;
DEFINE FIELD allow_order_currencies_different ON bank_payment_config TYPE bool DEFAULT false;
DEFINE FIELD is_debit_credit_managed ON bank_payment_config TYPE bool DEFAULT false;
DEFINE FIELD is_bank_order_line_origin_required ON bank_payment_config TYPE bool DEFAULT false;
DEFINE FIELD automatic_transmission_ok ON bank_payment_config TYPE bool DEFAULT false;
DEFINE FIELD transmission_user ON bank_payment_config TYPE record<user>;
DEFINE FIELD signing_user ON bank_payment_config TYPE record<user>;
DEFINE FIELD bank_statement_format ON bank_payment_config TYPE record<bank_statement_file_format>;
DEFINE FIELD automatic_import_ok ON bank_payment_config TYPE bool DEFAULT false;
DEFINE FIELD import_folder_path_cfonb ON bank_payment_config TYPE string;
DEFINE FIELD temp_import_folder_path_cfonb ON bank_payment_config TYPE string;
DEFINE FIELD imported_folder_path_cfonb ON bank_payment_config TYPE string;
DEFINE FIELD created_at ON bank_payment_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_payment_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_payment_config TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_bank_payment_config_company ON bank_payment_config FIELDS company;
DEFINE INDEX idx_bank_payment_config_bank_details ON bank_payment_config FIELDS bank_details;