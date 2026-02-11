-- =============================================================================================
-- |
-- | Fichier     : i18n_thousand_separator_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_thousand_separator` avec les séparateurs de base.
-- |
-- =============================================================================================

-- Espace comme séparateur de milliers
CREATE i18n_thousand_separator:space SET symbol = ' ';

-- Virgule comme séparateur de milliers
CREATE i18n_thousand_separator:comma SET symbol = ',';

-- Point comme séparateur de milliers
CREATE i18n_thousand_separator:dot SET symbol = '.';
