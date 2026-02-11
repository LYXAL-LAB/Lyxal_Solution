-- =============================================================================================
-- |
-- | Fichier     : i18n_unit_type.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_unit_type`, une énumération en lecture seule
-- |               pour les types d'unités (poids, longueur, etc.).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_unit_type
  TYPE NORMAL SCHEMAFULL
  COMMENT "Énumération des types d'unités (Poids, Longueur, Volume, etc.)"
  PERMISSIONS
    FOR select FULL;

-- Le nom du type d'unité sera récupéré via la clé i18n
DEFINE FIELD key.name ON i18n_unit_type
  TYPE record<i18n_key>
  COMMENT "Clé i18n pour le nom du type d'unité (ex: 'Poids')";
