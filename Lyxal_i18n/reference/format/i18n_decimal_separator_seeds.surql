-- =============================================================================================
-- |
-- | Fichier     : i18n_decimal_separator_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_decimal_separator` avec les séparateurs de base.
-- |
-- =============================================================================================

-- Virgule comme séparateur décimal
CREATE i18n_decimal_separator:comma SET symbol = ',';

-- Point comme séparateur décimal
CREATE i18n_decimal_separator:dot SET symbol = '.';
