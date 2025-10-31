-- ================================================================================
-- LYXAL SURREAL - AXELOR CONTRACT - MODULE 1 : ENTITÉS PRINCIPALES
-- ================================================================================
-- Entités : Contract, ContractVersion, ContractLine, ContractTemplate, AppContract
-- ================================================================================

-- Configuration Application Contract (AppContract.xml - 1473 bytes)
DEFINE TABLE app_contract SCHEMAFULL;
DEFINE FIELD app ON app_contract TYPE record<app> UNIQUE;
DEFINE FIELD is_unchangable_contract ON app_contract TYPE bool DEFAULT false;
DEFINE FIELD is_amendment_management ON app_contract TYPE bool DEFAULT false;
DEFINE FIELD is_renewal_management ON app_contract TYPE bool DEFAULT false;
DEFINE FIELD is_consumption_management ON app_contract TYPE bool DEFAULT false;
DEFINE FIELD is_subscription_invoice ON app_contract TYPE bool DEFAULT false;
DEFINE FIELD default_contract_template ON app_contract TYPE record<contract_template>;
DEFINE FIELD contract_sequence ON app_contract TYPE record<sequence>;
DEFINE FIELD version_sequence ON app_contract TYPE record<sequence>;
DEFINE FIELD invoicing_frequency ON app_contract TYPE int DEFAULT 1; -- 1:Monthly, 2:Quarterly, 3:Yearly
DEFINE FIELD automatic_renewal ON app_contract TYPE bool DEFAULT false;
DEFINE FIELD renewal_notice_period ON app_contract TYPE int DEFAULT 30;
DEFINE FIELD enable_contract_alerts ON app_contract TYPE bool DEFAULT true;
DEFINE FIELD contract_manager_role ON app_contract TYPE record<role>;
DEFINE FIELD enable_contract_dashboard ON app_contract TYPE bool DEFAULT true;
DEFINE FIELD contract_approval_workflow ON app_contract TYPE bool DEFAULT false;
DEFINE FIELD created_at ON app_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_contract TYPE int DEFAULT 0;

-- Contrat principal (Contract.xml - 6461 bytes)
DEFINE TABLE contract SCHEMAFULL;
DEFINE FIELD name ON contract TYPE string ASSERT $value != NONE;
DEFINE FIELD contract_id ON contract TYPE string UNIQUE;
DEFINE FIELD target_type_select ON contract TYPE int DEFAULT 1; -- 1:Customer, 2:Supplier
DEFINE FIELD contract_type_select ON contract TYPE int ASSERT $value != NONE; -- 1:Billing, 2:Framework
DEFINE FIELD company ON contract TYPE record<company>;
DEFINE FIELD partner ON contract TYPE record<partner>;
DEFINE FIELD currency ON contract TYPE record<currency>;
DEFINE FIELD start_date ON contract TYPE date ASSERT $value != NONE;
DEFINE FIELD end_date ON contract TYPE date;
DEFINE FIELD invoicing_start_date ON contract TYPE date;
DEFINE FIELD invoicing_end_date ON contract TYPE date;
DEFINE FIELD activation_date ON contract TYPE date;
DEFINE FIELD termination_date ON contract TYPE date;
DEFINE FIELD status_select ON contract TYPE int DEFAULT 1; -- 1:Draft, 2:Active, 3:Terminated, 4:Closed
DEFINE FIELD current_contract_version ON contract TYPE record<contract_version>;
DEFINE FIELD next_contract_version ON contract TYPE record<contract_version>;
DEFINE FIELD contract_template ON contract TYPE record<contract_template>;
DEFINE FIELD description ON contract TYPE string;
DEFINE FIELD note ON contract TYPE string;
DEFINE FIELD invoicing_moment_select ON contract TYPE int DEFAULT 1; -- 1:Beginning, 2:End
DEFINE FIELD number_of_days ON contract TYPE int;
DEFINE FIELD is_invoicing_management ON contract TYPE bool DEFAULT true;
DEFINE FIELD is_consumption_management ON contract TYPE bool DEFAULT false;
DEFINE FIELD is_additional_benefits_management ON contract TYPE bool DEFAULT false;
DEFINE FIELD timetable_template ON contract TYPE record<template>;
DEFINE FIELD renewed_contract ON contract TYPE record<contract>;
DEFINE FIELD version_number ON contract TYPE int DEFAULT 1;
DEFINE FIELD is_with_engagement ON contract TYPE bool DEFAULT false;
DEFINE FIELD engagement_start_from_version ON contract TYPE bool DEFAULT false;
DEFINE FIELD is_with_prior_notice ON contract TYPE bool DEFAULT false;
DEFINE FIELD prior_notice_duration ON contract TYPE int;
DEFINE FIELD prior_notice_unit_select ON contract TYPE int DEFAULT 1; -- 1:Days, 2:Weeks, 3:Months
DEFINE FIELD is_tackle_to_invoice_term ON contract TYPE bool DEFAULT false;
DEFINE FIELD is_auto_renewal ON contract TYPE bool DEFAULT false;
DEFINE FIELD renewal_duration ON contract TYPE int;
DEFINE FIELD renewal_duration_unit_select ON contract TYPE int DEFAULT 1;
DEFINE FIELD min_duration_of_renewal ON contract TYPE int;
DEFINE FIELD is_perpetual_renewal ON contract TYPE bool DEFAULT false;
DEFINE FIELD total_amount ON contract TYPE decimal DEFAULT 0.0;
DEFINE FIELD ex_tax_total ON contract TYPE decimal DEFAULT 0.0;
DEFINE FIELD in_tax_total ON contract TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_by ON contract TYPE record<user>;
DEFINE FIELD created_at ON contract TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON contract TYPE int DEFAULT 0;

-- Version de contrat (ContractVersion.xml - 5799 bytes)
DEFINE TABLE contract_version SCHEMAFULL;
DEFINE FIELD contract ON contract_version TYPE record<contract>;
DEFINE FIELD status_select ON contract_version TYPE int DEFAULT 1; -- 1:Draft, 2:Waiting, 3:Ongoing, 4:Terminated
DEFINE FIELD version_number ON contract_version TYPE int DEFAULT 1;
DEFINE FIELD creation_date ON contract_version TYPE date DEFAULT <future> { time::now().date() };
DEFINE FIELD activation_date ON contract_version TYPE date;
DEFINE FIELD end_date ON contract_version TYPE date;
DEFINE FIELD description ON contract_version TYPE string;
DEFINE FIELD supposed_activation_date ON contract_version TYPE date;
DEFINE FIELD supposed_end_date ON contract_version TYPE date;
DEFINE FIELD invoicing_moment_select ON contract_version TYPE int DEFAULT 1;
DEFINE FIELD number_of_days ON contract_version TYPE int;
DEFINE FIELD is_with_engagement ON contract_version TYPE bool DEFAULT false;
DEFINE FIELD engagement_duration ON contract_version TYPE int;
DEFINE FIELD engagement_unit_select ON contract_version TYPE int DEFAULT 1;
DEFINE FIELD engagement_start_from_version ON contract_version TYPE bool DEFAULT false;
DEFINE FIELD is_with_prior_notice ON contract_version TYPE bool DEFAULT false;
DEFINE FIELD prior_notice_duration ON contract_version TYPE int;
DEFINE FIELD prior_notice_unit_select ON contract_version TYPE int DEFAULT 1;
DEFINE FIELD is_tackle_to_invoice_term ON contract_version TYPE bool DEFAULT false;
DEFINE FIELD is_auto_renewal ON contract_version TYPE bool DEFAULT false;
DEFINE FIELD renewal_duration ON contract_version TYPE int;
DEFINE FIELD renewal_duration_unit_select ON contract_version TYPE int DEFAULT 1;
DEFINE FIELD min_duration_of_renewal ON contract_version TYPE int;
DEFINE FIELD is_perpetual_renewal ON contract_version TYPE bool DEFAULT false;
DEFINE FIELD contract_line_list ON contract_version TYPE array<record<contract_line>>;
DEFINE FIELD invoicing_duration ON contract_version TYPE int DEFAULT 1;
DEFINE FIELD invoicing_duration_unit_select ON contract_version TYPE int DEFAULT 3; -- Months
DEFINE FIELD next_invoice_date ON contract_version TYPE date;
DEFINE FIELD is_invoicing_management ON contract_version TYPE bool DEFAULT true;
DEFINE FIELD is_consumption_management ON contract_version TYPE bool DEFAULT false;
DEFINE FIELD is_additional_benefits_management ON contract_version TYPE bool DEFAULT false;
DEFINE FIELD automatic_invoicing ON contract_version TYPE bool DEFAULT false;
DEFINE FIELD invoice_frequency ON contract_version TYPE int DEFAULT 1;
DEFINE FIELD created_at ON contract_version TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON contract_version TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON contract_version TYPE int DEFAULT 0;

-- Ligne de contrat (ContractLine.xml - 5322 bytes)
DEFINE TABLE contract_line SCHEMAFULL;
DEFINE FIELD contract_version ON contract_line TYPE record<contract_version>;
DEFINE FIELD sequence ON contract_line TYPE int;
DEFINE FIELD full_name ON contract_line TYPE string;
DEFINE FIELD product ON contract_line TYPE record<product>;
DEFINE FIELD product_name ON contract_line TYPE string;
DEFINE FIELD unit ON contract_line TYPE record<unit>;
DEFINE FIELD qty ON contract_line TYPE decimal DEFAULT 1.0;
DEFINE FIELD price ON contract_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD price_discounted ON contract_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD unit_price ON contract_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD ex_tax_total ON contract_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD in_tax_total ON contract_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD discount_type_select ON contract_line TYPE int DEFAULT 1; -- 1:Percentage, 2:Fixed
DEFINE FIELD discount_amount ON contract_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD tax_line ON contract_line TYPE record<tax_line>;
DEFINE FIELD description ON contract_line TYPE string;
DEFINE FIELD is_consumption_line ON contract_line TYPE bool DEFAULT false;
DEFINE FIELD consumption_line_list ON contract_line TYPE array<record<consumption_line>>;
DEFINE FIELD analytic_move_line_list ON contract_line TYPE array<record<analytic_move_line>>;
DEFINE FIELD is_invoiced ON contract_line TYPE bool DEFAULT false;
DEFINE FIELD from_date ON contract_line TYPE date;
DEFINE FIELD to_date ON contract_line TYPE date;
DEFINE FIELD type_select ON contract_line TYPE int DEFAULT 1; -- 1:Normal, 2:Title, 3:Subtotal
DEFINE FIELD is_meta_line ON contract_line TYPE bool DEFAULT false;
DEFINE FIELD line_type_select ON contract_line TYPE int DEFAULT 1; -- 1:Onetime, 2:Recurring
DEFINE FIELD recurring_start_date ON contract_line TYPE date;
DEFINE FIELD recurring_end_date ON contract_line TYPE date;
DEFINE FIELD invoicing_period_select ON contract_line TYPE int DEFAULT 3; -- Months
DEFINE FIELD invoicing_period_number ON contract_line TYPE int DEFAULT 1;
DEFINE FIELD is_to_revaluate ON contract_line TYPE bool DEFAULT false;
DEFINE FIELD revaluation_formula ON contract_line TYPE record<revaluation_formula>;
DEFINE FIELD index_revaluation ON contract_line TYPE record<index_revaluation>;
DEFINE FIELD last_revaluation_date ON contract_line TYPE date;
DEFINE FIELD next_revaluation_date ON contract_line TYPE date;
DEFINE FIELD created_at ON contract_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON contract_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON contract_line TYPE int DEFAULT 0;

-- Modèle de contrat (ContractTemplate.xml - 4306 bytes)
DEFINE TABLE contract_template SCHEMAFULL;
DEFINE FIELD name ON contract_template TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON contract_template TYPE string UNIQUE;
DEFINE FIELD period_number ON contract_template TYPE int DEFAULT 0;
DEFINE FIELD target_type_select ON contract_template TYPE int DEFAULT 1;
DEFINE FIELD contract_type_select ON contract_template TYPE int ASSERT $value != NONE;
DEFINE FIELD company ON contract_template TYPE record<company>;
DEFINE FIELD currency ON contract_template TYPE record<currency>;
DEFINE FIELD payment_condition ON contract_template TYPE record<payment_condition>;
DEFINE FIELD payment_mode ON contract_template TYPE record<payment_mode>;
DEFINE FIELD duration ON contract_template TYPE int;
DEFINE FIELD duration_unit_select ON contract_template TYPE int DEFAULT 3; -- Months
DEFINE FIELD invoicing_duration ON contract_template TYPE int DEFAULT 1;
DEFINE FIELD invoicing_duration_unit_select ON contract_template TYPE int DEFAULT 3;
DEFINE FIELD invoicing_moment_select ON contract_template TYPE int DEFAULT 1;
DEFINE FIELD number_of_days ON contract_template TYPE int;
DEFINE FIELD description ON contract_template TYPE string;
DEFINE FIELD note ON contract_template TYPE string;
DEFINE FIELD is_with_engagement ON contract_template TYPE bool DEFAULT false;
DEFINE FIELD engagement_duration ON contract_template TYPE int;
DEFINE FIELD engagement_unit_select ON contract_template TYPE int DEFAULT 3;
DEFINE FIELD engagement_start_from_version ON contract_template TYPE bool DEFAULT false;
DEFINE FIELD is_with_prior_notice ON contract_template TYPE bool DEFAULT false;
DEFINE FIELD prior_notice_duration ON contract_template TYPE int;
DEFINE FIELD prior_notice_unit_select ON contract_template TYPE int DEFAULT 1;
DEFINE FIELD is_tackle_to_invoice_term ON contract_template TYPE bool DEFAULT false;
DEFINE FIELD is_auto_renewal ON contract_template TYPE bool DEFAULT false;
DEFINE FIELD renewal_duration ON contract_template TYPE int;
DEFINE FIELD renewal_duration_unit_select ON contract_template TYPE int DEFAULT 3;
DEFINE FIELD min_duration_of_renewal ON contract_template TYPE int;
DEFINE FIELD is_perpetual_renewal ON contract_template TYPE bool DEFAULT false;
DEFINE FIELD contract_line_list ON contract_template TYPE array<record<contract_template_line>>;
DEFINE FIELD is_invoicing_management ON contract_template TYPE bool DEFAULT true;
DEFINE FIELD is_consumption_management ON contract_template TYPE bool DEFAULT false;
DEFINE FIELD is_additional_benefits_management ON contract_template TYPE bool DEFAULT false;
DEFINE FIELD automatic_invoicing ON contract_template TYPE bool DEFAULT false;
DEFINE FIELD invoice_frequency ON contract_template TYPE int DEFAULT 1;
DEFINE FIELD timetable_template ON contract_template TYPE record<template>;
DEFINE FIELD is_active ON contract_template TYPE bool DEFAULT true;
DEFINE FIELD created_at ON contract_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON contract_template TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON contract_template TYPE int DEFAULT 0;

-- Ligne de modèle de contrat (entité complémentaire)
DEFINE TABLE contract_template_line SCHEMAFULL;
DEFINE FIELD contract_template ON contract_template_line TYPE record<contract_template>;
DEFINE FIELD sequence ON contract_template_line TYPE int;
DEFINE FIELD product ON contract_template_line TYPE record<product>;
DEFINE FIELD product_name ON contract_template_line TYPE string;
DEFINE FIELD unit ON contract_template_line TYPE record<unit>;
DEFINE FIELD qty ON contract_template_line TYPE decimal DEFAULT 1.0;
DEFINE FIELD price ON contract_template_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD unit_price ON contract_template_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD discount_type_select ON contract_template_line TYPE int DEFAULT 1;
DEFINE FIELD discount_amount ON contract_template_line TYPE decimal DEFAULT 0.0;
DEFINE FIELD tax_line ON contract_template_line TYPE record<tax_line>;
DEFINE FIELD description ON contract_template_line TYPE string;
DEFINE FIELD line_type_select ON contract_template_line TYPE int DEFAULT 1;
DEFINE FIELD invoicing_period_select ON contract_template_line TYPE int DEFAULT 3;
DEFINE FIELD invoicing_period_number ON contract_template_line TYPE int DEFAULT 1;
DEFINE FIELD is_to_revaluate ON contract_template_line TYPE bool DEFAULT false;
DEFINE FIELD revaluation_formula ON contract_template_line TYPE record<revaluation_formula>;
DEFINE FIELD index_revaluation ON contract_template_line TYPE record<index_revaluation>;
DEFINE FIELD created_at ON contract_template_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON contract_template_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON contract_template_line TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_app_contract_app ON app_contract FIELDS app;
DEFINE INDEX idx_app_contract_is_unchangable ON app_contract FIELDS is_unchangable_contract;
DEFINE INDEX idx_app_contract_amendment_mgmt ON app_contract FIELDS is_amendment_management;

DEFINE INDEX idx_contract_contract_id ON contract FIELDS contract_id;
DEFINE INDEX idx_contract_company ON contract FIELDS company;
DEFINE INDEX idx_contract_partner ON contract FIELDS partner;
DEFINE INDEX idx_contract_status ON contract FIELDS status_select;
DEFINE INDEX idx_contract_start_date ON contract FIELDS start_date;
DEFINE INDEX idx_contract_end_date ON contract FIELDS end_date;
DEFINE INDEX idx_contract_current_version ON contract FIELDS current_contract_version;
DEFINE INDEX idx_contract_target_type ON contract FIELDS target_type_select;
DEFINE INDEX idx_contract_type ON contract FIELDS contract_type_select;

DEFINE INDEX idx_contract_version_contract ON contract_version FIELDS contract;
DEFINE INDEX idx_contract_version_status ON contract_version FIELDS status_select;
DEFINE INDEX idx_contract_version_number ON contract_version FIELDS version_number;
DEFINE INDEX idx_contract_version_activation_date ON contract_version FIELDS activation_date;
DEFINE INDEX idx_contract_version_end_date ON contract_version FIELDS end_date;
DEFINE INDEX idx_contract_version_next_invoice ON contract_version FIELDS next_invoice_date;

DEFINE INDEX idx_contract_line_contract_version ON contract_line FIELDS contract_version;
DEFINE INDEX idx_contract_line_product ON contract_line FIELDS product;
DEFINE INDEX idx_contract_line_sequence ON contract_line FIELDS sequence;
DEFINE INDEX idx_contract_line_is_invoiced ON contract_line FIELDS is_invoiced;
DEFINE INDEX idx_contract_line_type ON contract_line FIELDS type_select;
DEFINE INDEX idx_contract_line_line_type ON contract_line FIELDS line_type_select;
DEFINE INDEX idx_contract_line_from_date ON contract_line FIELDS from_date;
DEFINE INDEX idx_contract_line_to_date ON contract_line FIELDS to_date;

DEFINE INDEX idx_contract_template_code ON contract_template FIELDS code;
DEFINE INDEX idx_contract_template_company ON contract_template FIELDS company;
DEFINE INDEX idx_contract_template_target_type ON contract_template FIELDS target_type_select;
DEFINE INDEX idx_contract_template_contract_type ON contract_template FIELDS contract_type_select;
DEFINE INDEX idx_contract_template_is_active ON contract_template FIELDS is_active;

DEFINE INDEX idx_contract_template_line_template ON contract_template_line FIELDS contract_template;
DEFINE INDEX idx_contract_template_line_product ON contract_template_line FIELDS product;
DEFINE INDEX idx_contract_template_line_sequence ON contract_template_line FIELDS sequence;