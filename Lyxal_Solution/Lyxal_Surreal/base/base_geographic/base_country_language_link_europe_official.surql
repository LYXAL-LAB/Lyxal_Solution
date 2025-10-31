DEFINE FUNCTION IF NOT EXISTS fn::base_country_language_link_europe_official_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: liens officiels pays→langues (Europe)', { run_id: $run_id, parent_run_id: $parent_run_id });

-- Helper RELATE
LET $link = function($c, $l) {
  RELATE type::thing('base_country',$c)->base_country_language->type::thing('base_language',$l) CONTENT {};
};

-- Europe de l'Ouest / Nord / Est / Sud
$link('FR','FR');
$link('BE','FR'); $link('BE','NL'); $link('BE','DE');
$link('CH','DE'); $link('CH','FR'); $link('CH','IT'); $link('CH','RM');
$link('LU','LB'); $link('LU','FR'); $link('LU','DE');
$link('IE','EN'); $link('IE','GA');
$link('GB','EN');
$link('ES','ES');
$link('PT','PT');
$link('IT','IT');
$link('DE','DE');
$link('NL','NL');
$link('SE','SV');
$link('NO','NO'); $link('NO','NN');
$link('FI','FI'); $link('FI','SV');
$link('DK','DA');
$link('IS','IS');
$link('EE','ET');
$link('LV','LV');
$link('LT','LT');
$link('PL','PL');
$link('CZ','CS');
$link('SK','SK');
$link('HU','HU');
$link('RO','RO');
$link('BG','BG');
$link('GR','EL');
$link('CY','EL'); $link('CY','TR');
$link('MT','MT'); $link('MT','EN');
$link('SI','SL');
$link('HR','HR');
$link('RS','SR');
$link('BA','BS'); $link('BA','HR'); $link('BA','SR');
$link('ME','SR');
$link('MK','MK');
$link('AL','SQ');
$link('MD','RO');
$link('UA','UK');
$link('BY','BE'); $link('BY','RU');
$link('RU','RU');
$link('TR','TR');
$link('AD','CA');
$link('MC','FR');
$link('LI','DE');
$link('GI','EN');
$link('SM','IT');
$link('VA','IT'); $link('VA','LA');

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
LET $f_rec = fn::builder_function_create_record('base_country_language_link_europe_official_initialise', $sm.id, 'Liens officiels pays→langues (Europe)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: liens officiels pays→langues (Europe)', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Liens officiels pays→langues (Europe)'
PERMISSIONS FULL;

