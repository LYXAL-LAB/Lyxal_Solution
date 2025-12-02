-- =============================================================================================
-- |
-- | Fichier     : i18n_date_pattern_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_date_pattern` avec des formats de date courants.
-- |
-- =============================================================================================

CREATE i18n_date_pattern:iso_short 
  SET pattern = 'yyyy-MM-dd', 
      skeleton = 'yMd',
      key.name = i18n_key:'i18n.date_pattern.iso_short.name';

CREATE i18n_date_pattern:eu_short 
  SET pattern = 'dd/MM/yyyy', 
      skeleton = 'yMd',
      key.name = i18n_key:'i18n.date_pattern.eu_short.name';

CREATE i18n_date_pattern:us_short 
  SET pattern = 'MM/dd/yyyy', 
      skeleton = 'yMd',
      key.name = i18n_key:'i18n.date_pattern.us_short.name';

CREATE i18n_date_pattern:text_short 
  SET pattern = 'd MMM yyyy', 
      skeleton = 'yMMMd',
      key.name = i18n_key:'i18n.date_pattern.text_short.name';

CREATE i18n_date_pattern:text_medium 
  SET pattern = 'MMMM d, yyyy', 
      skeleton = 'yMMMMd',
      key.name = i18n_key:'i18n.date_pattern.text_medium.name';

CREATE i18n_date_pattern:text_long 
  SET pattern = 'EEEE, MMMM d, yyyy', 
      skeleton = 'yMMMMEEEEd',
      key.name = i18n_key:'i18n.date_pattern.text_long.name';

CREATE i18n_date_pattern:iso_datetime 
  SET pattern = 'yyyy-MM-dd HH:mm:ss', 
      skeleton = 'yMdHms',
      key.name = i18n_key:'i18n.date_pattern.iso_datetime.name';

CREATE i18n_date_pattern:eu_datetime 
  SET pattern = 'dd/MM/yyyy HH:mm', 
      skeleton = 'yMdHm',
      key.name = i18n_key:'i18n.date_pattern.eu_datetime.name';
