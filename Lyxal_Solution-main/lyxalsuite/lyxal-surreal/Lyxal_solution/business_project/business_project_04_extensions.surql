-- ================================================================================
-- LYXAL SURREAL - AXELOR BUSINESS PROJECT - MODULE 4 : EXTENSIONS & ANALYTICS
-- ================================================================================
-- Entités : ProjectHistoryLine, ProjectHoldBack, ProjectHoldBackLine, ManualElement,
--          Partner, AccountConfig, Company, Site, Product, AnalyticMoveLine, AnalyticDistributionLine
-- ================================================================================

-- Historique de projet (ProjectHistoryLine.xml - 2148 bytes)
DEFINE TABLE project_history_line SCHEMAFULL;
DEFINE FIELD project ON project_history_line TYPE record<project>;
DEFINE FIELD project_task ON project_history_line TYPE record<project_task>;
DEFINE FIELD date ON project_history_line TYPE date;
DEFINE FIELD user ON project_history_line TYPE record<user>;
DEFINE FIELD action_type_select ON project_history_line TYPE int;
DEFINE FIELD old_value ON project_history_line TYPE string;
DEFINE FIELD new_value ON project_history_line TYPE string;
DEFINE FIELD field_name ON project_history_line TYPE string;
DEFINE FIELD comments ON project_history_line TYPE string;
DEFINE FIELD timesheet_line ON project_history_line TYPE record<timesheet_line>;
DEFINE FIELD expense_line ON project_history_line TYPE record<expense_line>;
DEFINE FIELD invoice_line ON project_history_line TYPE record<invoice_line>;
DEFINE FIELD sale_order_line ON project_history_line TYPE record<sale_order_line>;
DEFINE FIELD purchase_order_line ON project_history_line TYPE record<purchase_order_line>;
DEFINE FIELD created_at ON project_history_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project_history_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_history_line TYPE int DEFAULT 0;

-- Retenues de projet (ProjectHoldBack.xml - 1036 bytes)
DEFINE TABLE project_hold_back SCHEMAFULL;
DEFINE FIELD name ON project_hold_back TYPE string;
DEFINE FIELD project ON project_hold_back TYPE record<project>;
DEFINE FIELD hold_back_type_select ON project_hold_back TYPE int;
DEFINE FIELD percentage ON project_hold_back TYPE decimal;
DEFINE FIELD amount ON project_hold_back TYPE decimal;
DEFINE FIELD released_amount ON project_hold_back TYPE decimal;
DEFINE FIELD remaining_amount ON project_hold_back TYPE decimal;
DEFINE FIELD release_date ON project_hold_back TYPE date;
DEFINE FIELD status_select ON project_hold_back TYPE int DEFAULT 1;
DEFINE FIELD project_hold_back_line_list ON project_hold_back TYPE array<record<project_hold_back_line>>;
DEFINE FIELD invoicing_project ON project_hold_back TYPE record<invoicing_project>;
DEFINE FIELD currency ON project_hold_back TYPE record<currency>;
DEFINE FIELD created_at ON project_hold_back TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project_hold_back TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_hold_back TYPE int DEFAULT 0;

-- Lignes de retenues de projet (ProjectHoldBackLine.xml - 744 bytes)
DEFINE TABLE project_hold_back_line SCHEMAFULL;
DEFINE FIELD project_hold_back ON project_hold_back_line TYPE record<project_hold_back>;
DEFINE FIELD invoice_line ON project_hold_back_line TYPE record<invoice_line>;
DEFINE FIELD amount ON project_hold_back_line TYPE decimal;
DEFINE FIELD released_amount ON project_hold_back_line TYPE decimal;
DEFINE FIELD remaining_amount ON project_hold_back_line TYPE decimal;
DEFINE FIELD status_select ON project_hold_back_line TYPE int DEFAULT 1;
DEFINE FIELD release_date ON project_hold_back_line TYPE date;
DEFINE FIELD invoice ON project_hold_back_line TYPE record<invoice>;
DEFINE FIELD project ON project_hold_back_line TYPE record<project>;
DEFINE FIELD created_at ON project_hold_back_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project_hold_back_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_hold_back_line TYPE int DEFAULT 0;

-- Éléments manuels (ManualElement.xml - 1021 bytes)
DEFINE TABLE manual_element SCHEMAFULL;
DEFINE FIELD name ON manual_element TYPE string;
DEFINE FIELD project ON manual_element TYPE record<project>;
DEFINE FIELD project_task ON manual_element TYPE record<project_task>;
DEFINE FIELD element_type_select ON manual_element TYPE int;
DEFINE FIELD date ON manual_element TYPE date;
DEFINE FIELD amount ON manual_element TYPE decimal;
DEFINE FIELD quantity ON manual_element TYPE decimal;
DEFINE FIELD unit_price ON manual_element TYPE decimal;
DEFINE FIELD currency ON manual_element TYPE record<currency>;
DEFINE FIELD description ON manual_element TYPE string;
DEFINE FIELD invoicing_project ON manual_element TYPE record<invoicing_project>;
DEFINE FIELD is_invoiced ON manual_element TYPE bool DEFAULT false;
DEFINE FIELD invoice_line ON manual_element TYPE record<invoice_line>;
DEFINE FIELD product ON manual_element TYPE record<product>;
DEFINE FIELD unit ON manual_element TYPE record<unit>;
DEFINE FIELD created_at ON manual_element TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON manual_element TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON manual_element TYPE int DEFAULT 0;

-- Extensions Partner pour business project (Partner.xml - 917 bytes)
DEFINE TABLE partner_business_project SCHEMAFULL;
DEFINE FIELD partner ON partner_business_project TYPE record<partner>;
DEFINE FIELD project_list ON partner_business_project TYPE array<record<project>>;
DEFINE FIELD invoicing_project_list ON partner_business_project TYPE array<record<invoicing_project>>;
DEFINE FIELD is_business_project_customer ON partner_business_project TYPE bool DEFAULT false;
DEFINE FIELD default_project_folder ON partner_business_project TYPE record<project_folder>;
DEFINE FIELD default_invoicing_project ON partner_business_project TYPE record<invoicing_project>;
DEFINE FIELD project_invoice_frequency_select ON partner_business_project TYPE int;
DEFINE FIELD auto_generate_project ON partner_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_template ON partner_business_project TYPE record<project_template>;
DEFINE FIELD created_at ON partner_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON partner_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON partner_business_project TYPE int DEFAULT 0;

-- Extensions AccountConfig pour business project (AccountConfig.xml - 774 bytes)
DEFINE TABLE account_config_business_project SCHEMAFULL;
DEFINE FIELD account_config ON account_config_business_project TYPE record<account_config>;
DEFINE FIELD project_invoice_journal ON account_config_business_project TYPE record<journal>;
DEFINE FIELD project_expense_journal ON account_config_business_project TYPE record<journal>;
DEFINE FIELD project_timesheet_journal ON account_config_business_project TYPE record<journal>;
DEFINE FIELD project_account ON account_config_business_project TYPE record<account>;
DEFINE FIELD project_expense_account ON account_config_business_project TYPE record<account>;
DEFINE FIELD project_timesheet_account ON account_config_business_project TYPE record<account>;
DEFINE FIELD auto_generate_project_account ON account_config_business_project TYPE bool DEFAULT false;
DEFINE FIELD created_at ON account_config_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON account_config_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_config_business_project TYPE int DEFAULT 0;

-- Extensions Company pour business project (Company.xml - 609 bytes)
DEFINE TABLE company_business_project SCHEMAFULL;
DEFINE FIELD company ON company_business_project TYPE record<company>;
DEFINE FIELD project_folder_list ON company_business_project TYPE array<record<project_folder>>;
DEFINE FIELD default_project_folder ON company_business_project TYPE record<project_folder>;
DEFINE FIELD project_sequence ON company_business_project TYPE record<sequence>;
DEFINE FIELD project_task_sequence ON company_business_project TYPE record<sequence>;
DEFINE FIELD invoicing_project_sequence ON company_business_project TYPE record<sequence>;
DEFINE FIELD auto_generate_project_sequence ON company_business_project TYPE bool DEFAULT true;
DEFINE FIELD created_at ON company_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON company_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON company_business_project TYPE int DEFAULT 0;

-- Extensions Site pour business project (Site.xml - 544 bytes)
DEFINE TABLE site_business_project SCHEMAFULL;
DEFINE FIELD site ON site_business_project TYPE record<site>;
DEFINE FIELD project_list ON site_business_project TYPE array<record<project>>;
DEFINE FIELD default_project_folder ON site_business_project TYPE record<project_folder>;
DEFINE FIELD is_business_project_site ON site_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_manager ON site_business_project TYPE record<user>;
DEFINE FIELD auto_generate_project ON site_business_project TYPE bool DEFAULT false;
DEFINE FIELD created_at ON site_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON site_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON site_business_project TYPE int DEFAULT 0;

-- Extensions Product pour business project (Product.xml - 528 bytes)
DEFINE TABLE product_business_project SCHEMAFULL;
DEFINE FIELD product ON product_business_project TYPE record<product>;
DEFINE FIELD is_project_product ON product_business_project TYPE bool DEFAULT false;
DEFINE FIELD is_project_task_product ON product_business_project TYPE bool DEFAULT false;
DEFINE FIELD default_project_task_category ON product_business_project TYPE record<project_task_category>;
DEFINE FIELD auto_generate_project_task ON product_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_template ON product_business_project TYPE record<project_template>;
DEFINE FIELD created_at ON product_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON product_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON product_business_project TYPE int DEFAULT 0;

-- Extensions AnalyticMoveLine pour business project (AnalyticMoveLine.xml - 533 bytes)
DEFINE TABLE analytic_move_line_business_project SCHEMAFULL;
DEFINE FIELD analytic_move_line ON analytic_move_line_business_project TYPE record<analytic_move_line>;
DEFINE FIELD project ON analytic_move_line_business_project TYPE record<project>;
DEFINE FIELD project_task ON analytic_move_line_business_project TYPE record<project_task>;
DEFINE FIELD invoicing_project ON analytic_move_line_business_project TYPE record<invoicing_project>;
DEFINE FIELD is_project_analytic_line ON analytic_move_line_business_project TYPE bool DEFAULT false;
DEFINE FIELD created_at ON analytic_move_line_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_move_line_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_move_line_business_project TYPE int DEFAULT 0;

-- Extensions AnalyticDistributionLine pour business project (AnalyticDistributionLine.xml - 519 bytes)
DEFINE TABLE analytic_distribution_line_business_project SCHEMAFULL;
DEFINE FIELD analytic_distribution_line ON analytic_distribution_line_business_project TYPE record<analytic_distribution_line>;
DEFINE FIELD project ON analytic_distribution_line_business_project TYPE record<project>;
DEFINE FIELD project_task ON analytic_distribution_line_business_project TYPE record<project_task>;
DEFINE FIELD invoicing_project ON analytic_distribution_line_business_project TYPE record<invoicing_project>;
DEFINE FIELD is_project_distribution_line ON analytic_distribution_line_business_project TYPE bool DEFAULT false;
DEFINE FIELD created_at ON analytic_distribution_line_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_distribution_line_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_distribution_line_business_project TYPE int DEFAULT 0;

-- Index pour optimisation
DEFINE INDEX idx_project_history_line_project ON project_history_line FIELDS project;
DEFINE INDEX idx_project_history_line_project_task ON project_history_line FIELDS project_task;
DEFINE INDEX idx_project_history_line_date ON project_history_line FIELDS date;
DEFINE INDEX idx_project_history_line_user ON project_history_line FIELDS user;
DEFINE INDEX idx_project_history_line_action_type ON project_history_line FIELDS action_type_select;

DEFINE INDEX idx_project_hold_back_project ON project_hold_back FIELDS project;
DEFINE INDEX idx_project_hold_back_status ON project_hold_back FIELDS status_select;
DEFINE INDEX idx_project_hold_back_release_date ON project_hold_back FIELDS release_date;

DEFINE INDEX idx_project_hold_back_line_project_hold_back ON project_hold_back_line FIELDS project_hold_back;
DEFINE INDEX idx_project_hold_back_line_invoice_line ON project_hold_back_line FIELDS invoice_line;

DEFINE INDEX idx_manual_element_project ON manual_element FIELDS project;
DEFINE INDEX idx_manual_element_project_task ON manual_element FIELDS project_task;
DEFINE INDEX idx_manual_element_date ON manual_element FIELDS date;
DEFINE INDEX idx_manual_element_is_invoiced ON manual_element FIELDS is_invoiced;

DEFINE INDEX idx_partner_business_project_partner ON partner_business_project FIELDS partner;
DEFINE INDEX idx_partner_business_project_is_customer ON partner_business_project FIELDS is_business_project_customer;

DEFINE INDEX idx_account_config_business_project_account_config ON account_config_business_project FIELDS account_config;

DEFINE INDEX idx_company_business_project_company ON company_business_project FIELDS company;

DEFINE INDEX idx_site_business_project_site ON site_business_project FIELDS site;
DEFINE INDEX idx_site_business_project_is_business ON site_business_project FIELDS is_business_project_site;

DEFINE INDEX idx_product_business_project_product ON product_business_project FIELDS product;
DEFINE INDEX idx_product_business_project_is_project ON product_business_project FIELDS is_project_product;

DEFINE INDEX idx_analytic_move_line_business_project_analytic_move_line ON analytic_move_line_business_project FIELDS analytic_move_line;
DEFINE INDEX idx_analytic_move_line_business_project_project ON analytic_move_line_business_project FIELDS project;

DEFINE INDEX idx_analytic_distribution_line_business_project_analytic_distribution_line ON analytic_distribution_line_business_project FIELDS analytic_distribution_line;
DEFINE INDEX idx_analytic_distribution_line_business_project_project ON analytic_distribution_line_business_project FIELDS project; 