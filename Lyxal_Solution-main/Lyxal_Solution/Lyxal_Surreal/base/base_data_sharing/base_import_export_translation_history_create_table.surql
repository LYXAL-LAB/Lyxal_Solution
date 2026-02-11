DEFINE FUNCTION IF NOT EXISTS fn::base_import_export_translation_history_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_import_export_translation_history', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_import_export_translation_history TYPE NORMAL SCHEMAFULL
  COMMENT 'ImportExportTranslationHistory (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD actionType ON base_import_export_translation_history TYPE option<string>;
  DEFINE FIELD recordNumber ON base_import_export_translation_history TYPE option<int>;
  DEFINE FIELD errorNumber ON base_import_export_translation_history TYPE option<int>;
  DEFINE FIELD importExportTranslation ON base_import_export_translation_history TYPE option<record<base_import_export_translation>>;

  DEFINE FIELD created_at ON base_import_export_translation_history TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_import_export_translation_history TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_import_export_translation_history_tr ON base_import_export_translation_history FIELDS importExportTranslation;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_data_sharing' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_data_sharing introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_import_export_translation_history', $sm.id, 'Historique import/export translation (Axelor)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_import_export_translation_history_create_table_initialise', $sm.id, 'Crée la table base_import_export_translation_history', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_import_export_translation_history', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_import_export_translation_history'
PERMISSIONS FULL;

