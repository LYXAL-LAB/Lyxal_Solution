DEFINE FUNCTION IF NOT EXISTS fn::base_anonymizer_line_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_anonymizer_line', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_anonymizer_line TYPE NORMAL SCHEMAFULL
  COMMENT 'AnonymizerLine (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD anonymizer ON base_anonymizer_line TYPE option<record<base_anonymizer>>;
  DEFINE FIELD metaModel ON base_anonymizer_line TYPE record<base_meta_model>;
  DEFINE FIELD metaField ON base_anonymizer_line TYPE record<base_meta_field>;
  DEFINE FIELD useFakeData ON base_anonymizer_line TYPE bool DEFAULT false;
  DEFINE FIELD fakerApiField ON base_anonymizer_line TYPE option<record<base_faker_api_field>>;
  DEFINE FIELD metaJsonField ON base_anonymizer_line TYPE option<string>;

  DEFINE FIELD created_at ON base_anonymizer_line TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_anonymizer_line TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_anonymizer_line_anon ON base_anonymizer_line FIELDS anonymizer;
  DEFINE INDEX idx_base_anonymizer_line_model ON base_anonymizer_line FIELDS metaModel;
  DEFINE INDEX idx_base_anonymizer_line_field ON base_anonymizer_line FIELDS metaField;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_anonymizer_line', $sm.id, 'AnonymizerLine (Axelor)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_anonymizer_line_create_table_initialise', $sm.id, 'Crée la table base_anonymizer_line', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_anonymizer_line', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_anonymizer_line'
PERMISSIONS FULL;

