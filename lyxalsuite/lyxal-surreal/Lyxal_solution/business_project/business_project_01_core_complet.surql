-- ================================================================================
-- LYXAL SURREAL - AXELOR BUSINESS PROJECT - MODULE 1 : CORE PROJECT COMPLET
-- ================================================================================
-- Migration complète d'axelor-business-project vers SurrealDB
-- Entités : Project, ProjectTask, ProjectFolder, ProjectTemplate, ProjectTaskCategory
-- ================================================================================

-- Projets principaux (Project.xml - 8636 bytes)
DEFINE TABLE project SCHEMAFULL;
DEFINE FIELD name ON project TYPE string;
DEFINE FIELD full_name ON project TYPE string;
DEFINE FIELD code ON project TYPE string;
DEFINE FIELD description ON project TYPE string;
DEFINE FIELD company ON project TYPE record<company>;
DEFINE FIELD client_partner ON project TYPE record<partner>;
DEFINE FIELD contact_partner ON project TYPE record<partner>;
DEFINE FIELD assigned_to ON project TYPE record<user>;
DEFINE FIELD team ON project TYPE record<team>;
DEFINE FIELD project_folder ON project TYPE record<project_folder>;
DEFINE FIELD parent_project ON project TYPE record<project>;
DEFINE FIELD child_project_list ON project TYPE array<record<project>>;
DEFINE FIELD project_status ON project TYPE record<project_status>;
DEFINE FIELD project_type_select ON project TYPE int DEFAULT 1;
DEFINE FIELD priority_select ON project TYPE int DEFAULT 2;
DEFINE FIELD start_date ON project TYPE date;
DEFINE FIELD end_date ON project TYPE date;
DEFINE FIELD planned_start_date ON project TYPE date;
DEFINE FIELD planned_end_date ON project TYPE date;
DEFINE FIELD real_start_date ON project TYPE date;
DEFINE FIELD real_end_date ON project TYPE date;
DEFINE FIELD duration ON project TYPE int;
DEFINE FIELD progress_select ON project TYPE int DEFAULT 0;
DEFINE FIELD estimated_hours ON project TYPE decimal;
DEFINE FIELD spent_hours ON project TYPE decimal;
DEFINE FIELD remaining_hours ON project TYPE decimal;
DEFINE FIELD project_task_list ON project TYPE array<record<project_task>>;
DEFINE FIELD timesheet_line_list ON project TYPE array<record<timesheet_line>>;
DEFINE FIELD sale_order ON project TYPE record<sale_order>;
DEFINE FIELD sale_order_line_list ON project TYPE array<record<sale_order_line>>;
DEFINE FIELD purchase_order_line_list ON project TYPE array<record<purchase_order_line>>;
DEFINE FIELD invoice_line_list ON project TYPE array<record<invoice_line>>;
DEFINE FIELD invoicing_project ON project TYPE record<invoicing_project>;
DEFINE FIELD contract ON project TYPE record<contract>;
DEFINE FIELD is_business_project ON project TYPE bool DEFAULT false;
DEFINE FIELD is_invoiceable ON project TYPE bool DEFAULT true;
DEFINE FIELD currency ON project TYPE record<currency>;
DEFINE FIELD unit_price ON project TYPE decimal;
DEFINE FIELD total_amount ON project TYPE decimal;
DEFINE FIELD invoiced_amount ON project TYPE decimal;
DEFINE FIELD to_invoice_amount ON project TYPE decimal;
DEFINE FIELD expense_amount ON project TYPE decimal;
DEFINE FIELD margin_amount ON project TYPE decimal;
DEFINE FIELD margin_rate ON project TYPE decimal;
DEFINE FIELD project_template ON project TYPE record<project_template>;
DEFINE FIELD project_history_line_list ON project TYPE array<record<project_history_line>>;
DEFINE FIELD site ON project TYPE record<site>;
DEFINE FIELD project_hold_back_list ON project TYPE array<record<project_hold_back>>;
DEFINE FIELD manual_element_list ON project TYPE array<record<manual_element>>;
DEFINE FIELD synchronize_task ON project TYPE bool DEFAULT false;
DEFINE FIELD exclude_task_invoice ON project TYPE bool DEFAULT false;
DEFINE FIELD is_project_invoice_lines_grouped ON project TYPE bool DEFAULT false;
DEFINE FIELD project_category_set ON project TYPE array<record<project_category>>;
DEFINE FIELD is_shared_project ON project TYPE bool DEFAULT false;
DEFINE FIELD created_at ON project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project TYPE int DEFAULT 0;

-- Tâches de projet (ProjectTask.xml - 4553 bytes)
DEFINE TABLE project_task SCHEMAFULL;
DEFINE FIELD name ON project_task TYPE string;
DEFINE FIELD description ON project_task TYPE string;
DEFINE FIELD task_date ON project_task TYPE date;
DEFINE FIELD project ON project_task TYPE record<project>;
DEFINE FIELD parent_task ON project_task TYPE record<project_task>;
DEFINE FIELD child_task_list ON project_task TYPE array<record<project_task>>;
DEFINE FIELD assigned_to ON project_task TYPE record<user>;
DEFINE FIELD task_end_date ON project_task TYPE date;
DEFINE FIELD planned_start_date ON project_task TYPE date;
DEFINE FIELD planned_end_date ON project_task TYPE date;
DEFINE FIELD real_start_date ON project_task TYPE date;
DEFINE FIELD real_end_date ON project_task TYPE date;
DEFINE FIELD status_select ON project_task TYPE int DEFAULT 1;
DEFINE FIELD priority_select ON project_task TYPE int DEFAULT 2;
DEFINE FIELD progress_select ON project_task TYPE int DEFAULT 0;
DEFINE FIELD sequence ON project_task TYPE int;
DEFINE FIELD full_name ON project_task TYPE string;
DEFINE FIELD task_duration ON project_task TYPE int;
DEFINE FIELD planned_hours ON project_task TYPE decimal;
DEFINE FIELD spent_hours ON project_task TYPE decimal;
DEFINE FIELD remaining_hours ON project_task TYPE decimal;
DEFINE FIELD timesheet_line_list ON project_task TYPE array<record<timesheet_line>>;
DEFINE FIELD invoicing_type ON project_task TYPE int;
DEFINE FIELD unit_price ON project_task TYPE decimal;
DEFINE FIELD currency ON project_task TYPE record<currency>;
DEFINE FIELD sale_order_line ON project_task TYPE record<sale_order_line>;
DEFINE FIELD purchase_order_line ON project_task TYPE record<purchase_order_line>;
DEFINE FIELD invoice_line_list ON project_task TYPE array<record<invoice_line>>;
DEFINE FIELD invoicing_project ON project_task TYPE record<invoicing_project>;
DEFINE FIELD project_task_category ON project_task TYPE record<project_task_category>;
DEFINE FIELD is_billable ON project_task TYPE bool DEFAULT true;
DEFINE FIELD exclude_task_invoice ON project_task TYPE bool DEFAULT false;
DEFINE FIELD budgeted_time ON project_task TYPE decimal;
DEFINE FIELD financial_discount_amount ON project_task TYPE decimal;
DEFINE FIELD is_shared_task ON project_task TYPE bool DEFAULT false;
DEFINE FIELD metafile_set ON project_task TYPE array<record<metafile>>;
DEFINE FIELD created_at ON project_task TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project_task TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_task TYPE int DEFAULT 0;

-- Dossiers de projet (ProjectFolder.xml - 625 bytes)
DEFINE TABLE project_folder SCHEMAFULL;
DEFINE FIELD name ON project_folder TYPE string;
DEFINE FIELD code ON project_folder TYPE string;
DEFINE FIELD description ON project_folder TYPE string;
DEFINE FIELD parent_folder ON project_folder TYPE record<project_folder>;
DEFINE FIELD child_folder_list ON project_folder TYPE array<record<project_folder>>;
DEFINE FIELD project_list ON project_folder TYPE array<record<project>>;
DEFINE FIELD company ON project_folder TYPE record<company>;
DEFINE FIELD is_active ON project_folder TYPE bool DEFAULT true;
DEFINE FIELD sequence ON project_folder TYPE int;
DEFINE FIELD created_at ON project_folder TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project_folder TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_folder TYPE int DEFAULT 0;

-- Modèles de projet (ProjectTemplate.xml - 823 bytes)
DEFINE TABLE project_template SCHEMAFULL;
DEFINE FIELD name ON project_template TYPE string;
DEFINE FIELD code ON project_template TYPE string;
DEFINE FIELD description ON project_template TYPE string;
DEFINE FIELD company ON project_template TYPE record<company>;
DEFINE FIELD project_task_template_list ON project_template TYPE array<record<project_task_template>>;
DEFINE FIELD is_business_project ON project_template TYPE bool DEFAULT false;
DEFINE FIELD synchronize_task ON project_template TYPE bool DEFAULT false;
DEFINE FIELD exclude_task_invoice ON project_template TYPE bool DEFAULT false;
DEFINE FIELD is_project_invoice_lines_grouped ON project_template TYPE bool DEFAULT false;
DEFINE FIELD project_category_set ON project_template TYPE array<record<project_category>>;
DEFINE FIELD is_active ON project_template TYPE bool DEFAULT true;
DEFINE FIELD created_at ON project_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project_template TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_template TYPE int DEFAULT 0;

-- Catégories de tâches de projet (ProjectTaskCategory.xml - 671 bytes)
DEFINE TABLE project_task_category SCHEMAFULL;
DEFINE FIELD name ON project_task_category TYPE string;
DEFINE FIELD code ON project_task_category TYPE string;
DEFINE FIELD description ON project_task_category TYPE string;
DEFINE FIELD parent_category ON project_task_category TYPE record<project_task_category>;
DEFINE FIELD child_category_list ON project_task_category TYPE array<record<project_task_category>>;
DEFINE FIELD company ON project_task_category TYPE record<company>;
DEFINE FIELD is_active ON project_task_category TYPE bool DEFAULT true;
DEFINE FIELD sequence ON project_task_category TYPE int;
DEFINE FIELD created_at ON project_task_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project_task_category TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_task_category TYPE int DEFAULT 0;

-- Modèles de tâches de projet
DEFINE TABLE project_task_template SCHEMAFULL;
DEFINE FIELD name ON project_task_template TYPE string;
DEFINE FIELD description ON project_task_template TYPE string;
DEFINE FIELD project_template ON project_task_template TYPE record<project_template>;
DEFINE FIELD parent_task_template ON project_task_template TYPE record<project_task_template>;
DEFINE FIELD child_task_template_list ON project_task_template TYPE array<record<project_task_template>>;
DEFINE FIELD assigned_to ON project_task_template TYPE record<user>;
DEFINE FIELD task_duration ON project_task_template TYPE int;
DEFINE FIELD planned_hours ON project_task_template TYPE decimal;
DEFINE FIELD project_task_category ON project_task_template TYPE record<project_task_category>;
DEFINE FIELD is_billable ON project_task_template TYPE bool DEFAULT true;
DEFINE FIELD sequence ON project_task_template TYPE int;
DEFINE FIELD created_at ON project_task_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project_task_template TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_task_template TYPE int DEFAULT 0;

-- Index pour optimisation
DEFINE INDEX idx_project_company ON project FIELDS company;
DEFINE INDEX idx_project_client_partner ON project FIELDS client_partner;
DEFINE INDEX idx_project_status ON project FIELDS project_status;
DEFINE INDEX idx_project_start_date ON project FIELDS start_date;
DEFINE INDEX idx_project_end_date ON project FIELDS end_date;
DEFINE INDEX idx_project_assigned_to ON project FIELDS assigned_to;
DEFINE INDEX idx_project_team ON project FIELDS team;
DEFINE INDEX idx_project_folder ON project FIELDS project_folder;
DEFINE INDEX idx_project_code ON project FIELDS code;
DEFINE INDEX idx_project_is_business ON project FIELDS is_business_project;

DEFINE INDEX idx_project_task_project ON project_task FIELDS project;
DEFINE INDEX idx_project_task_parent ON project_task FIELDS parent_task;
DEFINE INDEX idx_project_task_assigned_to ON project_task FIELDS assigned_to;
DEFINE INDEX idx_project_task_status ON project_task FIELDS status_select;
DEFINE INDEX idx_project_task_date ON project_task FIELDS task_date;
DEFINE INDEX idx_project_task_category ON project_task FIELDS project_task_category;
DEFINE INDEX idx_project_task_sequence ON project_task FIELDS sequence;

DEFINE INDEX idx_project_folder_parent ON project_folder FIELDS parent_folder;
DEFINE INDEX idx_project_folder_company ON project_folder FIELDS company;
DEFINE INDEX idx_project_folder_code ON project_folder FIELDS code;
DEFINE INDEX idx_project_folder_active ON project_folder FIELDS is_active;

DEFINE INDEX idx_project_template_company ON project_template FIELDS company;
DEFINE INDEX idx_project_template_code ON project_template FIELDS code;
DEFINE INDEX idx_project_template_active ON project_template FIELDS is_active;

DEFINE INDEX idx_project_task_category_parent ON project_task_category FIELDS parent_category;
DEFINE INDEX idx_project_task_category_company ON project_task_category FIELDS company;
DEFINE INDEX idx_project_task_category_active ON project_task_category FIELDS is_active; 