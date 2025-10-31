DEFINE FUNCTION IF NOT EXISTS fn::base_geographical_area_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_geographical_area', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_geographical_area TYPE NORMAL SCHEMAFULL
COMMENT 'Zones géographiques hiérarchiques'
PERMISSIONS FULL;

DEFINE FIELD name ON base_geographical_area TYPE string;
DEFINE FIELD code ON base_geographical_area TYPE string;
DEFINE FIELD type_select ON base_geographical_area TYPE string; -- ex: REGION_GROUP, TRADE_ZONE, CUSTOM
DEFINE FIELD parent ON base_geographical_area TYPE option<record<base_geographical_area>>;
DEFINE FIELD children ON base_geographical_area TYPE array<record<base_geographical_area>>;
DEFINE FIELD country_set ON base_geographical_area TYPE array<record<base_country>>;
DEFINE FIELD is_active ON base_geographical_area TYPE bool DEFAULT true;
DEFINE FIELD created_at ON base_geographical_area TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_geographical_area TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_geographical_area_code ON base_geographical_area FIELDS code UNIQUE;
DEFINE INDEX idx_base_geographical_area_parent ON base_geographical_area FIELDS parent;
DEFINE INDEX idx_base_geographical_area_active ON base_geographical_area FIELDS is_active;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_geographical_area', $sm.id, 'Zones géographiques', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
LET $f_rec = fn::builder_function_create_record('base_geographical_area_create_table_initialise', $sm.id, 'Crée la table base_geographical_area', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_geographical_area', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_geographical_area'
PERMISSIONS FULL;

