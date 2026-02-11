-- =============================================================================================
-- |
-- | Fichier     : i18n_time_pattern_i18n_key_translate_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_translation` avec les traductions pour les noms des formats d'heure.
-- |
-- =============================================================================================

-- 24h_short
RELATE i18n_key:'i18n.time_pattern.24h_short.name'->i18n_translation->i18n_language:fr SET text = 'Heure courte (24h)';
RELATE i18n_key:'i18n.time_pattern.24h_short.name'->i18n_translation->i18n_language:en SET text = 'Short time (24h)';
RELATE i18n_key:'i18n.time_pattern.24h_short.name'->i18n_translation->i18n_language:es SET text = 'Hora corta (24h)';
RELATE i18n_key:'i18n.time_pattern.24h_short.name'->i18n_translation->i18n_language:de SET text = 'Kurze Zeit (24h)';
RELATE i18n_key:'i18n.time_pattern.24h_short.name'->i18n_translation->i18n_language:it SET text = 'Ora breve (24h)';

-- 24h_long
RELATE i18n_key:'i18n.time_pattern.24h_long.name'->i18n_translation->i18n_language:fr SET text = 'Heure longue (24h)';
RELATE i18n_key:'i18n.time_pattern.24h_long.name'->i18n_translation->i18n_language:en SET text = 'Long time (24h)';
RELATE i18n_key:'i18n.time_pattern.24h_long.name'->i18n_translation->i18n_language:es SET text = 'Hora larga (24h)';
RELATE i18n_key:'i18n.time_pattern.24h_long.name'->i18n_translation->i18n_language:de SET text = 'Lange Zeit (24h)';
RELATE i18n_key:'i18n.time_pattern.24h_long.name'->i18n_translation->i18n_language:it SET text = 'Ora lunga (24h)';

-- 12h_short
RELATE i18n_key:'i18n.time_pattern.12h_short.name'->i18n_translation->i18n_language:fr SET text = 'Heure courte (12h)';
RELATE i18n_key:'i18n.time_pattern.12h_short.name'->i18n_translation->i18n_language:en SET text = 'Short time (12h)';
RELATE i18n_key:'i18n.time_pattern.12h_short.name'->i18n_translation->i18n_language:es SET text = 'Hora corta (12h)';
RELATE i18n_key:'i18n.time_pattern.12h_short.name'->i18n_translation->i18n_language:de SET text = 'Kurze Zeit (12h)';
RELATE i18n_key:'i18n.time_pattern.12h_short.name'->i18n_translation->i18n_language:it SET text = 'Ora breve (12h)';

-- 12h_long
RELATE i18n_key:'i18n.time_pattern.12h_long.name'->i18n_translation->i18n_language:fr SET text = 'Heure longue (12h)';
RELATE i18n_key:'i18n.time_pattern.12h_long.name'->i18n_translation->i18n_language:en SET text = 'Long time (12h)';
RELATE i18n_key:'i18n.time_pattern.12h_long.name'->i18n_translation->i18n_language:es SET text = 'Hora larga (12h)';
RELATE i18n_key:'i18n.time_pattern.12h_long.name'->i18n_translation->i18n_language:de SET text = 'Lange Zeit (12h)';
RELATE i18n_key:'i18n.time_pattern.12h_long.name'->i18n_translation->i18n_language:it SET text = 'Ora lunga (12h)';

