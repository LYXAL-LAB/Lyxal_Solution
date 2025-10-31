-- lyxalbank: INDEX TECHNIQUES ET RELATIONNELS

--  Bank Statement
DEFINE INDEX idx_bank_statement_name ON TABLE bank_statement COLUMNS name;
DEFINE INDEX idx_bank_statement_file_format ON TABLE bank_statement COLUMNS file_format;
DEFINE INDEX idx_bank_statement_status ON TABLE bank_statement COLUMNS status_select;

--  Bank Statement Line
DEFINE INDEX idx_bsl_bank_statement ON TABLE bank_statement_line COLUMNS bank_statement;
DEFINE INDEX idx_bsl_currency ON TABLE bank_statement_line COLUMNS currency;
DEFINE INDEX idx_bsl_bank_details ON TABLE bank_statement_line COLUMNS bank_details;

--  Bank Statement Line AFB120
DEFINE INDEX idx_bsl_afb120_currency ON TABLE bank_statement_line_afb120 COLUMNS currency;
DEFINE INDEX idx_bsl_afb120_bank_details ON TABLE bank_statement_line_afb120 COLUMNS bank_details;

--  Reconciliation
DEFINE INDEX idx_reco_bank_details ON TABLE bank_reconciliation COLUMNS bank_details;
DEFINE INDEX idx_reco_status ON TABLE bank_reconciliation COLUMNS status_select;
DEFINE INDEX idx_reco_company ON TABLE bank_reconciliation COLUMNS company;
DEFINE INDEX idx_reco_line_reconciliation ON TABLE bank_reconciliation_line COLUMNS bank_reconciliation;

--  Bank Order
DEFINE INDEX idx_bank_order_company ON TABLE bank_order COLUMNS company;
DEFINE INDEX idx_bank_order_partner ON TABLE bank_order COLUMNS partner;
DEFINE INDEX idx_bank_order_payment_mode ON TABLE bank_order COLUMNS payment_mode;
DEFINE INDEX idx_bank_order_status ON TABLE bank_order COLUMNS status;

--  Statement Rule
DEFINE INDEX idx_bsr_account_mgt ON TABLE bank_statement_rule COLUMNS account_management;
DEFINE INDEX idx_bsr_partner ON TABLE bank_statement_rule COLUMNS partner;
DEFINE INDEX idx_bsr_rule_type ON TABLE bank_statement_rule COLUMNS rule_type_select;

--  Statement Query
DEFINE INDEX idx_bsq_name ON TABLE bank_statement_query COLUMNS name;
DEFINE INDEX idx_bsq_type ON TABLE bank_statement_query COLUMNS rule_type_select;

--  Config & App
DEFINE INDEX idx_bpc_company ON TABLE bank_payment_config COLUMNS company;
DEFINE INDEX idx_abp_app ON TABLE app_bank_payment COLUMNS app;
