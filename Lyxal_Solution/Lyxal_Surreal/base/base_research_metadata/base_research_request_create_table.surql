DEFINE FUNCTION IF NOT EXISTS fn::base_research_request_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_research_request', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_research_request TYPE NORMAL SCHEMAFULL
COMMENT 'Requêtes de recherche'
PERMISSIONS FULL;

DEFINE FIELD name ON base_research_request TYPE string;
DEFINE FIELD code ON base_research_request TYPE option<string>;
DEFINE FIELD metaModel ON base_research_request TYPE record<base_meta_model>;
DEFINE FIELD researchParameterList ON base_research_request TYPE array<record<base_research_parameter>>;
DEFINE FIELD researchResultLineList ON base_research_request TYPE array<record<base_research_result_line>>;

DEFINE FIELD created_at ON base_research_request TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_research_request TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_research_request_name ON base_research_request FIELDS name;
DEFINE INDEX idx_base_research_request_model ON base_research_request FIELDS metaModel;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_research_metadata' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_research_metadata introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_research_request', $sm.id, 'Requêtes de recherche', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_research_request_create_table_initialise', $sm.id, 'Crée la table base_research_request', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_research_request', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_research_request'
PERMISSIONS FULL;

