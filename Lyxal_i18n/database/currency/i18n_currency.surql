-- =============================================================================================
-- |
-- | Fichier     : i18n_currency.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_currency`, un référentiel en lecture seule
-- |               pour les devises (symboles, décimales, etc.).
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_currency 
  TYPE NORMAL SCHEMAFULL 
  COMMENT 'Référentiel des devises (symbole, décimales, position, etc.)'
  PERMISSIONS 
    FOR select FULL;

  -- Le nom de la devise sera récupéré via la clé i18n
  DEFINE FIELD key.name ON i18n_currency 
  TYPE record<i18n_key>
  COMMENT 'Clé i18n pour le nom de la devise (ex: "Euro")';

  DEFINE FIELD symbol ON i18n_currency TYPE option<string>
  COMMENT 'Symbole de la devise (ex: €)';
  
  DEFINE FIELD decimals ON i18n_currency TYPE int
  ASSERT $value >= 0
  COMMENT 'Nombre de décimales utilisées par la devise';

  DEFINE FIELD symbol_position ON i18n_currency 
  TYPE record<i18n_currency_symbol_position>
  COMMENT 'Référence à la position du symbole (avant ou après le montant)';

