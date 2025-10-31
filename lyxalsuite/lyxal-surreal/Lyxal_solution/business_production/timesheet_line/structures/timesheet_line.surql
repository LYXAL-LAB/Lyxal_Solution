-- Lignes de timesheet

DEFINE TABLE timesheet_line SCHEMAFULL;
DEFINE FIELD date ON timesheet_line TYPE date;
DEFINE FIELD user ON timesheet_line TYPE record<user>;
DEFINE FIELD employee ON timesheet_line TYPE record<employee>;
DEFINE FIELD timesheet ON timesheet_line TYPE record<timesheet>;
DEFINE FIELD project ON timesheet_line TYPE record<project>;
DEFINE FIELD project_task ON timesheet_line TYPE record<project_task>;
DEFINE FIELD product ON timesheet_line TYPE record<product>;
DEFINE FIELD duration ON timesheet_line TYPE decimal;
DEFINE FIELD hours_duration ON timesheet_line TYPE decimal;
DEFINE FIELD comments ON timesheet_line TYPE string;
DEFINE FIELD hourly_rate ON timesheet_line TYPE decimal;
DEFINE FIELD total_amount ON timesheet_line TYPE decimal;
DEFINE FIELD currency ON timesheet_line TYPE record<currency>;
DEFINE FIELD invoiced ON timesheet_line TYPE bool DEFAULT false;
DEFINE FIELD to_invoice ON timesheet_line TYPE bool DEFAULT true;
DEFINE FIELD invoice_line ON timesheet_line TYPE record<invoice_line>;
DEFINE FIELD production_order ON timesheet_line TYPE record<production_order>;
DEFINE FIELD manuf_order ON timesheet_line TYPE record<manuf_order>;
DEFINE FIELD operation_order ON timesheet_line TYPE record<operation_order>;
DEFINE FIELD work_center ON timesheet_line TYPE record<work_center>;
DEFINE FIELD machine ON timesheet_line TYPE record<machine>;
DEFINE FIELD activity_type_select ON timesheet_line TYPE int DEFAULT 1;
DEFINE FIELD is_production_activity ON timesheet_line TYPE bool DEFAULT false;
DEFINE FIELD efficiency_rate ON timesheet_line TYPE decimal DEFAULT 100.0;
DEFINE FIELD quality_score ON timesheet_line TYPE decimal;
DEFINE FIELD defect_rate ON timesheet_line TYPE decimal;
DEFINE FIELD produced_qty ON timesheet_line TYPE decimal;
DEFINE FIELD created_at ON timesheet_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON timesheet_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON timesheet_line TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_timesheet_line_date ON timesheet_line FIELDS date;
DEFINE INDEX idx_timesheet_line_user ON timesheet_line FIELDS user;
DEFINE INDEX idx_timesheet_line_employee ON timesheet_line FIELDS employee;
DEFINE INDEX idx_timesheet_line_project ON timesheet_line FIELDS project;
DEFINE INDEX idx_timesheet_line_project_task ON timesheet_line FIELDS project_task;
DEFINE INDEX idx_timesheet_line_production_order ON timesheet_line FIELDS production_order;
DEFINE INDEX idx_timesheet_line_manuf_order ON timesheet_line FIELDS manuf_order;
DEFINE INDEX idx_timesheet_line_operation_order ON timesheet_line FIELDS operation_order;
DEFINE INDEX idx_timesheet_line_work_center ON timesheet_line FIELDS work_center;
DEFINE INDEX idx_timesheet_line_invoiced ON timesheet_line FIELDS invoiced;
DEFINE INDEX idx_timesheet_line_to_invoice ON timesheet_line FIELDS to_invoice; 