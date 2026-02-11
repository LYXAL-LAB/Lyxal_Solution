-- Modes de paiement bancaire
DEFINE TABLE payment_mode_bank_payment SCHEMAFULL;
DEFINE FIELD code ON payment_mode_bank_payment TYPE string;
DEFINE FIELD name ON payment_mode_bank_payment TYPE string;
DEFINE FIELD type_select ON payment_mode_bank_payment TYPE int;
DEFINE FIELD in_or_out_select ON payment_mode_bank_payment TYPE int;
DEFINE FIELD account_in_bank_details ON payment_mode_bank_payment TYPE record<account>;
DEFINE FIELD account_out_bank_details ON payment_mode_bank_payment TYPE record<account>;
DEFINE FIELD bank_payment_config ON payment_mode_bank_payment TYPE record<bank_payment_config>;
DEFINE FIELD generate_bank_order ON payment_mode_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD order_type_select ON payment_mode_bank_payment TYPE int;
DEFINE FIELD bank_order_file_format ON payment_mode_bank_payment TYPE string;
DEFINE FIELD use_for_partner_payment ON payment_mode_bank_payment TYPE bool DEFAULT true;
DEFINE FIELD automatic_transmission ON payment_mode_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD need_validation_from_user ON payment_mode_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD bank_order_export_folder_path ON payment_mode_bank_payment TYPE string;
DEFINE FIELD signed_bank_order_file_format ON payment_mode_bank_payment TYPE string;
DEFINE FIELD sequence ON payment_mode_bank_payment TYPE record<sequence>;
DEFINE FIELD created_at ON payment_mode_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_mode_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_mode_bank_payment TYPE int DEFAULT 0;

-- Index 

DEFINE INDEX idx_payment_mode_bank_payment_code ON payment_mode_bank_payment FIELDS code;
DEFINE INDEX idx_payment_mode_bank_payment_type ON payment_mode_bank_payment FIELDS type_select;
DEFINE INDEX idx_payment_mode_bank_payment_config ON payment_mode_bank_payment FIELDS bank_payment_config;
