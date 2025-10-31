DEFINE FUNCTION IF NOT EXISTS fn::base_routing_create_tables_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création des tables base_routing*', { run_id: $run_id, parent_run_id: $parent_run_id });

-- routing
DEFINE TABLE IF NOT EXISTS base_routing TYPE NORMAL SCHEMAFULL
COMMENT 'Routage'
PERMISSIONS FULL;
DEFINE FIELD name ON base_routing TYPE string;
DEFINE FIELD routingActionList ON base_routing TYPE array<record<base_routing_action>>;
DEFINE FIELD created_at ON base_routing TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_routing TYPE datetime DEFAULT time::now();
DEFINE INDEX idx_base_routing_name ON base_routing FIELDS name;

-- routing_action
DEFINE TABLE IF NOT EXISTS base_routing_action TYPE NORMAL SCHEMAFULL
COMMENT 'Actions de routage'
PERMISSIONS FULL;
DEFINE FIELD routing ON base_routing_action TYPE record<base_routing>;
DEFINE FIELD name ON base_routing_action TYPE string;
DEFINE FIELD routingActionCreateList ON base_routing_action TYPE array<record<base_routing_action_create>>;
DEFINE FIELD created_at ON base_routing_action TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_routing_action TYPE datetime DEFAULT time::now();
DEFINE INDEX idx_base_routing_action_routing ON base_routing_action FIELDS routing;

-- routing_action_create
DEFINE TABLE IF NOT EXISTS base_routing_action_create TYPE NORMAL SCHEMAFULL
COMMENT 'Création d\'actions de routage'
PERMISSIONS FULL;
DEFINE FIELD routingAction ON base_routing_action_create TYPE record<base_routing_action>;
DEFINE FIELD metaModel ON base_routing_action_create TYPE record<base_meta_model>;
DEFINE FIELD created_at ON base_routing_action_create TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_routing_action_create TYPE datetime DEFAULT time::now();
DEFINE INDEX idx_base_routing_action_create_action ON base_routing_action_create FIELDS routingAction;

-- routing_action_create_line
DEFINE TABLE IF NOT EXISTS base_routing_action_create_line TYPE NORMAL SCHEMAFULL
COMMENT 'Lignes de création d\'actions de routage'
PERMISSIONS FULL;
DEFINE FIELD routingActionCreate ON base_routing_action_create_line TYPE record<base_routing_action_create>;
DEFINE FIELD metaField ON base_routing_action_create_line TYPE record<base_meta_field>;
DEFINE FIELD value ON base_routing_action_create_line TYPE option<string>;
DEFINE FIELD created_at ON base_routing_action_create_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_routing_action_create_line TYPE datetime DEFAULT time::now();
DEFINE INDEX idx_base_routing_action_create_line_create ON base_routing_action_create_line FIELDS routingActionCreate;

-- routing_rule
DEFINE TABLE IF NOT EXISTS base_routing_rule TYPE NORMAL SCHEMAFULL
COMMENT 'Règles de routage'
PERMISSIONS FULL;
DEFINE FIELD name ON base_routing_rule TYPE string;
DEFINE FIELD routing ON base_routing_rule TYPE record<base_routing>;
DEFINE FIELD sequence ON base_routing_rule TYPE option<int>;
DEFINE FIELD created_at ON base_routing_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_routing_rule TYPE datetime DEFAULT time::now();
DEFINE INDEX idx_base_routing_rule_routing ON base_routing_rule FIELDS routing;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_workflow' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_workflow introuvable' }; };
LET $t1 = fn::builder_table_create_record('base_routing', $sm.id, 'Routage', true, true, true, $phase, ['module_base'], $run_id);
LET $t2 = fn::builder_table_create_record('base_routing_action', $sm.id, 'Action de routage', true, true, true, $phase, ['module_base'], $run_id);
LET $t3 = fn::builder_table_create_record('base_routing_action_create', $sm.id, 'Création action de routage', true, true, true, $phase, ['module_base'], $run_id);
LET $t4 = fn::builder_table_create_record('base_routing_action_create_line', $sm.id, 'Ligne création action de routage', true, true, true, $phase, ['module_base'], $run_id);
LET $t5 = fn::builder_table_create_record('base_routing_rule', $sm.id, 'Règle de routage', true, true, true, $phase, ['module_base'], $run_id);

LET $f_rec = fn::builder_function_create_record('base_routing_create_tables_initialise', $sm.id, 'Crée les tables de routage', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création des tables base_routing*', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée les tables de routage (base_routing*)'
PERMISSIONS FULL;

