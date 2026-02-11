-- =============================================================================================
-- |
-- | Fichier : builder_i18n_key.surql
-- | Module : builder / builder_i18n_key
-- | Description : Crée la table `builder_i18n_key` (dictionnaire des clés i18n du module builder).
-- |
-- | Champs :
-- |   - description: option<string>
-- |   - created_at: datetime (VALUE now)
-- |   - updated_at: datetime (DEFAULT now)
-- |   - etag: int (DEFAULT 1)
-- |
-- | Dépendances :
-- |   - Aucune (référencée par builder_i18n_translation)
-- |
-- =============================================================================================
DEFINE TABLE IF NOT EXISTS builder_i18n_key SCHEMAFULL TYPE NORMAL
    COMMENT 'Dictionnaire des clés i18n du module builder.'
    PERMISSIONS FULL;

  DEFINE FIELD IF NOT EXISTS description ON TABLE builder_i18n_key
  TYPE option<string>
  COMMENT 'Description fonctionnelle de la clé (facultatif).';

  DEFINE FIELD IF NOT EXISTS created_at ON TABLE builder_i18n_key
  TYPE datetime
  VALUE time::now()
  COMMENT 'Date de création.';

  DEFINE FIELD IF NOT EXISTS updated_at ON TABLE builder_i18n_key
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Date de mise à jour.';

  DEFINE FIELD IF NOT EXISTS etag ON TABLE builder_i18n_key
  TYPE int
  DEFAULT 1
  COMMENT 'Contrôle optimiste (version)';