-- =============================================================================================
-- |
-- | Fichier     : i18n_week_start_i18n_key_translate_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_translation` avec les traductions pour les jours de la semaine.
-- |
-- =============================================================================================

-- Lundi
RELATE i18n_key:'i18n.week_day.1.name'->i18n_translation->i18n_language:fr SET text = 'Lundi';
RELATE i18n_key:'i18n.week_day.1.name'->i18n_translation->i18n_language:en SET text = 'Monday';
RELATE i18n_key:'i18n.week_day.1.name'->i18n_translation->i18n_language:es SET text = 'Lunes';
RELATE i18n_key:'i18n.week_day.1.name'->i18n_translation->i18n_language:de SET text = 'Montag';
RELATE i18n_key:'i18n.week_day.1.name'->i18n_translation->i18n_language:it SET text = 'Lunedì';

-- Mardi
RELATE i18n_key:'i18n.week_day.2.name'->i18n_translation->i18n_language:fr SET text = 'Mardi';
RELATE i18n_key:'i18n.week_day.2.name'->i18n_translation->i18n_language:en SET text = 'Tuesday';
RELATE i18n_key:'i18n.week_day.2.name'->i18n_translation->i18n_language:es SET text = 'Martes';
RELATE i18n_key:'i18n.week_day.2.name'->i18n_translation->i18n_language:de SET text = 'Dienstag';
RELATE i18n_key:'i18n.week_day.2.name'->i18n_translation->i18n_language:it SET text = 'Martedì';

-- Mercredi
RELATE i18n_key:'i18n.week_day.3.name'->i18n_translation->i18n_language:fr SET text = 'Mercredi';
RELATE i18n_key:'i18n.week_day.3.name'->i18n_translation->i18n_language:en SET text = 'Wednesday';
RELATE i18n_key:'i18n.week_day.3.name'->i18n_translation->i18n_language:es SET text = 'Miércoles';
RELATE i18n_key:'i18n.week_day.3.name'->i18n_translation->i18n_language:de SET text = 'Mittwoch';
RELATE i18n_key:'i18n.week_day.3.name'->i18n_translation->i18n_language:it SET text = 'Mercoledì';

-- Jeudi
RELATE i18n_key:'i18n.week_day.4.name'->i18n_translation->i18n_language:fr SET text = 'Jeudi';
RELATE i18n_key:'i18n.week_day.4.name'->i18n_translation->i18n_language:en SET text = 'Thursday';
RELATE i18n_key:'i18n.week_day.4.name'->i18n_translation->i18n_language:es SET text = 'Jueves';
RELATE i18n_key:'i18n.week_day.4.name'->i18n_translation->i18n_language:de SET text = 'Donnerstag';
RELATE i18n_key:'i18n.week_day.4.name'->i18n_translation->i18n_language:it SET text = 'Giovedì';

-- Vendredi
RELATE i18n_key:'i18n.week_day.5.name'->i18n_translation->i18n_language:fr SET text = 'Vendredi';
RELATE i18n_key:'i18n.week_day.5.name'->i18n_translation->i18n_language:en SET text = 'Friday';
RELATE i18n_key:'i18n.week_day.5.name'->i18n_translation->i18n_language:es SET text = 'Viernes';
RELATE i18n_key:'i18n.week_day.5.name'->i18n_translation->i18n_language:de SET text = 'Freitag';
RELATE i18n_key:'i18n.week_day.5.name'->i18n_translation->i18n_language:it SET text = 'Venerdì';

-- Samedi
RELATE i18n_key:'i18n.week_day.6.name'->i18n_translation->i18n_language:fr SET text = 'Samedi';
RELATE i18n_key:'i18n.week_day.6.name'->i18n_translation->i18n_language:en SET text = 'Saturday';
RELATE i18n_key:'i18n.week_day.6.name'->i18n_translation->i18n_language:es SET text = 'Sábado';
RELATE i18n_key:'i18n.week_day.6.name'->i18n_translation->i18n_language:de SET text = 'Samstag';
RELATE i18n_key:'i18n.week_day.6.name'->i18n_translation->i18n_language:it SET text = 'Sabato';

-- Dimanche
RELATE i18n_key:'i18n.week_day.7.name'->i18n_translation->i18n_language:fr SET text = 'Dimanche';
RELATE i18n_key:'i18n.week_day.7.name'->i18n_translation->i18n_language:en SET text = 'Sunday';
RELATE i18n_key:'i18n.week_day.7.name'->i18n_translation->i18n_language:es SET text = 'Domingo';
RELATE i18n_key:'i18n.week_day.7.name'->i18n_translation->i18n_language:de SET text = 'Sonntag';
RELATE i18n_key:'i18n.week_day.7.name'->i18n_translation->i18n_language:it SET text = 'Domenica';
