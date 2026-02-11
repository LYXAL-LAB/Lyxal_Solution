DEFINE FUNCTION IF NOT EXISTS fn::base_country_language_link_americas_official_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: liens officiels pays→langues (Amériques)', { run_id: $run_id, parent_run_id: $parent_run_id });

LET $link = function($c, $l) { RELATE type::thing('base_country',$c)->base_country_language->type::thing('base_language',$l) CONTENT {}; };

-- Amérique du Nord
$link('US','EN');
$link('CA','EN'); $link('CA','FR');
$link('GL','KL'); $link('GL','DA');

-- Caraïbes / Amérique centrale (langues principales officielles)
$link('MX','ES');
$link('BZ','EN');
$link('GT','ES');
$link('SV','ES');
$link('HN','ES');
$link('NI','ES');
$link('CR','ES');
$link('PA','ES');
$link('CU','ES');
$link('DO','ES');
$link('HT','FR'); $link('HT','HT');
$link('JM','EN');
$link('TT','EN');
$link('BB','EN');
$link('BS','EN');
$link('GD','EN');
$link('LC','EN');
$link('VC','EN');
$link('AG','EN');
$link('DM','EN');
$link('KN','EN');
$link('AW','NL'); $link('AW','PA');
$link('CW','NL');
$link('SX','NL'); $link('SX','EN');

-- Amérique du Sud
$link('AR','ES');
$link('BO','ES'); $link('BO','AY'); $link('BO','QU');
$link('BR','PT');
$link('CL','ES');
$link('CO','ES');
$link('EC','ES');
$link('FK','EN');
$link('GF','FR');
$link('GY','EN');
$link('PE','ES');
$link('PY','ES'); $link('PY','GN');
$link('SR','NL');
$link('UY','ES');
$link('VE','ES');

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
LET $f_rec = fn::builder_function_create_record('base_country_language_link_americas_official_initialise', $sm.id, 'Liens officiels pays→langues (Amériques)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: liens officiels pays→langues (Amériques)', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Liens officiels pays→langues (Amériques)'
PERMISSIONS FULL;

