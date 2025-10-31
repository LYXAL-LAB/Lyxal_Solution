-- Machines de production
DEFINE TABLE machine SCHEMAFULL;
DEFINE FIELD name ON machine TYPE string;
DEFINE FIELD code ON machine TYPE string;
DEFINE FIELD machine_type_select ON machine TYPE int;
DEFINE FIELD work_center ON machine TYPE record<work_center>;
DEFINE FIELD capacity_per_hour ON machine TYPE decimal;
DEFINE FIELD cost_per_hour ON machine TYPE decimal;
DEFINE FIELD efficiency_rate ON machine TYPE decimal DEFAULT 100.0;
DEFINE FIELD availability_rate ON machine TYPE decimal DEFAULT 100.0;
DEFINE FIELD operation_order_list ON machine TYPE array<record<operation_order>>;
DEFINE FIELD is_active ON machine TYPE bool DEFAULT true;
DEFINE FIELD description ON machine TYPE string;
DEFINE FIELD created_at ON machine TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON machine TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON machine TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_machine_work_center ON machine FIELDS work_center;
DEFINE INDEX idx_machine_code ON machine FIELDS code;
DEFINE INDEX idx_machine_type ON machine FIELDS machine_type_select;
DEFINE INDEX idx_machine_active ON machine FIELDS is_active;