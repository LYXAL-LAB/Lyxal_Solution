-- Extension Employee pour business production
DEFINE TABLE employee_business_production SCHEMAFULL;
DEFINE FIELD employee ON employee_business_production TYPE record<employee>;
DEFINE FIELD work_center_list ON employee_business_production TYPE array<record<work_center>>;
DEFINE FIELD default_work_center ON employee_business_production TYPE record<work_center>;
DEFINE FIELD production_capacity_per_hour ON employee_business_production TYPE decimal;
DEFINE FIELD production_cost_per_hour ON employee_business_production TYPE decimal;
DEFINE FIELD manufacturing_skill_level ON employee_business_production TYPE int DEFAULT 1;
DEFINE FIELD can_operate_machines ON employee_business_production TYPE bool DEFAULT false;
DEFINE FIELD machine_certifications ON employee_business_production TYPE array<string>;
DEFINE FIELD production_efficiency_rate ON employee_business_production TYPE decimal DEFAULT 100.0;
DEFINE FIELD is_production_supervisor ON employee_business_production TYPE bool DEFAULT false;
DEFINE FIELD supervised_work_centers ON employee_business_production TYPE array<record<work_center>>;
DEFINE FIELD created_at ON employee_business_production TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON employee_business_production TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON employee_business_production TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_employee_business_production_employee ON employee_business_production FIELDS employee;
DEFINE INDEX idx_employee_business_production_work_center ON employee_business_production FIELDS default_work_center;
DEFINE INDEX idx_employee_business_production_supervisor ON employee_business_production FIELDS is_production_supervisor;