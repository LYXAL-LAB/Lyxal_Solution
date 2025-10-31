DEFINE FUNCTION IF NOT EXISTS fn::base_sequence_version_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_sequence_version', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_sequence_version TYPE NORMAL SCHEMAFULL
COMMENT 'Versions de séquences'
PERMISSIONS FULL;

DEFINE FIELD sequence ON base_sequence_version TYPE record<base_sequence>;
DEFINE FIELD startDate ON base_sequence_version TYPE datetime;
DEFINE FIELD endDate ON base_sequence_version TYPE option<datetime>;
DEFINE FIELD nextNum ON base_sequence_version TYPE int DEFAULT 1;

DEFINE FIELD created_at ON base_sequence_version TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_sequence_version TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_sequence_version_sequence ON base_sequence_version FIELDS sequence;
DEFINE INDEX idx_base_sequence_version_dates ON base_sequence_version FIELDS startDate, endDate;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_workflow' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_workflow introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_sequence_version', $sm.id, 'Versions de séquences', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_sequence_version_create_table_initialise', $sm.id, 'Crée la table base_sequence_version', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_sequence_version', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_sequence_version'
PERMISSIONS FULL;

