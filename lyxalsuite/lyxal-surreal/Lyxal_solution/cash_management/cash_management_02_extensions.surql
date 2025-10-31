-- ================================================================================
-- LYXAL SURREAL - AXELOR CASH MANAGEMENT - MODULE 2 : EXTENSIONS
-- ================================================================================
-- Entités : Employee, Opportunity, Sequence
-- ================================================================================

-- Extensions Employee pour cash management (Employee.xml - 599 bytes)
DEFINE TABLE employee_cash_management SCHEMAFULL;
DEFINE FIELD employee ON employee_cash_management TYPE record<employee>;
DEFINE FIELD is_cash_manager ON employee_cash_management TYPE bool DEFAULT false;
DEFINE FIELD forecast_list ON employee_cash_management TYPE array<record<forecast>>;
DEFINE FIELD default_forecast_recap_line_type ON employee_cash_management TYPE record<forecast_recap_line_type>;
DEFINE FIELD cash_management_access_level ON employee_cash_management TYPE int DEFAULT 1;
DEFINE FIELD can_validate_forecast ON employee_cash_management TYPE bool DEFAULT false;
DEFINE FIELD can_generate_forecast ON employee_cash_management TYPE bool DEFAULT false;
DEFINE FIELD supervised_bank_details_set ON employee_cash_management TYPE array<record<bank_details>>;
DEFINE FIELD notification_enabled ON employee_cash_management TYPE bool DEFAULT true;
DEFINE FIELD created_at ON employee_cash_management TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employee_cash_management TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employee_cash_management TYPE int DEFAULT 0;

-- Extensions Opportunity pour cash management (Opportunity.xml - 513 bytes)
DEFINE TABLE opportunity_cash_management SCHEMAFULL;
DEFINE FIELD opportunity ON opportunity_cash_management TYPE record<opportunity>;
DEFINE FIELD forecast_recap_line_list ON opportunity_cash_management TYPE array<record<forecast_recap_line>>;
DEFINE FIELD forecast_generator_list ON opportunity_cash_management TYPE array<record<forecast_generator>>;
DEFINE FIELD is_included_in_forecast ON opportunity_cash_management TYPE bool DEFAULT false;
DEFINE FIELD forecast_amount ON opportunity_cash_management TYPE decimal;
DEFINE FIELD forecast_probability ON opportunity_cash_management TYPE decimal DEFAULT 50.0;
DEFINE FIELD expected_closing_date ON opportunity_cash_management TYPE date;
DEFINE FIELD payment_terms ON opportunity_cash_management TYPE record<payment_condition>;
DEFINE FIELD payment_mode ON opportunity_cash_management TYPE record<payment_mode>;
DEFINE FIELD forecast_currency ON opportunity_cash_management TYPE record<currency>;
DEFINE FIELD cash_flow_type_select ON opportunity_cash_management TYPE int DEFAULT 1;
DEFINE FIELD created_at ON opportunity_cash_management TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON opportunity_cash_management TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON opportunity_cash_management TYPE int DEFAULT 0;

-- Extensions Sequence pour cash management (Sequence.xml - 631 bytes)
DEFINE TABLE sequence_cash_management SCHEMAFULL;
DEFINE FIELD sequence ON sequence_cash_management TYPE record<sequence>;
DEFINE FIELD is_forecast_sequence ON sequence_cash_management TYPE bool DEFAULT false;
DEFINE FIELD company ON sequence_cash_management TYPE record<company>;
DEFINE FIELD forecast_prefix ON sequence_cash_management TYPE string DEFAULT "FCST";
DEFINE FIELD forecast_suffix ON sequence_cash_management TYPE string;
DEFINE FIELD forecast_padding ON sequence_cash_management TYPE int DEFAULT 5;
DEFINE FIELD auto_generate_forecast_code ON sequence_cash_management TYPE bool DEFAULT true;
DEFINE FIELD reset_yearly ON sequence_cash_management TYPE bool DEFAULT true;
DEFINE FIELD last_forecast_number ON sequence_cash_management TYPE int DEFAULT 0;
DEFINE FIELD current_year ON sequence_cash_management TYPE int;
DEFINE FIELD created_at ON sequence_cash_management TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sequence_cash_management TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sequence_cash_management TYPE int DEFAULT 0;

-- Configuration Application Cash Management
DEFINE TABLE app_cash_management SCHEMAFULL;
DEFINE FIELD name ON app_cash_management TYPE string DEFAULT "Cash Management";
DEFINE FIELD code ON app_cash_management TYPE string DEFAULT "cash-management";
DEFINE FIELD is_active ON app_cash_management TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app_cash_management TYPE int DEFAULT 50;
DEFINE FIELD depends_on_set ON app_cash_management TYPE array<string>;
DEFINE FIELD generate_forecast_sequence ON app_cash_management TYPE bool DEFAULT true;
DEFINE FIELD forecast_sequence ON app_cash_management TYPE record<sequence>;
DEFINE FIELD default_forecast_period_type ON app_cash_management TYPE int DEFAULT 1;
DEFINE FIELD enable_multi_bank_forecast ON app_cash_management TYPE bool DEFAULT true;
DEFINE FIELD enable_opportunity_forecast ON app_cash_management TYPE bool DEFAULT true;
DEFINE FIELD auto_generate_forecast_recap ON app_cash_management TYPE bool DEFAULT true;
DEFINE FIELD forecast_validation_required ON app_cash_management TYPE bool DEFAULT false;
DEFINE FIELD enable_forecast_dashboard ON app_cash_management TYPE bool DEFAULT true;
DEFINE FIELD created_at ON app_cash_management TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_cash_management TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_cash_management TYPE int DEFAULT 0;

-- Configuration Cash Management par compagnie
DEFINE TABLE cash_management_config SCHEMAFULL;
DEFINE FIELD company ON cash_management_config TYPE record<company>;
DEFINE FIELD forecast_sequence ON cash_management_config TYPE record<sequence>;
DEFINE FIELD default_forecast_period_type ON cash_management_config TYPE int DEFAULT 1;
DEFINE FIELD default_bank_details ON cash_management_config TYPE record<bank_details>;
DEFINE FIELD auto_include_confirmed_orders ON cash_management_config TYPE bool DEFAULT true;
DEFINE FIELD auto_include_opportunities ON cash_management_config TYPE bool DEFAULT false;
DEFINE FIELD forecast_horizon_months ON cash_management_config TYPE int DEFAULT 12;
DEFINE FIELD cash_flow_tolerance_percentage ON cash_management_config TYPE decimal DEFAULT 5.0;
DEFINE FIELD enable_cash_alerts ON cash_management_config TYPE bool DEFAULT true;
DEFINE FIELD minimum_cash_threshold ON cash_management_config TYPE decimal;
DEFINE FIELD critical_cash_threshold ON cash_management_config TYPE decimal;
DEFINE FIELD notification_email_list ON cash_management_config TYPE array<string>;
DEFINE FIELD created_at ON cash_management_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON cash_management_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON cash_management_config TYPE int DEFAULT 0;

-- Index pour optimisation
DEFINE INDEX idx_employee_cash_management_employee ON employee_cash_management FIELDS employee;
DEFINE INDEX idx_employee_cash_management_is_cash_manager ON employee_cash_management FIELDS is_cash_manager;
DEFINE INDEX idx_employee_cash_management_access_level ON employee_cash_management FIELDS cash_management_access_level;
DEFINE INDEX idx_employee_cash_management_can_validate ON employee_cash_management FIELDS can_validate_forecast;

DEFINE INDEX idx_opportunity_cash_management_opportunity ON opportunity_cash_management FIELDS opportunity;
DEFINE INDEX idx_opportunity_cash_management_is_included ON opportunity_cash_management FIELDS is_included_in_forecast;
DEFINE INDEX idx_opportunity_cash_management_expected_date ON opportunity_cash_management FIELDS expected_closing_date;
DEFINE INDEX idx_opportunity_cash_management_cash_flow_type ON opportunity_cash_management FIELDS cash_flow_type_select;

DEFINE INDEX idx_sequence_cash_management_sequence ON sequence_cash_management FIELDS sequence;
DEFINE INDEX idx_sequence_cash_management_company ON sequence_cash_management FIELDS company;
DEFINE INDEX idx_sequence_cash_management_is_forecast ON sequence_cash_management FIELDS is_forecast_sequence;
DEFINE INDEX idx_sequence_cash_management_current_year ON sequence_cash_management FIELDS current_year;

DEFINE INDEX idx_cash_management_config_company ON cash_management_config FIELDS company;
DEFINE INDEX idx_cash_management_config_default_bank ON cash_management_config FIELDS default_bank_details; 