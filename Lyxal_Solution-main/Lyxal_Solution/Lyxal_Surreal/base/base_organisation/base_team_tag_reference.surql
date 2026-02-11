DEFINE FUNCTION IF NOT EXISTS fn::base_team_tag_reference_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: seeds de tags Team', { run_id: $run_id, parent_run_id: $parent_run_id });

-- team_type_*
LET $tt1 = fn::system_tag_create_record('team_type_sales', 'Team Type: Sales', 'Équipe commerciale', '#f59e0b', true);
LET $tt2 = fn::system_tag_create_record('team_type_support', 'Team Type: Support', 'Équipe support / service client', '#3b82f6', true);
LET $tt3 = fn::system_tag_create_record('team_type_project', 'Team Type: Project', 'Équipe projet / delivery', '#10b981', true);
LET $tt4 = fn::system_tag_create_record('team_type_management', 'Team Type: Management', 'Équipe direction / management', '#ef4444', true);

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_organisation' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_failure'], 'Erreur: sous-module base_organisation introuvable pour builder_function (tags team)', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $f_rec = fn::builder_function_create_record('base_team_tag_reference_initialise', $sm.id, 'Initialise les tags de référence Team', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour base_team_tag_reference_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: seeds de tags Team', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise les tags de référence du sous-module Organisation (Team)'
PERMISSIONS FULL;

