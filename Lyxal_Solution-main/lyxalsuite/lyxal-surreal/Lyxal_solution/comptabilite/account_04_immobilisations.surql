-- ================================================================================
-- LYXAL SURREAL - AXELOR ACCOUNT - MODULE 4 : IMMOBILISATIONS
-- ================================================================================
-- Entités d'immobilisations : FixedAsset, FixedAssetCategory, AssetDisposalReason, etc.
-- ================================================================================

-- ================================================================================
-- IMMOBILISATIONS
-- ================================================================================

-- Immobilisations
DEFINE TABLE fixed_asset SCHEMAFULL;
DEFINE FIELD name ON fixed_asset TYPE string;
DEFINE FIELD code ON fixed_asset TYPE string;
DEFINE FIELD company ON fixed_asset TYPE record<company>;
DEFINE FIELD fixed_asset_category ON fixed_asset TYPE record<fixed_asset_category>;
DEFINE FIELD reference ON fixed_asset TYPE string;
DEFINE FIELD acquisition_date ON fixed_asset TYPE date;
DEFINE FIELD first_depreciation_date ON fixed_asset TYPE date;
DEFINE FIELD gross_value ON fixed_asset TYPE decimal;
DEFINE FIELD residual_value ON fixed_asset TYPE decimal;
DEFINE FIELD disposal_value ON fixed_asset TYPE decimal;
DEFINE FIELD partner ON fixed_asset TYPE record<partner>;
DEFINE FIELD supplier_invoice_line ON fixed_asset TYPE record<invoice_line>;
DEFINE FIELD journal ON fixed_asset TYPE record<journal>;
DEFINE FIELD fixed_asset_line_list ON fixed_asset TYPE array<record<fixed_asset_line>>;
DEFINE FIELD fixed_asset_derogatoryLine_list ON fixed_asset TYPE array<record<fixed_asset_derogatory_line>>;
DEFINE FIELD disposal_date ON fixed_asset TYPE date;
DEFINE FIELD disposal_type_select ON fixed_asset TYPE int;
DEFINE FIELD asset_disposal_reason ON fixed_asset TYPE record<asset_disposal_reason>;
DEFINE FIELD disposal_move ON fixed_asset TYPE record<move>;
DEFINE FIELD sale_account_move ON fixed_asset TYPE record<move>;
DEFINE FIELD depreciation_plan_select ON fixed_asset TYPE int;
DEFINE FIELD computation_method_select ON fixed_asset TYPE string;
DEFINE FIELD degressive_coef ON fixed_asset TYPE decimal;
DEFINE FIELD number_of_depreciation ON fixed_asset TYPE int;
DEFINE FIELD duration_in_month ON fixed_asset TYPE int;
DEFINE FIELD periodicityTypeSelect ON fixed_asset TYPE int;
DEFINE FIELD periodicity_in_month ON fixed_asset TYPE int;
DEFINE FIELD is_ifrs_eq_fiscal_depreciation ON fixed_asset TYPE bool DEFAULT false;
DEFINE FIELD ifrs_computation_method_select ON fixed_asset TYPE string;
DEFINE FIELD ifrs_degressive_coef ON fixed_asset TYPE decimal;
DEFINE FIELD ifrs_number_of_depreciation ON fixed_asset TYPE int;
DEFINE FIELD ifrs_duration_in_month ON fixed_asset TYPE int;
DEFINE FIELD ifrs_periodicityTypeSelect ON fixed_asset TYPE int;
DEFINE FIELD ifrs_periodicity_in_month ON fixed_asset TYPE int;
DEFINE FIELD ifrs_first_depreciation_date ON fixed_asset TYPE date;
DEFINE FIELD fiscal_computation_method_select ON fixed_asset TYPE string;
DEFINE FIELD fiscal_degressive_coef ON fixed_asset TYPE decimal;
DEFINE FIELD fiscal_number_of_depreciation ON fixed_asset TYPE int;
DEFINE FIELD fiscal_duration_in_month ON fixed_asset TYPE int;
DEFINE FIELD fiscal_periodicityTypeSelect ON fixed_asset TYPE int;
DEFINE FIELD fiscal_periodicity_in_month ON fixed_asset TYPE int;
DEFINE FIELD fiscal_first_depreciation_date ON fixed_asset TYPE date;
DEFINE FIELD status_select ON fixed_asset TYPE int DEFAULT 1;
DEFINE FIELD correction_account_move ON fixed_asset TYPE record<move>;
DEFINE FIELD purchase_account ON fixed_asset TYPE record<account>;
DEFINE FIELD purchase_account_move ON fixed_asset TYPE record<move>;
DEFINE FIELD tracking_number ON fixed_asset TYPE string;
DEFINE FIELD economic_nb_of_depreciation ON fixed_asset TYPE int;
DEFINE FIELD economic_duration_in_month ON fixed_asset TYPE int;
DEFINE FIELD economic_computation_method_select ON fixed_asset TYPE string;
DEFINE FIELD economic_degressive_coef ON fixed_asset TYPE decimal;
DEFINE FIELD economic_periodicityTypeSelect ON fixed_asset TYPE int;
DEFINE FIELD economic_periodicity_in_month ON fixed_asset TYPE int;
DEFINE FIELD economic_first_depreciation_date ON fixed_asset TYPE date;
DEFINE FIELD comments ON fixed_asset TYPE string;
DEFINE FIELD origin_select ON fixed_asset TYPE int DEFAULT 1;
DEFINE FIELD qty ON fixed_asset TYPE decimal DEFAULT 1;
DEFINE FIELD unit_amount ON fixed_asset TYPE decimal;
DEFINE FIELD analytic_distribution_template ON fixed_asset TYPE record<analytic_distribution_template>;
DEFINE FIELD created_at ON fixed_asset TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON fixed_asset TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON fixed_asset TYPE int DEFAULT 0;

-- ================================================================================
-- CATÉGORIES D'IMMOBILISATIONS
-- ================================================================================

-- Catégories d'immobilisations
DEFINE TABLE fixed_asset_category SCHEMAFULL;
DEFINE FIELD name ON fixed_asset_category TYPE string;
DEFINE FIELD code ON fixed_asset_category TYPE string;
DEFINE FIELD company ON fixed_asset_category TYPE record<company>;
DEFINE FIELD fixed_asset_type ON fixed_asset_category TYPE record<fixed_asset_type>;
DEFINE FIELD purchase_account ON fixed_asset_category TYPE record<account>;
DEFINE FIELD depreciation_account ON fixed_asset_category TYPE record<account>;
DEFINE FIELD charges_account ON fixed_asset_category TYPE record<account>;
DEFINE FIELD depreciation_journal ON fixed_asset_category TYPE record<journal>;
DEFINE FIELD realized_value_account ON fixed_asset_category TYPE record<account>;
DEFINE FIELD charges_account_on_cession ON fixed_asset_category TYPE record<account>;
DEFINE FIELD revenues_account_on_cession ON fixed_asset_category TYPE record<account>;
DEFINE FIELD analytical_account_select ON fixed_asset_category TYPE int;
DEFINE FIELD computation_method_select ON fixed_asset_category TYPE string;
DEFINE FIELD degressive_coef ON fixed_asset_category TYPE decimal;
DEFINE FIELD number_of_depreciation ON fixed_asset_category TYPE int;
DEFINE FIELD duration_in_month ON fixed_asset_category TYPE int;
DEFINE FIELD periodicity_type_select ON fixed_asset_category TYPE int;
DEFINE FIELD periodicity_in_month ON fixed_asset_category TYPE int;
DEFINE FIELD is_ifrs_eq_fiscal_depreciation ON fixed_asset_category TYPE bool DEFAULT false;
DEFINE FIELD ifrs_depreciation_account ON fixed_asset_category TYPE record<account>;
DEFINE FIELD ifrs_charges_account ON fixed_asset_category TYPE record<account>;
DEFINE FIELD ifrs_computation_method_select ON fixed_asset_category TYPE string;
DEFINE FIELD ifrs_degressive_coef ON fixed_asset_category TYPE decimal;
DEFINE FIELD ifrs_number_of_depreciation ON fixed_asset_category TYPE int;
DEFINE FIELD ifrs_duration_in_month ON fixed_asset_category TYPE int;
DEFINE FIELD ifrs_periodicity_type_select ON fixed_asset_category TYPE int;
DEFINE FIELD ifrs_periodicity_in_month ON fixed_asset_category TYPE int;
DEFINE FIELD fiscal_depreciation_account ON fixed_asset_category TYPE record<account>;
DEFINE FIELD fiscal_charges_account ON fixed_asset_category TYPE record<account>;
DEFINE FIELD fiscal_computation_method_select ON fixed_asset_category TYPE string;
DEFINE FIELD fiscal_degressive_coef ON fixed_asset_category TYPE decimal;
DEFINE FIELD fiscal_number_of_depreciation ON fixed_asset_category TYPE int;
DEFINE FIELD fiscal_duration_in_month ON fixed_asset_category TYPE int;
DEFINE FIELD fiscal_periodicity_type_select ON fixed_asset_category TYPE int;
DEFINE FIELD fiscal_periodicity_in_month ON fixed_asset_category TYPE int;
DEFINE FIELD is_validationRequired ON fixed_asset_category TYPE bool DEFAULT false;
DEFINE FIELD economic_depreciation_account ON fixed_asset_category TYPE record<account>;
DEFINE FIELD economic_charges_account ON fixed_asset_category TYPE record<account>;
DEFINE FIELD economic_computation_method_select ON fixed_asset_category TYPE string;
DEFINE FIELD economic_degressive_coef ON fixed_asset_category TYPE decimal;
DEFINE FIELD economic_number_of_depreciation ON fixed_asset_category TYPE int;
DEFINE FIELD economic_duration_in_month ON fixed_asset_category TYPE int;
DEFINE FIELD economic_periodicity_type_select ON fixed_asset_category TYPE int;
DEFINE FIELD economic_periodicity_in_month ON fixed_asset_category TYPE int;
DEFINE FIELD analytic_distribution_template ON fixed_asset_category TYPE record<analytic_distribution_template>;
DEFINE FIELD created_at ON fixed_asset_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON fixed_asset_category TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON fixed_asset_category TYPE int DEFAULT 0;

-- ================================================================================
-- TYPES D'IMMOBILISATIONS
-- ================================================================================

-- Types d'immobilisations
DEFINE TABLE fixed_asset_type SCHEMAFULL;
DEFINE FIELD name ON fixed_asset_type TYPE string;
DEFINE FIELD technical_type_select ON fixed_asset_type TYPE string;
DEFINE FIELD created_at ON fixed_asset_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON fixed_asset_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON fixed_asset_type TYPE int DEFAULT 0;

-- ================================================================================
-- LIGNES D'IMMOBILISATIONS
-- ================================================================================

-- Lignes d'immobilisations (plan d'amortissement)
DEFINE TABLE fixed_asset_line SCHEMAFULL;
DEFINE FIELD fixed_asset ON fixed_asset_line TYPE record<fixed_asset>;
DEFINE FIELD status_select ON fixed_asset_line TYPE int DEFAULT 0;
DEFINE FIELD depreciation_date ON fixed_asset_line TYPE date;
DEFINE FIELD depreciation_base ON fixed_asset_line TYPE decimal;
DEFINE FIELD depreciation ON fixed_asset_line TYPE decimal;
DEFINE FIELD cumulative_depreciation ON fixed_asset_line TYPE decimal;
DEFINE FIELD accounting_value ON fixed_asset_line TYPE decimal;
DEFINE FIELD move ON fixed_asset_line TYPE record<move>;
DEFINE FIELD type_select ON fixed_asset_line TYPE int;
DEFINE FIELD year ON fixed_asset_line TYPE record<year>;
DEFINE FIELD fiscal_depreciation_base ON fixed_asset_line TYPE decimal;
DEFINE FIELD fiscal_depreciation ON fixed_asset_line TYPE decimal;
DEFINE FIELD fiscal_cumulative_depreciation ON fixed_asset_line TYPE decimal;
DEFINE FIELD fiscal_accounting_value ON fixed_asset_line TYPE decimal;
DEFINE FIELD fiscal_move ON fixed_asset_line TYPE record<move>;
DEFINE FIELD ifrs_depreciation_base ON fixed_asset_line TYPE decimal;
DEFINE FIELD ifrs_depreciation ON fixed_asset_line TYPE decimal;
DEFINE FIELD ifrs_cumulative_depreciation ON fixed_asset_line TYPE decimal;
DEFINE FIELD ifrs_accounting_value ON fixed_asset_line TYPE decimal;
DEFINE FIELD ifrs_move ON fixed_asset_line TYPE record<move>;
DEFINE FIELD economic_depreciation_base ON fixed_asset_line TYPE decimal;
DEFINE FIELD economic_depreciation ON fixed_asset_line TYPE decimal;
DEFINE FIELD economic_cumulative_depreciation ON fixed_asset_line TYPE decimal;
DEFINE FIELD economic_accounting_value ON fixed_asset_line TYPE decimal;
DEFINE FIELD economic_move ON fixed_asset_line TYPE record<move>;
DEFINE FIELD created_at ON fixed_asset_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON fixed_asset_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON fixed_asset_line TYPE int DEFAULT 0;

-- ================================================================================
-- LIGNES DÉROGATOIRES D'IMMOBILISATIONS
-- ================================================================================

-- Lignes dérogatoires d'immobilisations
DEFINE TABLE fixed_asset_derogatory_line SCHEMAFULL;
DEFINE FIELD fixed_asset ON fixed_asset_derogatory_line TYPE record<fixed_asset>;
DEFINE FIELD status_select ON fixed_asset_derogatory_line TYPE int DEFAULT 0;
DEFINE FIELD depreciation_date ON fixed_asset_derogatory_line TYPE date;
DEFINE FIELD derogatory_amount ON fixed_asset_derogatory_line TYPE decimal;
DEFINE FIELD income_derogatory_amount ON fixed_asset_derogatory_line TYPE decimal;
DEFINE FIELD is_income ON fixed_asset_derogatory_line TYPE bool DEFAULT false;
DEFINE FIELD move ON fixed_asset_derogatory_line TYPE record<move>;
DEFINE FIELD year ON fixed_asset_derogatory_line TYPE record<year>;
DEFINE FIELD created_at ON fixed_asset_derogatory_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON fixed_asset_derogatory_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON fixed_asset_derogatory_line TYPE int DEFAULT 0;

-- ================================================================================
-- RAISONS DE CESSION D'ACTIFS
-- ================================================================================

-- Raisons de cession d'actifs
DEFINE TABLE asset_disposal_reason SCHEMAFULL;
DEFINE FIELD name ON asset_disposal_reason TYPE string;
DEFINE FIELD code ON asset_disposal_reason TYPE string;
DEFINE FIELD type_select ON asset_disposal_reason TYPE int;
DEFINE FIELD created_at ON asset_disposal_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON asset_disposal_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON asset_disposal_reason TYPE int DEFAULT 0;

-- ================================================================================
-- INDEX POUR OPTIMISATION
-- ================================================================================

-- Index pour FixedAsset
DEFINE INDEX idx_fixed_asset_code ON fixed_asset FIELDS code;
DEFINE INDEX idx_fixed_asset_company ON fixed_asset FIELDS company;
DEFINE INDEX idx_fixed_asset_category ON fixed_asset FIELDS fixed_asset_category;
DEFINE INDEX idx_fixed_asset_acquisition_date ON fixed_asset FIELDS acquisition_date;
DEFINE INDEX idx_fixed_asset_status ON fixed_asset FIELDS status_select;

-- Index pour FixedAssetCategory
DEFINE INDEX idx_fixed_asset_category_code ON fixed_asset_category FIELDS code;
DEFINE INDEX idx_fixed_asset_category_company ON fixed_asset_category FIELDS company;
DEFINE INDEX idx_fixed_asset_category_type ON fixed_asset_category FIELDS fixed_asset_type;

-- Index pour FixedAssetLine
DEFINE INDEX idx_fixed_asset_line_asset ON fixed_asset_line FIELDS fixed_asset;
DEFINE INDEX idx_fixed_asset_line_date ON fixed_asset_line FIELDS depreciation_date;
DEFINE INDEX idx_fixed_asset_line_status ON fixed_asset_line FIELDS status_select;

-- Index pour FixedAssetDerogatoryLine
DEFINE INDEX idx_fixed_asset_derog_asset ON fixed_asset_derogatory_line FIELDS fixed_asset;
DEFINE INDEX idx_fixed_asset_derog_date ON fixed_asset_derogatory_line FIELDS depreciation_date;
DEFINE INDEX idx_fixed_asset_derog_status ON fixed_asset_derogatory_line FIELDS status_select;

-- ================================================================================
-- FIN DU MODULE 4 - IMMOBILISATIONS
-- ================================================================================ 