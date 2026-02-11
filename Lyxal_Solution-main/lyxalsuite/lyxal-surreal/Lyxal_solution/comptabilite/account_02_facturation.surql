-- ================================================================================
-- LYXAL SURREAL - AXELOR ACCOUNT - MODULE 2 : FACTURATION
-- ================================================================================
-- Entités de facturation : Invoice, InvoiceLine, InvoicePayment, etc.
-- ================================================================================

-- ================================================================================
-- FACTURES
-- ================================================================================

-- Factures principales
DEFINE TABLE invoice SCHEMAFULL;
DEFINE FIELD canceled_payment_schedule ON invoice TYPE record<payment_schedule>;
DEFINE FIELD invoice_id ON invoice TYPE string;
DEFINE FIELD operation_type_select ON invoice TYPE int;
DEFINE FIELD operation_sub_type_select ON invoice TYPE int DEFAULT 1;
DEFINE FIELD partner_tax_nbr ON invoice TYPE string;
DEFINE FIELD company ON invoice TYPE record<company>;
DEFINE FIELD partner ON invoice TYPE record<partner>;
DEFINE FIELD contact_partner ON invoice TYPE record<partner>;
DEFINE FIELD third_party_payer_partner ON invoice TYPE record<partner>;
DEFINE FIELD payment_mode ON invoice TYPE record<payment_mode>;
DEFINE FIELD payment_condition ON invoice TYPE record<payment_condition>;
DEFINE FIELD bank_details ON invoice TYPE record<bank_details>;
DEFINE FIELD partner_account ON invoice TYPE record<account>;
DEFINE FIELD address ON invoice TYPE record<address>;
DEFINE FIELD delivery_address ON invoice TYPE record<address>;
DEFINE FIELD address_str ON invoice TYPE string;
DEFINE FIELD delivery_address_str ON invoice TYPE string;
DEFINE FIELD internal_reference ON invoice TYPE string;
DEFINE FIELD external_reference ON invoice TYPE string;
DEFINE FIELD price_list ON invoice TYPE record<price_list>;
DEFINE FIELD hide_discount ON invoice TYPE bool;
DEFINE FIELD discount_type_select ON invoice TYPE int;
DEFINE FIELD discount_amount ON invoice TYPE decimal;
DEFINE FIELD price_before_global_discount ON invoice TYPE decimal;
DEFINE FIELD invoice_date ON invoice TYPE date;
DEFINE FIELD due_date ON invoice TYPE date;
DEFINE FIELD next_due_date ON invoice TYPE date;
DEFINE FIELD origin_date ON invoice TYPE date;
DEFINE FIELD payment_date ON invoice TYPE date;
DEFINE FIELD schedule_payment_ok ON invoice TYPE bool DEFAULT false;
DEFINE FIELD payment_schedule ON invoice TYPE record<payment_schedule>;
DEFINE FIELD journal ON invoice TYPE record<journal>;
DEFINE FIELD move ON invoice TYPE record<move>;
DEFINE FIELD old_move ON invoice TYPE record<move>;
DEFINE FIELD doubtful_customer_ok ON invoice TYPE bool DEFAULT false;
DEFINE FIELD currency ON invoice TYPE record<currency>;
DEFINE FIELD invoice_payment_list ON invoice TYPE array<record<invoice_payment>>;
DEFINE FIELD ventilated_date_time ON invoice TYPE datetime;
DEFINE FIELD ventilated_by_user ON invoice TYPE record<user>;
DEFINE FIELD fiscal_position ON invoice TYPE record<fiscal_position>;
DEFINE FIELD invoice_line_list ON invoice TYPE array<record<invoice_line>>;
DEFINE FIELD invoice_line_tax_list ON invoice TYPE array<record<invoice_line_tax>>;
DEFINE FIELD already_printed_ok ON invoice TYPE bool DEFAULT true;
DEFINE FIELD original_invoice ON invoice TYPE record<invoice>;
DEFINE FIELD refund_invoice_list ON invoice TYPE array<record<invoice>>;
DEFINE FIELD irrecoverable_status_select ON invoice TYPE int DEFAULT 0;
DEFINE FIELD management_object ON invoice TYPE record<management_object>;
DEFINE FIELD standard_invoice ON invoice TYPE record<invoice>;
DEFINE FIELD batch_set ON invoice TYPE array<record<batch>>;
DEFINE FIELD debit_blocking_ok ON invoice TYPE bool;
DEFINE FIELD debit_blocking_reason ON invoice TYPE record<stop_reason>;
DEFINE FIELD debit_blocking_to_date ON invoice TYPE date;
DEFINE FIELD debit_blocking_by_user ON invoice TYPE record<user>;
DEFINE FIELD comment_on_debit_blocking ON invoice TYPE string;
DEFINE FIELD debt_recovery_blocking_ok ON invoice TYPE bool;
DEFINE FIELD debt_recovery_blocking_reason ON invoice TYPE record<stop_reason>;
DEFINE FIELD debt_recovery_blocking_to_date ON invoice TYPE date;
DEFINE FIELD debt_recovery_blocking_by_user ON invoice TYPE record<user>;
DEFINE FIELD comment_on_recovery_blocking ON invoice TYPE string;
DEFINE FIELD bill_of_exchange_blocking_ok ON invoice TYPE bool;
DEFINE FIELD bill_of_exchange_blocking_reason ON invoice TYPE record<stop_reason>;
DEFINE FIELD bill_of_exchange_blocking_to_date ON invoice TYPE date;
DEFINE FIELD bill_of_exchange_blocking_by_user ON invoice TYPE record<user>;
DEFINE FIELD comment_on_exchange_blocking ON invoice TYPE string;
DEFINE FIELD debit_number ON invoice TYPE string;
DEFINE FIELD reject_move_line ON invoice TYPE record<move_line>;
DEFINE FIELD usher_passage_ok ON invoice TYPE bool;
DEFINE FIELD lcr_accounted ON invoice TYPE bool;
DEFINE FIELD amount_rejected ON invoice TYPE decimal;
DEFINE FIELD reject_date_time ON invoice TYPE datetime;
DEFINE FIELD interbank_code_line ON invoice TYPE record<interbank_code_line>;
DEFINE FIELD direct_debit_amount ON invoice TYPE decimal;
DEFINE FIELD payment_move ON invoice TYPE record<move>;
DEFINE FIELD invoices_copy_select ON invoice TYPE int DEFAULT 1;
DEFINE FIELD note ON invoice TYPE string;
DEFINE FIELD specific_notes ON invoice TYPE string;
DEFINE FIELD printed_pdf ON invoice TYPE record<meta_file>;
DEFINE FIELD group_products_on_printings ON invoice TYPE bool;
DEFINE FIELD invoice_product_statement ON invoice TYPE string;
DEFINE FIELD ex_tax_total ON invoice TYPE decimal;
DEFINE FIELD tax_total ON invoice TYPE decimal;
DEFINE FIELD in_tax_total ON invoice TYPE decimal;
DEFINE FIELD amount_paid ON invoice TYPE decimal;
DEFINE FIELD amount_remaining ON invoice TYPE decimal;
DEFINE FIELD company_ex_tax_total ON invoice TYPE decimal;
DEFINE FIELD company_tax_total ON invoice TYPE decimal;
DEFINE FIELD company_in_tax_total ON invoice TYPE decimal;
DEFINE FIELD company_in_tax_total_remaining ON invoice TYPE decimal;
DEFINE FIELD has_pending_payments ON invoice TYPE bool;
DEFINE FIELD status_select ON invoice TYPE int DEFAULT 1;
DEFINE FIELD validated_by_user ON invoice TYPE record<user>;
DEFINE FIELD validated_date_time ON invoice TYPE datetime;
DEFINE FIELD in_ati ON invoice TYPE bool;
DEFINE FIELD supplier_invoice_nb ON invoice TYPE string;
DEFINE FIELD company_bank_details ON invoice TYPE record<bank_details>;
DEFINE FIELD invoice_automatic_mail ON invoice TYPE bool DEFAULT false;
DEFINE FIELD invoice_message_template ON invoice TYPE record<template>;
DEFINE FIELD invoice_automatic_mail_on_validate ON invoice TYPE bool DEFAULT false;
DEFINE FIELD invoice_message_template_on_validate ON invoice TYPE record<template>;
DEFINE FIELD advance_payment_invoice_set ON invoice TYPE array<record<invoice>>;
DEFINE FIELD trading_name ON invoice TYPE record<trading_name>;
DEFINE FIELD printing_settings ON invoice TYPE record<printing_settings>;
DEFINE FIELD created_at ON invoice TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice TYPE int DEFAULT 0;

-- ================================================================================
-- LIGNES DE FACTURE
-- ================================================================================

-- Lignes de facture
DEFINE TABLE invoice_line SCHEMAFULL;
DEFINE FIELD invoice ON invoice_line TYPE record<invoice>;
DEFINE FIELD sequence ON invoice_line TYPE int;
DEFINE FIELD product ON invoice_line TYPE record<product>;
DEFINE FIELD product_name ON invoice_line TYPE string;
DEFINE FIELD product_code ON invoice_line TYPE string;
DEFINE FIELD description ON invoice_line TYPE string;
DEFINE FIELD qty ON invoice_line TYPE decimal;
DEFINE FIELD unit ON invoice_line TYPE record<unit>;
DEFINE FIELD price ON invoice_line TYPE decimal;
DEFINE FIELD in_tax_price ON invoice_line TYPE decimal;
DEFINE FIELD price_discounted ON invoice_line TYPE decimal;
DEFINE FIELD unit_price ON invoice_line TYPE decimal;
DEFINE FIELD tax_line_set ON invoice_line TYPE array<record<tax_line>>;
DEFINE FIELD ex_tax_total ON invoice_line TYPE decimal;
DEFINE FIELD in_tax_total ON invoice_line TYPE decimal;
DEFINE FIELD tax_total ON invoice_line TYPE decimal;
DEFINE FIELD company_ex_tax_total ON invoice_line TYPE decimal;
DEFINE FIELD company_in_tax_total ON invoice_line TYPE decimal;
DEFINE FIELD discount_type_select ON invoice_line TYPE int;
DEFINE FIELD discount_amount ON invoice_line TYPE decimal;
DEFINE FIELD account ON invoice_line TYPE record<account>;
DEFINE FIELD fixed_asset_category ON invoice_line TYPE record<fixed_asset_category>;
DEFINE FIELD project ON invoice_line TYPE record<project>;
DEFINE FIELD analytic_move_line_list ON invoice_line TYPE array<record<analytic_move_line>>;
DEFINE FIELD analytic_distribution_template ON invoice_line TYPE record<analytic_distribution_template>;
DEFINE FIELD axis1_analytic_account ON invoice_line TYPE record<analytic_account>;
DEFINE FIELD axis2_analytic_account ON invoice_line TYPE record<analytic_account>;
DEFINE FIELD axis3_analytic_account ON invoice_line TYPE record<analytic_account>;
DEFINE FIELD axis4_analytic_account ON invoice_line TYPE record<analytic_account>;
DEFINE FIELD axis5_analytic_account ON invoice_line TYPE record<analytic_account>;
DEFINE FIELD type_select ON invoice_line TYPE int DEFAULT 0;
DEFINE FIELD budget_line_list ON invoice_line TYPE array<record<budget_line>>;
DEFINE FIELD cut_off_start_date ON invoice_line TYPE date;
DEFINE FIELD cut_off_end_date ON invoice_line TYPE date;
DEFINE FIELD is_hide_unit_amounts_on_printing ON invoice_line TYPE bool DEFAULT false;
DEFINE FIELD line_amount ON invoice_line TYPE decimal;
DEFINE FIELD sub_total_excluding_tax ON invoice_line TYPE decimal;
DEFINE FIELD line_amount_excluding_tax ON invoice_line TYPE decimal;
DEFINE FIELD sub_total_including_tax ON invoice_line TYPE decimal;
DEFINE FIELD line_amount_including_tax ON invoice_line TYPE decimal;
DEFINE FIELD created_at ON invoice_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_line TYPE int DEFAULT 0;

-- ================================================================================
-- TAXES DE FACTURE
-- ================================================================================

-- Lignes de taxes de facture
DEFINE TABLE invoice_line_tax SCHEMAFULL;
DEFINE FIELD invoice ON invoice_line_tax TYPE record<invoice>;
DEFINE FIELD tax_line ON invoice_line_tax TYPE record<tax_line>;
DEFINE FIELD ex_tax_base ON invoice_line_tax TYPE decimal;
DEFINE FIELD tax_total ON invoice_line_tax TYPE decimal;
DEFINE FIELD in_tax_total ON invoice_line_tax TYPE decimal;
DEFINE FIELD company_ex_tax_base ON invoice_line_tax TYPE decimal;
DEFINE FIELD company_tax_total ON invoice_line_tax TYPE decimal;
DEFINE FIELD company_in_tax_total ON invoice_line_tax TYPE decimal;
DEFINE FIELD reverse_charge ON invoice_line_tax TYPE bool DEFAULT false;
DEFINE FIELD created_at ON invoice_line_tax TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_line_tax TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_line_tax TYPE int DEFAULT 0;

-- ================================================================================
-- PAIEMENTS DE FACTURE
-- ================================================================================

-- Paiements de facture
DEFINE TABLE invoice_payment SCHEMAFULL;
DEFINE FIELD amount ON invoice_payment TYPE decimal;
DEFINE FIELD payment_date ON invoice_payment TYPE date;
DEFINE FIELD type_select ON invoice_payment TYPE int;
DEFINE FIELD status_select ON invoice_payment TYPE int DEFAULT 1;
DEFINE FIELD currency ON invoice_payment TYPE record<currency>;
DEFINE FIELD payment_mode ON invoice_payment TYPE record<payment_mode>;
DEFINE FIELD invoice ON invoice_payment TYPE record<invoice>;
DEFINE FIELD move ON invoice_payment TYPE record<move>;
DEFINE FIELD reconcile ON invoice_payment TYPE record<reconcile>;
DEFINE FIELD company ON invoice_payment TYPE record<company>;
DEFINE FIELD description ON invoice_payment TYPE string;
DEFINE FIELD bank_details ON invoice_payment TYPE record<bank_details>;
DEFINE FIELD company_bank_details ON invoice_payment TYPE record<bank_details>;
DEFINE FIELD cheque_date ON invoice_payment TYPE date;
DEFINE FIELD cheque_number ON invoice_payment TYPE string;
DEFINE FIELD cheque_owner ON invoice_payment TYPE string;
DEFINE FIELD cheque_bank ON invoice_payment TYPE record<bank>;
DEFINE FIELD deposit_slip ON invoice_payment TYPE record<deposit_slip>;
DEFINE FIELD manual_change ON invoice_payment TYPE bool DEFAULT false;
DEFINE FIELD created_at ON invoice_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_payment TYPE int DEFAULT 0;

-- ================================================================================
-- TERMES DE FACTURE
-- ================================================================================

-- Termes de facture (échéances)
DEFINE TABLE invoice_term SCHEMAFULL;
DEFINE FIELD invoice ON invoice_term TYPE record<invoice>;
DEFINE FIELD move_line ON invoice_term TYPE record<move_line>;
DEFINE FIELD sequence ON invoice_term TYPE int;
DEFINE FIELD percentage ON invoice_term TYPE decimal;
DEFINE FIELD amount ON invoice_term TYPE decimal;
DEFINE FIELD company_amount ON invoice_term TYPE decimal;
DEFINE FIELD due_date ON invoice_term TYPE date;
DEFINE FIELD estimated_payment_date ON invoice_term TYPE date;
DEFINE FIELD origin_date ON invoice_term TYPE date;
DEFINE FIELD is_holdback ON invoice_term TYPE bool DEFAULT false;
DEFINE FIELD holdback_amount ON invoice_term TYPE decimal;
DEFINE FIELD payment_amount ON invoice_term TYPE decimal;
DEFINE FIELD amount_remaining ON invoice_term TYPE decimal;
DEFINE FIELD is_paid ON invoice_term TYPE bool DEFAULT false;
DEFINE FIELD payment_session ON invoice_term TYPE record<payment_session>;
DEFINE FIELD bank_details ON invoice_term TYPE record<bank_details>;
DEFINE FIELD payment_mode ON invoice_term TYPE record<payment_mode>;
DEFINE FIELD financial_discount_deadline_date ON invoice_term TYPE date;
DEFINE FIELD financial_discount_rate ON invoice_term TYPE decimal;
DEFINE FIELD financial_discount_total_amount ON invoice_term TYPE decimal;
DEFINE FIELD remaining_amount_after_fin_discount ON invoice_term TYPE decimal;
DEFINE FIELD financial_discount ON invoice_term TYPE record<financial_discount>;
DEFINE FIELD created_at ON invoice_term TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_term TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_term TYPE int DEFAULT 0;

-- Paiements des termes de facture
DEFINE TABLE invoice_term_payment SCHEMAFULL;
DEFINE FIELD invoice_term ON invoice_term_payment TYPE record<invoice_term>;
DEFINE FIELD invoice_payment ON invoice_term_payment TYPE record<invoice_payment>;
DEFINE FIELD paid_amount ON invoice_term_payment TYPE decimal;
DEFINE FIELD company_paid_amount ON invoice_term_payment TYPE decimal;
DEFINE FIELD created_at ON invoice_term_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_term_payment TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_term_payment TYPE int DEFAULT 0;

-- ================================================================================
-- BATCH DE FACTURE
-- ================================================================================

-- Batch de facturation
DEFINE TABLE invoice_batch SCHEMAFULL;
DEFINE FIELD action_select ON invoice_batch TYPE int;
DEFINE FIELD invoice_type_select ON invoice_batch TYPE int;
DEFINE FIELD due_date_from ON invoice_batch TYPE date;
DEFINE FIELD due_date_to ON invoice_batch TYPE date;
DEFINE FIELD bill_of_exchange_type_select ON invoice_batch TYPE int;
DEFINE FIELD include_other_bill_of_exchange ON invoice_batch TYPE bool DEFAULT false;
DEFINE FIELD partner_set ON invoice_batch TYPE array<record<partner>>;
DEFINE FIELD partner_category_set ON invoice_batch TYPE array<record<partner_category>>;
DEFINE FIELD company ON invoice_batch TYPE record<company>;
DEFINE FIELD currency ON invoice_batch TYPE record<currency>;
DEFINE FIELD payment_mode ON invoice_batch TYPE record<payment_mode>;
DEFINE FIELD created_at ON invoice_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_batch TYPE int DEFAULT 0;

-- ================================================================================
-- SITUATIONS DE PAIEMENT
-- ================================================================================

-- Situations de paiement de facturation
DEFINE TABLE invoicing_payment_situation SCHEMAFULL;
DEFINE FIELD partner ON invoicing_payment_situation TYPE record<partner>;
DEFINE FIELD company ON invoicing_payment_situation TYPE record<company>;
DEFINE FIELD payment_mode ON invoicing_payment_situation TYPE record<payment_mode>;
DEFINE FIELD bank_details ON invoicing_payment_situation TYPE record<bank_details>;
DEFINE FIELD invoice_list ON invoicing_payment_situation TYPE array<record<invoice>>;
DEFINE FIELD total_amount_invoiced ON invoicing_payment_situation TYPE decimal;
DEFINE FIELD total_amount_remaining ON invoicing_payment_situation TYPE decimal;
DEFINE FIELD created_at ON invoicing_payment_situation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoicing_payment_situation TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoicing_payment_situation TYPE int DEFAULT 0;

-- ================================================================================
-- DÉCLARATION DE PRODUITS FACTURE
-- ================================================================================

-- Déclaration de produits de facture
DEFINE TABLE invoice_product_statement SCHEMAFULL;
DEFINE FIELD invoice ON invoice_product_statement TYPE record<invoice>;
DEFINE FIELD product ON invoice_product_statement TYPE record<product>;
DEFINE FIELD product_statement ON invoice_product_statement TYPE string;
DEFINE FIELD created_at ON invoice_product_statement TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_product_statement TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_product_statement TYPE int DEFAULT 0;

-- ================================================================================
-- ASSISTANT DE RAPPORT DE FACTURE
-- ================================================================================

-- Assistant de rapport de facture
DEFINE TABLE assistant_report_invoice SCHEMAFULL;
DEFINE FIELD company ON assistant_report_invoice TYPE record<company>;
DEFINE FIELD date_from ON assistant_report_invoice TYPE date;
DEFINE FIELD date_to ON assistant_report_invoice TYPE date;
DEFINE FIELD partner_set ON assistant_report_invoice TYPE array<record<partner>>;
DEFINE FIELD payment_mode_set ON assistant_report_invoice TYPE array<record<payment_mode>>;
DEFINE FIELD status_select ON assistant_report_invoice TYPE int;
DEFINE FIELD type_select ON assistant_report_invoice TYPE int;
DEFINE FIELD created_at ON assistant_report_invoice TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON assistant_report_invoice TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON assistant_report_invoice TYPE int DEFAULT 0;

-- ================================================================================
-- INDEX POUR OPTIMISATION
-- ================================================================================

-- Index pour Invoice
DEFINE INDEX idx_invoice_id ON invoice FIELDS invoice_id;
DEFINE INDEX idx_invoice_company ON invoice FIELDS company;
DEFINE INDEX idx_invoice_partner ON invoice FIELDS partner;
DEFINE INDEX idx_invoice_date ON invoice FIELDS invoice_date;
DEFINE INDEX idx_invoice_due_date ON invoice FIELDS due_date;
DEFINE INDEX idx_invoice_status ON invoice FIELDS status_select;
DEFINE INDEX idx_invoice_operation_type ON invoice FIELDS operation_type_select;

-- Index pour InvoiceLine
DEFINE INDEX idx_invoice_line_invoice ON invoice_line FIELDS invoice;
DEFINE INDEX idx_invoice_line_product ON invoice_line FIELDS product;
DEFINE INDEX idx_invoice_line_account ON invoice_line FIELDS account;

-- Index pour InvoicePayment
DEFINE INDEX idx_invoice_payment_invoice ON invoice_payment FIELDS invoice;
DEFINE INDEX idx_invoice_payment_date ON invoice_payment FIELDS payment_date;
DEFINE INDEX idx_invoice_payment_status ON invoice_payment FIELDS status_select;

-- Index pour InvoiceTerm
DEFINE INDEX idx_invoice_term_invoice ON invoice_term FIELDS invoice;
DEFINE INDEX idx_invoice_term_move_line ON invoice_term FIELDS move_line;
DEFINE INDEX idx_invoice_term_due_date ON invoice_term FIELDS due_date;

-- ================================================================================
-- FIN DU MODULE 2 - FACTURATION
-- ================================================================================ 