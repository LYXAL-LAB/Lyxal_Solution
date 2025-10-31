DEFINE FUNCTION IF NOT EXISTS fn::base_attribution_model_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_attribution_model', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_attribution_model TYPE NORMAL SCHEMAFULL
  COMMENT 'Modèles d\'attribution marketing'
  PERMISSIONS FULL;

  DEFINE FIELD name ON base_attribution_model TYPE string;
  DEFINE FIELD code ON base_attribution_model TYPE string;
  DEFINE FIELD description ON base_attribution_model TYPE option<string>;
  DEFINE FIELD name_fr ON base_attribution_model TYPE option<string>;
  DEFINE FIELD name_en ON base_attribution_model TYPE option<string>;
  DEFINE FIELD name_de ON base_attribution_model TYPE option<string>;
  DEFINE FIELD name_es ON base_attribution_model TYPE option<string>;
  DEFINE FIELD weight_distribution ON base_attribution_model TYPE object DEFAULT {};
  DEFINE FIELD calculation_method ON base_attribution_model TYPE option<string>;
  DEFINE FIELD time_window_days ON base_attribution_model TYPE int DEFAULT 30;
  DEFINE FIELD icon ON base_attribution_model TYPE string DEFAULT 'fa-chart-line';
  DEFINE FIELD color ON base_attribution_model TYPE string DEFAULT '#007bff';
  DEFINE FIELD sort_order ON base_attribution_model TYPE int DEFAULT 0;
  DEFINE FIELD is_active ON base_attribution_model TYPE bool DEFAULT true;
  DEFINE FIELD is_default ON base_attribution_model TYPE bool DEFAULT false;
  DEFINE FIELD created_at ON base_attribution_model TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_attribution_model TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_attribution_model_code ON base_attribution_model FIELDS code UNIQUE;
  DEFINE INDEX idx_base_attribution_model_active ON base_attribution_model FIELDS is_active;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_research_metadata' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_research_metadata introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_attribution_model', $sm.id, 'Modèles d\'attribution', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_attribution_model_create_table_initialise', $sm.id, 'Crée la table base_attribution_model', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_attribution_model', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_attribution_model'
PERMISSIONS FULL;

