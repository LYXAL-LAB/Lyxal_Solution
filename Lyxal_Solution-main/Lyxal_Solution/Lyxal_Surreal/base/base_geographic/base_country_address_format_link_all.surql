DEFINE FUNCTION IF NOT EXISTS fn::base_country_address_format_link_all_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: liens pays→format d\'adresse', { run_id: $run_id, parent_run_id: $parent_run_id });

LET $setFmt = function($c, $fmtId) {
  UPDATE type::thing('base_country', $c) SET addressFormat = type::thing('base_address_format', $fmtId);
};

-- Europe de l'Ouest
$setFmt('FR','FR');
$setFmt('DE','DE');
$setFmt('IT','IT');
$setFmt('ES','ES');
$setFmt('PT','PT');
$setFmt('NL','NL');
$setFmt('BE','BE');
$setFmt('LU','LU');
$setFmt('CH','CH');
$setFmt('LI','LI');
$setFmt('AT','AT');
$setFmt('SE','SE');
$setFmt('NO','NO');
$setFmt('FI','FI');
$setFmt('DK','DK');
$setFmt('IS','IS');
$setFmt('IE','IE');
$setFmt('GB','GB');
$setFmt('AD','AD');
$setFmt('MC','MC');
$setFmt('SM','SM');
$setFmt('VA','VA');

-- Europe Est / Sud-Est
$setFmt('PL','PL');
$setFmt('CZ','CZ');
$setFmt('SK','SK');
$setFmt('HU','HU');
$setFmt('RO','RO');
$setFmt('BG','BG');
$setFmt('GR','GR');
$setFmt('TR','TR');
$setFmt('CY','CY');
$setFmt('MT','MT');
$setFmt('SI','SI');
$setFmt('HR','HR');
$setFmt('RS','RS');
$setFmt('BA','BA');
$setFmt('ME','ME');
$setFmt('MK','MK');
$setFmt('AL','AL');
$setFmt('MD','MD');
$setFmt('UA','UA');
$setFmt('BY','BY');
$setFmt('FO','FO');
$setFmt('JE','JE');
$setFmt('GG','GG');
$setFmt('IM','IM');

-- Amériques
$setFmt('US','US');
$setFmt('CA','CA');
$setFmt('BR','BR');
$setFmt('MX','MX');
$setFmt('AR','AR');
$setFmt('CL','CL');
$setFmt('CO','CO');
$setFmt('PE','PE');
$setFmt('UY','UY');
$setFmt('VE','VE');
$setFmt('EC','EC');
$setFmt('PY','PY');
$setFmt('BO','BO');
$setFmt('GT','GT');
$setFmt('BZ','BZ');
$setFmt('SV','SV');
$setFmt('HN','HN');
$setFmt('NI','NI');
$setFmt('CR','CR');
$setFmt('PA','PA');
$setFmt('DO','DO');
$setFmt('HT','HT');
$setFmt('PR','PR');

-- Asie
$setFmt('JP','JP');
$setFmt('KR','KR');
$setFmt('TW','TW');
$setFmt('HK','HK');
$setFmt('MO','MO');
$setFmt('CN','CN');
$setFmt('IN','IN');
$setFmt('AE','AE');
$setFmt('QA','QA');
$setFmt('SG','SG');
$setFmt('TH','TH');
$setFmt('MY','MY');
$setFmt('PH','PH');
$setFmt('ID','ID');
$setFmt('PK','PK');
$setFmt('BD','BD');
$setFmt('LK','LK');
$setFmt('NP','NP');
$setFmt('VN','VN');
$setFmt('KH','KH');
$setFmt('LA','LA');
$setFmt('MM','MM');
$setFmt('MN','MN');
$setFmt('GE','GE');
$setFmt('AM','AM');
$setFmt('AZ','AZ');
$setFmt('KZ','KZ');
$setFmt('KG','KG');
$setFmt('TJ','TJ');
$setFmt('TM','TM');
$setFmt('UZ','UZ');
$setFmt('IL','IL');
$setFmt('JO','JO');
$setFmt('KW','KW');
$setFmt('PS','PS');
$setFmt('SA','SA');
$setFmt('OM','OM');
$setFmt('BH','BH');

-- Océanie
$setFmt('AU','AU');
$setFmt('NZ','NZ');

-- Afrique
$setFmt('ZA','ZA');
$setFmt('MA','MA');
$setFmt('DZ','DZ');
$setFmt('EG','EG');
$setFmt('NG','NG');
$setFmt('KE','KE');
$setFmt('TN','TN');
$setFmt('SN','SN');
$setFmt('ET','ET');
$setFmt('TZ','TZ');

-- Générer des formats dédiés pour tous les pays restants (zéro fallback)
LET $missing = (SELECT code2, name FROM base_country WHERE addressFormat = NONE);
LET $toCreate = (SELECT {
  id: type::thing('base_address_format', code2),
  code: string::concat('addr_', code2),
  template: '{name}\n{street}\n{postalCode} {city}\n{country}',
  postalCodeRegex: NONE,
  requiresState: false,
  uppercasePostalCode: false,
  linesMax: 6,
  example: string::concat('Nom Exemple\nRue Exemple 1\n', code2, ' - ', name),
  tags: [system_tag:address_format_active]
} FROM $missing);
IF array::len($toCreate) > 0 {
  CREATE base_address_format CONTENT $toCreate;
  UPDATE base_country SET addressFormat = type::thing('base_address_format', code2) WHERE addressFormat = NONE;
};

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
LET $f_rec = fn::builder_function_create_record('base_country_address_format_link_all_initialise', $sm.id, 'Lie chaque pays à un format d\'adresse', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: liens pays→format d\'adresse', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Lie chaque pays à un format d\'adresse par défaut'
PERMISSIONS FULL;

