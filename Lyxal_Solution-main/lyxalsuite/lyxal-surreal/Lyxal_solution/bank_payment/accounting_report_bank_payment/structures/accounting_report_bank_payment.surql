-- Rapports comptables pour bank payment
DEFINE TABLE accounting_report_bank_payment SCHEMAFULL;
DEFINE FIELD name ON accounting_report_bank_payment TYPE string;
DEFINE FIELD report_type ON accounting_report_bank_payment TYPE record<accounting_report_type>;
DEFINE FIELD company ON accounting_report_bank_payment TYPE record<company>;
DEFINE FIELD period ON accounting_report_bank_payment TYPE record<period>;
DEFINE FIELD date_from ON accounting_report_bank_payment TYPE date;
DEFINE FIELD date_to ON accounting_report_bank_payment TYPE date;
DEFINE FIELD currency ON accounting_report_bank_payment TYPE record<currency>;
DEFINE FIELD journal ON accounting_report_bank_payment TYPE record<journal>;
DEFINE FIELD bank_details ON accounting_report_bank_payment TYPE record<bank_details>;
DEFINE FIELD payment_mode ON accounting_report_bank_payment TYPE record<payment_mode_bank_payment>;
DEFINE FIELD bank_reconciliation ON accounting_report_bank_payment TYPE record<bank_reconciliation>;
DEFINE FIELD status_select ON accounting_report_bank_payment TYPE int DEFAULT 1;
DEFINE FIELD export_path ON accounting_report_bank_payment TYPE string;
DEFINE FIELD created_at ON accounting_report_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_report_bank_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_report_bank_payment TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_accounting_report_bank_payment_company ON accounting_report_bank_payment FIELDS company;
DEFINE INDEX idx_accounting_report_bank_payment_type ON accounting_report_bank_payment FIELDS report_type;
DEFINE INDEX idx_accounting_report_bank_payment_status ON accounting_report_bank_payment FIELDS status_select;