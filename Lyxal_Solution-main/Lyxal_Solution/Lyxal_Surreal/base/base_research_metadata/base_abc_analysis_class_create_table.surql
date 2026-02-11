DEFINE FUNCTION IF NOT EXISTS fn::base_abc_analysis_class_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_abc_analysis_class', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_abc_analysis_class TYPE NORMAL SCHEMAFULL
COMMENT 'Classes d\'analyse ABC'
PERMISSIONS FULL;

DEFINE FIELD name ON base_abc_analysis_class TYPE string;
DEFINE FIELD code ON base_abc_analysis_class TYPE string;
DEFINE FIELD abc_analysis ON base_abc_analysis_class TYPE record<base_abc_analysis>;
DEFINE FIELD abc_analysis_line_list ON base_abc_analysis_class TYPE array<record<base_abc_analysis_line>>;
DEFINE FIELD threshold_percent ON base_abc_analysis_class TYPE decimal;
DEFINE FIELD created_at ON base_abc_analysis_class TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_abc_analysis_class TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON base_abc_analysis_class TYPE int DEFAULT 0;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_research_metadata' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_research_metadata introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_abc_analysis_class', $sm.id, 'Classe d\'analyse ABC', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_abc_analysis_class_create_table_initialise', $sm.id, 'Crée la table base_abc_analysis_class', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_abc_analysis_class', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_abc_analysis_class'
PERMISSIONS FULL;

