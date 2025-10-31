DEFINE FUNCTION IF NOT EXISTS fn::base_canton_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_canton', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_canton TYPE NORMAL SCHEMAFULL
COMMENT 'Cantons / subdivisions'
PERMISSIONS FULL;

DEFINE FIELD name ON base_canton TYPE string;
DEFINE FIELD code ON base_canton TYPE option<string>;
DEFINE FIELD country ON base_canton TYPE record<base_country>;
DEFINE FIELD region ON base_canton TYPE option<record<base_region>>;
DEFINE FIELD is_active ON base_canton TYPE bool DEFAULT true;
DEFINE FIELD created_at ON base_canton TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_canton TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_canton_code ON base_canton FIELDS code;
DEFINE INDEX idx_base_canton_country ON base_canton FIELDS country;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_canton', $sm.id, 'Cantons / subdivisions', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
LET $f_rec = fn::builder_function_create_record('base_canton_create_table_initialise', $sm.id, 'Crée la table base_canton', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_canton', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_canton'
PERMISSIONS FULL;

