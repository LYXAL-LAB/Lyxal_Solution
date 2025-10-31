-- Tickets
DEFINE TABLE ticket SCHEMAFUL;
DEFINE FIELD ticketSeq ON ticket TYPE string;
DEFINE FIELD subject ON ticket TYPE string ASSERT $value != NULL;
DEFINE FIELD fullName ON ticket TYPE string;
DEFINE FIELD description ON ticket TYPE string;
DEFINE FIELD project ON ticket TYPE record<project>;
DEFINE FIELD customerPartner ON ticket TYPE record<partner>;
DEFINE FIELD contactPartner ON ticket TYPE record<partner>;
DEFINE FIELD assignedToUser ON ticket TYPE record<user>;
DEFINE FIELD responsibleUser ON ticket TYPE record<user>;
DEFINE FIELD ticketType ON ticket TYPE record<ticket_type>;
DEFINE FIELD slaPolicy ON ticket TYPE record<sla>;
DEFINE FIELD startDateT ON ticket TYPE datetime;
DEFINE FIELD endDateT ON ticket TYPE datetime;
DEFINE FIELD deadlineDateT ON ticket TYPE datetime;
DEFINE FIELD isSlaCompleted ON ticket TYPE bool DEFAULT false;
DEFINE FIELD prioritySelect ON ticket TYPE int DEFAULT 2;
DEFINE FIELD progressSelect ON ticket TYPE int;
DEFINE FIELD statusComment ON ticket TYPE string;
DEFINE FIELD tags ON ticket TYPE array;
DEFINE FIELD createdAt ON ticket TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON ticket TYPE datetime DEFAULT time::now();

-- SLA
DEFINE TABLE sla SCHEMAFUL;
DEFINE FIELD name ON sla TYPE string ASSERT $value != NULL;
DEFINE FIELD ticketType ON sla TYPE record<ticket_type>;
DEFINE FIELD reachStageTicketStatus ON sla TYPE record<ticket_status>;
DEFINE FIELD prioritySelect ON sla TYPE int DEFAULT 2;
DEFINE FIELD days ON sla TYPE int DEFAULT 0;
DEFINE FIELD hours ON sla TYPE int DEFAULT 0;
DEFINE FIELD isWorkingDays ON sla TYPE bool DEFAULT false;

-- Références
DEFINE TABLE ticket_type SCHEMAFUL;
DEFINE FIELD name ON ticket_type TYPE string ASSERT $value != NULL;

DEFINE TABLE ticket_status SCHEMAFUL;
DEFINE FIELD name ON ticket_status TYPE string ASSERT $value != NULL;
DEFINE FIELD sequence ON ticket_status TYPE int;
DEFINE FIELD priority ON ticket_status TYPE int;

-- Transitions (relation graphe)
DEFINE TABLE transitioned_to SCHEMAFUL TYPE RELATION;
DEFINE FIELD in ON transitioned_to TYPE record<ticket> ASSERT $value != NULL;
DEFINE FIELD out ON transitioned_to TYPE record<ticket_status> ASSERT $value != NULL;
DEFINE FIELD changedBy ON transitioned_to TYPE record<user>;
DEFINE FIELD changedAt ON transitioned_to TYPE datetime DEFAULT time::now();
DEFINE FIELD comment ON transitioned_to TYPE string;

-- Attribution
DEFINE TABLE assigned_to SCHEMAFUL TYPE RELATION;
DEFINE FIELD in ON assigned_to TYPE record<ticket> ASSERT $value != NULL;
DEFINE FIELD out ON assigned_to TYPE record<user> ASSERT $value != NULL;
DEFINE FIELD assignedAt ON assigned_to TYPE datetime DEFAULT time::now();

-- Suggestions IA (future intégration)
DEFINE TABLE agent_suggestion SCHEMAFUL;
DEFINE FIELD ticket ON agent_suggestion TYPE record<ticket>;
DEFINE FIELD suggestionType ON agent_suggestion TYPE string; -- ex: 'next_status', 'assign_user'
DEFINE FIELD content ON agent_suggestion TYPE string;
DEFINE FIELD score ON agent_suggestion TYPE float;
DEFINE FIELD suggestedAt ON agent_suggestion TYPE datetime DEFAULT time::now();

-- KPI consolidé
DEFINE TABLE ticket_kpi SCHEMAFUL;
DEFINE FIELD ticket ON ticket_kpi TYPE record<ticket>;
DEFINE FIELD totalTransitions ON ticket_kpi TYPE int;
DEFINE FIELD resolutionTimeHours ON ticket_kpi TYPE float;
DEFINE FIELD slaMet ON ticket_kpi TYPE bool;
DEFINE FIELD updatedAt ON ticket_kpi TYPE datetime DEFAULT time::now();