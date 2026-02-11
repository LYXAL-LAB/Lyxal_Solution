DEFINE FUNCTION IF NOT EXISTS fn::base_priority_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_priority', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_priority TYPE NORMAL SCHEMAFULL
  COMMENT 'Niveaux de priorité applicatifs'
  PERMISSIONS FULL;

  DEFINE FIELD name ON base_priority TYPE string;
  DEFINE FIELD name_fr ON base_priority TYPE option<string>;
  DEFINE FIELD name_en ON base_priority TYPE option<string>;
  DEFINE FIELD name_de ON base_priority TYPE option<string>;
  DEFINE FIELD name_es ON base_priority TYPE option<string>;
  DEFINE FIELD level ON base_priority TYPE int;
  DEFINE FIELD color ON base_priority TYPE string;
  DEFINE FIELD icon ON base_priority TYPE option<string>;
  DEFINE FIELD description ON base_priority TYPE option<string>;
  DEFINE FIELD recommended_response_time ON base_priority TYPE option<int>;
  DEFINE FIELD recommended_resolution_time ON base_priority TYPE option<int>;
  DEFINE FIELD is_critical ON base_priority TYPE bool DEFAULT false;
  DEFINE FIELD requires_notification ON base_priority TYPE bool DEFAULT false;
  DEFINE FIELD display_order ON base_priority TYPE int DEFAULT 0;
  DEFINE FIELD is_active ON base_priority TYPE bool DEFAULT true;
  DEFINE FIELD created_at ON base_priority TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_priority TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_priority_level ON base_priority FIELDS level;
  DEFINE INDEX idx_base_priority_active ON base_priority FIELDS is_active;
  DEFINE INDEX idx_base_priority_critical ON base_priority FIELDS is_critical;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_priority', $sm.id, 'Niveaux de priorité', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_priority_create_table_initialise', $sm.id, 'Crée la table base_priority', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_priority', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_priority'
PERMISSIONS FULL;

