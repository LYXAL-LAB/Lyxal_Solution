-- Configuration d'entreprise pour bank payment
DEFINE TABLE company_bank_payment SCHEMAFULL;
DEFINE FIELD name ON company_bank_payment TYPE string;
DEFINE FIELD code ON company_bank_payment TYPE string;
DEFINE FIELD partner ON company_bank_payment TYPE record<partner>;
DEFINE FIELD currency ON company_bank_payment TYPE record<currency>;
DEFINE FIELD bank_payment_config_list ON company_bank_payment TYPE array<record<bank_payment_config>>;
DEFINE FIELD bank_order_file_format_list ON company_bank_payment TYPE array<string>;
DEFINE FIELD ebics_partner ON company_bank_payment TYPE record<ebics_partner>;
DEFINE FIELD created_at ON company_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON company_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON company_bank_payment TYPE int DEFAULT 0;

