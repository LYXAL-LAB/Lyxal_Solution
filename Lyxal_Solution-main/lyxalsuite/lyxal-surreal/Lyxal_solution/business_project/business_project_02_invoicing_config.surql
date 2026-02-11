-- ================================================================================
-- LYXAL SURREAL - AXELOR BUSINESS PROJECT - MODULE 2 : INVOICING & CONFIG
-- ================================================================================
-- Entités : InvoicingProject, AppBusinessProject, BusinessProjectConfig, Invoice,
--          InvoiceLine, AppProject, App, Contract
-- ================================================================================

-- Projets de facturation (InvoicingProject.xml - 3007 bytes)
DEFINE TABLE invoicing_project SCHEMAFULL;
DEFINE FIELD name ON invoicing_project TYPE string;
DEFINE FIELD code ON invoicing_project TYPE string;
DEFINE FIELD description ON invoicing_project TYPE string;
DEFINE FIELD company ON invoicing_project TYPE record<company>;
DEFINE FIELD partner ON invoicing_project TYPE record<partner>;
DEFINE FIELD contact_partner ON invoicing_project TYPE record<partner>;
DEFINE FIELD assigned_to ON invoicing_project TYPE record<user>;
DEFINE FIELD team ON invoicing_project TYPE record<team>;
DEFINE FIELD status_select ON invoicing_project TYPE int DEFAULT 1;
DEFINE FIELD progress_select ON invoicing_project TYPE int DEFAULT 0;
DEFINE FIELD start_date ON invoicing_project TYPE date;
DEFINE FIELD end_date ON invoicing_project TYPE date;
DEFINE FIELD invoice_frequency_select ON invoicing_project TYPE int;
DEFINE FIELD next_invoice_date ON invoicing_project TYPE date;
DEFINE FIELD project_list ON invoicing_project TYPE array<record<project>>;
DEFINE FIELD project_task_list ON invoicing_project TYPE array<record<project_task>>;
DEFINE FIELD timesheet_line_list ON invoicing_project TYPE array<record<timesheet_line>>;
DEFINE FIELD sale_order_line_list ON invoicing_project TYPE array<record<sale_order_line>>;
DEFINE FIELD purchase_order_line_list ON invoicing_project TYPE array<record<purchase_order_line>>;
DEFINE FIELD invoice_line_list ON invoicing_project TYPE array<record<invoice_line>>;
DEFINE FIELD currency ON invoicing_project TYPE record<currency>;
DEFINE FIELD unit_price ON invoicing_project TYPE decimal;
DEFINE FIELD total_costs ON invoicing_project TYPE decimal;
DEFINE FIELD invoiced_amount ON invoicing_project TYPE decimal;
DEFINE FIELD to_invoice_amount ON invoicing_project TYPE decimal;
DEFINE FIELD is_business_project ON invoicing_project TYPE bool DEFAULT false;
DEFINE FIELD exclude_task_invoice ON invoicing_project TYPE bool DEFAULT false;
DEFINE FIELD created_at ON invoicing_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoicing_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoicing_project TYPE int DEFAULT 0;

-- Application Business Project (AppBusinessProject.xml - 5728 bytes)
DEFINE TABLE app_business_project SCHEMAFULL;
DEFINE FIELD name ON app_business_project TYPE string DEFAULT "Business Project";
DEFINE FIELD code ON app_business_project TYPE string DEFAULT "business-project";
DEFINE FIELD is_active ON app_business_project TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app_business_project TYPE int DEFAULT 30;
DEFINE FIELD depends_on_set ON app_business_project TYPE array<string>;
DEFINE FIELD generate_project_sequence ON app_business_project TYPE bool DEFAULT true;
DEFINE FIELD project_sequence ON app_business_project TYPE record<sequence>;
DEFINE FIELD generate_project_task_sequence ON app_business_project TYPE bool DEFAULT true;
DEFINE FIELD project_task_sequence ON app_business_project TYPE record<sequence>;
DEFINE FIELD generate_invoicing_project_sequence ON app_business_project TYPE bool DEFAULT true;
DEFINE FIELD invoicing_project_sequence ON app_business_project TYPE record<sequence>;
DEFINE FIELD is_project_invoice_lines_grouped ON app_business_project TYPE bool DEFAULT false;
DEFINE FIELD automatic_invoice_project_timesheet ON app_business_project TYPE bool DEFAULT false;
DEFINE FIELD automatic_invoice_project_expense ON app_business_project TYPE bool DEFAULT false;
DEFINE FIELD is_invoice_project_timesheet ON app_business_project TYPE bool DEFAULT true;
DEFINE FIELD is_invoice_project_expense ON app_business_project TYPE bool DEFAULT true;
DEFINE FIELD exclude_task_invoice_project ON app_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_invoice_lines_grouping_by_partner ON app_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_invoice_lines_grouping_by_project ON app_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_invoice_lines_grouping_by_product ON app_business_project TYPE bool DEFAULT false;
DEFINE FIELD created_at ON app_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_business_project TYPE int DEFAULT 0;

-- Configuration Business Project (BusinessProjectConfig.xml - 1033 bytes)
DEFINE TABLE business_project_config SCHEMAFULL;
DEFINE FIELD company ON business_project_config TYPE record<company>;
DEFINE FIELD project_sequence ON business_project_config TYPE record<sequence>;
DEFINE FIELD project_task_sequence ON business_project_config TYPE record<sequence>;
DEFINE FIELD invoicing_project_sequence ON business_project_config TYPE record<sequence>;
DEFINE FIELD default_project_folder ON business_project_config TYPE record<project_folder>;
DEFINE FIELD automatic_invoice_project_timesheet ON business_project_config TYPE bool DEFAULT false;
DEFINE FIELD automatic_invoice_project_expense ON business_project_config TYPE bool DEFAULT false;
DEFINE FIELD is_project_invoice_lines_grouped ON business_project_config TYPE bool DEFAULT false;
DEFINE FIELD exclude_task_invoice_project ON business_project_config TYPE bool DEFAULT false;
DEFINE FIELD project_invoice_lines_grouping_by_partner ON business_project_config TYPE bool DEFAULT false;
DEFINE FIELD project_invoice_lines_grouping_by_project ON business_project_config TYPE bool DEFAULT false;
DEFINE FIELD project_invoice_lines_grouping_by_product ON business_project_config TYPE bool DEFAULT false;
DEFINE FIELD created_at ON business_project_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON business_project_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON business_project_config TYPE int DEFAULT 0;

-- Extensions Invoice pour business project (Invoice.xml - 1421 bytes)
DEFINE TABLE invoice_business_project SCHEMAFULL;
DEFINE FIELD invoice ON invoice_business_project TYPE record<invoice>;
DEFINE FIELD project ON invoice_business_project TYPE record<project>;
DEFINE FIELD invoicing_project ON invoice_business_project TYPE record<invoicing_project>;
DEFINE FIELD is_invoice_project_timesheet ON invoice_business_project TYPE bool DEFAULT false;
DEFINE FIELD is_invoice_project_expense ON invoice_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_task_list ON invoice_business_project TYPE array<record<project_task>>;
DEFINE FIELD timesheet_line_list ON invoice_business_project TYPE array<record<timesheet_line>>;
DEFINE FIELD expense_line_list ON invoice_business_project TYPE array<record<expense_line>>;
DEFINE FIELD invoice_project_timesheet_set ON invoice_business_project TYPE array<record<timesheet_line>>;
DEFINE FIELD invoice_project_expense_set ON invoice_business_project TYPE array<record<expense_line>>;
DEFINE FIELD created_at ON invoice_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_business_project TYPE int DEFAULT 0;

-- Extensions InvoiceLine pour business project (InvoiceLine.xml - 884 bytes)
DEFINE TABLE invoice_line_business_project SCHEMAFULL;
DEFINE FIELD invoice_line ON invoice_line_business_project TYPE record<invoice_line>;
DEFINE FIELD project ON invoice_line_business_project TYPE record<project>;
DEFINE FIELD project_task ON invoice_line_business_project TYPE record<project_task>;
DEFINE FIELD timesheet_line ON invoice_line_business_project TYPE record<timesheet_line>;
DEFINE FIELD expense_line ON invoice_line_business_project TYPE record<expense_line>;
DEFINE FIELD is_project_invoice_line ON invoice_line_business_project TYPE bool DEFAULT false;
DEFINE FIELD invoicing_project ON invoice_line_business_project TYPE record<invoicing_project>;
DEFINE FIELD sale_order_line ON invoice_line_business_project TYPE record<sale_order_line>;
DEFINE FIELD purchase_order_line ON invoice_line_business_project TYPE record<purchase_order_line>;
DEFINE FIELD created_at ON invoice_line_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_line_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_line_business_project TYPE int DEFAULT 0;

-- Application Project de base (AppProject.xml - 575 bytes)
DEFINE TABLE app_project SCHEMAFULL;
DEFINE FIELD name ON app_project TYPE string DEFAULT "Project";
DEFINE FIELD code ON app_project TYPE string DEFAULT "project";
DEFINE FIELD is_active ON app_project TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app_project TYPE int DEFAULT 20;
DEFINE FIELD depends_on_set ON app_project TYPE array<string>;
DEFINE FIELD generate_project_sequence ON app_project TYPE bool DEFAULT true;
DEFINE FIELD project_sequence ON app_project TYPE record<sequence>;
DEFINE FIELD generate_project_task_sequence ON app_project TYPE bool DEFAULT true;
DEFINE FIELD project_task_sequence ON app_project TYPE record<sequence>;
DEFINE FIELD created_at ON app_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_project TYPE int DEFAULT 0;

-- Application étendue (App.xml - 537 bytes)
DEFINE TABLE app_business_project_extended SCHEMAFULL;
DEFINE FIELD name ON app_business_project_extended TYPE string DEFAULT "Business Project Extended";
DEFINE FIELD code ON app_business_project_extended TYPE string DEFAULT "business-project-extended";
DEFINE FIELD is_active ON app_business_project_extended TYPE bool DEFAULT true;
DEFINE FIELD depends_on_set ON app_business_project_extended TYPE array<string>;
DEFINE FIELD enable_project_management ON app_business_project_extended TYPE bool DEFAULT true;
DEFINE FIELD enable_invoicing_project ON app_business_project_extended TYPE bool DEFAULT true;
DEFINE FIELD enable_business_project ON app_business_project_extended TYPE bool DEFAULT true;
DEFINE FIELD created_at ON app_business_project_extended TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_business_project_extended TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_business_project_extended TYPE int DEFAULT 0;

-- Extensions Contract pour business project (Contract.xml - 531 bytes)
DEFINE TABLE contract_business_project SCHEMAFULL;
DEFINE FIELD contract ON contract_business_project TYPE record<contract>;
DEFINE FIELD project ON contract_business_project TYPE record<project>;
DEFINE FIELD invoicing_project ON contract_business_project TYPE record<invoicing_project>;
DEFINE FIELD is_business_project ON contract_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_folder ON contract_business_project TYPE record<project_folder>;
DEFINE FIELD project_template ON contract_business_project TYPE record<project_template>;
DEFINE FIELD auto_generate_project ON contract_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_task_template_set ON contract_business_project TYPE array<record<project_task_template>>;
DEFINE FIELD created_at ON contract_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON contract_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON contract_business_project TYPE int DEFAULT 0;

-- Index pour optimisation
DEFINE INDEX idx_invoicing_project_company ON invoicing_project FIELDS company;
DEFINE INDEX idx_invoicing_project_partner ON invoicing_project FIELDS partner;
DEFINE INDEX idx_invoicing_project_status ON invoicing_project FIELDS status_select;
DEFINE INDEX idx_invoicing_project_start_date ON invoicing_project FIELDS start_date;
DEFINE INDEX idx_invoicing_project_next_invoice_date ON invoicing_project FIELDS next_invoice_date;
DEFINE INDEX idx_invoicing_project_assigned_to ON invoicing_project FIELDS assigned_to;

DEFINE INDEX idx_business_project_config_company ON business_project_config FIELDS company;

DEFINE INDEX idx_invoice_business_project_invoice ON invoice_business_project FIELDS invoice;
DEFINE INDEX idx_invoice_business_project_project ON invoice_business_project FIELDS project;
DEFINE INDEX idx_invoice_business_project_invoicing_project ON invoice_business_project FIELDS invoicing_project;

DEFINE INDEX idx_invoice_line_business_project_invoice_line ON invoice_line_business_project FIELDS invoice_line;
DEFINE INDEX idx_invoice_line_business_project_project ON invoice_line_business_project FIELDS project;
DEFINE INDEX idx_invoice_line_business_project_project_task ON invoice_line_business_project FIELDS project_task;

DEFINE INDEX idx_contract_business_project_contract ON contract_business_project FIELDS contract;
DEFINE INDEX idx_contract_business_project_project ON contract_business_project FIELDS project; 