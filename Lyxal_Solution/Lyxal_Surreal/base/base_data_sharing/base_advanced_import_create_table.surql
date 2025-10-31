DEFINE FUNCTION IF NOT EXISTS fn::base_advanced_import_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_advanced_import', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_advanced_import TYPE NORMAL SCHEMAFULL
  COMMENT 'AdvancedImport (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD name ON base_advanced_import TYPE option<string>;
  DEFINE FIELD statusSelect ON base_advanced_import TYPE option<int>;
  DEFINE FIELD fileSeparator ON base_advanced_import TYPE string DEFAULT ';';
  DEFINE FIELD importFile ON base_advanced_import TYPE option<record<base_metafile>>;
  DEFINE FIELD attachment ON base_advanced_import TYPE option<record<base_metafile>>;
  DEFINE FIELD isConfigInFile ON base_advanced_import TYPE bool DEFAULT false;
  DEFINE FIELD isFileTabConfigAdded ON base_advanced_import TYPE bool DEFAULT false;
  DEFINE FIELD isHeader ON base_advanced_import TYPE bool DEFAULT true;
  DEFINE FIELD isValidateValue ON base_advanced_import TYPE bool DEFAULT false;
  DEFINE FIELD nbOfFirstLineIgnore ON base_advanced_import TYPE int DEFAULT 0;
  DEFINE FIELD fileTabList ON base_advanced_import TYPE array<record<base_file_tab>>;
  DEFINE FIELD importHistoryList ON base_advanced_import TYPE array<record<base_import_history>>;
  DEFINE FIELD errorLog ON base_advanced_import TYPE option<record<base_metafile>>;
  DEFINE FIELD languageSelect ON base_advanced_import TYPE option<string>;
  DEFINE FIELD fileExtension ON base_advanced_import TYPE option<string>;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_data_sharing' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_data_sharing introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_advanced_import', $sm.id, 'Advanced Import', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_advanced_import_create_table_initialise', $sm.id, 'Crée la table base_advanced_import (Axelor)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_advanced_import', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_advanced_import (copie Axelor)'
PERMISSIONS FULL;

