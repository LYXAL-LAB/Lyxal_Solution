DEFINE FUNCTION IF NOT EXISTS fn::base_advanced_export_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_advanced_export', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_advanced_export TYPE NORMAL SCHEMAFULL
  COMMENT 'AdvancedExport (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD name ON base_advanced_export TYPE option<string>;
  DEFINE FIELD metaModel ON base_advanced_export TYPE record<base_meta_model>;
  DEFINE FIELD advancedExportLineList ON base_advanced_export TYPE array<record<base_advanced_export_line>>;
  DEFINE FIELD maxExportLimit ON base_advanced_export TYPE int DEFAULT 1000;
  DEFINE FIELD queryFetchSize ON base_advanced_export TYPE int DEFAULT 100;
  DEFINE FIELD includeArchivedRecords ON base_advanced_export TYPE bool DEFAULT false;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_data_sharing' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_data_sharing introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_advanced_export', $sm.id, 'Advanced Export', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_advanced_export_create_table_initialise', $sm.id, 'Crée la table base_advanced_export (Axelor)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_advanced_export', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_advanced_export (copie Axelor)'
PERMISSIONS FULL;

