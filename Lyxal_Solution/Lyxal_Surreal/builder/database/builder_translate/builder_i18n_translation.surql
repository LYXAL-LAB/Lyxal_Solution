-- =============================================================================================
-- |
-- | Fichier : builder_i18n_translation.surql
-- | Module : builder / translate
-- | Description : Table relationnelle des traductions i18n entre `builder_i18n_key` (in)
-- |               et `i18n_language` (out). Contrainte d'unicité (in, out).
-- |
-- | Champs :
-- |   - in: record<builder_i18n_key> (READONLY, REJECT on delete)
-- |   - out: record<i18n_language>   (READONLY, REJECT on delete)
-- |   - text: string (non vide)
-- |   - created_at: datetime (DEFAULT now)
-- |   - updated_at: datetime (VALUE now)
-- |   - etag: int (DEFAULT 1)
-- |
-- | Index :
-- |   - i18n_translation_unique: UNIQUE (in, out)
-- |
-- | Dépendances :
-- |   - builder_i18n_key (in)
-- |   - i18n_language   (out)
-- =============================================================================================
DEFINE TABLE IF NOT EXISTS builder_i18n_translation SCHEMAFULL TYPE RELATION
    COMMENT 'Traductions i18n: relation de builder_i18n_key vers i18n_language.'
    PERMISSIONS FULL;

  DEFINE FIELD IF NOT EXISTS in ON TABLE builder_i18n_translation
    TYPE record<builder_i18n_key>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT 'Clé i18n.';

  DEFINE FIELD IF NOT EXISTS out ON TABLE builder_i18n_translation
    TYPE record<i18n_language>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT 'Langue de traduction.';

  DEFINE FIELD IF NOT EXISTS text ON TABLE builder_i18n_translation
    TYPE string
    ASSERT string::len(string::trim($value)) > 0
    COMMENT 'Texte traduit pour la clé et la langue.';

  DEFINE FIELD IF NOT EXISTS created_at ON TABLE builder_i18n_translation
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de création.';

  DEFINE FIELD IF NOT EXISTS updated_at ON TABLE builder_i18n_translation
    TYPE datetime
    VALUE time::now()
    COMMENT 'Date de mise à jour.';

  DEFINE FIELD IF NOT EXISTS etag ON TABLE builder_i18n_translation
    TYPE int
    DEFAULT 1
    COMMENT 'Contrôle optimiste (version)';

  DEFINE INDEX IF NOT EXISTS i18n_translation_unique ON TABLE builder_i18n_translation
    FIELDS in, out UNIQUE
    COMMENT 'Une traduction par (clé, langue).';