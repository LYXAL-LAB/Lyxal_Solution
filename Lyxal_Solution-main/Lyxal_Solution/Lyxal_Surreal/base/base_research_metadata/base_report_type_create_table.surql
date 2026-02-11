DEFINE FUNCTION IF NOT EXISTS fn::base_report_type_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_report_type', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_report_type TYPE NORMAL SCHEMAFULL
  COMMENT 'Types de rapports'
  PERMISSIONS FULL;

  DEFINE FIELD name ON base_report_type TYPE string;
  DEFINE FIELD code ON base_report_type TYPE string;
  DEFINE FIELD description ON base_report_type TYPE option<string>;
  DEFINE FIELD module ON base_report_type TYPE option<record<base_app_module>>;
  DEFINE FIELD category ON base_report_type TYPE string DEFAULT 'BUSINESS';
  DEFINE FIELD is_active ON base_report_type TYPE bool DEFAULT true;
  DEFINE FIELD is_default ON base_report_type TYPE bool DEFAULT false;
  DEFINE FIELD icon ON base_report_type TYPE string DEFAULT 'fa-chart-bar';
  DEFINE FIELD color ON base_report_type TYPE string DEFAULT '#007bff';
  DEFINE FIELD sort_order ON base_report_type TYPE int DEFAULT 0;
  DEFINE FIELD template_path ON base_report_type TYPE option<string>;
  DEFINE FIELD export_formats ON base_report_type TYPE array<string> DEFAULT ['PDF','EXCEL','CSV'];
  DEFINE FIELD parameters_schema ON base_report_type TYPE option<object>;
  DEFINE FIELD required_permissions ON base_report_type TYPE array<string>;
  DEFINE FIELD restricted_roles ON base_report_type TYPE array<string>;
  DEFINE FIELD created_at ON base_report_type TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_report_type TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_report_type TYPE int DEFAULT 0;

  DEFINE INDEX idx_base_report_type_code ON base_report_type FIELDS code UNIQUE;
  DEFINE INDEX idx_base_report_type_module ON base_report_type FIELDS module;
  DEFINE INDEX idx_base_report_type_category ON base_report_type FIELDS category;
  DEFINE INDEX idx_base_report_type_active ON base_report_type FIELDS is_active;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_research_metadata' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_research_metadata introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_report_type', $sm.id, 'Types de rapports', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_report_type_create_table_initialise', $sm.id, 'Crée la table base_report_type', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_report_type', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_report_type'
PERMISSIONS FULL;

