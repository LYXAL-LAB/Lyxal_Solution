DEFINE FUNCTION IF NOT EXISTS fn::base_tour_line_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_tour_line', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_tour_line TYPE NORMAL SCHEMAFULL
  COMMENT 'Lignes de tournée'
  PERMISSIONS FULL;

  DEFINE FIELD tour ON base_tour_line TYPE record<base_tour>;
  DEFINE FIELD sequence ON base_tour_line TYPE int DEFAULT 0;
  DEFINE FIELD partner ON base_tour_line TYPE option<record<base_partner>>;
  DEFINE FIELD address ON base_tour_line TYPE option<record<base_address>>;
  DEFINE FIELD planned_date ON base_tour_line TYPE option<date>;
  DEFINE FIELD planned_time ON base_tour_line TYPE option<time>;
  DEFINE FIELD actual_date ON base_tour_line TYPE option<date>;
  DEFINE FIELD actual_time ON base_tour_line TYPE option<time>;
  DEFINE FIELD duration ON base_tour_line TYPE option<duration>;
  DEFINE FIELD distance_from_previous ON base_tour_line TYPE float DEFAULT 0.0;
  DEFINE FIELD status_select ON base_tour_line TYPE int DEFAULT 1;
  DEFINE FIELD visit_purpose ON base_tour_line TYPE option<string>;
  DEFINE FIELD visit_result ON base_tour_line TYPE option<string>;
  DEFINE FIELD notes ON base_tour_line TYPE option<string>;
  DEFINE FIELD is_mandatory ON base_tour_line TYPE bool DEFAULT false;
  DEFINE FIELD priority_select ON base_tour_line TYPE int DEFAULT 2;
  DEFINE FIELD lead ON base_tour_line TYPE option<record<base_lead>>;
  DEFINE FIELD opportunity ON base_tour_line TYPE option<record<base_opportunity>>;
  DEFINE FIELD event ON base_tour_line TYPE option<record<base_event>>;
  DEFINE FIELD created_at ON base_tour_line TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_tour_line TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_tour_line TYPE int DEFAULT 0;

  DEFINE INDEX idx_base_tour_line_tour ON base_tour_line FIELDS tour;
  DEFINE INDEX idx_base_tour_line_sequence ON base_tour_line FIELDS sequence;
  DEFINE INDEX idx_base_tour_line_partner ON base_tour_line FIELDS partner;
  DEFINE INDEX idx_base_tour_line_status ON base_tour_line FIELDS status_select;
  DEFINE INDEX idx_base_tour_line_planned_date ON base_tour_line FIELDS planned_date;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_organisation' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_organisation introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_tour_line', $sm.id, 'Lignes de tournée', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_tour_line_create_table_initialise', $sm.id, 'Crée la table base_tour_line', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_tour_line', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_tour_line'
PERMISSIONS FULL;

