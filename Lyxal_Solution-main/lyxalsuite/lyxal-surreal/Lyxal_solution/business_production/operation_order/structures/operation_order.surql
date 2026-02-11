-- Ordres d'opération
DEFINE TABLE operation_order SCHEMAFULL;
DEFINE FIELD name ON operation_order TYPE string;
DEFINE FIELD operation_name ON operation_order TYPE string;
DEFINE FIELD priority ON operation_order TYPE int DEFAULT 0;
DEFINE FIELD sequence ON operation_order TYPE int;
DEFINE FIELD production_order ON operation_order TYPE record<production_order>;
DEFINE FIELD manuf_order ON operation_order TYPE record<manuf_order>;
DEFINE FIELD work_center ON operation_order TYPE record<work_center>;
DEFINE FIELD machine ON operation_order TYPE record<machine>;
DEFINE FIELD planned_start_date_time ON operation_order TYPE datetime;
DEFINE FIELD planned_end_date_time ON operation_order TYPE datetime;
DEFINE FIELD real_start_date_time ON operation_order TYPE datetime;
DEFINE FIELD real_end_date_time ON operation_order TYPE datetime;
DEFINE FIELD planned_duration ON operation_order TYPE int;
DEFINE FIELD real_duration ON operation_order TYPE int;
DEFINE FIELD status_select ON operation_order TYPE int DEFAULT 1;
DEFINE FIELD machine_work_center ON operation_order TYPE record<work_center>;
DEFINE FIELD setup_duration ON operation_order TYPE int;
DEFINE FIELD processing_duration ON operation_order TYPE int;
DEFINE FIELD teardown_duration ON operation_order TYPE int;
DEFINE FIELD qty ON operation_order TYPE decimal;
DEFINE FIELD progress_percentage ON operation_order TYPE decimal;
DEFINE FIELD timesheet_line_list ON operation_order TYPE array<record<timesheet_line>>;
DEFINE FIELD description ON operation_order TYPE string;
DEFINE FIELD created_at ON operation_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON operation_order TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON operation_order TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_operation_order_production_order ON operation_order FIELDS production_order;
DEFINE INDEX idx_operation_order_manuf_order ON operation_order FIELDS manuf_order;
DEFINE INDEX idx_operation_order_work_center ON operation_order FIELDS work_center;
DEFINE INDEX idx_operation_order_status ON operation_order FIELDS status_select;
DEFINE INDEX idx_operation_order_sequence ON operation_order FIELDS sequence;
DEFINE INDEX idx_operation_order_start_date ON operation_order FIELDS planned_start_date_time;