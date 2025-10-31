DEFINE FUNCTION IF NOT EXISTS fn::base_approval_level_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_approval_level', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_approval_level TYPE NORMAL SCHEMAFULL
COMMENT 'Niveaux d\'approbation hiérarchiques et permissions'
PERMISSIONS FULL;

-- Champs principaux
DEFINE FIELD code ON base_approval_level TYPE string;
DEFINE FIELD name ON base_approval_level TYPE string;
DEFINE FIELD description ON base_approval_level TYPE option<string>;

-- Hiérarchie et priorité
DEFINE FIELD hierarchy_level ON base_approval_level TYPE int;
DEFINE FIELD parent_level_id ON base_approval_level TYPE option<record<base_approval_level>>;
DEFINE FIELD priority ON base_approval_level TYPE int;
DEFINE FIELD decision_weight ON base_approval_level TYPE int DEFAULT 1;

-- Limites et seuils
DEFINE FIELD max_approval_amount ON base_approval_level TYPE option<decimal>;
DEFINE FIELD currency_id ON base_approval_level TYPE option<record<base_currency>>;
DEFINE FIELD max_approval_percentage ON base_approval_level TYPE option<decimal>;
DEFINE FIELD max_daily_approvals ON base_approval_level TYPE option<int>;
DEFINE FIELD max_concurrent_approvals ON base_approval_level TYPE option<int>;

-- Permissions et droits
DEFINE FIELD can_approve_discounts ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD can_approve_pricing ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD can_approve_orders ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD can_approve_invoices ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD can_approve_payments ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD can_approve_users ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD can_delegate_approval ON base_approval_level TYPE bool DEFAULT false;

-- Workflow
DEFINE FIELD auto_approval ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD auto_approval_delay ON base_approval_level TYPE option<int>;
DEFINE FIELD requires_justification ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD requires_signature ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD notifications_enabled ON base_approval_level TYPE bool DEFAULT true;

-- Escalades
DEFINE FIELD escalation_delay ON base_approval_level TYPE option<int>;
DEFINE FIELD escalation_level_id ON base_approval_level TYPE option<record<base_approval_level>>;
DEFINE FIELD auto_escalation ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD max_escalations ON base_approval_level TYPE int DEFAULT 3;

-- Rôles & utilisateurs
DEFINE FIELD associated_roles ON base_approval_level TYPE array<string>;
DEFINE FIELD default_approvers ON base_approval_level TYPE array<string>;
DEFINE FIELD approval_group ON base_approval_level TYPE option<string>;
DEFINE FIELD approval_mode ON base_approval_level TYPE string DEFAULT 'SINGLE';

-- Config avancée / UI
DEFINE FIELD working_hours ON base_approval_level TYPE object;
DEFINE FIELD working_days ON base_approval_level TYPE array<string>;
DEFINE FIELD timezone ON base_approval_level TYPE option<string>;
DEFINE FIELD sla_config ON base_approval_level TYPE object;
DEFINE FIELD sequence ON base_approval_level TYPE int;
DEFINE FIELD color ON base_approval_level TYPE string DEFAULT '#007bff';
DEFINE FIELD icon ON base_approval_level TYPE string DEFAULT 'Shield';
DEFINE FIELD badge ON base_approval_level TYPE option<string>;

-- Etats / meta
DEFINE FIELD is_active ON base_approval_level TYPE bool DEFAULT true;
DEFINE FIELD is_system ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD is_default ON base_approval_level TYPE bool DEFAULT false;
DEFINE FIELD created_on ON base_approval_level TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON base_approval_level TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_base_approval_level_code ON base_approval_level FIELDS code UNIQUE;
DEFINE INDEX idx_base_approval_level_hierarchy ON base_approval_level FIELDS hierarchy_level;
DEFINE INDEX idx_base_approval_level_priority ON base_approval_level FIELDS priority;
DEFINE INDEX idx_base_approval_level_active ON base_approval_level FIELDS is_active;
DEFINE INDEX idx_base_approval_level_display ON base_approval_level FIELDS is_active, sequence;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_workflow' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_workflow introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_approval_level', $sm.id, 'Niveaux d\'approbation', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_approval_level_create_table_initialise', $sm.id, 'Crée la table base_approval_level', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_approval_level', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_approval_level (workflow approbations)'
PERMISSIONS FULL;

