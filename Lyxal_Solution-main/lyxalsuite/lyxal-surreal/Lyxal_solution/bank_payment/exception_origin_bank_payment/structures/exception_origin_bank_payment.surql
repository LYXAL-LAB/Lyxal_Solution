-- Origines d'exception pour bank payment
DEFINE TABLE exception_origin_bank_payment SCHEMAFULL;
DEFINE FIELD name ON exception_origin_bank_payment TYPE string;
DEFINE FIELD code ON exception_origin_bank_payment TYPE string;
DEFINE FIELD exception_type_select ON exception_origin_bank_payment TYPE int;
DEFINE FIELD related_to_select ON exception_origin_bank_payment TYPE int;
DEFINE FIELD description ON exception_origin_bank_payment TYPE string;
DEFINE FIELD is_active ON exception_origin_bank_payment TYPE bool DEFAULT true;
DEFINE FIELD sequence ON exception_origin_bank_payment TYPE int;
DEFINE FIELD company ON exception_origin_bank_payment TYPE record<company>;
DEFINE FIELD bank_payment_module_ok ON exception_origin_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD bank_reconciliation_exception_ok ON exception_origin_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD bank_statement_import_exception_ok ON exception_origin_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD bank_order_exception_ok ON exception_origin_bank_payment TYPE bool DEFAULT false;
DEFINE FIELD created_at ON exception_origin_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON exception_origin_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON exception_origin_bank_payment TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_exception_origin_bank_payment_code ON exception_origin_bank_payment FIELDS code;
DEFINE INDEX idx_exception_origin_bank_payment_active ON exception_origin_bank_payment FIELDS is_active;
DEFINE INDEX idx_exception_origin_bank_payment_company ON exception_origin_bank_payment FIELDS company;