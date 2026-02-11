-- Ordres de fabrication
DEFINE TABLE manuf_order SCHEMAFULL;
DEFINE FIELD manuf_order_seq ON manuf_order TYPE string;
DEFINE FIELD name ON manuf_order TYPE string;
DEFINE FIELD company ON manuf_order TYPE record<company>;
DEFINE FIELD product ON manuf_order TYPE record<product>;
DEFINE FIELD qty ON manuf_order TYPE decimal;
DEFINE FIELD unit ON manuf_order TYPE record<unit>;
DEFINE FIELD planned_start_date_time ON manuf_order TYPE datetime;
DEFINE FIELD planned_end_date_time ON manuf_order TYPE datetime;
DEFINE FIELD real_start_date_time ON manuf_order TYPE datetime;
DEFINE FIELD real_end_date_time ON manuf_order TYPE datetime;
DEFINE FIELD status_select ON manuf_order TYPE int DEFAULT 1;
DEFINE FIELD priority_select ON manuf_order TYPE int DEFAULT 2;
DEFINE FIELD production_order ON manuf_order TYPE record<production_order>;
DEFINE FIELD sale_order ON manuf_order TYPE record<sale_order>;
DEFINE FIELD sale_order_line ON manuf_order TYPE record<sale_order_line>;
DEFINE FIELD bill_of_material ON manuf_order TYPE record<bill_of_material>;
DEFINE FIELD routing ON manuf_order TYPE record<routing>;
DEFINE FIELD work_center ON manuf_order TYPE record<work_center>;
DEFINE FIELD operation_order_list ON manuf_order TYPE array<record<operation_order>>;
DEFINE FIELD to_consume_product_list ON manuf_order TYPE array<record<product>>;
DEFINE FIELD to_produce_product_list ON manuf_order TYPE array<record<product>>;
DEFINE FIELD consumed_stock_move_line_list ON manuf_order TYPE array<record<stock_move_line>>;
DEFINE FIELD produced_stock_move_line_list ON manuf_order TYPE array<record<stock_move_line>>;
DEFINE FIELD waste_stock_move_line_list ON manuf_order TYPE array<record<stock_move_line>>;
DEFINE FIELD machine_hours ON manuf_order TYPE decimal;
DEFINE FIELD human_hours ON manuf_order TYPE decimal;
DEFINE FIELD progress_percentage ON manuf_order TYPE decimal;
DEFINE FIELD waste_rate ON manuf_order TYPE decimal;
DEFINE FIELD cost_amount ON manuf_order TYPE decimal;
DEFINE FIELD note ON manuf_order TYPE string;
DEFINE FIELD created_at ON manuf_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON manuf_order TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON manuf_order TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_manuf_order_company ON manuf_order FIELDS company;
DEFINE INDEX idx_manuf_order_status ON manuf_order FIELDS status_select;
DEFINE INDEX idx_manuf_order_product ON manuf_order FIELDS product;
DEFINE INDEX idx_manuf_order_production_order ON manuf_order FIELDS production_order;
DEFINE INDEX idx_manuf_order_start_date ON manuf_order FIELDS planned_start_date_time;
DEFINE INDEX idx_manuf_order_seq ON manuf_order FIELDS manuf_order_seq;