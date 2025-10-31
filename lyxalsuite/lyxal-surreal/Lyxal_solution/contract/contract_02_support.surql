-- ================================================================================
-- LYXAL SURREAL - AXELOR CONTRACT - MODULE 2 : ENTITÉS DE SUPPORT
-- ================================================================================
-- Entités : ConsumptionLine, InvoicePeriod, ContractBatch, IndexRevaluation, IndexValue, RevaluationFormula
-- ================================================================================

-- Ligne de consommation (ConsumptionLine.xml - 1418 bytes)
DEFINE TABLE consumption_line SCHEMAFULL;
DEFINE FIELD contract_line ON consumption_line TYPE record<contract_line>;
DEFINE FIELD qty ON consumption_line TYPE decimal ASSERT $value > 0.0;
DEFINE FIELD product ON consumption_line TYPE record<product> ASSERT $value != NONE;
DEFINE FIELD unit ON consumption_line TYPE record<unit>;
DEFINE FIELD line_date ON consumption_line TYPE date;
DEFINE FIELD is_invoiced ON consumption_line TYPE bool DEFAULT false;
DEFINE FIELD unit_price ON consumption_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD price_discounted ON consumption_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD ex_tax_total ON consumption_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD in_tax_total ON consumption_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD reference ON consumption_line TYPE string;
DEFINE FIELD description ON consumption_line TYPE string;
DEFINE FIELD consumption_type_select ON consumption_line TYPE int DEFAULT 1; -- 1:Manual, 2:Automatic
DEFINE FIELD invoice_line ON consumption_line TYPE record<invoice_line>;
DEFINE FIELD consumption_period_start ON consumption_line TYPE date;
DEFINE FIELD consumption_period_end ON consumption_line TYPE date;
DEFINE FIELD meter_reading_start ON consumption_line TYPE decimal;
DEFINE FIELD meter_reading_end ON consumption_line TYPE decimal;
DEFINE FIELD consumption_value ON consumption_line TYPE decimal;
DEFINE FIELD consumption_unit ON consumption_line TYPE record<unit>;
DEFINE FIELD billing_rate ON consumption_line TYPE decimal;
DEFINE FIELD created_at ON consumption_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON consumption_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON consumption_line TYPE int DEFAULT 0;

-- Période de facturation (InvoicePeriod.xml - 1555 bytes)
DEFINE TABLE invoice_period SCHEMAFULL;
DEFINE FIELD full_name ON invoice_period TYPE string;
DEFINE FIELD start_date ON invoice_period TYPE date ASSERT $value != NONE;
DEFINE FIELD end_date ON invoice_period TYPE date ASSERT $value != NONE;
DEFINE FIELD invoice_date ON invoice_period TYPE date;
DEFINE FIELD contract_version ON invoice_period TYPE record<contract_version>;
DEFINE FIELD status_select ON invoice_period TYPE int DEFAULT 1; -- 1:Draft, 2:Validated, 3:Invoiced
DEFINE FIELD invoice ON invoice_period TYPE record<invoice>;
DEFINE FIELD description ON invoice_period TYPE string;
DEFINE FIELD is_prorated ON invoice_period TYPE bool DEFAULT false;
DEFINE FIELD prorated_start_date ON invoice_period TYPE date;
DEFINE FIELD prorated_end_date ON invoice_period TYPE date;
DEFINE FIELD period_type_select ON invoice_period TYPE int DEFAULT 3; -- 1:Daily, 2:Weekly, 3:Monthly, 4:Quarterly, 5:Yearly
DEFINE FIELD period_number ON invoice_period TYPE int DEFAULT 1;
DEFINE FIELD automatic_invoicing ON invoice_period TYPE bool DEFAULT false;
DEFINE FIELD invoicing_moment_select ON invoice_period TYPE int DEFAULT 1; -- 1:Beginning, 2:End
DEFINE FIELD number_of_days ON invoice_period TYPE int;
DEFINE FIELD invoice_line_list ON invoice_period TYPE array<record<invoice_line>>;
DEFINE FIELD total_amount ON invoice_period TYPE decimal DEFAULT 0.0;
DEFINE FIELD ex_tax_total ON invoice_period TYPE decimal DEFAULT 0.0;
DEFINE FIELD in_tax_total ON invoice_period TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON invoice_period TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_period TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_period TYPE int DEFAULT 0;

-- Traitement par lot de contrats (ContractBatch.xml - 1431 bytes)
DEFINE TABLE contract_batch SCHEMAFULL;
DEFINE FIELD code ON contract_batch TYPE string UNIQUE ASSERT $value != NONE;
DEFINE FIELD action_select ON contract_batch TYPE int ASSERT $value != NONE; -- 1:Invoice, 2:Renewal, 3:Termination, 4:Revaluation
DEFINE FIELD company ON contract_batch TYPE record<company>;
DEFINE FIELD fetch_limit ON contract_batch TYPE int DEFAULT 100;
DEFINE FIELD description ON contract_batch TYPE string;
DEFINE FIELD batch_list ON contract_batch TYPE array<record<batch>>;
DEFINE FIELD is_active ON contract_batch TYPE bool DEFAULT true;
DEFINE FIELD schedule_date ON contract_batch TYPE date;
DEFINE FIELD last_execution_date ON contract_batch TYPE datetime;
DEFINE FIELD next_execution_date ON contract_batch TYPE datetime;
DEFINE FIELD execution_frequency ON contract_batch TYPE int DEFAULT 1; -- 1:Daily, 2:Weekly, 3:Monthly
DEFINE FIELD auto_execute ON contract_batch TYPE bool DEFAULT false;
DEFINE FIELD filter_criteria ON contract_batch TYPE object;
DEFINE FIELD contract_status_filter ON contract_batch TYPE array<int>;
DEFINE FIELD partner_filter ON contract_batch TYPE array<record<partner>>;
DEFINE FIELD contract_type_filter ON contract_batch TYPE array<int>;
DEFINE FIELD date_from ON contract_batch TYPE date;
DEFINE FIELD date_to ON contract_batch TYPE date;
DEFINE FIELD email_notification ON contract_batch TYPE bool DEFAULT false;
DEFINE FIELD notification_email_list ON contract_batch TYPE array<string>;
DEFINE FIELD execution_log ON contract_batch TYPE string;
DEFINE FIELD success_count ON contract_batch TYPE int DEFAULT 0;
DEFINE FIELD error_count ON contract_batch TYPE int DEFAULT 0;
DEFINE FIELD created_at ON contract_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON contract_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON contract_batch TYPE int DEFAULT 0;

-- Réévaluation d'index (IndexRevaluation.xml - 668 bytes)
DEFINE TABLE index_revaluation SCHEMAFULL;
DEFINE FIELD code ON index_revaluation TYPE string UNIQUE ASSERT $value != NONE;
DEFINE FIELD name ON index_revaluation TYPE string;
DEFINE FIELD index_value_list ON index_revaluation TYPE array<record<index_value>>;
DEFINE FIELD description ON index_revaluation TYPE string;
DEFINE FIELD index_type_select ON index_revaluation TYPE int DEFAULT 1; -- 1:Economic, 2:Financial, 3:Consumer
DEFINE FIELD source ON index_revaluation TYPE string;
DEFINE FIELD publication_frequency ON index_revaluation TYPE int DEFAULT 3; -- Monthly
DEFINE FIELD base_value ON index_revaluation TYPE decimal DEFAULT 100.0;
DEFINE FIELD base_date ON index_revaluation TYPE date;
DEFINE FIELD currency ON index_revaluation TYPE record<currency>;
DEFINE FIELD is_active ON index_revaluation TYPE bool DEFAULT true;
DEFINE FIELD last_update_date ON index_revaluation TYPE datetime;
DEFINE FIELD automatic_update ON index_revaluation TYPE bool DEFAULT false;
DEFINE FIELD external_source_url ON index_revaluation TYPE string;
DEFINE FIELD created_at ON index_revaluation TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON index_revaluation TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON index_revaluation TYPE int DEFAULT 0;

-- Valeur d'index (IndexValue.xml - 765 bytes)
DEFINE TABLE index_value SCHEMAFULL;
DEFINE FIELD index_revaluation ON index_value TYPE record<index_revaluation>;
DEFINE FIELD start_date ON index_value TYPE date ASSERT $value != NONE;
DEFINE FIELD end_date ON index_value TYPE date;
DEFINE FIELD value ON index_value TYPE decimal;
DEFINE FIELD period_name ON index_value TYPE string;
DEFINE FIELD variation_percentage ON index_value TYPE decimal;
DEFINE FIELD variation_absolute ON index_value TYPE decimal;
DEFINE FIELD is_estimated ON index_value TYPE bool DEFAULT false;
DEFINE FIELD source_reference ON index_value TYPE string;
DEFINE FIELD publication_date ON index_value TYPE date;
DEFINE FIELD validation_status ON index_value TYPE int DEFAULT 1; -- 1:Draft, 2:Validated, 3:Published
DEFINE FIELD validator ON index_value TYPE record<user>;
DEFINE FIELD validation_date ON index_value TYPE datetime;
DEFINE FIELD comments ON index_value TYPE string;
DEFINE FIELD created_at ON index_value TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON index_value TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON index_value TYPE int DEFAULT 0;

-- Formule de réévaluation (RevaluationFormula.xml - 741 bytes)
DEFINE TABLE revaluation_formula SCHEMAFULL;
DEFINE FIELD code ON revaluation_formula TYPE string UNIQUE ASSERT $value != NONE;
DEFINE FIELD name ON revaluation_formula TYPE string;
DEFINE FIELD formula ON revaluation_formula TYPE string;
DEFINE FIELD invoice_comment ON revaluation_formula TYPE string;
DEFINE FIELD description ON revaluation_formula TYPE string;
DEFINE FIELD formula_type_select ON revaluation_formula TYPE int DEFAULT 1; -- 1:Percentage, 2:Fixed, 3:Index
DEFINE FIELD is_active ON revaluation_formula TYPE bool DEFAULT true;
DEFINE FIELD calculation_method ON revaluation_formula TYPE int DEFAULT 1; -- 1:Additive, 2:Multiplicative
DEFINE FIELD minimum_threshold ON revaluation_formula TYPE decimal;
DEFINE FIELD maximum_threshold ON revaluation_formula TYPE decimal;
DEFINE FIELD rounding_mode ON revaluation_formula TYPE int DEFAULT 1; -- 1:Half_up, 2:Half_down, 3:Up, 4:Down
DEFINE FIELD decimal_places ON revaluation_formula TYPE int DEFAULT 2;
DEFINE FIELD application_frequency ON revaluation_formula TYPE int DEFAULT 12; -- Months
DEFINE FIELD last_application_date ON revaluation_formula TYPE date;
DEFINE FIELD next_application_date ON revaluation_formula TYPE date;
DEFINE FIELD automatic_application ON revaluation_formula TYPE bool DEFAULT false;
DEFINE FIELD approval_required ON revaluation_formula TYPE bool DEFAULT false;
DEFINE FIELD created_at ON revaluation_formula TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON revaluation_formula TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON revaluation_formula TYPE int DEFAULT 0;

-- Historique de réévaluation (entité complémentaire)
DEFINE TABLE revaluation_history SCHEMAFULL;
DEFINE FIELD contract_line ON revaluation_history TYPE record<contract_line>;
DEFINE FIELD revaluation_formula ON revaluation_history TYPE record<revaluation_formula>;
DEFINE FIELD index_revaluation ON revaluation_history TYPE record<index_revaluation>;
DEFINE FIELD old_price ON revaluation_history TYPE decimal;
DEFINE FIELD new_price ON revaluation_history TYPE decimal;
DEFINE FIELD variation_percentage ON revaluation_history TYPE decimal;
DEFINE FIELD variation_amount ON revaluation_history TYPE decimal;
DEFINE FIELD application_date ON revaluation_history TYPE date DEFAULT <future> { time::now().date() };
DEFINE FIELD period_start ON revaluation_history TYPE date;
DEFINE FIELD period_end ON revaluation_history TYPE date;
DEFINE FIELD calculation_details ON revaluation_history TYPE object;
DEFINE FIELD status_select ON revaluation_history TYPE int DEFAULT 1; -- 1:Calculated, 2:Applied, 3:Cancelled
DEFINE FIELD applied_by ON revaluation_history TYPE record<user>;
DEFINE FIELD applied_date ON revaluation_history TYPE datetime;
DEFINE FIELD comments ON revaluation_history TYPE string;
DEFINE FIELD created_at ON revaluation_history TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON revaluation_history TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON revaluation_history TYPE int DEFAULT 0;

-- Configuration des notifications de contrat (entité complémentaire)
DEFINE TABLE contract_notification SCHEMAFULL;
DEFINE FIELD contract ON contract_notification TYPE record<contract>;
DEFINE FIELD notification_type ON contract_notification TYPE int ASSERT $value != NONE; -- 1:Expiration, 2:Renewal, 3:Payment, 4:Revaluation
DEFINE FIELD trigger_date ON contract_notification TYPE date;
DEFINE FIELD trigger_days_before ON contract_notification TYPE int DEFAULT 0;
DEFINE FIELD is_sent ON contract_notification TYPE bool DEFAULT false;
DEFINE FIELD sent_date ON contract_notification TYPE datetime;
DEFINE FIELD recipient_email_list ON contract_notification TYPE array<string>;
DEFINE FIELD email_template ON contract_notification TYPE record<template>;
DEFINE FIELD message_subject ON contract_notification TYPE string;
DEFINE FIELD message_content ON contract_notification TYPE string;
DEFINE FIELD retry_count ON contract_notification TYPE int DEFAULT 0;
DEFINE FIELD max_retry ON contract_notification TYPE int DEFAULT 3;
DEFINE FIELD next_retry_date ON contract_notification TYPE datetime;
DEFINE FIELD failure_reason ON contract_notification TYPE string;
DEFINE FIELD is_active ON contract_notification TYPE bool DEFAULT true;
DEFINE FIELD created_at ON contract_notification TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON contract_notification TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON contract_notification TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_consumption_line_contract_line ON consumption_line FIELDS contract_line;
DEFINE INDEX idx_consumption_line_product ON consumption_line FIELDS product;
DEFINE INDEX idx_consumption_line_line_date ON consumption_line FIELDS line_date;
DEFINE INDEX idx_consumption_line_is_invoiced ON consumption_line FIELDS is_invoiced;
DEFINE INDEX idx_consumption_line_consumption_type ON consumption_line FIELDS consumption_type_select;

DEFINE INDEX idx_invoice_period_start_date ON invoice_period FIELDS start_date;
DEFINE INDEX idx_invoice_period_end_date ON invoice_period FIELDS end_date;
DEFINE INDEX idx_invoice_period_contract_version ON invoice_period FIELDS contract_version;
DEFINE INDEX idx_invoice_period_status ON invoice_period FIELDS status_select;
DEFINE INDEX idx_invoice_period_invoice_date ON invoice_period FIELDS invoice_date;

DEFINE INDEX idx_contract_batch_code ON contract_batch FIELDS code;
DEFINE INDEX idx_contract_batch_action ON contract_batch FIELDS action_select;
DEFINE INDEX idx_contract_batch_company ON contract_batch FIELDS company;
DEFINE INDEX idx_contract_batch_is_active ON contract_batch FIELDS is_active;
DEFINE INDEX idx_contract_batch_next_execution ON contract_batch FIELDS next_execution_date;

DEFINE INDEX idx_index_revaluation_code ON index_revaluation FIELDS code;
DEFINE INDEX idx_index_revaluation_is_active ON index_revaluation FIELDS is_active;
DEFINE INDEX idx_index_revaluation_index_type ON index_revaluation FIELDS index_type_select;
DEFINE INDEX idx_index_revaluation_last_update ON index_revaluation FIELDS last_update_date;

DEFINE INDEX idx_index_value_index_revaluation ON index_value FIELDS index_revaluation;
DEFINE INDEX idx_index_value_start_date ON index_value FIELDS start_date;
DEFINE INDEX idx_index_value_end_date ON index_value FIELDS end_date;
DEFINE INDEX idx_index_value_validation_status ON index_value FIELDS validation_status;
DEFINE INDEX idx_index_value_publication_date ON index_value FIELDS publication_date;

DEFINE INDEX idx_revaluation_formula_code ON revaluation_formula FIELDS code;
DEFINE INDEX idx_revaluation_formula_is_active ON revaluation_formula FIELDS is_active;
DEFINE INDEX idx_revaluation_formula_type ON revaluation_formula FIELDS formula_type_select;
DEFINE INDEX idx_revaluation_formula_next_application ON revaluation_formula FIELDS next_application_date;

DEFINE INDEX idx_revaluation_history_contract_line ON revaluation_history FIELDS contract_line;
DEFINE INDEX idx_revaluation_history_application_date ON revaluation_history FIELDS application_date;
DEFINE INDEX idx_revaluation_history_status ON revaluation_history FIELDS status_select;
DEFINE INDEX idx_revaluation_history_applied_by ON revaluation_history FIELDS applied_by;

DEFINE INDEX idx_contract_notification_contract ON contract_notification FIELDS contract;
DEFINE INDEX idx_contract_notification_type ON contract_notification FIELDS notification_type;
DEFINE INDEX idx_contract_notification_trigger_date ON contract_notification FIELDS trigger_date;
DEFINE INDEX idx_contract_notification_is_sent ON contract_notification FIELDS is_sent;
DEFINE INDEX idx_contract_notification_is_active ON contract_notification FIELDS is_active;