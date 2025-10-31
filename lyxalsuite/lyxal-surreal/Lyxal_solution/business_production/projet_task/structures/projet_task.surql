-- ================================================================================
-- Table : project_task - Extension du module business-production
-- cf : project/project_task/structures/project_task.surql
-- ================================================================================

DEFINE FIELD production_order ON project_task TYPE record<production_order>;
DEFINE FIELD manuf_order ON project_task TYPE record<manuf_order>;
DEFINE FIELD operation_order ON project_task TYPE record<operation_order>;
DEFINE FIELD work_center ON project_task TYPE record<work_center>;

-- Index

DEFINE INDEX idx_project_task_production_order ON project_task FIELDS production_order;
DEFINE INDEX idx_project_task_manuf_order ON project_task FIELDS manuf_order;
DEFINE INDEX idx_project_task_operation_order ON project_task FIELDS operation_order;