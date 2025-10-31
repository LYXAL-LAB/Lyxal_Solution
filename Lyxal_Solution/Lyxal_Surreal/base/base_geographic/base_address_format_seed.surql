DEFINE FUNCTION IF NOT EXISTS fn::base_address_format_seed_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_start', 'log_initialise'], 'Start: seeds de données base_address_format', { run_id: $run_id, parent_run_id: $parent_run_id });

LET $mk = function($id, $code, $template, $regex, $requiresState, $upperPC, $linesMax, $example) {
  LET $exists = (SELECT id FROM type::thing('base_address_format', $id) LIMIT 1)[0];
  IF $exists == NONE {
    CREATE type::thing('base_address_format', $id) CONTENT {
      code: $code,
      template: $template,
      postalCodeRegex: $regex,
      requiresState: $requiresState,
      uppercasePostalCode: $upperPC,
      linesMax: $linesMax,
      example: $example,
      tags: [system_tag:address_format_active]
    };
  };
};

-- Profils principaux
RETURN {
  seed: [
    $mk('INTL_DEFAULT','addr_INTL_DEFAULT','{name}\n{street}\n{postalCode} {city}\n{country}', NONE, false, false, 6, 'Jean Dupont\n12 Rue Exemple\n75001 Paris\nFrance'),
    $mk('FR','addr_FR','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Jean Dupont\n12 Rue Exemple\n75001 Paris\nFrance'),
    $mk('DE','addr_DE','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Max Mustermann\nMusterstraße 1\n10115 Berlin\nDeutschland'),
    $mk('IT','addr_IT','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Mario Rossi\nVia Roma 1\n00100 Roma\nItalia'),
    $mk('ES','addr_ES','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Juan Pérez\nCalle Mayor 1\n28001 Madrid\nEspaña'),
    $mk('PT','addr_PT','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}-?\\d{3}$', false, false, 6, 'João Silva\nAv. da Liberdade 1\n1000-001 Lisboa\nPortugal'),
    $mk('NL','addr_NL','{name}\n{street}\n{postalCode} {city}\n{country}','^[0-9]{4} ?[A-Za-z]{2}$', false, true, 6, 'Jan Jansen\nDorpsstraat 1\n1234 AB Amsterdam\nNederland'),
    $mk('BE','addr_BE','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Jean Peeters\nRue Principale 1\n1000 Bruxelles\nBelgique'),
    $mk('LU','addr_LU','{name}\n{street}\n{postalCode} {city}\n{country}','^L-?\\d{4}$', false, true, 6, 'Jean Muller\nRue Principale 1\nL-1234 Luxembourg\nLuxembourg'),
    $mk('CH','addr_CH','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Hans Meier\nBahnhofstrasse 1\n8000 Zürich\nSchweiz'),
    $mk('AT','addr_AT','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Max Mustermann\nHauptstraße 1\n1010 Wien\nÖsterreich'),
    $mk('SE','addr_SE','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{3} ?\\d{2}$', false, false, 6, 'Anna Svensson\nGatan 1\n123 45 Stockholm\nSverige'),
    $mk('NO','addr_NO','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Ola Nordmann\nGate 1\n0123 Oslo\nNorge'),
    $mk('FI','addr_FI','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Matti Meikäläinen\nKatu 1\n00100 Helsinki\nSuomi'),
    $mk('DK','addr_DK','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Jens Jensen\nGade 1\n1000 København\nDanmark'),
    $mk('IE','addr_IE','{name}\n{street}\n{city}\n{postalCode}\n{country}','^[A-Za-z0-9]{3} ?[A-Za-z0-9]{4}$', false, true, 7, 'John Murphy\nMain Street 1\nDublin\nD02 XY12\nIreland'),
    $mk('GB','addr_GB','{name}\n{street}\n{city}\n{postalCode}\n{country}','^(GIR 0AA|[A-Z]{1,2}\\d[\\dA-Z]? \\d[ABD-HJLNP-UW-Z]{2})$', false, true, 7, 'John Smith\n10 Downing Street\nLondon\nSW1A 2AA\nUnited Kingdom'),
    $mk('AD','addr_AD','{name}\n{street}\n{postalCode} {city}\n{country}','^AD-?\\d{3}$', false, true, 6, 'Josep\nCarrer 1\nAD500 Andorra la Vella\nAndorra'),
    $mk('MC','addr_MC','{name}\n{street}\n{postalCode} {city}\n{country}','^980\\d{2}$', false, false, 6, 'Jean\nRue 1\n98000 Monaco\nMonaco'),
    $mk('SM','addr_SM','{name}\n{street}\n{postalCode} {city}\n{country}','^4789\\d?$', false, false, 6, 'Marco\nVia 1\n47890 San Marino\nSan Marino'),
    $mk('VA','addr_VA','{name}\n{street}\n{postalCode} {city}\n{country}','^00120$', false, false, 6, 'Papa\nPiazza 1\n00120 Città del Vaticano\nVaticano'),
    $mk('US','addr_US','{name}\n{street}\n{city}, {region} {postalCode}\n{country}','^\\d{5}(-\\d{4})?$', true, false, 6, 'John Doe\n1600 Pennsylvania Ave NW\nWashington, DC 20500\nUnited States'),
    $mk('CA','addr_CA','{name}\n{street}\n{city} {region} {postalCode}\n{country}','^[A-Za-z]\\d[A-Za-z][ -]?\\d[A-Za-z]\\d$', true, true, 6, 'Jane Doe\n24 Sussex Dr\nOttawa ON K1M 1M4\nCanada'),
    $mk('AU','addr_AU','{name}\n{street}\n{city} {region} {postalCode}\n{country}','^\\d{4}$', true, false, 6, 'John Citizen\n1 Main St\nSydney NSW 2000\nAustralia'),
    $mk('NZ','addr_NZ','{name}\n{street}\n{city} {postalCode}\n{country}','^\\d{4}$', false, false, 6, 'Joe Bloggs\n1 Queen St\nAuckland 1010\nNew Zealand'),
    $mk('JP','addr_JP','{name}\n{postalCode}\n{city} {region}\n{street}\n{country}','^\\d{3}-?\\d{4}$', true, false, 7, '山田 太郎\n100-0001\n千代田区 東京都\n千代田1-1\n日本'),
    $mk('KR','addr_KR','{name}\n{street}\n{city} {postalCode}\n{country}','^\\d{5}$', false, false, 6, 'Kim\nStreet 1\nSeoul 04524\nRepublic of Korea'),
    $mk('TW','addr_TW','{name}\n{street}\n{city} {region} {postalCode}\n{country}','^\\d{3}(?:-?\\d{2})?$', true, false, 6, 'Wang\nStreet 1\nTaipei City Taipei 100\nTaiwan'),
    $mk('HK','addr_HK','{name}\n{street}\n{district}\n{city}\n{country}', NONE, false, false, 7, 'Chan\nStreet 1\nCentral\nHong Kong\nHong Kong'),
    $mk('MO','addr_MO','{name}\n{street}\n{district}\n{city}\n{country}', NONE, false, false, 7, 'Ho\nStreet 1\nSão Lázaro\nMacau\nMacao'),
    $mk('CN','addr_CN','{name}\n{street}\n{city} {region} {postalCode}\n{country}','^\\d{6}$', true, false, 6, '张伟\n长安街1号\n北京市 北京市 100000\n中国'),
    $mk('RU','addr_RU','{name}\n{street}\n{city} {region} {postalCode}\n{country}','^\\d{6}$', true, false, 6, 'Иван Иванов\nул. Тверская, 1\nМосква Москва 101000\nРоссия'),
    $mk('BR','addr_BR','{name}\n{street}\n{city} - {region}\n{postalCode}\n{country}','^\\d{5}-?\\d{3}$', true, false, 7, 'João Silva\nAv. Paulista, 1\nSão Paulo - SP\n01311-000\nBrasil'),
    $mk('MX','addr_MX','{name}\n{street}\n{postalCode} {city}, {region}\n{country}','^\\d{5}$', true, false, 6, 'Juan Pérez\nAv. Reforma 1\n06600 Ciudad de México, CDMX\nMéxico'),
    $mk('IN','addr_IN','{name}\n{street}\n{city} {region} {postalCode}\n{country}','^\\d{6}$', false, false, 6, 'Rahul Sharma\nMG Road 1\nBengaluru KA 560001\nIndia'),
    $mk('AE','addr_AE','{name}\n{street}\n{city}\n{country}', NONE, false, false, 5, 'Mohammed\nStreet 1\nDubai\nUnited Arab Emirates'),
    $mk('QA','addr_QA','{name}\n{street}\n{city} {postalCode}\n{country}', NONE, false, false, 6, 'Ali\nStreet 1\nDoha\nQatar'),

    -- Europe Est / Sud-Est
    $mk('PL','addr_PL','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{2}-\\d{3}$', false, false, 6, 'Jan Kowalski\nUl. Przykladowa 1\n00-001 Warszawa\nPolska'),
    $mk('CZ','addr_CZ','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{3} ?\\d{2}$', false, false, 6, 'Jan Novák\nUlice 1\n110 00 Praha\nČesko'),
    $mk('SK','addr_SK','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{3} ?\\d{2}$', false, false, 6, 'Ján Mrkvička\nUlica 1\n811 01 Bratislava\nSlovensko'),
    $mk('HU','addr_HU','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Kovács Péter\nUtca 1\n1051 Budapest\nMagyarország'),
    $mk('RO','addr_RO','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Ion Popescu\nStr. Exemplu 1\n010011 București\nRomânia'),
    $mk('BG','addr_BG','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Ivan Ivanov\nUl. 1\n1000 Sofia\nBulgaria'),
    $mk('GR','addr_GR','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Γιάννης Παπαδόπουλος\nΟδός 1\n10558 Αθήνα\nΕλλάδα'),
    $mk('TR','addr_TR','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Ahmet Yılmaz\nCadde 1\n34000 İstanbul\nTürkiye'),
    $mk('CY','addr_CY','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Andreas\nStreet 1\n1010 Nicosia\nCyprus'),
    $mk('MT','addr_MT','{name}\n{street}\n{city} {postalCode}\n{country}','^[A-Z]{3} ?\\d{4}$', false, true, 6, 'Joseph\nTriq 1\nValletta VLT 1111\nMalta'),
    $mk('SI','addr_SI','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Janez Novak\nUlica 1\n1000 Ljubljana\nSlovenija'),
    $mk('HR','addr_HR','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Ivan Horvat\nUlica 1\n10000 Zagreb\nHrvatska'),
    $mk('RS','addr_RS','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Marko Markovic\nUlica 1\n11000 Beograd\nSrbija'),
    $mk('BA','addr_BA','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Ivan\nUlica 1\n71000 Sarajevo\nBosna i Hercegovina'),
    $mk('ME','addr_ME','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Petar\nUlica 1\n81000 Podgorica\nCrna Gora'),
    $mk('MK','addr_MK','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Petar\nUlica 1\n1000 Skopje\nSeverna Makedonija'),
    $mk('AL','addr_AL','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Arben\nRruga 1\n1001 Tiranë\nShqipëria'),
    $mk('MD','addr_MD','{name}\n{street}\n{postalCode} {city}\n{country}','^MD-?\\d{4}$', false, true, 6, 'Ion\nStr. 1\nMD-2001 Chișinău\nMoldova'),
    $mk('UA','addr_UA','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Іван Іванов\nВул. 1\n01001 Київ\nУкраїна'),
    $mk('BY','addr_BY','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Іван Іваноў\nВул. 1\n220000 Мінск\nБеларусь'),
    $mk('FO','addr_FO','{name}\n{street}\n{postalCode} {city}\n{country}','^(?:FO-)?\\d{3}$', false, true, 6, 'Jóannes\nGøta 1\n100 Tórshavn\nFøroyar'),
    $mk('JE','addr_JE','{name}\n{street}\n{city}\n{postalCode}\n{country}','^(GIR 0AA|[A-Z]{1,2}\\d[\\dA-Z]? \\d[ABD-HJLNP-UW-Z]{2})$', false, true, 7, 'John\nStreet 1\nSt Helier\nJE2 3AA\nJersey'),
    $mk('GG','addr_GG','{name}\n{street}\n{city}\n{postalCode}\n{country}','^(GIR 0AA|[A-Z]{1,2}\\d[\\dA-Z]? \\d[ABD-HJLNP-UW-Z]{2})$', false, true, 7, 'John\nStreet 1\nSt Peter Port\nGY1 1AA\nGuernsey'),
    $mk('IM','addr_IM','{name}\n{street}\n{city}\n{postalCode}\n{country}','^(GIR 0AA|[A-Z]{1,2}\\d[\\dA-Z]? \\d[ABD-HJLNP-UW-Z]{2})$', false, true, 7, 'John\nStreet 1\nDouglas\nIM1 1AA\nIsle of Man'),

    -- Amériques (principaux)
    $mk('AR','addr_AR','{name}\n{street}\n{postalCode} {city}\n{country}','^[A-Z]?\\d{4}(?:[A-Z]{3})?$', false, true, 6, 'Juan Pérez\nCalle Falsa 123\nC1000 ABC Buenos Aires\nArgentina'),
    $mk('CL','addr_CL','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{7}$', false, false, 6, 'Juan\nCalle 1\n7500000 Santiago\nChile'),
    $mk('CO','addr_CO','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Juan\nCalle 1\n110111 Bogotá\nColombia'),
    $mk('PE','addr_PE','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Juan\nCalle 1\n15001 Lima\nPerú'),
    $mk('UY','addr_UY','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Juan\nCalle 1\n11000 Montevideo\nUruguay'),
    $mk('VE','addr_VE','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Juan\nCalle 1\n1010 Caracas\nVenezuela'),
    $mk('EC','addr_EC','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Juan\nCalle 1\n170515 Quito\nEcuador'),
    $mk('PY','addr_PY','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Juan\nCalle 1\n1209 Asunción\nParaguay'),
    $mk('BO','addr_BO','{name}\n{street}\n{city}\n{country}', NONE, false, false, 6, 'Juan\nCalle 1\nLa Paz\nBolivia'),
    $mk('GT','addr_GT','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Juan\nCalle 1\n01001 Ciudad de Guatemala\nGuatemala'),
    $mk('BZ','addr_BZ','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'John\nStreet 1\n0000 Belize City\nBelize'),
    $mk('SV','addr_SV','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Juan\nCalle 1\n01101 San Salvador\nEl Salvador'),
    $mk('HN','addr_HN','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Juan\nCalle 1\n11101 Tegucigalpa\nHonduras'),
    $mk('NI','addr_NI','{name}\n{street}\n{city} {postalCode}\n{country}', NONE, false, false, 6, 'Juan\nCalle 1\nManagua 11001\nNicaragua'),
    $mk('CR','addr_CR','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Juan\nCalle 1\n10101 San José\nCosta Rica'),
    $mk('PA','addr_PA','{name}\n{street}\n{city} {postalCode}\n{country}', NONE, false, false, 6, 'Juan\nCalle 1\nPanamá 0801\nPanamá'),
    $mk('DO','addr_DO','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Juan\nCalle 1\n10101 Santo Domingo\nRepública Dominicana'),
    $mk('HT','addr_HT','{name}\n{street}\n{postalCode} {city}\n{country}','^(?:HT-)?\\d{4}$', false, true, 6, 'Jean\nRue 1\nHT-6110 Cap-Haïtien\nHaïti'),
    $mk('PR','addr_PR','{name}\n{street}\n{city}, {region} {postalCode}\n{country}','^\\d{5}(-\\d{4})?$', true, false, 6, 'John Doe\nStreet 1\nSan Juan, PR 00901\nPuerto Rico'),

    -- Afrique (quelques pays majeurs)
    $mk('DZ','addr_DZ','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Ahmed\nRue 1\n16000 Alger\nAlgérie'),
    $mk('ZA','addr_ZA','{name}\n{street}\n{city} {postalCode}\n{country}','^\\d{4}$', false, false, 6, 'John\nStreet 1\nCape Town 8001\nSouth Africa'),
    $mk('MA','addr_MA','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Mohamed\nRue 1\n20000 Casablanca\nMaroc'),
    $mk('EG','addr_EG','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Ahmed\nStreet 1\n11511 Cairo\nEgypt'),
    $mk('NG','addr_NG','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Chinedu\nStreet 1\n100001 Lagos\nNigeria'),
    $mk('KE','addr_KE','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'John\nStreet 1\n00100 Nairobi\nKenya'),
    $mk('TN','addr_TN','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Ali\nRue 1\n1001 Tunis\nTunisie'),
    $mk('SN','addr_SN','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Cheikh\nRue 1\n10000 Dakar\nSénégal'),
    $mk('ET','addr_ET','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Abebe\nStreet 1\n1000 Addis Ababa\nEthiopia'),
    $mk('TZ','addr_TZ','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Juma\nStreet 1\n14111 Dar es Salaam\nTanzania')

    -- Asie complémentaires
    $mk('SG','addr_SG','{name}\n{street}\n{city} {postalCode}\n{country}','^\\d{6}$', false, false, 6, 'Tan Ah Kow\nStreet 1\nSingapore 238801\nSingapore'),
    $mk('TH','addr_TH','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Somchai\nStreet 1\n10200 Bangkok\nThailand'),
    $mk('MY','addr_MY','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Ali\nJalan 1\n50450 Kuala Lumpur\nMalaysia'),
    $mk('PH','addr_PH','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Juan\nStreet 1\n1000 Manila\nPhilippines'),
    $mk('ID','addr_ID','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Budi\nJalan 1\n10110 Jakarta\nIndonesia'),
    $mk('PK','addr_PK','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Ali\nStreet 1\n44000 Islamabad\nPakistan'),
    $mk('BD','addr_BD','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Rahman\nStreet 1\n1212 Dhaka\nBangladesh'),
    $mk('LK','addr_LK','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Kumar\nStreet 1\n00100 Colombo\nSri Lanka'),
    $mk('NP','addr_NP','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Ram\nStreet 1\n44600 Kathmandu\nNepal'),
    $mk('VN','addr_VN','{name}\n{street}\n{city} {postalCode}\n{country}','^\\d{6}$', false, false, 6, 'Nguyen\nStreet 1\nHà Nội 100000\nViệt Nam'),
    $mk('KH','addr_KH','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Sok\nStreet 1\n12000 Phnom Penh\nCambodia'),
    $mk('LA','addr_LA','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Som\nStreet 1\n01000 Vientiane\nLaos'),
    $mk('MM','addr_MM','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Aung\nStreet 1\n11181 Yangon\nMyanmar'),
    $mk('MN','addr_MN','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Bat\nStreet 1\n15160 Ulaanbaatar\nMongolia'),
    $mk('GE','addr_GE','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Giorgi\nStreet 1\n0108 Tbilisi\nGeorgia'),
    $mk('AM','addr_AM','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{4}$', false, false, 6, 'Aram\nStreet 1\n0010 Yerevan\nArmenia'),
    $mk('AZ','addr_AZ','{name}\n{street}\n{postalCode} {city}\n{country}','^AZ ?\\d{4}$', false, true, 6, 'Ali\nStreet 1\nAZ1000 Baku\nAzerbaijan'),
    $mk('KZ','addr_KZ','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Nursultan\nStreet 1\n010000 Astana\nKazakhstan'),
    $mk('KG','addr_KG','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Bishkek\nStreet 1\n720000 Bishkek\nKyrgyzstan'),
    $mk('TJ','addr_TJ','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Dushanbe\nStreet 1\n734000 Dushanbe\nTajikistan'),
    $mk('TM','addr_TM','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Ashgabat\nStreet 1\n744000 Ashgabat\nTurkmenistan'),
    $mk('UZ','addr_UZ','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{6}$', false, false, 6, 'Tashkent\nStreet 1\n100000 Tashkent\nUzbekistan'),
    $mk('IL','addr_IL','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{7}$', false, false, 6, 'David\nStreet 1\n6100000 Tel Aviv\nIsrael'),
    $mk('JO','addr_JO','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Omar\nStreet 1\n11110 Amman\nJordan'),
    $mk('KW','addr_KW','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Ali\nStreet 1\n00000 Kuwait City\nKuwait'),
    $mk('PS','addr_PS','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Mohammad\nStreet 1\n97000 Gaza\nPalestine'),
    $mk('SA','addr_SA','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{5}$', false, false, 6, 'Abdullah\nStreet 1\n12211 Riyadh\nSaudi Arabia'),
    $mk('OM','addr_OM','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{3}$', false, false, 6, 'Ali\nStreet 1\n112 Muscat\nOman'),
    $mk('BH','addr_BH','{name}\n{street}\n{postalCode} {city}\n{country}','^\\d{3,4}$', false, false, 6, 'Ali\nStreet 1\n320 Manama\nBahrain')
  ]
};

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_geographic introuvable' }; };
LET $f_rec = fn::builder_function_create_record('base_address_format_seed_initialise', $sm.id, 'Seeds des formats d\'adresse', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_reference', 'log_done', 'log_success'], 'Done: seeds de données base_address_format', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Seeds des formats d\'adresse'
PERMISSIONS FULL;

