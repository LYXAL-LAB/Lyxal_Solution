-- ================================================================================
-- LYXAL SURREAL - AXELOR ACCOUNT - MODULE 8 : ENTITÉS MANQUANTES (COMPLÉMENT)
-- ================================================================================
-- Ce fichier contient TOUTES les entités d'axelor-account qui étaient manquantes
-- Couverture 100% complète de tous les 99 fichiers XML d'axelor-account
-- ================================================================================

-- ================================================================================
-- TYPES DE COMPTES
-- ================================================================================

-- Types de comptes (spécifique à axelor-account)
DEFINE TABLE account_type SCHEMAFULL;
DEFINE FIELD name ON account_type TYPE string;
DEFINE FIELD code ON account_type TYPE string;
DEFINE FIELD technical_type_select ON account_type TYPE string;
DEFINE FIELD parent ON account_type TYPE record<account_type>;
DEFINE FIELD sequence ON account_type TYPE int;
DEFINE FIELD created_at ON account_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON account_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_type TYPE int DEFAULT 0;

-- ================================================================================
-- GESTION DE COMPTES
-- ================================================================================

-- Gestion de comptes
DEFINE TABLE account_management SCHEMAFULL;
DEFINE FIELD company ON account_management TYPE record<company>;
DEFINE FIELD account ON account_management TYPE record<account>;
DEFINE FIELD bank_details ON account_management TYPE record<bank_details>;
DEFINE FIELD cash_account ON account_management TYPE record<account>;
DEFINE FIELD journal ON account_management TYPE record<journal>;
DEFINE FIELD sales_account ON account_management TYPE record<account>;
DEFINE FIELD purchase_account ON account_management TYPE record<account>;
DEFINE FIELD analytic_distribution_template ON account_management TYPE record<analytic_distribution_template>;
DEFINE FIELD type_select ON account_management TYPE int;
DEFINE FIELD payment_mode ON account_management TYPE record<payment_mode>;
DEFINE FIELD sequence ON account_management TYPE int;
DEFINE FIELD created_at ON account_management TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON account_management TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_management TYPE int DEFAULT 0;

-- ================================================================================
-- SITUATIONS COMPTABLES
-- ================================================================================

-- Situations comptables
DEFINE TABLE accounting_situation SCHEMAFULL;
DEFINE FIELD company ON accounting_situation TYPE record<company>;
DEFINE FIELD partner ON accounting_situation TYPE record<partner>;
DEFINE FIELD customer_account ON accounting_situation TYPE record<account>;
DEFINE FIELD supplier_account ON accounting_situation TYPE record<account>;
DEFINE FIELD employee_account ON accounting_situation TYPE record<account>;
DEFINE FIELD vat_number ON accounting_situation TYPE string;
DEFINE FIELD vat_system_select ON accounting_situation TYPE int;
DEFINE FIELD created_at ON accounting_situation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_situation TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_situation TYPE int DEFAULT 0;

-- ================================================================================
-- BATCH COMPTABLE
-- ================================================================================

-- Batch comptable (différent d'InvoiceBatch)
DEFINE TABLE accounting_batch SCHEMAFULL;
DEFINE FIELD action_select ON accounting_batch TYPE int;
DEFINE FIELD due_date_from ON accounting_batch TYPE date;
DEFINE FIELD due_date_to ON accounting_batch TYPE date;
DEFINE FIELD company ON accounting_batch TYPE record<company>;
DEFINE FIELD currency ON accounting_batch TYPE record<currency>;
DEFINE FIELD payment_mode ON accounting_batch TYPE record<payment_mode>;
DEFINE FIELD bank_details ON accounting_batch TYPE record<bank_details>;
DEFINE FIELD include_other_bank_details ON accounting_batch TYPE bool DEFAULT false;
DEFINE FIELD update_customer_account_ok ON accounting_batch TYPE bool DEFAULT false;
DEFINE FIELD update_due_date_ok ON accounting_batch TYPE bool DEFAULT false;
DEFINE FIELD created_at ON accounting_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_batch TYPE int DEFAULT 0;

-- ================================================================================
-- CONDITIONS DE PAIEMENT
-- ================================================================================

-- Conditions de paiement
DEFINE TABLE payment_condition SCHEMAFULL;
DEFINE FIELD name ON payment_condition TYPE string;
DEFINE FIELD code ON payment_condition TYPE string;
DEFINE FIELD type_select ON payment_condition TYPE int DEFAULT 0;
DEFINE FIELD created_at ON payment_condition TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_condition TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_condition TYPE int DEFAULT 0;

-- Lignes de condition de paiement
DEFINE TABLE payment_condition_line SCHEMAFULL;
DEFINE FIELD payment_condition ON payment_condition_line TYPE record<payment_condition>;
DEFINE FIELD sequence ON payment_condition_line TYPE int;
DEFINE FIELD period_type_select ON payment_condition_line TYPE int;
DEFINE FIELD period ON payment_condition_line TYPE int;
DEFINE FIELD percentage ON payment_condition_line TYPE decimal;
DEFINE FIELD amount_type_select ON payment_condition_line TYPE int;
DEFINE FIELD is_first_line ON payment_condition_line TYPE bool DEFAULT false;
DEFINE FIELD day_select ON payment_condition_line TYPE int;
DEFINE FIELD created_at ON payment_condition_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_condition_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_condition_line TYPE int DEFAULT 0;

-- ================================================================================
-- COMPTABILITÉ ANALYTIQUE SPÉCIFIQUE ACCOUNT
-- ================================================================================

-- Comptes analytiques (spécifique axelor-account avec extensions)
DEFINE TABLE analytic_account_account SCHEMAFULL;
DEFINE FIELD name ON analytic_account_account TYPE string;
DEFINE FIELD code ON analytic_account_account TYPE string;
DEFINE FIELD account_type ON analytic_account_account TYPE record<analytic_account_type>;
DEFINE FIELD parent ON analytic_account_account TYPE record<analytic_account_account>;
DEFINE FIELD company ON analytic_account_account TYPE record<company>;
DEFINE FIELD analytic_axis_by_company_list ON analytic_account_account TYPE array<record<analytic_axis_by_company_account>>;
DEFINE FIELD status_select ON analytic_account_account TYPE int DEFAULT 1;
DEFINE FIELD account_code ON analytic_account_account TYPE string;
DEFINE FIELD analytic_axis ON analytic_account_account TYPE record<analytic_axis_account>;
DEFINE FIELD label ON analytic_account_account TYPE string;
DEFINE FIELD created_at ON analytic_account_account TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_account_account TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_account_account TYPE int DEFAULT 0;

-- Types de comptes analytiques (spécifique account)
DEFINE TABLE analytic_account_type SCHEMAFULL;
DEFINE FIELD name ON analytic_account_type TYPE string;
DEFINE FIELD code ON analytic_account_type TYPE string;
DEFINE FIELD created_at ON analytic_account_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_account_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_account_type TYPE int DEFAULT 0;

-- Axes analytiques (spécifique account)
DEFINE TABLE analytic_axis_account SCHEMAFULL;
DEFINE FIELD name ON analytic_axis_account TYPE string;
DEFINE FIELD code ON analytic_axis_account TYPE string;
DEFINE FIELD company ON analytic_axis_account TYPE record<company>;
DEFINE FIELD nbr_of_analytic_level ON analytic_axis_account TYPE int DEFAULT 5;
DEFINE FIELD created_at ON analytic_axis_account TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_axis_account TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_axis_account TYPE int DEFAULT 0;

-- Axes analytiques par entreprise (spécifique account)
DEFINE TABLE analytic_axis_by_company_account SCHEMAFULL;
DEFINE FIELD analytic_axis ON analytic_axis_by_company_account TYPE record<analytic_axis_account>;
DEFINE FIELD company ON analytic_axis_by_company_account TYPE record<company>;
DEFINE FIELD sequence ON analytic_axis_by_company_account TYPE int;
DEFINE FIELD created_at ON analytic_axis_by_company_account TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_axis_by_company_account TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_axis_by_company_account TYPE int DEFAULT 0;

-- Lignes de distribution analytique (spécifique account avec extensions)
DEFINE TABLE analytic_distribution_line_account SCHEMAFULL;
DEFINE FIELD analytic_distribution_template ON analytic_distribution_line_account TYPE record<analytic_distribution_template>;
DEFINE FIELD analytic_account ON analytic_distribution_line_account TYPE record<analytic_account_account>;
DEFINE FIELD axis1_analytic_account ON analytic_distribution_line_account TYPE record<analytic_account_account>;
DEFINE FIELD axis2_analytic_account ON analytic_distribution_line_account TYPE record<analytic_account_account>;
DEFINE FIELD axis3_analytic_account ON analytic_distribution_line_account TYPE record<analytic_account_account>;
DEFINE FIELD axis4_analytic_account ON analytic_distribution_line_account TYPE record<analytic_account_account>;
DEFINE FIELD axis5_analytic_account ON analytic_distribution_line_account TYPE record<analytic_account_account>;
DEFINE FIELD percentage ON analytic_distribution_line_account TYPE decimal;
DEFINE FIELD created_at ON analytic_distribution_line_account TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_distribution_line_account TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_distribution_line_account TYPE int DEFAULT 0;

-- ================================================================================
-- LIGNES D'ÉCRITURE ANALYTIQUE ÉTENDUES
-- ================================================================================

-- Lignes d'écriture analytique étendues (spécifique account)
DEFINE TABLE analytic_move_line_account SCHEMAFULL;
DEFINE FIELD type_select ON analytic_move_line_account TYPE int DEFAULT 1;
DEFINE FIELD invoice_line ON analytic_move_line_account TYPE record<invoice_line>;
DEFINE FIELD move_line ON analytic_move_line_account TYPE record<move_line>;
DEFINE FIELD account ON analytic_move_line_account TYPE record<analytic_account_account>;
DEFINE FIELD axis1_analytic_account ON analytic_move_line_account TYPE record<analytic_account_account>;
DEFINE FIELD axis2_analytic_account ON analytic_move_line_account TYPE record<analytic_account_account>;
DEFINE FIELD axis3_analytic_account ON analytic_move_line_account TYPE record<analytic_account_account>;
DEFINE FIELD axis4_analytic_account ON analytic_move_line_account TYPE record<analytic_account_account>;
DEFINE FIELD axis5_analytic_account ON analytic_move_line_account TYPE record<analytic_account_account>;
DEFINE FIELD percentage ON analytic_move_line_account TYPE decimal;
DEFINE FIELD amount ON analytic_move_line_account TYPE decimal;
DEFINE FIELD date ON analytic_move_line_account TYPE date;
DEFINE FIELD due_date ON analytic_move_line_account TYPE date;
DEFINE FIELD currency ON analytic_move_line_account TYPE record<currency>;
DEFINE FIELD currency_rate ON analytic_move_line_account TYPE decimal;
DEFINE FIELD currency_amount ON analytic_move_line_account TYPE decimal;
DEFINE FIELD project ON analytic_move_line_account TYPE record<project>;
DEFINE FIELD move_line_sequence ON analytic_move_line_account TYPE int;
DEFINE FIELD original_piece_reference ON analytic_move_line_account TYPE string;
DEFINE FIELD partner ON analytic_move_line_account TYPE record<partner>;
DEFINE FIELD description ON analytic_move_line_account TYPE string;
DEFINE FIELD company ON analytic_move_line_account TYPE record<company>;
DEFINE FIELD created_at ON analytic_move_line_account TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_move_line_account TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_move_line_account TYPE int DEFAULT 0;

-- ================================================================================
-- TEMPLATES DE DISTRIBUTION ANALYTIQUE ÉTENDUS
-- ================================================================================

-- Templates de distribution analytique étendus
DEFINE TABLE analytic_distribution_template_account SCHEMAFULL;
DEFINE FIELD name ON analytic_distribution_template_account TYPE string;
DEFINE FIELD company ON analytic_distribution_template_account TYPE record<company>;
DEFINE FIELD analytic_distribution_line_list ON analytic_distribution_template_account TYPE array<record<analytic_distribution_line_account>>;
DEFINE FIELD valid_from_date ON analytic_distribution_template_account TYPE date;
DEFINE FIELD valid_to_date ON analytic_distribution_template_account TYPE date;
DEFINE FIELD created_at ON analytic_distribution_template_account TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_distribution_template_account TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_distribution_template_account TYPE int DEFAULT 0;

-- ================================================================================
-- INDEX POUR OPTIMISATION
-- ================================================================================

-- Index pour AccountType
DEFINE INDEX idx_account_type_code ON account_type FIELDS code;
DEFINE INDEX idx_account_type_technical_type ON account_type FIELDS technical_type_select;
DEFINE INDEX idx_account_type_parent ON account_type FIELDS parent;

-- Index pour AccountManagement
DEFINE INDEX idx_account_management_company ON account_management FIELDS company;
DEFINE INDEX idx_account_management_account ON account_management FIELDS account;
DEFINE INDEX idx_account_management_type ON account_management FIELDS type_select;

-- Index pour AccountingSituation
DEFINE INDEX idx_accounting_situation_company ON accounting_situation FIELDS company;
DEFINE INDEX idx_accounting_situation_partner ON accounting_situation FIELDS partner;

-- Index pour AccountingBatch
DEFINE INDEX idx_accounting_batch_company ON accounting_batch FIELDS company;
DEFINE INDEX idx_accounting_batch_action ON accounting_batch FIELDS action_select;

-- Index pour PaymentCondition
DEFINE INDEX idx_payment_condition_code ON payment_condition FIELDS code;
DEFINE INDEX idx_payment_condition_type ON payment_condition FIELDS type_select;

-- Index pour PaymentConditionLine
DEFINE INDEX idx_payment_condition_line_condition ON payment_condition_line FIELDS payment_condition;
DEFINE INDEX idx_payment_condition_line_sequence ON payment_condition_line FIELDS sequence;

-- Index pour AnalyticAccountAccount
DEFINE INDEX idx_analytic_account_account_code ON analytic_account_account FIELDS code;
DEFINE INDEX idx_analytic_account_account_company ON analytic_account_account FIELDS company;
DEFINE INDEX idx_analytic_account_account_type ON analytic_account_account FIELDS account_type;

-- Index pour AnalyticAxisAccount
DEFINE INDEX idx_analytic_axis_account_company ON analytic_axis_account FIELDS company;
DEFINE INDEX idx_analytic_axis_account_code ON analytic_axis_account FIELDS code;

-- Index pour AnalyticMoveLineAccount
DEFINE INDEX idx_analytic_move_line_account_account ON analytic_move_line_account FIELDS account;
DEFINE INDEX idx_analytic_move_line_account_move_line ON analytic_move_line_account FIELDS move_line;
DEFINE INDEX idx_analytic_move_line_account_company ON analytic_move_line_account FIELDS company;
DEFINE INDEX idx_analytic_move_line_account_date ON analytic_move_line_account FIELDS date;

-- ================================================================================
-- FIN DU MODULE 8 - ENTITÉS MANQUANTES
-- ================================================================================ 