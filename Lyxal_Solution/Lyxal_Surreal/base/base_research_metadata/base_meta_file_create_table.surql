DEFINE FUNCTION IF NOT EXISTS fn::base_meta_file_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_meta_file', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_metafile TYPE NORMAL SCHEMAFULL
COMMENT 'Fichiers métadonnées'
PERMISSIONS FULL;

DEFINE FIELD fileName ON base_meta_file TYPE string;
DEFINE FIELD filePath ON base_meta_file TYPE option<string>;
DEFINE FIELD fileSize ON base_meta_file TYPE option<int>;
DEFINE FIELD fileType ON base_meta_file TYPE option<string>;

DEFINE FIELD created_at ON base_meta_file TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_meta_file TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_meta_file_name ON base_meta_file FIELDS fileName;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_research_metadata' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_research_metadata introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_meta_file', $sm.id, 'Fichiers métadonnées', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_meta_file_create_table_initialise', $sm.id, 'Crée la table base_meta_file', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_meta_file', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_meta_file'
PERMISSIONS FULL;

