-- LYXAL SURREAL - AXELOR BUSINESS PRODUCTION - MODULE 3
-- Entités finales : InvoicingProject, SaleOrderLine extension, SaleOrderLineDetails, AppProduction

-- Projets de facturation
DEFINE TABLE invoicing_project SCHEMAFULL;
DEFINE FIELD name ON invoicing_project TYPE string;
DEFINE FIELD code ON invoicing_project TYPE string;
DEFINE FIELD company ON invoicing_project TYPE record<company>;
DEFINE FIELD client_partner ON invoicing_project TYPE record<partner>;
DEFINE FIELD assigned_to ON invoicing_project TYPE record<user>;
DEFINE FIELD team ON invoicing_project TYPE record<team>;
DEFINE FIELD status_select ON invoicing_project TYPE int DEFAULT 1;
DEFINE FIELD progress_select ON invoicing_project TYPE int DEFAULT 0;
DEFINE FIELD start_date ON invoicing_project TYPE date;
DEFINE FIELD end_date ON invoicing_project TYPE date;
DEFINE FIELD description ON invoicing_project TYPE string;
DEFINE FIELD invoicing_sequence_select ON invoicing_project TYPE string;
DEFINE FIELD invoice_frequency_select ON invoicing_project TYPE int;
DEFINE FIELD next_invoice_date ON invoicing_project TYPE date;
DEFINE FIELD unit_price ON invoicing_project TYPE decimal;
DEFINE FIELD currency ON invoicing_project TYPE record<currency>;
DEFINE FIELD project_task_list ON invoicing_project TYPE array<record<project_task>>;
DEFINE FIELD timesheet_line_list ON invoicing_project TYPE array<record<timesheet_line>>;
DEFINE FIELD sale_order ON invoicing_project TYPE record<sale_order>;
DEFINE FIELD sale_order_line_list ON invoicing_project TYPE array<record<sale_order_line>>;
DEFINE FIELD invoice_line_list ON invoicing_project TYPE array<record<invoice_line>>;
DEFINE FIELD production_order_list ON invoicing_project TYPE array<record<production_order>>;
DEFINE FIELD total_planned_hours ON invoicing_project TYPE decimal;
DEFINE FIELD total_spent_hours ON invoicing_project TYPE decimal;
DEFINE FIELD total_invoiced_amount ON invoicing_project TYPE decimal;
DEFINE FIELD is_production_project ON invoicing_project TYPE bool DEFAULT false;
DEFINE FIELD work_center_list ON invoicing_project TYPE array<record<work_center>>;
DEFINE FIELD created_at ON invoicing_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoicing_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoicing_project TYPE int DEFAULT 0;

-- Extension SaleOrderLine pour business production
DEFINE TABLE sale_order_line_production SCHEMAFULL;
DEFINE FIELD sale_order_line ON sale_order_line_production TYPE record<sale_order_line>;
DEFINE FIELD production_order ON sale_order_line_production TYPE record<production_order>;
DEFINE FIELD manuf_order_list ON sale_order_line_production TYPE array<record<manuf_order>>;
DEFINE FIELD is_manufacturing_required ON sale_order_line_production TYPE bool DEFAULT false;
DEFINE FIELD bill_of_material ON sale_order_line_production TYPE record<bill_of_material>;
DEFINE FIELD routing ON sale_order_line_production TYPE record<routing>;
DEFINE FIELD work_center ON sale_order_line_production TYPE record<work_center>;
DEFINE FIELD planned_production_date ON sale_order_line_production TYPE datetime;
DEFINE FIELD actual_production_date ON sale_order_line_production TYPE datetime;
DEFINE FIELD production_status_select ON sale_order_line_production TYPE int DEFAULT 1;
DEFINE FIELD produced_qty ON sale_order_line_production TYPE decimal DEFAULT 0;
DEFINE FIELD manufacturing_lead_time ON sale_order_line_production TYPE int;
DEFINE FIELD production_cost ON sale_order_line_production TYPE decimal;
DEFINE FIELD invoicing_project ON sale_order_line_production TYPE record<invoicing_project>;
DEFINE FIELD is_project_based ON sale_order_line_production TYPE bool DEFAULT false;
DEFINE FIELD project_task_list ON sale_order_line_production TYPE array<record<project_task>>;
DEFINE FIELD created_at ON sale_order_line_production TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sale_order_line_production TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sale_order_line_production TYPE int DEFAULT 0;

-- Détails des lignes de commande de vente
DEFINE TABLE sale_order_line_details SCHEMAFULL;
DEFINE FIELD sale_order_line ON sale_order_line_details TYPE record<sale_order_line>;
DEFINE FIELD sequence ON sale_order_line_details TYPE int;
DEFINE FIELD detail_type_select ON sale_order_line_details TYPE int;
DEFINE FIELD name ON sale_order_line_details TYPE string;
DEFINE FIELD description ON sale_order_line_details TYPE string;
DEFINE FIELD product ON sale_order_line_details TYPE record<product>;
DEFINE FIELD qty ON sale_order_line_details TYPE decimal;
DEFINE FIELD unit ON sale_order_line_details TYPE record<unit>;
DEFINE FIELD unit_price ON sale_order_line_details TYPE decimal;
DEFINE FIELD price_discounted ON sale_order_line_details TYPE decimal;
DEFINE FIELD tax_line ON sale_order_line_details TYPE record<tax_line>;
DEFINE FIELD ex_tax_total ON sale_order_line_details TYPE decimal;
DEFINE FIELD in_tax_total ON sale_order_line_details TYPE decimal;
DEFINE FIELD work_center ON sale_order_line_details TYPE record<work_center>;
DEFINE FIELD operation_order ON sale_order_line_details TYPE record<operation_order>;
DEFINE FIELD manuf_order ON sale_order_line_details TYPE record<manuf_order>;
DEFINE FIELD production_order ON sale_order_line_details TYPE record<production_order>;
DEFINE FIELD is_manufacturing_detail ON sale_order_line_details TYPE bool DEFAULT false;
DEFINE FIELD manufacturing_duration ON sale_order_line_details TYPE decimal;
DEFINE FIELD manufacturing_cost ON sale_order_line_details TYPE decimal;
DEFINE FIELD resource_type_select ON sale_order_line_details TYPE int;
DEFINE FIELD employee ON sale_order_line_details TYPE record<employee>;
DEFINE FIELD machine ON sale_order_line_details TYPE record<machine>;
DEFINE FIELD project_task ON sale_order_line_details TYPE record<project_task>;
DEFINE FIELD invoicing_project ON sale_order_line_details TYPE record<invoicing_project>;
DEFINE FIELD is_billable ON sale_order_line_details TYPE bool DEFAULT true;
DEFINE FIELD invoice_line ON sale_order_line_details TYPE record<invoice_line>;
DEFINE FIELD created_at ON sale_order_line_details TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sale_order_line_details TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sale_order_line_details TYPE int DEFAULT 0;



-- Index pour optimisation
DEFINE INDEX idx_invoicing_project_company ON invoicing_project FIELDS company;
DEFINE INDEX idx_invoicing_project_client_partner ON invoicing_project FIELDS client_partner;
DEFINE INDEX idx_invoicing_project_status ON invoicing_project FIELDS status_select;
DEFINE INDEX idx_invoicing_project_start_date ON invoicing_project FIELDS start_date;
DEFINE INDEX idx_invoicing_project_assigned_to ON invoicing_project FIELDS assigned_to;
DEFINE INDEX idx_invoicing_project_next_invoice_date ON invoicing_project FIELDS next_invoice_date;
DEFINE INDEX idx_invoicing_project_is_production ON invoicing_project FIELDS is_production_project;

DEFINE INDEX idx_sale_order_line_production_sale_order_line ON sale_order_line_production FIELDS sale_order_line;
DEFINE INDEX idx_sale_order_line_production_production_order ON sale_order_line_production FIELDS production_order;
DEFINE INDEX idx_sale_order_line_production_status ON sale_order_line_production FIELDS production_status_select;
DEFINE INDEX idx_sale_order_line_production_planned_date ON sale_order_line_production FIELDS planned_production_date;

DEFINE INDEX idx_sale_order_line_details_sale_order_line ON sale_order_line_details FIELDS sale_order_line;
DEFINE INDEX idx_sale_order_line_details_sequence ON sale_order_line_details FIELDS sequence;
DEFINE INDEX idx_sale_order_line_details_type ON sale_order_line_details FIELDS detail_type_select;
DEFINE INDEX idx_sale_order_line_details_work_center ON sale_order_line_details FIELDS work_center;
DEFINE INDEX idx_sale_order_line_details_production_order ON sale_order_line_details FIELDS production_order; 