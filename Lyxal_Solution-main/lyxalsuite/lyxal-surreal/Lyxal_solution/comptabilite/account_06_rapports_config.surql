-- ================================================================================
-- LYXAL SURREAL - AXELOR ACCOUNT - MODULE 6 : RAPPORTS ET CONFIGURATION
-- ================================================================================
-- Entités de rapports comptables et configuration : AccountingReport, AppAccount, etc.
-- ================================================================================

-- ================================================================================
-- RAPPORTS COMPTABLES
-- ================================================================================

-- Rapports comptables
DEFINE TABLE accounting_report SCHEMAFULL;
DEFINE FIELD name ON accounting_report TYPE string;
DEFINE FIELD ref ON accounting_report TYPE string;
DEFINE FIELD report_type ON accounting_report TYPE record<accounting_report_type>;
DEFINE FIELD company ON accounting_report TYPE record<company>;
DEFINE FIELD date_from ON accounting_report TYPE date;
DEFINE FIELD date_to ON accounting_report TYPE date;
DEFINE FIELD period ON accounting_report TYPE record<period>;
DEFINE FIELD year ON accounting_report TYPE record<year>;
DEFINE FIELD export_type_select ON accounting_report TYPE int DEFAULT 0;
DEFINE FIELD journal_set ON accounting_report TYPE array<record<journal>>;
DEFINE FIELD accounting_report_config_line_list ON accounting_report TYPE array<record<accounting_report_config_line>>;
DEFINE FIELD accounting_report_analytic_config_line_list ON accounting_report TYPE array<record<accounting_report_analytic_config_line>>;
DEFINE FIELD accounting_report_move_line_list ON accounting_report TYPE array<record<accounting_report_move_line>>;
DEFINE FIELD accounting_report_value_list ON accounting_report TYPE array<record<accounting_report_value>>;
DEFINE FIELD total_debit ON accounting_report TYPE decimal;
DEFINE FIELD total_credit ON accounting_report TYPE decimal;
DEFINE FIELD balance ON accounting_report TYPE decimal;
DEFINE FIELD status_select ON accounting_report TYPE int DEFAULT 1;
DEFINE FIELD export_path ON accounting_report TYPE string;
DEFINE FIELD exported_ok ON accounting_report TYPE bool DEFAULT false;
DEFINE FIELD exported_date ON accounting_report TYPE datetime;
DEFINE FIELD created_at ON accounting_report TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_report TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_report TYPE int DEFAULT 0;

-- Types de rapports comptables
DEFINE TABLE accounting_report_type SCHEMAFULL;
DEFINE FIELD name ON accounting_report_type TYPE string;
DEFINE FIELD code ON accounting_report_type TYPE string;
DEFINE FIELD type_select ON accounting_report_type TYPE int;
DEFINE FIELD created_at ON accounting_report_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_report_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_report_type TYPE int DEFAULT 0;

-- Lignes de configuration de rapport comptable
DEFINE TABLE accounting_report_config_line SCHEMAFULL;
DEFINE FIELD accounting_report ON accounting_report_config_line TYPE record<accounting_report>;
DEFINE FIELD sequence ON accounting_report_config_line TYPE int;
DEFINE FIELD code ON accounting_report_config_line TYPE string;
DEFINE FIELD name ON accounting_report_config_line TYPE string;
DEFINE FIELD account_set ON accounting_report_config_line TYPE array<record<account>>;
DEFINE FIELD rule_type_select ON accounting_report_config_line TYPE string;
DEFINE FIELD created_at ON accounting_report_config_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_report_config_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_report_config_line TYPE int DEFAULT 0;

-- Lignes de configuration analytique de rapport comptable
DEFINE TABLE accounting_report_analytic_config_line SCHEMAFULL;
DEFINE FIELD accounting_report ON accounting_report_analytic_config_line TYPE record<accounting_report>;
DEFINE FIELD sequence ON accounting_report_analytic_config_line TYPE int;
DEFINE FIELD analytic_account_set ON accounting_report_analytic_config_line TYPE array<record<analytic_account>>;
DEFINE FIELD created_at ON accounting_report_analytic_config_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_report_analytic_config_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_report_analytic_config_line TYPE int DEFAULT 0;

-- Lignes d'écriture de rapport comptable
DEFINE TABLE accounting_report_move_line SCHEMAFULL;
DEFINE FIELD accounting_report ON accounting_report_move_line TYPE record<accounting_report>;
DEFINE FIELD move_line ON accounting_report_move_line TYPE record<move_line>;
DEFINE FIELD created_at ON accounting_report_move_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_report_move_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_report_move_line TYPE int DEFAULT 0;

-- Valeurs de rapport comptable
DEFINE TABLE accounting_report_value SCHEMAFULL;
DEFINE FIELD accounting_report ON accounting_report_value TYPE record<accounting_report>;
DEFINE FIELD sequence ON accounting_report_value TYPE int;
DEFINE FIELD code ON accounting_report_value TYPE string;
DEFINE FIELD name ON accounting_report_value TYPE string;
DEFINE FIELD result ON accounting_report_value TYPE decimal;
DEFINE FIELD created_at ON accounting_report_value TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_report_value TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_report_value TYPE int DEFAULT 0;

-- ================================================================================
-- CONFIGURATION D'APPLICATION
-- ================================================================================

-- Configuration de l'application comptable
DEFINE TABLE app_account SCHEMAFULL;
DEFINE FIELD app ON app_account TYPE record<app>;
DEFINE FIELD customer_account_sequence ON app_account TYPE record<sequence>;
DEFINE FIELD supplier_account_sequence ON app_account TYPE record<sequence>;
DEFINE FIELD employee_account_sequence ON app_account TYPE record<sequence>;
DEFINE FIELD customer_sales_journal ON app_account TYPE record<journal>;
DEFINE FIELD customer_credit_note_journal ON app_account TYPE record<journal>;
DEFINE FIELD supplier_purchase_journal ON app_account TYPE record<journal>;
DEFINE FIELD supplier_credit_note_journal ON app_account TYPE record<journal>;
DEFINE FIELD reject_journal ON app_account TYPE record<journal>;
DEFINE FIELD account_clearing_journal ON app_account TYPE record<journal>;
DEFINE FIELD automatic_reconcile_on_invoice ON app_account TYPE bool DEFAULT false;
DEFINE FIELD automatic_invoice_printing ON app_account TYPE bool DEFAULT false;
DEFINE FIELD display_delay_to_pay ON app_account TYPE bool DEFAULT false;
DEFINE FIELD display_customer_payments_on_invoice ON app_account TYPE bool DEFAULT false;
DEFINE FIELD display_due_date_on_invoice ON app_account TYPE bool DEFAULT false;
DEFINE FIELD expense_journal ON app_account TYPE record<journal>;
DEFINE FIELD manual_misc_operations_journal ON app_account TYPE record<journal>;
DEFINE FIELD sale_journal_type ON app_account TYPE record<journal_type>;
DEFINE FIELD purchase_journal_type ON app_account TYPE record<journal_type>;
DEFINE FIELD cash_journal_type ON app_account TYPE record<journal_type>;
DEFINE FIELD credit_note_journal_type ON app_account TYPE record<journal_type>;
DEFINE FIELD generate_move_for_invoice_payment ON app_account TYPE bool DEFAULT false;
DEFINE FIELD generate_move_for_advance_payment ON app_account TYPE bool DEFAULT false;
DEFINE FIELD allow_cancel_validated_invoice ON app_account TYPE bool DEFAULT false;
DEFINE FIELD allow_remove_validated_invoice ON app_account TYPE bool DEFAULT false;
DEFINE FIELD fixed_asset_category_required_on_invoice ON app_account TYPE bool DEFAULT false;
DEFINE FIELD manage_analytic_accounting ON app_account TYPE bool DEFAULT false;
DEFINE FIELD manage_budget ON app_account TYPE bool DEFAULT false;
DEFINE FIELD manage_cut_off_period ON app_account TYPE bool DEFAULT false;
DEFINE FIELD generate_debit_note ON app_account TYPE bool DEFAULT false;
DEFINE FIELD display_tracking_number_on_printing ON app_account TYPE bool DEFAULT false;
DEFINE FIELD is_mandatory_tracking_nbr ON app_account TYPE bool DEFAULT false;
DEFINE FIELD created_at ON app_account TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_account TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_account TYPE int DEFAULT 0;

-- Configuration de l'application facturation
DEFINE TABLE app_invoice SCHEMAFULL;
DEFINE FIELD app ON app_invoice TYPE record<app>;
DEFINE FIELD default_payment_condition ON app_invoice TYPE record<payment_condition>;
DEFINE FIELD default_payment_mode ON app_invoice TYPE record<payment_mode>;
DEFINE FIELD display_delay_to_pay ON app_invoice TYPE bool DEFAULT false;
DEFINE FIELD display_customer_payments_on_invoice ON app_invoice TYPE bool DEFAULT false;
DEFINE FIELD generate_supplier_invoice_control_on_receipt ON app_invoice TYPE bool DEFAULT false;
DEFINE FIELD supplier_invoice_legal_note ON app_invoice TYPE string;
DEFINE FIELD sale_invoice_legal_note ON app_invoice TYPE string;
DEFINE FIELD invoice_in_ati_mode ON app_invoice TYPE bool DEFAULT false;
DEFINE FIELD compute_method_discount_select ON app_invoice TYPE int DEFAULT 1;
DEFINE FIELD created_at ON app_invoice TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_invoice TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_invoice TYPE int DEFAULT 0;

-- ================================================================================
-- CONFIGURATION DE COMPTES
-- ================================================================================

-- Configuration de comptes
DEFINE TABLE account_config SCHEMAFULL;
DEFINE FIELD company ON account_config TYPE record<company>;
DEFINE FIELD customer_account ON account_config TYPE record<account>;
DEFINE FIELD supplier_account ON account_config TYPE record<account>;
DEFINE FIELD employee_account ON account_config TYPE record<account>;
DEFINE FIELD cash_difference_account ON account_config TYPE record<account>;
DEFINE FIELD advance_payment_account ON account_config TYPE record<account>;
DEFINE FIELD payment_difference_account ON account_config TYPE record<account>;
DEFINE FIELD doubtful_customer_account ON account_config TYPE record<account>;
DEFINE FIELD irrecoverable_account ON account_config TYPE record<account>;
DEFINE FIELD customer_sales_journal ON account_config TYPE record<journal>;
DEFINE FIELD customer_credit_note_journal ON account_config TYPE record<journal>;
DEFINE FIELD supplier_purchase_journal ON account_config TYPE record<journal>;
DEFINE FIELD supplier_credit_note_journal ON account_config TYPE record<journal>;
DEFINE FIELD reject_journal ON account_config TYPE record<journal>;
DEFINE FIELD account_clearing_journal ON account_config TYPE record<journal>;
DEFINE FIELD reimbursement_journal ON account_config TYPE record<journal>;
DEFINE FIELD irrecoverable_journal ON account_config TYPE record<journal>;
DEFINE FIELD auto_misc_ops_journal ON account_config TYPE record<journal>;
DEFINE FIELD manual_misc_ops_journal ON account_config TYPE record<journal>;
DEFINE FIELD sale_journal_type ON account_config TYPE record<journal_type>;
DEFINE FIELD purchase_journal_type ON account_config TYPE record<journal_type>;
DEFINE FIELD cash_journal_type ON account_config TYPE record<journal_type>;
DEFINE FIELD credit_note_journal_type ON account_config TYPE record<journal_type>;
DEFINE FIELD customer_account_sequence ON account_config TYPE record<sequence>;
DEFINE FIELD supplier_account_sequence ON account_config TYPE record<sequence>;
DEFINE FIELD employee_account_sequence ON account_config TYPE record<sequence>;
DEFINE FIELD year_opening_account ON account_config TYPE record<account>;
DEFINE FIELD year_closure_account ON account_config TYPE record<account>;
DEFINE FIELD has_default_templates ON account_config TYPE bool DEFAULT false;
DEFINE FIELD discount_account ON account_config TYPE record<account>;
DEFINE FIELD created_at ON account_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON account_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_config TYPE int DEFAULT 0;

-- Templates de configuration comptable
DEFINE TABLE accounting_config_template SCHEMAFULL;
DEFINE FIELD name ON accounting_config_template TYPE string;
DEFINE FIELD country ON accounting_config_template TYPE record<country>;
DEFINE FIELD created_at ON accounting_config_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_config_template TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_config_template TYPE int DEFAULT 0;

-- ================================================================================
-- IMPORT FEC
-- ================================================================================

-- Import FEC (Fichier des Écritures Comptables)
DEFINE TABLE fec_import SCHEMAFULL;
DEFINE FIELD import_file ON fec_import TYPE record<meta_file>;
DEFINE FIELD company ON fec_import TYPE record<company>;
DEFINE FIELD import_type_select ON fec_import TYPE record<import_fec_type>;
DEFINE FIELD type_select ON fec_import TYPE int DEFAULT 1;
DEFINE FIELD status_select ON fec_import TYPE int DEFAULT 1;
DEFINE FIELD import_date ON fec_import TYPE datetime;
DEFINE FIELD log_file ON fec_import TYPE record<meta_file>;
DEFINE FIELD reject_file ON fec_import TYPE record<meta_file>;
DEFINE FIELD nb_moves_imported ON fec_import TYPE int;
DEFINE FIELD nb_moves_rejected ON fec_import TYPE int;
DEFINE FIELD created_at ON fec_import TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON fec_import TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON fec_import TYPE int DEFAULT 0;

-- Types d'import FEC
DEFINE TABLE import_fec_type SCHEMAFULL;
DEFINE FIELD name ON import_fec_type TYPE string;
DEFINE FIELD created_at ON import_fec_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON import_fec_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON import_fec_type TYPE int DEFAULT 0;

-- ================================================================================
-- CONFIGURATION CFONB
-- ================================================================================

-- Configuration CFONB
DEFINE TABLE cfonb_config SCHEMAFULL;
DEFINE FIELD name ON cfonb_config TYPE string;
DEFINE FIELD company ON cfonb_config TYPE record<company>;
DEFINE FIELD sender_num ON cfonb_config TYPE string;
DEFINE FIELD sender_name_code ON cfonb_config TYPE string;
DEFINE FIELD total_record_code_export_type ON cfonb_config TYPE int DEFAULT 1;
DEFINE FIELD created_at ON cfonb_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON cfonb_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON cfonb_config TYPE int DEFAULT 0;

-- ================================================================================
-- ASSISTANT DE CLÔTURE
-- ================================================================================

-- Assistant de clôture
DEFINE TABLE closure_assistant SCHEMAFULL;
DEFINE FIELD company ON closure_assistant TYPE record<company>;
DEFINE FIELD year ON closure_assistant TYPE record<year>;
DEFINE FIELD closure_assistant_line_list ON closure_assistant TYPE array<record<closure_assistant_line>>;
DEFINE FIELD journal ON closure_assistant TYPE record<journal>;
DEFINE FIELD move_description ON closure_assistant TYPE string;
DEFINE FIELD opening_account ON closure_assistant TYPE record<account>;
DEFINE FIELD result_account ON closure_assistant TYPE record<account>;
DEFINE FIELD closure_account ON closure_assistant TYPE record<account>;
DEFINE FIELD opening_move ON closure_assistant TYPE record<move>;
DEFINE FIELD closure_move ON closure_assistant TYPE record<move>;
DEFINE FIELD created_at ON closure_assistant TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON closure_assistant TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON closure_assistant TYPE int DEFAULT 0;

-- Lignes de l'assistant de clôture
DEFINE TABLE closure_assistant_line SCHEMAFULL;
DEFINE FIELD closure_assistant ON closure_assistant_line TYPE record<closure_assistant>;
DEFINE FIELD account ON closure_assistant_line TYPE record<account>;
DEFINE FIELD move_line ON closure_assistant_line TYPE record<move_line>;
DEFINE FIELD balance ON closure_assistant_line TYPE decimal;
DEFINE FIELD opening_balance ON closure_assistant_line TYPE decimal;
DEFINE FIELD created_at ON closure_assistant_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON closure_assistant_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON closure_assistant_line TYPE int DEFAULT 0;

-- ================================================================================
-- INDEX POUR OPTIMISATION
-- ================================================================================

-- Index pour AccountingReport
DEFINE INDEX idx_accounting_report_ref ON accounting_report FIELDS ref;
DEFINE INDEX idx_accounting_report_company ON accounting_report FIELDS company;
DEFINE INDEX idx_accounting_report_type ON accounting_report FIELDS report_type;
DEFINE INDEX idx_accounting_report_status ON accounting_report FIELDS status_select;

-- Index pour AppAccount
DEFINE INDEX idx_app_account_app ON app_account FIELDS app;

-- Index pour AccountConfig
DEFINE INDEX idx_account_config_company ON account_config FIELDS company;

-- Index pour FECImport
DEFINE INDEX idx_fec_import_company ON fec_import FIELDS company;
DEFINE INDEX idx_fec_import_status ON fec_import FIELDS status_select;
DEFINE INDEX idx_fec_import_date ON fec_import FIELDS import_date;

-- ================================================================================
-- FIN DU MODULE 6 - RAPPORTS ET CONFIGURATION
-- ================================================================================ 