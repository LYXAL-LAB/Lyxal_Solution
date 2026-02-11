DEFINE FUNCTION IF NOT EXISTS fn::base_country_language_link_asia_official_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: liens officiels pays→langues (Asie)', { run_id: $run_id, parent_run_id: $parent_run_id });

LET $link = function($c, $l) { RELATE type::thing('base_country',$c)->base_country_language->type::thing('base_language',$l) CONTENT {}; };

$link('CN','ZH');
$link('JP','JA');
$link('KR','KO');
$link('KP','KO');
$link('MN','MN');
$link('HK','ZH'); $link('HK','EN');
$link('MO','ZH');
$link('TW','ZH');
$link('VN','VI');
$link('TH','TH');
$link('KH','KM');
$link('LA','LO');
$link('MM','MY');
$link('MY','MS');
$link('SG','EN'); $link('SG','MS'); $link('SG','TA'); $link('SG','ZH');
$link('ID','ID');
$link('BN','MS');
$link('PH','EN'); $link('PH','TL');
$link('IN','HI'); $link('IN','EN');
$link('PK','UR'); $link('PK','EN');
$link('BD','BN');
$link('LK','SI'); $link('LK','TA');
$link('NP','NE');
$link('AF','PS'); $link('AF','FA');
$link('AE','AR');
$link('QA','AR');
$link('SA','AR');
$link('KW','AR');
$link('BH','AR');
$link('OM','AR');
$link('IR','FA');
$link('IQ','AR'); $link('IQ','KU');
$link('IL','HE');
$link('PS','AR');
$link('JO','AR');
$link('LB','AR');
$link('SY','AR');
$link('TR','TR');

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
LET $f_rec = fn::builder_function_create_record('base_country_language_link_asia_official_initialise', $sm.id, 'Liens officiels pays→langues (Asie)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: liens officiels pays→langues (Asie)', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Liens officiels pays→langues (Asie)'
PERMISSIONS FULL;

