-- =============================================================================================
-- |
-- | Fichier : error_code.surql
-- | Module : error / error_code
-- | Description : Registre immuable des codes d'erreur. Géré via les déploiements (seeds),
-- |               non modifiable par l'application.
-- |
-- | Champs :
-- |   - success_result: bool (dérivé de severity)
-- |   - severity: record<error_severity>
-- |   - i18n: object
-- |     {
-- |       message: record<i18n_key>,
-- |       description: option<record<i18n_key>>
-- |     }
-- |   - metadata: option<object>
-- |   - payload: option<object>
-- |
-- =============================================================================================
DEFINE TABLE IF NOT EXISTS error_code TYPE NORMAL SCHEMAFULL
  COMMENT 'Registre immuable des codes d''erreur'
  PERMISSIONS
    FOR select FULL
    FOR create, update, delete NONE;

  DEFINE FIELD IF NOT EXISTS success_result ON error_code
    TYPE bool
    COMMENT 'Résultat booléen dérivé de severity';

  DEFINE FIELD IF NOT EXISTS severity ON error_code
    TYPE record<error_severity>
    REFERENCE ON DELETE REJECT
    COMMENT 'Sévérité (référence dynamique)';

  -- Objet I18n
  DEFINE FIELD IF NOT EXISTS i18n ON error_code
    TYPE object
    COMMENT 'Conteneur pour les références i18n';

  DEFINE FIELD IF NOT EXISTS i18n.message ON error_code
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n associée au message principal';

  DEFINE FIELD IF NOT EXISTS i18n.description ON error_code
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description lisible du code (documentation technique)';

  DEFINE FIELD IF NOT EXISTS metadata ON error_code
    FLEXIBLE
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Payload libre (catégorie, action recommandée, etc.)';

  DEFINE FIELD IF NOT EXISTS payload ON error_code
    FLEXIBLE
    TYPE option<object>
    DEFAULT {}
    COMMENT 'Informations complémentaires';

-- Indexes
DEFINE INDEX IF NOT EXISTS idx_error_code_success_result ON error_code
  FIELDS success_result
  COMMENT 'Filtrage par résultat de succès';

DEFINE INDEX IF NOT EXISTS idx_error_code_severity ON error_code
  FIELDS severity
  COMMENT 'Filtrage par sévérité';