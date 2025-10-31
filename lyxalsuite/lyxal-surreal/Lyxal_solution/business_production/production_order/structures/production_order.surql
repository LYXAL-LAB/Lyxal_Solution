-- Ordres de production
DEFINE TABLE production_order SCHEMAFULL;
DEFINE FIELD production_order_seq ON production_order TYPE string;
DEFINE FIELD name ON production_order TYPE string;
DEFINE FIELD company ON production_order TYPE record<company>;
DEFINE FIELD product ON production_order TYPE record<product>;
DEFINE FIELD qty ON production_order TYPE decimal;
DEFINE FIELD unit ON production_order TYPE record<unit>;
DEFINE FIELD planned_start_date_time ON production_order TYPE datetime;
DEFINE FIELD planned_end_date_time ON production_order TYPE datetime;
DEFINE FIELD real_start_date_time ON production_order TYPE datetime;
DEFINE FIELD real_end_date_time ON production_order TYPE datetime;
DEFINE FIELD status_select ON production_order TYPE int DEFAULT 1;
DEFINE FIELD priority_select ON production_order TYPE int DEFAULT 2;
DEFINE FIELD sale_order ON production_order TYPE record<sale_order>;
DEFINE FIELD sale_order_line ON production_order TYPE record<sale_order_line>;
DEFINE FIELD manuf_order_set ON production_order TYPE array<record<manuf_order>>;
DEFINE FIELD work_center ON production_order TYPE record<work_center>;
DEFINE FIELD produced_stock_move_line_list ON production_order TYPE array<record<stock_move_line>>;
DEFINE FIELD consumed_stock_move_line_list ON production_order TYPE array<record<stock_move_line>>;
DEFINE FIELD operation_order_list ON production_order TYPE array<record<operation_order>>;
DEFINE FIELD bill_of_material ON production_order TYPE record<bill_of_material>;
DEFINE FIELD routing ON production_order TYPE record<routing>;
DEFINE FIELD total_hours ON production_order TYPE decimal;
DEFINE FIELD machine_hours ON production_order TYPE decimal;
DEFINE FIELD human_hours ON production_order TYPE decimal;
DEFINE FIELD progress_percentage ON production_order TYPE decimal;
DEFINE FIELD waste_rate ON production_order TYPE decimal;
DEFINE FIELD note ON production_order TYPE string;
DEFINE FIELD created_at ON production_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON production_order TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON production_order TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_production_order_company ON production_order FIELDS company;
DEFINE INDEX idx_production_order_status ON production_order FIELDS status_select;
DEFINE INDEX idx_production_order_product ON production_order FIELDS product;
DEFINE INDEX idx_production_order_sale_order ON production_order FIELDS sale_order;
DEFINE INDEX idx_production_order_start_date ON production_order FIELDS planned_start_date_time;
DEFINE INDEX idx_production_order_seq ON production_order FIELDS production_order_seq;