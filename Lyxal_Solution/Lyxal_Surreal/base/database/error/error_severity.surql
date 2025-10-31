-- =============================================================================================
-- |
-- | Fichier : error_severity.surql
-- | Module : error / error_severity
-- | Description : Dictionnaire immuable des sévérités d'erreur. Cette table est gérée
-- |               comme du code ; toute modification doit passer par un fichier de
-- |               migration .surql et un déploiement contrôlé.
-- |
-- | Champs :
-- |   - i18n: object
-- |     {
-- |       label: record<i18n_key>,
-- |       description: option<record<i18n_key>>,
-- |       message: option<record<i18n_key>>
-- |     }
-- |   - rank: number (pour ordonner les niveaux, ex: info=20, error=40)
-- |   - is_active: bool (DEFAULT true)
-- |
-- | Index :
-- |   - idx_error_severity_is_active: (is_active)
-- |
-- | Dépendances :
-- |   - i18n_key
-- =============================================================================================
DEFINE TABLE IF NOT EXISTS error_severity TYPE NORMAL SCHEMAFULL
  COMMENT 'Dictionnaire immuable des sévérités d\'erreur'
  PERMISSIONS
    FOR select WHERE is_active = true
    FOR create, update, delete NONE;

  -- Objet I18n
  DEFINE FIELD IF NOT EXISTS i18n ON error_severity
    TYPE object
    COMMENT 'Conteneur pour les références i18n';

  DEFINE FIELD IF NOT EXISTS i18n.label ON error_severity
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n du libellé de la sévérité';

  DEFINE FIELD IF NOT EXISTS i18n.description ON error_severity
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n de la description de la sévérité (optionnelle)';

  DEFINE FIELD IF NOT EXISTS i18n.message ON error_severity
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n pour un message générique lié à la sévérité (optionnelle)';

  DEFINE FIELD IF NOT EXISTS rank ON error_severity
    TYPE number
    COMMENT 'Poids numérique pour ordonner et comparer les niveaux de sévérité';

  DEFINE FIELD IF NOT EXISTS is_active ON error_severity
    TYPE bool
    DEFAULT true
    COMMENT 'Activation de la sévérité';

-- Indexes
DEFINE INDEX IF NOT EXISTS idx_error_severity_is_active ON error_severity
  FIELDS is_active
  COMMENT 'Filtrage par statut actif/inactif';