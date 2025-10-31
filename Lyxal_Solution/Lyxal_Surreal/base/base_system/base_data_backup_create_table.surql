DEFINE FUNCTION IF NOT EXISTS fn::base_data_backup_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_data_backup', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_data_backup TYPE NORMAL SCHEMAFULL
  COMMENT 'DataBackup (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD backupMetaFile ON base_data_backup TYPE option<record<base_meta_file>>;
  DEFINE FIELD statusSelect ON base_data_backup TYPE int DEFAULT 0;
  DEFINE FIELD logMetaFile ON base_data_backup TYPE option<record<base_meta_file>>;
  DEFINE FIELD backupDate ON base_data_backup TYPE option<datetime>;
  DEFINE FIELD restoreDate ON base_data_backup TYPE option<datetime>;
  DEFINE FIELD fetchLimit ON base_data_backup TYPE option<int>;
  DEFINE FIELD isRelativeDate ON base_data_backup TYPE option<bool>;
  DEFINE FIELD updateImportId ON base_data_backup TYPE option<bool>;
  DEFINE FIELD checkAllErrorFirst ON base_data_backup TYPE option<bool>;
  DEFINE FIELD isProcessEmptyTable ON base_data_backup TYPE option<bool>;
  DEFINE FIELD anonymizer ON base_data_backup TYPE option<record<base_anonymizer>>;

  DEFINE FIELD created_at ON base_data_backup TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_data_backup TYPE datetime DEFAULT time::now();

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_data_backup', $sm.id, 'Sauvegarde des données (Axelor)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_data_backup_create_table_initialise', $sm.id, 'Crée la table base_data_backup', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_data_backup', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_data_backup'
PERMISSIONS FULL;

