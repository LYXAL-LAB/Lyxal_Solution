DEFINE FUNCTION IF NOT EXISTS fn::base_data_sharing_referential_line_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_data_sharing_referential_line', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_data_sharing_referential_line TYPE NORMAL SCHEMAFULL
  COMMENT 'DataSharingReferentialLine (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD dataSharingReferential ON base_data_sharing_referential_line TYPE record<base_data_sharing_referential>;
  DEFINE FIELD metaModel ON base_data_sharing_referential_line TYPE record<base_meta_model>;
  DEFINE FIELD queryCondition ON base_data_sharing_referential_line TYPE option<string>;
  DEFINE FIELD wizardMetaModel ON base_data_sharing_referential_line TYPE option<record<base_meta_model>>;
  DEFINE FIELD wizardRefId ON base_data_sharing_referential_line TYPE option<number>;

  DEFINE INDEX idx_base_ds_line_ref ON base_data_sharing_referential_line FIELDS dataSharingReferential;
  DEFINE INDEX idx_base_ds_line_model ON base_data_sharing_referential_line FIELDS metaModel;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_data_sharing' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_data_sharing introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_data_sharing_referential_line', $sm.id, 'Data Sharing Referential Line', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_data_sharing_referential_line_create_table_initialise', $sm.id, 'Crée la table base_data_sharing_referential_line (Axelor)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_data_sharing_referential_line', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_data_sharing_referential_line (copie Axelor)'
PERMISSIONS FULL;

