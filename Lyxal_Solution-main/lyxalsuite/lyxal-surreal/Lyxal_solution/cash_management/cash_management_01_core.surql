-- ================================================================================
-- LYXAL SURREAL - AXELOR CASH MANAGEMENT - MODULE 1 : CORE FORECAST
-- ================================================================================
-- Migration complète d'axelor-cash-management vers SurrealDB
-- Entités : Forecast, ForecastGenerator, ForecastRecap, ForecastRecapLine, ForecastRecapLineType
-- ================================================================================

-- Prévisions de trésorerie (Forecast.xml - 1532 bytes)
DEFINE TABLE forecast SCHEMAFULL;
DEFINE FIELD name ON forecast TYPE string;
DEFINE FIELD forecast_sequence ON forecast TYPE string;
DEFINE FIELD company ON forecast TYPE record<company>;
DEFINE FIELD bank_details ON forecast TYPE record<bank_details>;
DEFINE FIELD from_date ON forecast TYPE date;
DEFINE FIELD to_date ON forecast TYPE date;
DEFINE FIELD period_type_select ON forecast TYPE int DEFAULT 1;
DEFINE FIELD status_select ON forecast TYPE int DEFAULT 1;
DEFINE FIELD current_balance ON forecast TYPE decimal;
DEFINE FIELD final_balance ON forecast TYPE decimal;
DEFINE FIELD forecast_recap_list ON forecast TYPE array<record<forecast_recap>>;
DEFINE FIELD forecast_recap_line_list ON forecast TYPE array<record<forecast_recap_line>>;
DEFINE FIELD comments ON forecast TYPE string;
DEFINE FIELD bank_account ON forecast TYPE record<account>;
DEFINE FIELD currency ON forecast TYPE record<currency>;
DEFINE FIELD is_global_forecast ON forecast TYPE bool DEFAULT false;
DEFINE FIELD forecast_generator_list ON forecast TYPE array<record<forecast_generator>>;
DEFINE FIELD user ON forecast TYPE record<user>;
DEFINE FIELD team ON forecast TYPE record<team>;
DEFINE FIELD created_at ON forecast TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON forecast TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON forecast TYPE int DEFAULT 0;

-- Générateurs de prévision (ForecastGenerator.xml - 1469 bytes)
DEFINE TABLE forecast_generator SCHEMAFULL;
DEFINE FIELD name ON forecast_generator TYPE string;
DEFINE FIELD company ON forecast_generator TYPE record<company>;
DEFINE FIELD forecast ON forecast_generator TYPE record<forecast>;
DEFINE FIELD element_select ON forecast_generator TYPE int;
DEFINE FIELD from_date ON forecast_generator TYPE date;
DEFINE FIELD to_date ON forecast_generator TYPE date;
DEFINE FIELD amount ON forecast_generator TYPE decimal;
DEFINE FIELD percentage ON forecast_generator TYPE decimal;
DEFINE FIELD sequence ON forecast_generator TYPE int;
DEFINE FIELD is_active ON forecast_generator TYPE bool DEFAULT true;
DEFINE FIELD forecast_recap_line_type ON forecast_generator TYPE record<forecast_recap_line_type>;
DEFINE FIELD partner_set ON forecast_generator TYPE array<record<partner>>;
DEFINE FIELD partner_type_select ON forecast_generator TYPE int;
DEFINE FIELD payment_mode ON forecast_generator TYPE record<payment_mode>;
DEFINE FIELD payment_condition ON forecast_generator TYPE record<payment_condition>;
DEFINE FIELD journal ON forecast_generator TYPE record<journal>;
DEFINE FIELD account ON forecast_generator TYPE record<account>;
DEFINE FIELD analytic_account ON forecast_generator TYPE record<analytic_account>;
DEFINE FIELD opportunity_set ON forecast_generator TYPE array<record<opportunity>>;
DEFINE FIELD type_select ON forecast_generator TYPE int DEFAULT 1;
DEFINE FIELD description ON forecast_generator TYPE string;
DEFINE FIELD created_at ON forecast_generator TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON forecast_generator TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON forecast_generator TYPE int DEFAULT 0;

-- Récapitulatif de prévision (ForecastRecap.xml - 2194 bytes)
DEFINE TABLE forecast_recap SCHEMAFULL;
DEFINE FIELD forecast ON forecast_recap TYPE record<forecast>;
DEFINE FIELD estimate_date ON forecast_recap TYPE date;
DEFINE FIELD amount ON forecast_recap TYPE decimal;
DEFINE FIELD currency ON forecast_recap TYPE record<currency>;
DEFINE FIELD balance ON forecast_recap TYPE decimal;
DEFINE FIELD cumulative_balance ON forecast_recap TYPE decimal;
DEFINE FIELD forecast_recap_line_list ON forecast_recap TYPE array<record<forecast_recap_line>>;
DEFINE FIELD comments ON forecast_recap TYPE string;
DEFINE FIELD period_number ON forecast_recap TYPE int;
DEFINE FIELD period_type_select ON forecast_recap TYPE int DEFAULT 1;
DEFINE FIELD is_consolidated ON forecast_recap TYPE bool DEFAULT false;
DEFINE FIELD bank_details ON forecast_recap TYPE record<bank_details>;
DEFINE FIELD starting_balance ON forecast_recap TYPE decimal;
DEFINE FIELD ending_balance ON forecast_recap TYPE decimal;
DEFINE FIELD total_inflow ON forecast_recap TYPE decimal;
DEFINE FIELD total_outflow ON forecast_recap TYPE decimal;
DEFINE FIELD net_cash_flow ON forecast_recap TYPE decimal;
DEFINE FIELD variance_amount ON forecast_recap TYPE decimal;
DEFINE FIELD variance_percentage ON forecast_recap TYPE decimal;
DEFINE FIELD is_realized ON forecast_recap TYPE bool DEFAULT false;
DEFINE FIELD realized_amount ON forecast_recap TYPE decimal;
DEFINE FIELD created_at ON forecast_recap TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON forecast_recap TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON forecast_recap TYPE int DEFAULT 0;

-- Lignes de récapitulatif de prévision (ForecastRecapLine.xml - 1347 bytes)
DEFINE TABLE forecast_recap_line SCHEMAFULL;
DEFINE FIELD forecast_recap ON forecast_recap_line TYPE record<forecast_recap>;
DEFINE FIELD forecast ON forecast_recap_line TYPE record<forecast>;
DEFINE FIELD forecast_recap_line_type ON forecast_recap_line TYPE record<forecast_recap_line_type>;
DEFINE FIELD element_select ON forecast_recap_line TYPE int;
DEFINE FIELD estimate_date ON forecast_recap_line TYPE date;
DEFINE FIELD amount ON forecast_recap_line TYPE decimal;
DEFINE FIELD currency ON forecast_recap_line TYPE record<currency>;
DEFINE FIELD comments ON forecast_recap_line TYPE string;
DEFINE FIELD sequence ON forecast_recap_line TYPE int;
DEFINE FIELD partner ON forecast_recap_line TYPE record<partner>;
DEFINE FIELD payment_mode ON forecast_recap_line TYPE record<payment_mode>;
DEFINE FIELD payment_condition ON forecast_recap_line TYPE record<payment_condition>;
DEFINE FIELD journal ON forecast_recap_line TYPE record<journal>;
DEFINE FIELD account ON forecast_recap_line TYPE record<account>;
DEFINE FIELD analytic_account ON forecast_recap_line TYPE record<analytic_account>;
DEFINE FIELD opportunity ON forecast_recap_line TYPE record<opportunity>;
DEFINE FIELD invoice ON forecast_recap_line TYPE record<invoice>;
DEFINE FIELD sale_order ON forecast_recap_line TYPE record<sale_order>;
DEFINE FIELD purchase_order ON forecast_recap_line TYPE record<purchase_order>;
DEFINE FIELD is_realized ON forecast_recap_line TYPE bool DEFAULT false;
DEFINE FIELD realized_amount ON forecast_recap_line TYPE decimal;
DEFINE FIELD realized_date ON forecast_recap_line TYPE date;
DEFINE FIELD variance_amount ON forecast_recap_line TYPE decimal;
DEFINE FIELD created_at ON forecast_recap_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON forecast_recap_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON forecast_recap_line TYPE int DEFAULT 0;

-- Types de lignes de récapitulatif (ForecastRecapLineType.xml - 2433 bytes)
DEFINE TABLE forecast_recap_line_type SCHEMAFULL;
DEFINE FIELD name ON forecast_recap_line_type TYPE string;
DEFINE FIELD code ON forecast_recap_line_type TYPE string;
DEFINE FIELD element_select ON forecast_recap_line_type TYPE int;
DEFINE FIELD type_select ON forecast_recap_line_type TYPE int DEFAULT 1;
DEFINE FIELD sign_select ON forecast_recap_line_type TYPE int DEFAULT 1;
DEFINE FIELD sequence ON forecast_recap_line_type TYPE int;
DEFINE FIELD is_active ON forecast_recap_line_type TYPE bool DEFAULT true;
DEFINE FIELD company ON forecast_recap_line_type TYPE record<company>;
DEFINE FIELD description ON forecast_recap_line_type TYPE string;
DEFINE FIELD color_select ON forecast_recap_line_type TYPE int;
DEFINE FIELD icon_select ON forecast_recap_line_type TYPE int;
DEFINE FIELD is_used_in_dashboard ON forecast_recap_line_type TYPE bool DEFAULT false;
DEFINE FIELD dashboard_position ON forecast_recap_line_type TYPE int;
DEFINE FIELD account_set ON forecast_recap_line_type TYPE array<record<account>>;
DEFINE FIELD partner_type_set ON forecast_recap_line_type TYPE array<record<partner_type>>;
DEFINE FIELD payment_mode_set ON forecast_recap_line_type TYPE array<record<payment_mode>>;
DEFINE FIELD payment_condition_set ON forecast_recap_line_type TYPE array<record<payment_condition>>;
DEFINE FIELD journal_set ON forecast_recap_line_type TYPE array<record<journal>>;
DEFINE FIELD analytic_account_set ON forecast_recap_line_type TYPE array<record<analytic_account>>;
DEFINE FIELD product_category_set ON forecast_recap_line_type TYPE array<record<product_category>>;
DEFINE FIELD product_set ON forecast_recap_line_type TYPE array<record<product>>;
DEFINE FIELD is_invoice_term ON forecast_recap_line_type TYPE bool DEFAULT false;
DEFINE FIELD is_salary ON forecast_recap_line_type TYPE bool DEFAULT false;
DEFINE FIELD is_loan ON forecast_recap_line_type TYPE bool DEFAULT false;
DEFINE FIELD is_operational_expense ON forecast_recap_line_type TYPE bool DEFAULT false;
DEFINE FIELD is_investment ON forecast_recap_line_type TYPE bool DEFAULT false;
DEFINE FIELD created_at ON forecast_recap_line_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON forecast_recap_line_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON forecast_recap_line_type TYPE int DEFAULT 0;

-- Index pour optimisation
DEFINE INDEX idx_forecast_company ON forecast FIELDS company;
DEFINE INDEX idx_forecast_bank_details ON forecast FIELDS bank_details;
DEFINE INDEX idx_forecast_from_date ON forecast FIELDS from_date;
DEFINE INDEX idx_forecast_to_date ON forecast FIELDS to_date;
DEFINE INDEX idx_forecast_status ON forecast FIELDS status_select;
DEFINE INDEX idx_forecast_user ON forecast FIELDS user;
DEFINE INDEX idx_forecast_sequence ON forecast FIELDS forecast_sequence;

DEFINE INDEX idx_forecast_generator_company ON forecast_generator FIELDS company;
DEFINE INDEX idx_forecast_generator_forecast ON forecast_generator FIELDS forecast;
DEFINE INDEX idx_forecast_generator_element ON forecast_generator FIELDS element_select;
DEFINE INDEX idx_forecast_generator_active ON forecast_generator FIELDS is_active;
DEFINE INDEX idx_forecast_generator_sequence ON forecast_generator FIELDS sequence;
DEFINE INDEX idx_forecast_generator_type ON forecast_generator FIELDS type_select;

DEFINE INDEX idx_forecast_recap_forecast ON forecast_recap FIELDS forecast;
DEFINE INDEX idx_forecast_recap_estimate_date ON forecast_recap FIELDS estimate_date;
DEFINE INDEX idx_forecast_recap_period_number ON forecast_recap FIELDS period_number;
DEFINE INDEX idx_forecast_recap_is_consolidated ON forecast_recap FIELDS is_consolidated;
DEFINE INDEX idx_forecast_recap_is_realized ON forecast_recap FIELDS is_realized;

DEFINE INDEX idx_forecast_recap_line_forecast_recap ON forecast_recap_line FIELDS forecast_recap;
DEFINE INDEX idx_forecast_recap_line_forecast ON forecast_recap_line FIELDS forecast;
DEFINE INDEX idx_forecast_recap_line_type ON forecast_recap_line FIELDS forecast_recap_line_type;
DEFINE INDEX idx_forecast_recap_line_element ON forecast_recap_line FIELDS element_select;
DEFINE INDEX idx_forecast_recap_line_estimate_date ON forecast_recap_line FIELDS estimate_date;
DEFINE INDEX idx_forecast_recap_line_partner ON forecast_recap_line FIELDS partner;
DEFINE INDEX idx_forecast_recap_line_is_realized ON forecast_recap_line FIELDS is_realized;

DEFINE INDEX idx_forecast_recap_line_type_company ON forecast_recap_line_type FIELDS company;
DEFINE INDEX idx_forecast_recap_line_type_code ON forecast_recap_line_type FIELDS code;
DEFINE INDEX idx_forecast_recap_line_type_element ON forecast_recap_line_type FIELDS element_select;
DEFINE INDEX idx_forecast_recap_line_type_type ON forecast_recap_line_type FIELDS type_select;
DEFINE INDEX idx_forecast_recap_line_type_active ON forecast_recap_line_type FIELDS is_active;
DEFINE INDEX idx_forecast_recap_line_type_sequence ON forecast_recap_line_type FIELDS sequence; 