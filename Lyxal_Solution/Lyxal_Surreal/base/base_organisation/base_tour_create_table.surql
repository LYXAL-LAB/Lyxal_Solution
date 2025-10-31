DEFINE FUNCTION IF NOT EXISTS fn::base_tour_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_tour', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_tour TYPE NORMAL SCHEMAFULL
  COMMENT 'Tournées (visites)'
  PERMISSIONS FULL;

  DEFINE FIELD name ON base_tour TYPE string;
  DEFINE FIELD code ON base_tour TYPE option<string>;
  DEFINE FIELD description ON base_tour TYPE option<string>;
  DEFINE FIELD user ON base_tour TYPE option<record<base_user>>;
  DEFINE FIELD team ON base_tour TYPE option<record<base_team>>;
  DEFINE FIELD start_date ON base_tour TYPE option<date>;
  DEFINE FIELD end_date ON base_tour TYPE option<date>;
  DEFINE FIELD status_select ON base_tour TYPE int DEFAULT 1;
  DEFINE FIELD total_distance ON base_tour TYPE float DEFAULT 0.0;
  DEFINE FIELD total_duration ON base_tour TYPE option<duration>;
  DEFINE FIELD estimated_cost ON base_tour TYPE float DEFAULT 0.0;
  DEFINE FIELD actual_cost ON base_tour TYPE float DEFAULT 0.0;
  DEFINE FIELD currency ON base_tour TYPE option<record<base_currency>>;
  DEFINE FIELD company ON base_tour TYPE option<record<base_company>>;
  DEFINE FIELD tour_line_list ON base_tour TYPE array<record<base_tour_line>>;
  DEFINE FIELD is_active ON base_tour TYPE bool DEFAULT true;
  DEFINE FIELD created_at ON base_tour TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_tour TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_tour TYPE int DEFAULT 0;

  DEFINE INDEX idx_base_tour_code ON base_tour FIELDS code;
  DEFINE INDEX idx_base_tour_user ON base_tour FIELDS user;
  DEFINE INDEX idx_base_tour_status ON base_tour FIELDS status_select;
  DEFINE INDEX idx_base_tour_date_range ON base_tour FIELDS start_date, end_date;
  DEFINE INDEX idx_base_tour_active ON base_tour FIELDS is_active;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_organisation' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_organisation introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_tour', $sm.id, 'Tournées (visites)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_tour_create_table_initialise', $sm.id, 'Crée la table base_tour', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_tour', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_tour'
PERMISSIONS FULL;

