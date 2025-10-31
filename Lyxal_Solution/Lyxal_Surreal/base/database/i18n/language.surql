-- =============================================================================================
-- |
-- | Fichier : language.surql
-- | Module : i18n
-- | Description : Définit la table `language`, un dictionnaire semi-géré des langues
-- |               supportées par l'application.
-- |
-- | Remarques :
-- |   - Le catalogue des langues est géré par migration (pas de create/delete).
-- |   - L'état d'activation (`isActive`) est géré par l'application via des fonctions dédiées.
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS language SCHEMAFULL
    COMMENT 'Dictionnaire semi-géré des langues supportées (ISO 639-1).'
    PERMISSIONS
        -- Tout le monde peut lire les langues actives
        FOR select WHERE isActive = true
        -- Personne ne peut créer ou supprimer de langues
        FOR create, delete NONE
        -- Seuls les utilisateurs authentifiés peuvent mettre à jour (pour activer/désactiver)
        FOR update WHERE $auth.id != NONE;

-- FIELDS
DEFINE FIELD IF NOT EXISTS code ON TABLE language
    TYPE string
    COMMENT 'Code ISO 639-1 (ex: fr, en)';

DEFINE FIELD IF NOT EXISTS name ON TABLE language
    TYPE string
    COMMENT 'Nom de la langue (ex: French, English)';

DEFINE FIELD IF NOT EXISTS nativeName ON TABLE language
    TYPE option<string>
    COMMENT 'Nom natif (ex: Français, English)';

DEFINE FIELD IF NOT EXISTS icon_drapeau ON TABLE language
    TYPE option<record<system_asset>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Référence vers l''asset du drapeau (table system_asset).';

-- Clé i18n réutilisable pour le nom affiché (évite de dupliquer des traductions côté UI)
DEFINE FIELD IF NOT EXISTS key.name ON TABLE language
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Clé i18n partagée pour le libellé de langue';

-- Direction & Snowball
DEFINE FIELD IF NOT EXISTS direction ON TABLE language
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['ltr','rtl']
    COMMENT 'Direction d\'écriture (ltr/rtl)';

DEFINE FIELD IF NOT EXISTS snowballSupported ON TABLE language
    TYPE bool
    DEFAULT false
    COMMENT 'Support de stemmer Snowball (pour analyzers Surreal)';

-- État
DEFINE FIELD IF NOT EXISTS isActive ON TABLE language
    TYPE bool
    DEFAULT true
    COMMENT 'Langue active';

-- INDEXES
DEFINE INDEX IF NOT EXISTS idx_language_code_unique
    ON TABLE language
    FIELDS code UNIQUE
    COMMENT 'Unicité du code de la langue';

DEFINE INDEX IF NOT EXISTS idx_language_name
    ON TABLE language
    FIELDS name
    COMMENT 'Nom de la langue';