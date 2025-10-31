-- =============================================================================================
-- |
-- | Fichier : i18n_key.surql
-- | Module : i18n / i18n_key
-- | Description : Crée la table `i18n_key` (dictionnaire des clés i18n du module i18n).
-- |
-- | Champs :
-- |   - description: option<string>
-- |
-- | Dépendances :
-- |   - Aucune (référencée par i18n_translation)
-- |
-- =============================================================================================
DEFINE TABLE IF NOT EXISTS i18n_key SCHEMAFULL TYPE NORMAL
    COMMENT 'Dictionnaire des clés i18n du module i18n.'
    PERMISSIONS FULL;

  DEFINE FIELD IF NOT EXISTS context ON TABLE i18n_key
  TYPE option<string>
  COMMENT 'Contexte/module de la clé : icon_category, icon, theme, service, etc.';

  DEFINE FIELD IF NOT EXISTS description ON TABLE i18n_key
  TYPE option<string>
  COMMENT 'Description fonctionnelle de la clé (facultatif).';