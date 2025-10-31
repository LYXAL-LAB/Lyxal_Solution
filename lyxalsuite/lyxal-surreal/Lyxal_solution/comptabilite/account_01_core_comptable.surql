-- ================================================================================
-- LYXAL SURREAL - AXELOR ACCOUNT - MODULE 1 : CORE COMPTABLE
-- ================================================================================
-- Entités comptables fondamentales : Account, Move, MoveLine, Journal, etc.
-- ================================================================================

-- ================================================================================
-- COMPTES COMPTABLES
-- ================================================================================

-- Comptes comptables principaux
DEFINE TABLE account SCHEMAFULL;
DEFINE FIELD name ON account TYPE string;
DEFINE FIELD code ON account TYPE string;
DEFINE FIELD parent_account ON account TYPE record<account>;
DEFINE FIELD account_type ON account TYPE record<account_type>;
DEFINE FIELD reconcile_ok ON account TYPE bool;
DEFINE FIELD company ON account TYPE record<company>;
DEFINE FIELD compatible_account_set ON account TYPE array<record<account>>;
DEFINE FIELD use_for_partner_balance ON account TYPE bool;
DEFINE FIELD common_position ON account TYPE int;
DEFINE FIELD default_tax_set ON account TYPE array<record<tax>>;
DEFINE FIELD label ON account TYPE string;
DEFINE FIELD analytic_distribution_required_on_invoice_lines ON account TYPE bool;
DEFINE FIELD analytic_distribution_required_on_move_lines ON account TYPE bool;
DEFINE FIELD analytic_distribution_authorized ON account TYPE bool;
DEFINE FIELD is_tax_authorized_on_move_line ON account TYPE bool;
DEFINE FIELD is_tax_required_on_move_line ON account TYPE bool;
DEFINE FIELD manage_cut_off_period ON account TYPE bool;
DEFINE FIELD has_automatic_application_accounting_date ON account TYPE bool;
DEFINE FIELD batch_set ON account TYPE array<record<batch>>;
DEFINE FIELD service_type ON account TYPE record<service_type>;
DEFINE FIELD analytic_distribution_template ON account TYPE record<analytic_distribution_template>;
DEFINE FIELD status_select ON account TYPE int DEFAULT 0;
DEFINE FIELD is_regulatory_account ON account TYPE bool;
DEFINE FIELD is_retrieved_on_payment_session ON account TYPE bool;
DEFINE FIELD vat_system_select ON account TYPE int DEFAULT 0;
DEFINE FIELD tag_set ON account TYPE array<record<tag>>;
DEFINE FIELD created_at ON account TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON account TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account TYPE int DEFAULT 0;

-- Types de comptes
DEFINE TABLE account_type SCHEMAFULL;
DEFINE FIELD name ON account_type TYPE string;
DEFINE FIELD code ON account_type TYPE string;
DEFINE FIELD technical_type_select ON account_type TYPE string;
DEFINE FIELD sequence ON account_type TYPE int;
DEFINE FIELD created_at ON account_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON account_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_type TYPE int DEFAULT 0;

-- Équivalence de comptes
DEFINE TABLE account_equiv SCHEMAFULL;
DEFINE FIELD from_account ON account_equiv TYPE record<account>;
DEFINE FIELD to_account ON account_equiv TYPE record<account>;
DEFINE FIELD company ON account_equiv TYPE record<company>;
DEFINE FIELD created_at ON account_equiv TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON account_equiv TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_equiv TYPE int DEFAULT 0;

-- Clearance de comptes
DEFINE TABLE account_clearance SCHEMAFULL;
DEFINE FIELD name ON account_clearance TYPE string;
DEFINE FIELD company ON account_clearance TYPE record<company>;
DEFINE FIELD account_set ON account_clearance TYPE array<record<account>>;
DEFINE FIELD move_line_set ON account_clearance TYPE array<record<move_line>>;
DEFINE FIELD created_at ON account_clearance TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON account_clearance TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_clearance TYPE int DEFAULT 0;

-- ================================================================================
-- JOURNAUX COMPTABLES
-- ================================================================================

-- Journaux comptables
DEFINE TABLE journal SCHEMAFULL;
DEFINE FIELD name ON journal TYPE string;
DEFINE FIELD code ON journal TYPE string;
DEFINE FIELD journal_type ON journal TYPE record<journal_type>;
DEFINE FIELD company ON journal TYPE record<company>;
DEFINE FIELD sequence ON journal TYPE record<sequence>;
DEFINE FIELD description ON journal TYPE string;
DEFINE FIELD active ON journal TYPE bool DEFAULT true;
DEFINE FIELD notify_on_import ON journal TYPE bool DEFAULT false;
DEFINE FIELD auto_account_ok ON journal TYPE bool DEFAULT false;
DEFINE FIELD allow_accounting_daybook ON journal TYPE bool DEFAULT false;
DEFINE FIELD created_at ON journal TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON journal TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON journal TYPE int DEFAULT 0;

-- Types de journaux
DEFINE TABLE journal_type SCHEMAFULL;
DEFINE FIELD name ON journal_type TYPE string;
DEFINE FIELD code ON journal_type TYPE string;
DEFINE FIELD technical_type_select ON journal_type TYPE string;
DEFINE FIELD sequence ON journal_type TYPE int;
DEFINE FIELD created_at ON journal_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON journal_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON journal_type TYPE int DEFAULT 0;

-- ================================================================================
-- ÉCRITURES COMPTABLES
-- ================================================================================

-- Écritures comptables (Move)
DEFINE TABLE move SCHEMAFULL;
DEFINE FIELD journal ON move TYPE record<journal>;
DEFINE FIELD period ON move TYPE record<period>;
DEFINE FIELD date ON move TYPE date;
DEFINE FIELD reference ON move TYPE string;
DEFINE FIELD move_line_list ON move TYPE array<record<move_line>>;
DEFINE FIELD move_line_mass_entry_list ON move TYPE array<record<move_line_mass_entry>>;
DEFINE FIELD partner ON move TYPE record<partner>;
DEFINE FIELD third_party_payer_partner ON move TYPE record<partner>;
DEFINE FIELD company ON move TYPE record<company>;
DEFINE FIELD payment_mode ON move TYPE record<payment_mode>;
DEFINE FIELD payment_condition ON move TYPE record<payment_condition>;
DEFINE FIELD partner_bank_details ON move TYPE record<bank_details>;
DEFINE FIELD invoice ON move TYPE record<invoice>;
DEFINE FIELD status_select ON move TYPE int DEFAULT 1;
DEFINE FIELD reject_ok ON move TYPE bool DEFAULT false;
DEFINE FIELD export_number ON move TYPE string;
DEFINE FIELD export_date ON move TYPE date;
DEFINE FIELD due_date ON move TYPE date;
DEFINE FIELD accounting_ok ON move TYPE bool DEFAULT false;
DEFINE FIELD accounting_report ON move TYPE record<accounting_report>;
DEFINE FIELD fiscal_position ON move TYPE record<fiscal_position>;
DEFINE FIELD payment_voucher ON move TYPE record<payment_voucher>;
DEFINE FIELD payment_session ON move TYPE record<payment_session>;
DEFINE FIELD company_currency ON move TYPE record<currency>;
DEFINE FIELD company_currency_code ON move TYPE string;
DEFINE FIELD company_bank_details ON move TYPE record<bank_details>;
DEFINE FIELD currency ON move TYPE record<currency>;
DEFINE FIELD currency_code ON move TYPE string;
DEFINE FIELD ignore_in_accounting_ok ON move TYPE bool DEFAULT false;
DEFINE FIELD ignore_in_debt_recovery_ok ON move TYPE bool DEFAULT false;
DEFINE FIELD accounting_date ON move TYPE date;
DEFINE FIELD technical_origin_select ON move TYPE int;
DEFINE FIELD adjusting_move ON move TYPE bool DEFAULT false;
DEFINE FIELD auto_year_closure_move ON move TYPE bool;
DEFINE FIELD cut_off_move_generated ON move TYPE bool;
DEFINE FIELD batch_set ON move TYPE array<record<batch>>;
DEFINE FIELD functional_origin_select ON move TYPE int;
DEFINE FIELD trading_name ON move TYPE record<trading_name>;
DEFINE FIELD origin_date ON move TYPE date;
DEFINE FIELD origin ON move TYPE string;
DEFINE FIELD description ON move TYPE string;
DEFINE FIELD cut_off_origin_move ON move TYPE record<move>;
DEFINE FIELD pfp_validator_user ON move TYPE record<user>;
DEFINE FIELD pfp_validate_status_select ON move TYPE int DEFAULT 0;
DEFINE FIELD reason_of_refusal_to_pay ON move TYPE record<cancel_reason>;
DEFINE FIELD reason_of_refusal_to_pay_str ON move TYPE string;
DEFINE FIELD fec_import ON move TYPE record<fec_import>;
DEFINE FIELD mass_entry_status_select ON move TYPE int DEFAULT 0;
DEFINE FIELD mass_entry_errors ON move TYPE string;
DEFINE FIELD mass_entry_manage_cut_off ON move TYPE bool;
DEFINE FIELD created_at ON move TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move TYPE int DEFAULT 0;

-- Lignes d'écriture comptables (MoveLine)
DEFINE TABLE move_line SCHEMAFULL;
DEFINE FIELD move ON move_line TYPE record<move>;
DEFINE FIELD partner ON move_line TYPE record<partner>;
DEFINE FIELD account ON move_line TYPE record<account>;
DEFINE FIELD date ON move_line TYPE date;
DEFINE FIELD due_date ON move_line TYPE date;
DEFINE FIELD cut_off_start_date ON move_line TYPE date;
DEFINE FIELD cut_off_end_date ON move_line TYPE date;
DEFINE FIELD is_cut_off_generated ON move_line TYPE bool DEFAULT false;
DEFINE FIELD counter ON move_line TYPE int;
DEFINE FIELD debit ON move_line TYPE decimal;
DEFINE FIELD credit ON move_line TYPE decimal;
DEFINE FIELD description ON move_line TYPE string;
DEFINE FIELD origin ON move_line TYPE string;
DEFINE FIELD external_origin ON move_line TYPE string;
DEFINE FIELD debit_reconcile_list ON move_line TYPE array<record<reconcile>>;
DEFINE FIELD credit_reconcile_list ON move_line TYPE array<record<reconcile>>;
DEFINE FIELD amount_paid ON move_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD invoice_reject ON move_line TYPE record<invoice>;
DEFINE FIELD exported_direct_debit_ok ON move_line TYPE bool DEFAULT false;
DEFINE FIELD interbank_code_line ON move_line TYPE record<interbank_code_line>;
DEFINE FIELD reimbursement_status_select ON move_line TYPE int DEFAULT 0;
DEFINE FIELD passage_reason ON move_line TYPE string;
DEFINE FIELD usher_passage_ok ON move_line TYPE bool;
DEFINE FIELD tax_line_set ON move_line TYPE array<record<tax_line>>;
DEFINE FIELD tax_line_before_reverse_set ON move_line TYPE array<record<tax_line>>;
DEFINE FIELD source_tax_line_set ON move_line TYPE array<record<tax_line>>;
DEFINE FIELD tax_equiv ON move_line TYPE record<tax_equiv>;
DEFINE FIELD currency_rate ON move_line TYPE decimal;
DEFINE FIELD currency_amount ON move_line TYPE decimal;
DEFINE FIELD posted_nbr ON move_line TYPE string;
DEFINE FIELD fixed_asset_category ON move_line TYPE record<fixed_asset_category>;
DEFINE FIELD max_amount_to_reconcile ON move_line TYPE decimal;
DEFINE FIELD payment_schedule_line ON move_line TYPE record<payment_schedule_line>;
DEFINE FIELD amount_exported_in_direct_debit ON move_line TYPE decimal;
DEFINE FIELD account_clearance ON move_line TYPE record<account_clearance>;
DEFINE FIELD irrecoverable_status_select ON move_line TYPE int DEFAULT 0;
DEFINE FIELD management_object ON move_line TYPE record<management_object>;
DEFINE FIELD analytic_move_line_list ON move_line TYPE array<record<analytic_move_line>>;
DEFINE FIELD analytic_distribution_template ON move_line TYPE record<analytic_distribution_template>;
DEFINE FIELD is_other_currency ON move_line TYPE bool DEFAULT false;
DEFINE FIELD account_code ON move_line TYPE string;
DEFINE FIELD account_name ON move_line TYPE string;
DEFINE FIELD partner_full_name ON move_line TYPE string;
DEFINE FIELD partner_seq ON move_line TYPE string;
DEFINE FIELD partner_id ON move_line TYPE string;
DEFINE FIELD account_id ON move_line TYPE string;
DEFINE FIELD tax_rate ON move_line TYPE decimal;
DEFINE FIELD tax_code ON move_line TYPE string;
DEFINE FIELD is_selected_bank_reconciliation ON move_line TYPE bool DEFAULT false;
DEFINE FIELD tax_amount ON move_line TYPE decimal;
DEFINE FIELD tax_payment_move_line_list ON move_line TYPE array<record<tax_payment_move_line>>;
DEFINE FIELD reconcile_group ON move_line TYPE record<reconcile_group>;
DEFINE FIELD origin_date ON move_line TYPE date;
DEFINE FIELD invoice_term_list ON move_line TYPE array<record<invoice_term>>;
DEFINE FIELD name ON move_line TYPE string;
DEFINE FIELD amount_remaining ON move_line TYPE decimal;
DEFINE FIELD line_amount ON move_line TYPE decimal;
DEFINE FIELD axis1_analytic_account ON move_line TYPE record<analytic_account>;
DEFINE FIELD axis2_analytic_account ON move_line TYPE record<analytic_account>;
DEFINE FIELD axis3_analytic_account ON move_line TYPE record<analytic_account>;
DEFINE FIELD axis4_analytic_account ON move_line TYPE record<analytic_account>;
DEFINE FIELD axis5_analytic_account ON move_line TYPE record<analytic_account>;
DEFINE FIELD vat_system_select ON move_line TYPE int DEFAULT 0;
DEFINE FIELD financial_discount ON move_line TYPE record<financial_discount>;
DEFINE FIELD financial_discount_rate ON move_line TYPE decimal;
DEFINE FIELD financial_discount_total_amount ON move_line TYPE decimal;
DEFINE FIELD remaining_amount_after_fin_discount ON move_line TYPE decimal;
DEFINE FIELD company_code ON move_line TYPE string;
DEFINE FIELD company_name ON move_line TYPE string;
DEFINE FIELD journal_code ON move_line TYPE string;
DEFINE FIELD journal_name ON move_line TYPE string;
DEFINE FIELD currency_code ON move_line TYPE string;
DEFINE FIELD currency_decimals ON move_line TYPE int;
DEFINE FIELD company_currency_code ON move_line TYPE string;
DEFINE FIELD company_currency_decimals ON move_line TYPE int;
DEFINE FIELD fiscal_year_code ON move_line TYPE string;
DEFINE FIELD accounting_date ON move_line TYPE date;
DEFINE FIELD adjusting_move ON move_line TYPE bool;
DEFINE FIELD is_non_deductible_tax ON move_line TYPE bool;
DEFINE FIELD batch_set ON move_line TYPE array<record<batch>>;
DEFINE FIELD cut_off_prorata_amount ON move_line TYPE decimal;
DEFINE FIELD created_at ON move_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move_line TYPE int DEFAULT 0;

-- ================================================================================
-- SAISIE DE MASSE
-- ================================================================================

-- Saisie de masse des lignes d'écritures
DEFINE TABLE move_line_mass_entry SCHEMAFULL;
DEFINE FIELD move_mass_entry ON move_line_mass_entry TYPE record<move>;
DEFINE FIELD partner ON move_line_mass_entry TYPE record<partner>;
DEFINE FIELD account ON move_line_mass_entry TYPE record<account>;
DEFINE FIELD date ON move_line_mass_entry TYPE date;
DEFINE FIELD due_date ON move_line_mass_entry TYPE date;
DEFINE FIELD counter ON move_line_mass_entry TYPE int;
DEFINE FIELD debit ON move_line_mass_entry TYPE decimal;
DEFINE FIELD credit ON move_line_mass_entry TYPE decimal;
DEFINE FIELD description ON move_line_mass_entry TYPE string;
DEFINE FIELD origin ON move_line_mass_entry TYPE string;
DEFINE FIELD currency_rate ON move_line_mass_entry TYPE decimal;
DEFINE FIELD currency_amount ON move_line_mass_entry TYPE decimal;
DEFINE FIELD analytic_distribution_template ON move_line_mass_entry TYPE record<analytic_distribution_template>;
DEFINE FIELD tax_line_set ON move_line_mass_entry TYPE array<record<tax_line>>;
DEFINE FIELD tax_rate ON move_line_mass_entry TYPE decimal;
DEFINE FIELD tax_amount ON move_line_mass_entry TYPE decimal;
DEFINE FIELD axis1_analytic_account ON move_line_mass_entry TYPE record<analytic_account>;
DEFINE FIELD axis2_analytic_account ON move_line_mass_entry TYPE record<analytic_account>;
DEFINE FIELD axis3_analytic_account ON move_line_mass_entry TYPE record<analytic_account>;
DEFINE FIELD axis4_analytic_account ON move_line_mass_entry TYPE record<analytic_account>;
DEFINE FIELD axis5_analytic_account ON move_line_mass_entry TYPE record<analytic_account>;
DEFINE FIELD origin_date ON move_line_mass_entry TYPE date;
DEFINE FIELD cut_off_start_date ON move_line_mass_entry TYPE date;
DEFINE FIELD cut_off_end_date ON move_line_mass_entry TYPE date;
DEFINE FIELD created_at ON move_line_mass_entry TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move_line_mass_entry TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move_line_mass_entry TYPE int DEFAULT 0;

-- ================================================================================
-- RÉCONCILIATION
-- ================================================================================

-- Réconciliations
DEFINE TABLE reconcile SCHEMAFULL;
DEFINE FIELD code ON reconcile TYPE string;
DEFINE FIELD debit_move_line ON reconcile TYPE record<move_line>;
DEFINE FIELD credit_move_line ON reconcile TYPE record<move_line>;
DEFINE FIELD amount ON reconcile TYPE decimal;
DEFINE FIELD reconcile_date ON reconcile TYPE date;
DEFINE FIELD status_select ON reconcile TYPE int DEFAULT 1;
DEFINE FIELD must_be_zero_balance_ok ON reconcile TYPE bool DEFAULT false;
DEFINE FIELD reconcile_group ON reconcile TYPE record<reconcile_group>;
DEFINE FIELD company ON reconcile TYPE record<company>;
DEFINE FIELD created_at ON reconcile TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON reconcile TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON reconcile TYPE int DEFAULT 0;

-- Groupes de réconciliation
DEFINE TABLE reconcile_group SCHEMAFULL;
DEFINE FIELD code ON reconcile_group TYPE string;
DEFINE FIELD company ON reconcile_group TYPE record<company>;
DEFINE FIELD status_select ON reconcile_group TYPE int DEFAULT 1;
DEFINE FIELD reconcile_list ON reconcile_group TYPE array<record<reconcile>>;
DEFINE FIELD letter ON reconcile_group TYPE string;
DEFINE FIELD is_temporary ON reconcile_group TYPE bool DEFAULT false;
DEFINE FIELD created_at ON reconcile_group TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON reconcile_group TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON reconcile_group TYPE int DEFAULT 0;

-- ================================================================================
-- TEMPLATES D'ÉCRITURE
-- ================================================================================

-- Templates d'écritures
DEFINE TABLE move_template SCHEMAFULL;
DEFINE FIELD name ON move_template TYPE string;
DEFINE FIELD code ON move_template TYPE string;
DEFINE FIELD move_template_type ON move_template TYPE record<move_template_type>;
DEFINE FIELD company ON move_template TYPE record<company>;
DEFINE FIELD journal ON move_template TYPE record<journal>;
DEFINE FIELD move_template_line_list ON move_template TYPE array<record<move_template_line>>;
DEFINE FIELD full_name ON move_template TYPE string;
DEFINE FIELD endOfValidityDate ON move_template TYPE date;
DEFINE FIELD is_valid ON move_template TYPE bool DEFAULT true;
DEFINE FIELD created_at ON move_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move_template TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move_template TYPE int DEFAULT 0;

-- Lignes de templates d'écritures
DEFINE TABLE move_template_line SCHEMAFULL;
DEFINE FIELD move_template ON move_template_line TYPE record<move_template>;
DEFINE FIELD sequence ON move_template_line TYPE int;
DEFINE FIELD account ON move_template_line TYPE record<account>;
DEFINE FIELD account_type ON move_template_line TYPE record<account_type>;
DEFINE FIELD partner ON move_template_line TYPE record<partner>;
DEFINE FIELD debit ON move_template_line TYPE decimal;
DEFINE FIELD credit ON move_template_line TYPE decimal;
DEFINE FIELD debit_credit_select ON move_template_line TYPE int;
DEFINE FIELD percentage ON move_template_line TYPE decimal;
DEFINE FIELD amount_type_select ON move_template_line TYPE int;
DEFINE FIELD name ON move_template_line TYPE string;
DEFINE FIELD description ON move_template_line TYPE string;
DEFINE FIELD tax_line_set ON move_template_line TYPE array<record<tax_line>>;
DEFINE FIELD analytic_distribution_template ON move_template_line TYPE record<analytic_distribution_template>;
DEFINE FIELD axis1_analytic_account ON move_template_line TYPE record<analytic_account>;
DEFINE FIELD axis2_analytic_account ON move_template_line TYPE record<analytic_account>;
DEFINE FIELD axis3_analytic_account ON move_template_line TYPE record<analytic_account>;
DEFINE FIELD axis4_analytic_account ON move_template_line TYPE record<analytic_account>;
DEFINE FIELD axis5_analytic_account ON move_template_line TYPE record<analytic_account>;
DEFINE FIELD created_at ON move_template_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move_template_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move_template_line TYPE int DEFAULT 0;

-- Types de templates d'écritures
DEFINE TABLE move_template_type SCHEMAFULL;
DEFINE FIELD name ON move_template_type TYPE string;
DEFINE FIELD code ON move_template_type TYPE string;
DEFINE FIELD type_select ON move_template_type TYPE int;
DEFINE FIELD created_at ON move_template_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move_template_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move_template_type TYPE int DEFAULT 0;

-- ================================================================================
-- INDEX POUR OPTIMISATION
-- ================================================================================

-- Index pour Account
DEFINE INDEX idx_account_code ON account FIELDS code;
DEFINE INDEX idx_account_company ON account FIELDS company;
DEFINE INDEX idx_account_type ON account FIELDS account_type;
DEFINE INDEX idx_account_status ON account FIELDS status_select;

-- Index pour Journal
DEFINE INDEX idx_journal_code ON journal FIELDS code;
DEFINE INDEX idx_journal_company ON journal FIELDS company;
DEFINE INDEX idx_journal_type ON journal FIELDS journal_type;

-- Index pour Move
DEFINE INDEX idx_move_reference ON move FIELDS reference;
DEFINE INDEX idx_move_company ON move FIELDS company;
DEFINE INDEX idx_move_journal ON move FIELDS journal;
DEFINE INDEX idx_move_period ON move FIELDS period;
DEFINE INDEX idx_move_date ON move FIELDS date;
DEFINE INDEX idx_move_status ON move FIELDS status_select;

-- Index pour MoveLine
DEFINE INDEX idx_move_line_move ON move_line FIELDS move;
DEFINE INDEX idx_move_line_account ON move_line FIELDS account;
DEFINE INDEX idx_move_line_partner ON move_line FIELDS partner;
DEFINE INDEX idx_move_line_date ON move_line FIELDS date;
DEFINE INDEX idx_move_line_due_date ON move_line FIELDS due_date;

-- Index pour Reconcile
DEFINE INDEX idx_reconcile_debit_move_line ON reconcile FIELDS debit_move_line;
DEFINE INDEX idx_reconcile_credit_move_line ON reconcile FIELDS credit_move_line;
DEFINE INDEX idx_reconcile_code ON reconcile FIELDS code;
DEFINE INDEX idx_reconcile_date ON reconcile FIELDS reconcile_date;

-- ================================================================================
-- FIN DU MODULE 1 - CORE COMPTABLE
-- ================================================================================