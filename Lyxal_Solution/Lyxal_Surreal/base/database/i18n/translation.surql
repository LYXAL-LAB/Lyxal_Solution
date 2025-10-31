-- =============================================================================================
-- |
-- | Fichier : translation.surql
-- | Module : base / i18n
-- | Description : Table relationnelle des traductions i18n entre `i18n_key` (in)
-- |               et `language` (out). Contrainte d'unicité (in, out).
-- |
-- | Champs :
-- |   - in: record<i18n_key> (READONLY, REJECT on delete)
-- |   - out: record<language>   (READONLY, REJECT on delete)
-- |   - text: string (non vide)
-- |   - created_at: datetime (DEFAULT now)
-- |   - updated_at: datetime (VALUE now)
-- |   - etag: int (DEFAULT 1)
-- |
-- | Index :
-- |   - translation_unique: UNIQUE (in, out)
-- |
-- | Dépendances :
-- |   - i18n_key (in)
-- |   - language   (out)
-- =============================================================================================
DEFINE TABLE IF NOT EXISTS translation SCHEMAFULL TYPE RELATION
    COMMENT 'Traductions i18n: relation de i18n_key vers language.'
    PERMISSIONS FULL;

  DEFINE FIELD IF NOT EXISTS in ON TABLE translation
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT 'Clé i18n.';

  DEFINE FIELD IF NOT EXISTS out ON TABLE translation
    TYPE record<language>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT 'Langue de traduction.';

  DEFINE FIELD IF NOT EXISTS text ON TABLE translation
    TYPE string
    COMMENT 'Texte traduit pour la clé et la langue.';

  DEFINE FIELD IF NOT EXISTS created_at ON TABLE translation
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de création.';

  DEFINE FIELD IF NOT EXISTS updated_at ON TABLE translation
    TYPE datetime
    VALUE time::now()
    COMMENT 'Date de mise à jour.';

  DEFINE FIELD IF NOT EXISTS etag ON TABLE translation
    TYPE int
    DEFAULT 1
    COMMENT 'Contrôle optimiste (version)';

  DEFINE INDEX IF NOT EXISTS translation_unique ON TABLE translation
    FIELDS in, out UNIQUE
    COMMENT 'Une traduction par (i18n_key, language).';