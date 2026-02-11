-- =============================================================================================
-- |
-- | Fichier     : i18n_date_pattern_i18n_key_translate_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_translation` avec les traductions pour les noms des formats de date.
-- |
-- =============================================================================================

-- iso_short
RELATE i18n_key:'i18n.date_pattern.iso_short.name'->i18n_translation->i18n_language:fr SET text = 'Date ISO (AAAA-MM-JJ)';
RELATE i18n_key:'i18n.date_pattern.iso_short.name'->i18n_translation->i18n_language:en SET text = 'ISO Date (YYYY-MM-DD)';
RELATE i18n_key:'i18n.date_pattern.iso_short.name'->i18n_translation->i18n_language:es SET text = 'Fecha ISO (AAAA-MM-DD)';
RELATE i18n_key:'i18n.date_pattern.iso_short.name'->i18n_translation->i18n_language:de SET text = 'ISO-Datum (JJJJ-MM-TT)';
RELATE i18n_key:'i18n.date_pattern.iso_short.name'->i18n_translation->i18n_language:it SET text = 'Data ISO (AAAA-MM-GG)';

-- eu_short
RELATE i18n_key:'i18n.date_pattern.eu_short.name'->i18n_translation->i18n_language:fr SET text = 'Date courte (JJ/MM/AAAA)';
RELATE i18n_key:'i18n.date_pattern.eu_short.name'->i18n_translation->i18n_language:en SET text = 'Short Date (DD/MM/YYYY)';
RELATE i18n_key:'i18n.date_pattern.eu_short.name'->i18n_translation->i18n_language:es SET text = 'Fecha corta (DD/MM/AAAA)';
RELATE i18n_key:'i18n.date_pattern.eu_short.name'->i18n_translation->i18n_language:de SET text = 'Kurzes Datum (TT/MM/JJJJ)';
RELATE i18n_key:'i18n.date_pattern.eu_short.name'->i18n_translation->i18n_language:it SET text = 'Data breve (GG/MM/AAAA)';

-- us_short
RELATE i18n_key:'i18n.date_pattern.us_short.name'->i18n_translation->i18n_language:fr SET text = 'Date US (MM/JJ/AAAA)';
RELATE i18n_key:'i18n.date_pattern.us_short.name'->i18n_translation->i18n_language:en SET text = 'US Date (MM/DD/YYYY)';
RELATE i18n_key:'i18n.date_pattern.us_short.name'->i18n_translation->i18n_language:es SET text = 'Fecha de EE. UU. (MM/DD/AAAA)';
RELATE i18n_key:'i18n.date_pattern.us_short.name'->i18n_translation->i18n_language:de SET text = 'US-Datum (MM/TT/JJJJ)';
RELATE i18n_key:'i18n.date_pattern.us_short.name'->i18n_translation->i18n_language:it SET text = 'Data USA (MM/GG/AAAA)';

-- text_short
RELATE i18n_key:'i18n.date_pattern.text_short.name'->i18n_translation->i18n_language:fr SET text = 'Date textuelle courte';
RELATE i18n_key:'i18n.date_pattern.text_short.name'->i18n_translation->i18n_language:en SET text = 'Short text date';
RELATE i18n_key:'i18n.date_pattern.text_short.name'->i18n_translation->i18n_language:es SET text = 'Fecha de texto corta';
RELATE i18n_key:'i18n.date_pattern.text_short.name'->i18n_translation->i18n_language:de SET text = 'Kurzes Textdatum';
RELATE i18n_key:'i18n.date_pattern.text_short.name'->i18n_translation->i18n_language:it SET text = 'Data testuale breve';

-- text_medium
RELATE i18n_key:'i18n.date_pattern.text_medium.name'->i18n_translation->i18n_language:fr SET text = 'Date textuelle moyenne';
RELATE i18n_key:'i18n.date_pattern.text_medium.name'->i18n_translation->i18n_language:en SET text = 'Medium text date';
RELATE i18n_key:'i18n.date_pattern.text_medium.name'->i18n_translation->i18n_language:es SET text = 'Fecha de texto mediana';
RELATE i18n_key:'i18n.date_pattern.text_medium.name'->i18n_translation->i18n_language:de SET text = 'Mittleres Textdatum';
RELATE i18n_key:'i18n.date_pattern.text_medium.name'->i18n_translation->i18n_language:it SET text = 'Data testuale media';

-- text_long
RELATE i18n_key:'i18n.date_pattern.text_long.name'->i18n_translation->i18n_language:fr SET text = 'Date textuelle longue';
RELATE i18n_key:'i18n.date_pattern.text_long.name'->i18n_translation->i18n_language:en SET text = 'Long text date';
RELATE i18n_key:'i18n.date_pattern.text_long.name'->i18n_translation->i18n_language:es SET text = 'Fecha de texto larga';
RELATE i18n_key:'i18n.date_pattern.text_long.name'->i18n_translation->i18n_language:de SET text = 'Langes Textdatum';
RELATE i18n_key:'i18n.date_pattern.text_long.name'->i18n_translation->i18n_language:it SET text = 'Data testuale lunga';

-- iso_datetime
RELATE i18n_key:'i18n.date_pattern.iso_datetime.name'->i18n_translation->i18n_language:fr SET text = 'Date et heure ISO';
RELATE i18n_key:'i18n.date_pattern.iso_datetime.name'->i18n_translation->i18n_language:en SET text = 'ISO date & time';
RELATE i18n_key:'i18n.date_pattern.iso_datetime.name'->i18n_translation->i18n_language:es SET text = 'Fecha y hora ISO';
RELATE i18n_key:'i18n.date_pattern.iso_datetime.name'->i18n_translation->i18n_language:de SET text = 'ISO-Datum und -Uhrzeit';
RELATE i18n_key:'i18n.date_pattern.iso_datetime.name'->i18n_translation->i18n_language:it SET text = 'Data e ora ISO';

-- eu_datetime
RELATE i18n_key:'i18n.date_pattern.eu_datetime.name'->i18n_translation->i18n_language:fr SET text = 'Date et heure courtes';
RELATE i18n_key:'i18n.date_pattern.eu_datetime.name'->i18n_translation->i18n_language:en SET text = 'Short date & time';
RELATE i18n_key:'i18n.date_pattern.eu_datetime.name'->i18n_translation->i18n_language:es SET text = 'Fecha y hora cortas';
RELATE i18n_key:'i18n.date_pattern.eu_datetime.name'->i18n_translation->i18n_language:de SET text = 'Kurzes Datum und Uhrzeit';
RELATE i18n_key:'i18n.date_pattern.eu_datetime.name'->i18n_translation->i18n_language:it SET text = 'Data e ora brevi';
