DEFINE FUNCTION IF NOT EXISTS fn::base_country_language_link_all_official_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: liens officiels pays→langues (tous continents)', { run_id: $run_id, parent_run_id: $parent_run_id });

LET $s1 = fn::base_country_language_link_europe_official_initialise($run_id, $phase);
IF $s1.success != true { RETURN { success: false, run_id: $run_id, step: 'europe', result: $s1 }; };

LET $s2 = fn::base_country_language_link_africa_official_initialise($run_id, $phase);
IF $s2.success != true { RETURN { success: false, run_id: $run_id, step: 'africa', result: $s2 }; };

LET $s3 = fn::base_country_language_link_americas_official_initialise($run_id, $phase);
IF $s3.success != true { RETURN { success: false, run_id: $run_id, step: 'americas', result: $s3 }; };

LET $s4 = fn::base_country_language_link_asia_official_initialise($run_id, $phase);
IF $s4.success != true { RETURN { success: false, run_id: $run_id, step: 'asia', result: $s4 }; };

LET $s5 = fn::base_country_language_link_oceania_official_initialise($run_id, $phase);
IF $s5.success != true { RETURN { success: false, run_id: $run_id, step: 'oceania', result: $s5 }; };

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
LET $f_rec = fn::builder_function_create_record('base_country_language_link_all_official_initialise', $sm.id, 'Liens officiels pays→langues (tous continents)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: liens officiels pays→langues (all)', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Orchestrateur des liens officiels pays→langues (tous continents)'
PERMISSIONS FULL;

