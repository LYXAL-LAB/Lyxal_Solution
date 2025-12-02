-- =============================================================================================
-- |
-- | Fichier     : i18n_currency_symbol_position.surql
-- | Module      : i18n
-- | Description : Définit la table `i18n_currency_symbol_position`, une énumération
-- |               en lecture seule pour la position du symbole monétaire.
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS i18n_currency_symbol_position 
  TYPE NORMAL SCHEMAFULL 
  COMMENT 'Énumération de la position du symbole monétaire (avant/après)'
  PERMISSIONS 
    FOR select FULL;

  DEFINE FIELD IF NOT EXISTS code ON TABLE i18n_currency_symbol_position 
  TYPE string
  COMMENT 'Position du symbole (before | after)';

  DEFINE FIELD IF NOT EXISTS key.name ON TABLE i18n_currency_symbol_position 
  TYPE option<record<i18n_key>>
  COMMENT 'Clé i18n du libellé pour la traduction (ex: "Avant le montant")';

  DEFINE INDEX IF NOT EXISTS idx_i18n_currency_symbol_position_code_unique 
  ON TABLE i18n_currency_symbol_position 
  FIELDS code UNIQUE
  COMMENT 'Unicité du code de la position du symbole monétaire';