DEFINE FUNCTION IF NOT EXISTS fn::base_model_email_link_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_model_email_link', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_model_email_link TYPE NORMAL SCHEMAFULL
  COMMENT 'ModelEmailLink (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD metaModel ON base_model_email_link TYPE option<record<base_meta_model>>;
  DEFINE FIELD emailField ON base_model_email_link TYPE option<string>;
  DEFINE FIELD addressTypeSelect ON base_model_email_link TYPE option<int>;

  DEFINE FIELD created_at ON base_model_email_link TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_model_email_link TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_model_email_link_model ON base_model_email_link FIELDS metaModel;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_communication' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_communication introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_model_email_link', $sm.id, 'Lien modèle-email (Axelor)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_model_email_link_create_table_initialise', $sm.id, 'Crée la table base_model_email_link', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_model_email_link', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_model_email_link'
PERMISSIONS FULL;

