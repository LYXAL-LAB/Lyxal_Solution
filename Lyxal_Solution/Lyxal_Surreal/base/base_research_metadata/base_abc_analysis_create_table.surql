DEFINE FUNCTION IF NOT EXISTS fn::base_abc_analysis_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_abc_analysis', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_abc_analysis TYPE NORMAL SCHEMAFULL
COMMENT 'Analyse ABC principale'
PERMISSIONS FULL;

DEFINE FIELD name ON base_abc_analysis TYPE string;
DEFINE FIELD abc_analysis_seq ON base_abc_analysis TYPE string;
DEFINE FIELD description ON base_abc_analysis TYPE string;
DEFINE FIELD type_select ON base_abc_analysis TYPE string;
DEFINE FIELD status_select ON base_abc_analysis TYPE int DEFAULT 1;
DEFINE FIELD company ON base_abc_analysis TYPE record<base_company>;
DEFINE FIELD abc_analysis_class_list ON base_abc_analysis TYPE array<record<base_abc_analysis_class>>;
DEFINE FIELD product_set ON base_abc_analysis TYPE array<record<base_product>>;
DEFINE FIELD product_category_set ON base_abc_analysis TYPE array<record<base_product_category>>;
DEFINE FIELD product_family_set ON base_abc_analysis TYPE array<record<base_product_family>>;
DEFINE FIELD created_at ON base_abc_analysis TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_abc_analysis TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON base_abc_analysis TYPE int DEFAULT 0;

DEFINE INDEX idx_base_abc_analysis_name ON base_abc_analysis FIELDS name;
DEFINE INDEX idx_base_abc_analysis_company ON base_abc_analysis FIELDS company;
DEFINE INDEX idx_base_abc_analysis_status ON base_abc_analysis FIELDS status_select;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_research_metadata' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_research_metadata introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_abc_analysis', $sm.id, 'Analyse ABC principale', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_abc_analysis_create_table_initialise', $sm.id, 'Crée la table base_abc_analysis', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_abc_analysis', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_abc_analysis'
PERMISSIONS FULL;

