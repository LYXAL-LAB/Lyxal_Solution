-- =============================================================================================
-- |
-- | Fichier     : i18n_unit.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_unit`, un référentiel en lecture seule
-- |               pour les unités de mesure (poids, volume, etc.).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_unit
  TYPE NORMAL SCHEMAFULL
  COMMENT "Référentiel des unités de mesure (kg, m, L, etc.)"
  PERMISSIONS
    FOR select FULL;

-- Le nom de l'unité sera récupéré via la clé i18n
DEFINE FIELD key.name ON i18n_unit
  TYPE record<i18n_key>
  COMMENT "Clé i18n pour le nom de l'unité (ex: 'Kilogramme')";

-- Le symbole ou l'abréviation de l'unité
DEFINE FIELD symbol ON i18n_unit
  TYPE string
  COMMENT "Symbole ou abréviation de l'unité (ex: 'kg')";

-- Type d'unité pour le regroupement ou la logique métier
DEFINE FIELD unit_type ON i18n_unit
  TYPE record<i18n_unit_type>
  COMMENT "Référence au type d'unité (poids, volume, etc.)";

-- Index pour assurer l'unicité du symbole
DEFINE INDEX IF NOT EXISTS idx_i18n_unit_symbol_unique
  ON TABLE i18n_unit
  FIELDS symbol UNIQUE;

