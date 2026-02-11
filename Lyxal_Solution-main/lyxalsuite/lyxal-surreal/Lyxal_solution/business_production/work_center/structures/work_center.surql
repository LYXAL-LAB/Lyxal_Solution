-- Centres de travail
DEFINE TABLE work_center SCHEMAFULL;
DEFINE FIELD name ON work_center TYPE string;
DEFINE FIELD code ON work_center TYPE string;
DEFINE FIELD company ON work_center TYPE record<company>;
DEFINE FIELD work_center_type_select ON work_center TYPE int;
DEFINE FIELD capacity_per_hour ON work_center TYPE decimal;
DEFINE FIELD cost_amount ON work_center TYPE decimal;
DEFINE FIELD cost_type_select ON work_center TYPE int;
DEFINE FIELD machine_list ON work_center TYPE array<record<machine>>;
DEFINE FIELD employee_list ON work_center TYPE array<record<employee>>;
DEFINE FIELD is_machine ON work_center TYPE bool DEFAULT false;
DEFINE FIELD is_human ON work_center TYPE bool DEFAULT true;
DEFINE FIELD department ON work_center TYPE record<department>;
DEFINE FIELD stock_location ON work_center TYPE record<stock_location>;
DEFINE FIELD min_capacity_per_cycle ON work_center TYPE decimal;
DEFINE FIELD max_capacity_per_cycle ON work_center TYPE decimal;
DEFINE FIELD setup_time ON work_center TYPE int;
DEFINE FIELD teardown_time ON work_center TYPE int;
DEFINE FIELD efficiency_rate ON work_center TYPE decimal DEFAULT 100.0;
DEFINE FIELD availability_rate ON work_center TYPE decimal DEFAULT 100.0;
DEFINE FIELD operation_order_list ON work_center TYPE array<record<operation_order>>;
DEFINE FIELD description ON work_center TYPE string;
DEFINE FIELD is_active ON work_center TYPE bool DEFAULT true;
DEFINE FIELD created_at ON work_center TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON work_center TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON work_center TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_work_center_company ON work_center FIELDS company;
DEFINE INDEX idx_work_center_code ON work_center FIELDS code;
DEFINE INDEX idx_work_center_type ON work_center FIELDS work_center_type_select;
DEFINE INDEX idx_work_center_active ON work_center FIELDS is_active;
DEFINE INDEX idx_work_center_department ON work_center FIELDS department;