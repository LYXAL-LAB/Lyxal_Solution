-- ================================================================================
-- LYXAL SURREAL - AXELOR ACCOUNT - MODULE 5 : COMPTABILITÉ ANALYTIQUE
-- ================================================================================
-- Entités de comptabilité analytique : AnalyticAccount, AnalyticMoveLine, etc.
-- ================================================================================

-- ================================================================================
-- COMPTES ANALYTIQUES
-- ================================================================================

-- Comptes analytiques
DEFINE TABLE analytic_account SCHEMAFULL;
DEFINE FIELD name ON analytic_account TYPE string;
DEFINE FIELD code ON analytic_account TYPE string;
DEFINE FIELD account_type ON analytic_account TYPE record<analytic_account_type>;
DEFINE FIELD parent ON analytic_account TYPE record<analytic_account>;
DEFINE FIELD company ON analytic_account TYPE record<company>;
DEFINE FIELD analyticAxisByCompanyList ON analytic_account TYPE array<record<analytic_axis_by_company>>;
DEFINE FIELD status_select ON analytic_account TYPE int DEFAULT 1;
DEFINE FIELD account_code ON analytic_account TYPE string;
DEFINE FIELD analyticAxis ON analytic_account TYPE record<analytic_axis>;
DEFINE FIELD label ON analytic_account TYPE string;
DEFINE FIELD created_at ON analytic_account TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_account TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_account TYPE int DEFAULT 0;

-- Types de comptes analytiques
DEFINE TABLE analytic_account_type SCHEMAFULL;
DEFINE FIELD name ON analytic_account_type TYPE string;
DEFINE FIELD code ON analytic_account_type TYPE string;
DEFINE FIELD created_at ON analytic_account_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_account_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_account_type TYPE int DEFAULT 0;

-- ================================================================================
-- AXES ANALYTIQUES
-- ================================================================================

-- Axes analytiques
DEFINE TABLE analytic_axis SCHEMAFULL;
DEFINE FIELD name ON analytic_axis TYPE string;
DEFINE FIELD code ON analytic_axis TYPE string;
DEFINE FIELD company ON analytic_axis TYPE record<company>;
DEFINE FIELD created_at ON analytic_axis TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_axis TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_axis TYPE int DEFAULT 0;

-- Axes analytiques par entreprise
DEFINE TABLE analytic_axis_by_company SCHEMAFULL;
DEFINE FIELD analytic_axis ON analytic_axis_by_company TYPE record<analytic_axis>;
DEFINE FIELD company ON analytic_axis_by_company TYPE record<company>;
DEFINE FIELD sequence ON analytic_axis_by_company TYPE int;
DEFINE FIELD created_at ON analytic_axis_by_company TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_axis_by_company TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_axis_by_company TYPE int DEFAULT 0;

-- ================================================================================
-- LIGNES D'ÉCRITURE ANALYTIQUE
-- ================================================================================

-- Lignes d'écriture analytique
DEFINE TABLE analytic_move_line SCHEMAFULL;
DEFINE FIELD type_select ON analytic_move_line TYPE int DEFAULT 1;
DEFINE FIELD invoice_line ON analytic_move_line TYPE record<invoice_line>;
DEFINE FIELD move_line ON analytic_move_line TYPE record<move_line>;
DEFINE FIELD account ON analytic_move_line TYPE record<analytic_account>;
DEFINE FIELD axis1_analytic_account ON analytic_move_line TYPE record<analytic_account>;
DEFINE FIELD axis2_analytic_account ON analytic_move_line TYPE record<analytic_account>;
DEFINE FIELD axis3_analytic_account ON analytic_move_line TYPE record<analytic_account>;
DEFINE FIELD axis4_analytic_account ON analytic_move_line TYPE record<analytic_account>;
DEFINE FIELD axis5_analytic_account ON analytic_move_line TYPE record<analytic_account>;
DEFINE FIELD percentage ON analytic_move_line TYPE decimal;
DEFINE FIELD amount ON analytic_move_line TYPE decimal;
DEFINE FIELD date ON analytic_move_line TYPE date;
DEFINE FIELD due_date ON analytic_move_line TYPE date;
DEFINE FIELD currency ON analytic_move_line TYPE record<currency>;
DEFINE FIELD currency_rate ON analytic_move_line TYPE decimal;
DEFINE FIELD currency_amount ON analytic_move_line TYPE decimal;
DEFINE FIELD project ON analytic_move_line TYPE record<project>;
DEFINE FIELD move_line_sequence ON analytic_move_line TYPE int;
DEFINE FIELD original_piece_reference ON analytic_move_line TYPE string;
DEFINE FIELD partner ON analytic_move_line TYPE record<partner>;
DEFINE FIELD description ON analytic_move_line TYPE string;
DEFINE FIELD company ON analytic_move_line TYPE record<company>;
DEFINE FIELD created_at ON analytic_move_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_move_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_move_line TYPE int DEFAULT 0;

-- ================================================================================
-- REQUÊTES DE LIGNES D'ÉCRITURE ANALYTIQUE
-- ================================================================================

-- Requêtes de lignes d'écriture analytique
DEFINE TABLE analytic_move_line_query SCHEMAFULL;
DEFINE FIELD company ON analytic_move_line_query TYPE record<company>;
DEFINE FIELD date_from ON analytic_move_line_query TYPE date;
DEFINE FIELD date_to ON analytic_move_line_query TYPE date;
DEFINE FIELD type_select ON analytic_move_line_query TYPE int;
DEFINE FIELD analytic_account_set ON analytic_move_line_query TYPE array<record<analytic_account>>;
DEFINE FIELD project_set ON analytic_move_line_query TYPE array<record<project>>;
DEFINE FIELD partner_set ON analytic_move_line_query TYPE array<record<partner>>;
DEFINE FIELD analytic_move_line_query_parameter_list ON analytic_move_line_query TYPE array<record<analytic_move_line_query_parameter>>;
DEFINE FIELD created_at ON analytic_move_line_query TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_move_line_query TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_move_line_query TYPE int DEFAULT 0;

-- Paramètres de requêtes de lignes d'écriture analytique
DEFINE TABLE analytic_move_line_query_parameter SCHEMAFULL;
DEFINE FIELD analytic_move_line_query ON analytic_move_line_query_parameter TYPE record<analytic_move_line_query>;
DEFINE FIELD axis_select ON analytic_move_line_query_parameter TYPE int;
DEFINE FIELD analytic_account_set ON analytic_move_line_query_parameter TYPE array<record<analytic_account>>;
DEFINE FIELD created_at ON analytic_move_line_query_parameter TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_move_line_query_parameter TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_move_line_query_parameter TYPE int DEFAULT 0;

-- ================================================================================
-- TEMPLATES DE DISTRIBUTION ANALYTIQUE
-- ================================================================================

-- Templates de distribution analytique
DEFINE TABLE analytic_distribution_template SCHEMAFULL;
DEFINE FIELD name ON analytic_distribution_template TYPE string;
DEFINE FIELD company ON analytic_distribution_template TYPE record<company>;
DEFINE FIELD analytic_distribution_line_list ON analytic_distribution_template TYPE array<record<analytic_distribution_line>>;
DEFINE FIELD created_at ON analytic_distribution_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_distribution_template TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_distribution_template TYPE int DEFAULT 0;

-- Lignes de distribution analytique
DEFINE TABLE analytic_distribution_line SCHEMAFULL;
DEFINE FIELD analytic_distribution_template ON analytic_distribution_line TYPE record<analytic_distribution_template>;
DEFINE FIELD analytic_account ON analytic_distribution_line TYPE record<analytic_account>;
DEFINE FIELD axis1_analytic_account ON analytic_distribution_line TYPE record<analytic_account>;
DEFINE FIELD axis2_analytic_account ON analytic_distribution_line TYPE record<analytic_account>;
DEFINE FIELD axis3_analytic_account ON analytic_distribution_line TYPE record<analytic_account>;
DEFINE FIELD axis4_analytic_account ON analytic_distribution_line TYPE record<analytic_account>;
DEFINE FIELD axis5_analytic_account ON analytic_distribution_line TYPE record<analytic_account>;
DEFINE FIELD percentage ON analytic_distribution_line TYPE decimal;
DEFINE FIELD created_at ON analytic_distribution_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_distribution_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_distribution_line TYPE int DEFAULT 0;

-- ================================================================================
-- RÈGLES ANALYTIQUES
-- ================================================================================

-- Règles analytiques
DEFINE TABLE analytic_rules SCHEMAFULL;
DEFINE FIELD name ON analytic_rules TYPE string;
DEFINE FIELD company ON analytic_rules TYPE record<company>;
DEFINE FIELD account_set ON analytic_rules TYPE array<record<account>>;
DEFINE FIELD product_set ON analytic_rules TYPE array<record<product>>;
DEFINE FIELD product_category_set ON analytic_rules TYPE array<record<product_category>>;
DEFINE FIELD product_family_set ON analytic_rules TYPE array<record<product_family>>;
DEFINE FIELD partner_set ON analytic_rules TYPE array<record<partner>>;
DEFINE FIELD partner_category_set ON analytic_rules TYPE array<record<partner_category>>;
DEFINE FIELD analytic_distribution_template ON analytic_rules TYPE record<analytic_distribution_template>;
DEFINE FIELD is_rule_for_invoice_line ON analytic_rules TYPE bool DEFAULT false;
DEFINE FIELD is_rule_for_move_line ON analytic_rules TYPE bool DEFAULT false;
DEFINE FIELD axis1_analytic_account ON analytic_rules TYPE record<analytic_account>;
DEFINE FIELD axis2_analytic_account ON analytic_rules TYPE record<analytic_account>;
DEFINE FIELD axis3_analytic_account ON analytic_rules TYPE record<analytic_account>;
DEFINE FIELD axis4_analytic_account ON analytic_rules TYPE record<analytic_account>;
DEFINE FIELD axis5_analytic_account ON analytic_rules TYPE record<analytic_account>;
DEFINE FIELD created_at ON analytic_rules TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_rules TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_rules TYPE int DEFAULT 0;

-- ================================================================================
-- INDEX POUR OPTIMISATION
-- ================================================================================

-- Index pour AnalyticAccount
DEFINE INDEX idx_analytic_account_code ON analytic_account FIELDS code;
DEFINE INDEX idx_analytic_account_company ON analytic_account FIELDS company;
DEFINE INDEX idx_analytic_account_type ON analytic_account FIELDS account_type;
DEFINE INDEX idx_analytic_account_parent ON analytic_account FIELDS parent;
DEFINE INDEX idx_analytic_account_status ON analytic_account FIELDS status_select;

-- Index pour AnalyticMoveLine
DEFINE INDEX idx_analytic_move_line_account ON analytic_move_line FIELDS account;
DEFINE INDEX idx_analytic_move_line_move_line ON analytic_move_line FIELDS move_line;
DEFINE INDEX idx_analytic_move_line_invoice_line ON analytic_move_line FIELDS invoice_line;
DEFINE INDEX idx_analytic_move_line_date ON analytic_move_line FIELDS date;
DEFINE INDEX idx_analytic_move_line_company ON analytic_move_line FIELDS company;
DEFINE INDEX idx_analytic_move_line_partner ON analytic_move_line FIELDS partner;

-- Index pour AnalyticDistributionTemplate
DEFINE INDEX idx_analytic_distribution_template_company ON analytic_distribution_template FIELDS company;
DEFINE INDEX idx_analytic_distribution_template_name ON analytic_distribution_template FIELDS name;

-- Index pour AnalyticRules
DEFINE INDEX idx_analytic_rules_company ON analytic_rules FIELDS company;
DEFINE INDEX idx_analytic_rules_name ON analytic_rules FIELDS name;

-- ================================================================================
-- FIN DU MODULE 5 - COMPTABILITÉ ANALYTIQUE
-- ================================================================================ 