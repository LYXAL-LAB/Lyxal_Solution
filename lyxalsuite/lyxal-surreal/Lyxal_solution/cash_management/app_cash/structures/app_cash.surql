-- =================================================================
-- TABLE APP_CASH - Configuration globale du module Cash Management
-- =================================================================

DEFINE TABLE app_cash_management SCHEMAFULL;
    COMMENT "Configuration globale du module Cash Management";

DEFINE FIELD module_id ON app_cash_management TYPE record<app_module>;
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