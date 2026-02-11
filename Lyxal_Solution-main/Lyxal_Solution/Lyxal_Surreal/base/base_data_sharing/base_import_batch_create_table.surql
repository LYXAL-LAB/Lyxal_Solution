DEFINE FUNCTION IF NOT EXISTS fn::base_import_batch_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_import_batch', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_import_batch TYPE NORMAL SCHEMAFULL
  COMMENT 'ImportBatch (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD code ON base_import_batch TYPE string;
  DEFINE FIELD actionSelect ON base_import_batch TYPE int;
  DEFINE FIELD batchList ON base_import_batch TYPE array<record<base_batch>> DEFAULT [];
  DEFINE FIELD company ON base_import_batch TYPE option<record<base_company>>;
  DEFINE FIELD description ON base_import_batch TYPE option<string>;

  DEFINE FIELD importConfig ON base_import_batch TYPE option<record<base_import_configuration>>;
  DEFINE FIELD advancedImport ON base_import_batch TYPE option<record<base_advanced_import>>;
  DEFINE FIELD importFromConnector ON base_import_batch TYPE option<bool>;
  DEFINE FIELD fileSourceConnectorParameters ON base_import_batch TYPE option<record<base_file_source_connector_parameters>>;
  DEFINE FIELD dataFileName ON base_import_batch TYPE option<string>;

  DEFINE FIELD created_at ON base_import_batch TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_import_batch TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_import_batch_code ON base_import_batch FIELDS code UNIQUE;
  DEFINE INDEX idx_base_import_batch_company ON base_import_batch FIELDS company;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_data_sharing' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_data_sharing introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_import_batch', $sm.id, 'ImportBatch (Axelor)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_import_batch_create_table_initialise', $sm.id, 'Crée la table base_import_batch', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_import_batch', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_import_batch'
PERMISSIONS FULL;

