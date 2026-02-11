DEFINE FUNCTION IF NOT EXISTS fn::base_country_language_link_africa_official_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: liens officiels pays→langues (Afrique)', { run_id: $run_id, parent_run_id: $parent_run_id });

LET $link = function($c, $l) { RELATE type::thing('base_country',$c)->base_country_language->type::thing('base_language',$l) CONTENT {}; };

-- Afrique du Nord
$link('DZ','AR');
$link('EG','AR');
$link('LY','AR');
$link('MA','AR'); $link('MA','FR');
$link('TN','AR'); $link('TN','FR');
$link('EH','AR');

-- Afrique subsaharienne (sélection officielle)
$link('AO','PT');
$link('BF','FR');
$link('BI','FR'); $link('BI','RN');
$link('BJ','FR');
$link('BW','EN');
$link('CD','FR');
$link('CF','FR');
$link('CG','FR');
$link('CI','FR');
$link('CM','FR'); $link('CM','EN');
$link('CV','PT');
$link('DJ','AR'); $link('DJ','FR');
$link('ER','TI'); $link('ER','AR'); $link('ER','EN');
$link('ET','AM'); $link('ET','EN');
$link('GA','FR');
$link('GH','EN');
$link('GM','EN');
$link('GN','FR');
$link('GQ','ES'); $link('GQ','FR'); $link('GQ','PT');
$link('GW','PT');
$link('KE','EN'); $link('KE','SW');
$link('KM','AR'); $link('KM','FR');
$link('LR','EN');
$link('LS','EN'); $link('LS','ST');
$link('MG','FR'); $link('MG','MG');
$link('ML','FR');
$link('MR','AR');
$link('MU','EN'); $link('MU','FR');
$link('MW','EN');
$link('MZ','PT');
$link('NA','EN');
$link('NE','FR');
$link('NG','EN');
$link('RW','EN'); $link('RW','FR'); $link('RW','RW');
$link('SC','FR'); $link('SC','EN');
$link('SD','AR');
$link('SL','EN');
$link('SN','FR');
$link('SO','SO'); $link('SO','AR');
$link('SS','EN');
$link('ST','PT');
$link('SZ','EN');
$link('TD','FR'); $link('TD','AR');
$link('TG','FR');
$link('TZ','EN'); $link('TZ','SW');
$link('UG','EN');
$link('ZA','EN'); $link('ZA','AF'); $link('ZA','ZU'); $link('ZA','XH'); $link('ZA','ST'); $link('ZA','TN'); $link('ZA','NS'); $link('ZA','SS'); $link('ZA','VE'); $link('ZA','NR');
$link('ZM','EN');
$link('ZW','EN');

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
LET $f_rec = fn::builder_function_create_record('base_country_language_link_africa_official_initialise', $sm.id, 'Liens officiels pays→langues (Afrique)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: liens officiels pays→langues (Afrique)', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Liens officiels pays→langues (Afrique)'
PERMISSIONS FULL;

