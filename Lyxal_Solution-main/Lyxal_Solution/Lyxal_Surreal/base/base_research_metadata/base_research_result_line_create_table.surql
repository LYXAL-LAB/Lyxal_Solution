DEFINE FUNCTION IF NOT EXISTS fn::base_research_result_line_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_research_result_line', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_research_result_line TYPE NORMAL SCHEMAFULL
COMMENT 'Lignes de résultats de recherche'
PERMISSIONS FULL;

DEFINE FIELD researchRequest ON base_research_result_line TYPE record<base_research_request>;
DEFINE FIELD metaField ON base_research_result_line TYPE record<base_meta_field>;
DEFINE FIELD value ON base_research_result_line TYPE option<string>;

DEFINE FIELD created_at ON base_research_result_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_research_result_line TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_research_result_line_request ON base_research_result_line FIELDS researchRequest;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_research_metadata' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_research_metadata introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_research_result_line', $sm.id, 'Lignes de résultats', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_research_result_line_create_table_initialise', $sm.id, 'Crée la table base_research_result_line', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_research_result_line', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_research_result_line'
PERMISSIONS FULL;

