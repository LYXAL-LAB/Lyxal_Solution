-- =============================================================================================
-- |
-- | Fichier     : i18n_time_notation_i18n_key_translate_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_translation` avec les traductions pour les notations horaires.
-- |
-- =============================================================================================

-- Traductions pour 'i18n.time_notation.12h.name'
RELATE i18n_key:'i18n.time_notation.12h.name'->i18n_translation->i18n_language:fr SET text = 'Format 12 heures';
RELATE i18n_key:'i18n.time_notation.12h.name'->i18n_translation->i18n_language:en SET text = '12-hour format';
RELATE i18n_key:'i18n.time_notation.12h.name'->i18n_translation->i18n_language:es SET text = 'Formato de 12 horas';
RELATE i18n_key:'i18n.time_notation.12h.name'->i18n_translation->i18n_language:de SET text = '12-Stunden-Format';
RELATE i18n_key:'i18n.time_notation.12h.name'->i18n_translation->i18n_language:it SET text = 'Formato 12 ore';

-- Traductions pour 'i18n.time_notation.24h.name'
RELATE i18n_key:'i18n.time_notation.24h.name'->i18n_translation->i18n_language:fr SET text = 'Format 24 heures';
RELATE i18n_key:'i18n.time_notation.24h.name'->i18n_translation->i18n_language:en SET text = '24-hour format';
RELATE i18n_key:'i18n.time_notation.24h.name'->i18n_translation->i18n_language:es SET text = 'Formato de 24 horas';
RELATE i18n_key:'i18n.time_notation.24h.name'->i18n_translation->i18n_language:de SET text = '24-Stunden-Format';
RELATE i18n_key:'i18n.time_notation.24h.name'->i18n_translation->i18n_language:it SET text = 'Formato 24 ore';
