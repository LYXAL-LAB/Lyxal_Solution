-- Application bank payment
DEFINE TABLE app_bank_payment SCHEMAFULL;
DEFINE FIELD name ON app_bank_payment TYPE string DEFAULT "Bank Payment";
DEFINE FIELD code ON app_bank_payment TYPE string DEFAULT "bank-payment";
DEFINE FIELD is_active ON app_bank_payment TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app_bank_payment TYPE int DEFAULT 20;
DEFINE FIELD depends_on_set ON app_bank_payment TYPE array<string>;
DEFINE FIELD bank_order_export_path ON app_bank_payment TYPE string;
DEFINE FIELD bank_statement_import_path ON app_bank_payment TYPE string;
DEFINE FIELD auto_reconcile_on_import ON app_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD reconcile_threshold ON app_bank_payment TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON app_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_bank_payment TYPE int DEFAULT 0;