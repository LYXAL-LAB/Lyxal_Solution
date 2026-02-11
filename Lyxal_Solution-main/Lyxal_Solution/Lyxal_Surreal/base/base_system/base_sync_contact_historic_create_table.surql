DEFINE FUNCTION IF NOT EXISTS fn::base_sync_contact_historic_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_sync_contact_historic', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_sync_contact_historic TYPE NORMAL SCHEMAFULL
  COMMENT 'Historique de contact synchronisé'
  PERMISSIONS FULL;
  DEFINE FIELD sync_contact ON base_sync_contact_historic TYPE record<base_sync_contact>;
  DEFINE FIELD sync_date ON base_sync_contact_historic TYPE datetime;
  DEFINE FIELD sync_status ON base_sync_contact_historic TYPE string;
  DEFINE FIELD error_message ON base_sync_contact_historic TYPE string;
  DEFINE FIELD created_at ON base_sync_contact_historic TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_sync_contact_historic TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_sync_contact_historic TYPE int DEFAULT 0;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_sync_contact_historic', $sm.id, 'Historique de contact synchronisé', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_sync_contact_historic_create_table_initialise', $sm.id, 'Crée la table base_sync_contact_historic', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_sync_contact_historic', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_sync_contact_historic'
PERMISSIONS FULL;

