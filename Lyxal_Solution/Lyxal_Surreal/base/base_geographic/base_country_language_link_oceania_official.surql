DEFINE FUNCTION IF NOT EXISTS fn::base_country_language_link_oceania_official_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: liens officiels pays→langues (Océanie)', { run_id: $run_id, parent_run_id: $parent_run_id });

LET $link = function($c, $l) { RELATE type::thing('base_country',$c)->base_country_language->type::thing('base_language',$l) CONTENT {}; };

$link('AU','EN');
$link('NZ','EN'); $link('NZ','MI');
$link('FJ','EN'); $link('FJ','FJ');
$link('PG','EN');
$link('SB','EN');
$link('VU','EN'); $link('VU','FR');
$link('NC','FR');
$link('PF','FR');
$link('WF','FR');
$link('AS','EN');
$link('WS','SM');
$link('TO','TO');
$link('TV','EN');
$link('KI','EN');
$link('FM','EN');
$link('MH','EN');
$link('PW','EN');
$link('GU','EN');

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
LET $f_rec = fn::builder_function_create_record('base_country_language_link_oceania_official_initialise', $sm.id, 'Liens officiels pays→langues (Océanie)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: liens officiels pays→langues (Océanie)', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Liens officiels pays→langues (Océanie)'
PERMISSIONS FULL;

