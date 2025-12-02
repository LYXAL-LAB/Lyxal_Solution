-- =============================================================================================
-- | TABLE : translation
-- | Module : i18n
-- | Description : Table relationnelle des traductions i18n entre `i18n_key` (in)
-- |               et `language` (out). Contrainte d'unicité (in, out).
-- |               Refactorisé selon les conventions Lyxal avec structure modulaire
-- |
-- | Remarques :
-- |   - Type RELATION : conserve les champs `in` et `out` pour la relation
-- |   - Une traduction unique par couple (i18n_key, language)
-- |   - Gestion de l'état de validation des traductions
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS translation SCHEMAFULL
    TYPE RELATION IN i18n_key OUT language ENFORCED
    COMMENT 'Traductions i18n: relation de i18n_key vers language.'
    PERMISSIONS FULL;


-- ============================================================================
-- BLOC CONTENT : Contenu de la traduction
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content ON TABLE translation
    TYPE object
    COMMENT 'Bloc contenu : texte traduit';

    DEFINE FIELD IF NOT EXISTS content.text ON TABLE translation
        TYPE string
        ASSERT $value != NONE AND string::len(string::trim($value)) > 0
        COMMENT 'Texte traduit pour la clé et la langue (non vide)';

-- ============================================================================
-- BLOC STATUS : État de la traduction
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE translation
    TYPE object
    COMMENT 'Bloc statut : état de validation de la traduction';

    DEFINE FIELD IF NOT EXISTS status.is_validated ON TABLE translation
        TYPE bool
        DEFAULT false
        COMMENT 'Indique si la traduction a été validée par un modérateur';

    DEFINE FIELD IF NOT EXISTS status.is_published ON TABLE translation
        TYPE bool
        DEFAULT true
        COMMENT 'Indique si la traduction est publiée (visible dans l\'application)';

    DEFINE FIELD IF NOT EXISTS status.validation_status ON TABLE translation
        TYPE string
        DEFAULT "draft"
        ASSERT $value IN ["draft", "pending", "approved", "rejected"]
        COMMENT 'Statut de validation : "draft" (brouillon), "pending" (en attente), "approved" (approuvée), "rejected" (rejetée)';

    DEFINE FIELD IF NOT EXISTS status.validated_at ON TABLE translation
        TYPE option<datetime>
        COMMENT 'Date de validation de la traduction';

    DEFINE FIELD IF NOT EXISTS status.validated_by ON TABLE translation
        TYPE option<string>
        COMMENT 'Identifiant du validateur de la traduction';

-- ============================================================================
-- BLOC METADATA : Métadonnées de la traduction
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE translation
    TYPE object
    COMMENT 'Bloc métadonnées : informations sur la traduction';

    DEFINE FIELD IF NOT EXISTS metadata.created_at ON TABLE translation
        TYPE datetime
        DEFAULT time::now()
        COMMENT 'Date de création de la traduction';

    DEFINE FIELD IF NOT EXISTS metadata.updated_at ON TABLE translation
        TYPE datetime
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification de la traduction';

    DEFINE FIELD IF NOT EXISTS metadata.created_by ON TABLE translation
        TYPE option<string>
        COMMENT 'Identifiant du créateur de la traduction';

    DEFINE FIELD IF NOT EXISTS metadata.updated_by ON TABLE translation
        TYPE option<string>
        COMMENT 'Identifiant du dernier modificateur de la traduction';

    DEFINE FIELD IF NOT EXISTS metadata.etag ON TABLE translation
        TYPE uuid
        DEFAULT ALWAYS rand::uuid::v7()
        COMMENT 'Contrôle optimiste de version (incrementé à chaque modification)';

    DEFINE FIELD IF NOT EXISTS metadata.source ON TABLE translation
        TYPE string
        DEFAULT "manual"
        ASSERT $value IN ["manual", "auto", "import", "api"]
        COMMENT 'Source de la traduction : "manual" (manuelle), "auto" (automatique), "import" (importée), "api" (via API)';

    DEFINE FIELD IF NOT EXISTS metadata.quality_score ON TABLE translation
        TYPE option<float>
        ASSERT $value = NONE OR ($value >= 0.0 AND $value <= 1.0)
        COMMENT 'Score de qualité de la traduction (0.0 à 1.0) - optionnel';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE translation
        TYPE option<string>
        COMMENT 'Notes ou commentaires sur la traduction';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS translation_unique ON TABLE translation
    FIELDS in, out UNIQUE
    COMMENT 'Une traduction unique par couple (i18n_key, language)';

DEFINE INDEX IF NOT EXISTS idx_translation_language ON TABLE translation
    FIELDS out
    COMMENT 'Index sur la langue pour optimiser les requêtes par langue';

DEFINE INDEX IF NOT EXISTS idx_translation_key ON TABLE translation
    FIELDS in
    COMMENT 'Index sur la clé i18n pour optimiser les requêtes par clé';

DEFINE INDEX IF NOT EXISTS idx_translation_status ON TABLE translation
    FIELDS status.is_published, status.is_validated
    COMMENT 'Index sur le statut pour filtrer les traductions publiées et validées';

DEFINE INDEX IF NOT EXISTS idx_translation_validation_status ON TABLE translation
    FIELDS status.validation_status
    COMMENT 'Index sur le statut de validation';

DEFINE INDEX IF NOT EXISTS idx_translation_created_at ON TABLE translation
    FIELDS metadata.created_at
    COMMENT 'Index sur la date de création pour le tri chronologique';
