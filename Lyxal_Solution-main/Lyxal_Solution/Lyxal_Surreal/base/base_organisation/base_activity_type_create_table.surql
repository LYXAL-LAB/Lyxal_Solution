DEFINE FUNCTION IF NOT EXISTS fn::base_activity_type_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_activity_type', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_activity_type TYPE NORMAL SCHEMAFULL
  COMMENT 'Types d\'activité'
  PERMISSIONS FULL;

  DEFINE FIELD name ON base_activity_type TYPE string;
  DEFINE FIELD code ON base_activity_type TYPE string;
  DEFINE FIELD description ON base_activity_type TYPE option<string>;
  DEFINE FIELD name_fr ON base_activity_type TYPE option<string>;
  DEFINE FIELD name_en ON base_activity_type TYPE option<string>;
  DEFINE FIELD name_de ON base_activity_type TYPE option<string>;
  DEFINE FIELD name_es ON base_activity_type TYPE option<string>;
  DEFINE FIELD category ON base_activity_type TYPE option<record<base_activity_category>>;
  DEFINE FIELD icon ON base_activity_type TYPE string DEFAULT 'fa-calendar';
  DEFINE FIELD color ON base_activity_type TYPE string DEFAULT '#007bff';
  DEFINE FIELD sort_order ON base_activity_type TYPE int DEFAULT 0;
  DEFINE FIELD is_billable ON base_activity_type TYPE bool DEFAULT false;
  DEFINE FIELD requires_duration ON base_activity_type TYPE bool DEFAULT true;
  DEFINE FIELD requires_location ON base_activity_type TYPE bool DEFAULT false;
  DEFINE FIELD requires_attendees ON base_activity_type TYPE bool DEFAULT false;
  DEFINE FIELD auto_track ON base_activity_type TYPE bool DEFAULT false;
  DEFINE FIELD default_duration_minutes ON base_activity_type TYPE int DEFAULT 60;
  DEFINE FIELD default_reminder_minutes ON base_activity_type TYPE int DEFAULT 15;
  DEFINE FIELD is_active ON base_activity_type TYPE bool DEFAULT true;
  DEFINE FIELD is_default ON base_activity_type TYPE bool DEFAULT false;
  DEFINE FIELD created_at ON base_activity_type TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_activity_type TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_activity_type TYPE int DEFAULT 0;

  DEFINE INDEX idx_base_activity_type_code ON base_activity_type FIELDS code UNIQUE;
  DEFINE INDEX idx_base_activity_type_category ON base_activity_type FIELDS category;
  DEFINE INDEX idx_base_activity_type_active ON base_activity_type FIELDS is_active;
  DEFINE INDEX idx_base_activity_type_sort ON base_activity_type FIELDS sort_order;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_organisation' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_organisation introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_activity_type', $sm.id, 'Types d\'activité', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_activity_type_create_table_initialise', $sm.id, 'Crée la table base_activity_type', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_activity_type', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_activity_type'
PERMISSIONS FULL;

