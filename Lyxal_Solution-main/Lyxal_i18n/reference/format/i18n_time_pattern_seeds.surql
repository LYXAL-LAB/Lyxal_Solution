-- =============================================================================================
-- |
-- | Fichier     : i18n_time_pattern_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_time_pattern` avec des formats d'heure courants.
-- |
-- =============================================================================================

CREATE i18n_time_pattern:24h_short
  SET pattern = 'HH:mm',
      skeleton = 'Hm',
      key.name = i18n_key:'i18n.time_pattern.24h_short.name';

CREATE i18n_time_pattern:24h_long
  SET pattern = 'HH:mm:ss',
      skeleton = 'Hms',
      key.name = i18n_key:'i18n.time_pattern.24h_long.name';

CREATE i18n_time_pattern:12h_short
  SET pattern = 'h:mm a',
      skeleton = 'hm',
      key.name = i18n_key:'i18n.time_pattern.12h_short.name';

CREATE i18n_time_pattern:12h_long
  SET pattern = 'h:mm:ss a',
      skeleton = 'hms',
      key.name = i18n_key:'i18n.time_pattern.12h_long.name';

