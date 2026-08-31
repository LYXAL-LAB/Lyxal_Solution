-- ============================================================================
-- TABLE  : error_definition
-- MODULE : lyxal_error
-- RÔLE   : Catalogue canonique de toutes les erreurs Lyxal
-- ============================================================================

DEFINE TABLE OVERWRITE error_definition
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Catalogue central des codes d'erreur de tous les modules Lyxal";


-- ----------------------------------------------------------------------------
-- Code canonique
-- Exemple : BOOKING_USERNAME_EMAIL_INVALID
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE code
    ON TABLE error_definition
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT
        string::len($value) >= 3
        AND string::len($value) <= 128
        AND $value ~ r"^[A-Z][A-Z0-9_]+$"
    COMMENT "Code technique stable et unique de l'erreur";


-- ----------------------------------------------------------------------------
-- Module propriétaire
-- Exemples : booking, auth, notification, webhook
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE module
    ON TABLE error_definition
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT
        string::len($value) >= 2
        AND string::len($value) <= 64
        AND $value ~ r"^[a-z][a-z0-9_-]+$"
    COMMENT "Module Lyxal propriétaire du code d'erreur";


-- ----------------------------------------------------------------------------
-- Domaine fonctionnel facultatif
-- Exemple : username, booking, oauth, smtp
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE domain
    ON TABLE error_definition
    TYPE option<string>
    VALUE {
        IF $value = NONE OR $value = "" {
            NONE
        } ELSE {
            string::lowercase(string::trim($value))
        }
    }
    ASSERT
        $value = NONE
        OR (
            string::len($value) >= 2
            AND string::len($value) <= 64
            AND $value ~ r"^[a-z][a-z0-9_-]+$"
        )
    COMMENT "Sous-domaine fonctionnel de l'erreur";


-- ----------------------------------------------------------------------------
-- Catégorie générale
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE category
    ON TABLE error_definition
    TYPE string
    DEFAULT "business"
    ASSERT $value IN [
        "validation",
        "business",
        "authentication",
        "authorization",
        "not_found",
        "conflict",
        "rate_limit",
        "dependency",
        "network",
        "timeout",
        "internal"
    ]
    COMMENT "Catégorie normalisée de l'erreur";


-- ----------------------------------------------------------------------------
-- Niveau de gravité
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE severity
    ON TABLE error_definition
    TYPE string
    DEFAULT "error"
    ASSERT $value IN [
        "info",
        "warning",
        "error",
        "critical"
    ]
    COMMENT "Niveau de gravité de l'erreur";


-- ----------------------------------------------------------------------------
-- Message technique canonique
-- Généralement conservé en anglais pour les développeurs et les logs
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE message
    ON TABLE error_definition
    TYPE string
    VALUE string::trim($value)
    ASSERT
        string::len($value) > 0
        AND string::len($value) <= 1000
    COMMENT "Message technique canonique de l'erreur";


-- ----------------------------------------------------------------------------
-- Traductions
--
-- Exemple :
--
-- {
--     fr: {
--         label: "Adresse e-mail invalide",
--         description: "L'adresse e-mail saisie n'est pas valide.",
--         resolution: "Vérifiez l'adresse saisie."
--     },
--     en: {
--         label: "Invalid email address",
--         description: "The provided email address is invalid.",
--         resolution: "Check the provided email address."
--     }
-- }
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE translations
    ON TABLE error_definition
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Traductions indexées par code langue";


-- ----------------------------------------------------------------------------
-- Langue de repli
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE default_language
    ON TABLE error_definition
    TYPE string
    DEFAULT "en"
    VALUE string::lowercase(string::trim($value))
    ASSERT $value ~ r"^[a-z]{2}(-[a-z]{2})?$"
    COMMENT "Langue utilisée lorsqu'une traduction demandée est absente";


-- ----------------------------------------------------------------------------
-- Statut HTTP suggéré
-- Il reste facultatif car certaines erreurs ne transitent pas par HTTP
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE http_status
    ON TABLE error_definition
    TYPE option<int>
    ASSERT
        $value = NONE
        OR ($value >= 400 AND $value <= 599)
    COMMENT "Statut HTTP recommandé";


-- ----------------------------------------------------------------------------
-- Nouvelle tentative
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE retryable
    ON TABLE error_definition
    TYPE bool
    DEFAULT false
    COMMENT "Indique si l'opération peut être retentée automatiquement";


-- ----------------------------------------------------------------------------
-- Journalisation des occurrences
-- Certaines erreurs de validation courantes peuvent ne pas nécessiter de log
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE log_occurrence
    ON TABLE error_definition
    TYPE bool
    DEFAULT true
    COMMENT "Indique si les occurrences doivent être journalisées";


-- ----------------------------------------------------------------------------
-- Activation
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE enabled
    ON TABLE error_definition
    TYPE bool
    DEFAULT true
    COMMENT "Permet de désactiver une définition sans la supprimer";


-- ----------------------------------------------------------------------------
-- Documentation associée
--
-- Exemple :
-- {
--     developer_url: "https://docs.lyxal.dev/errors/...",
--     user_url: "https://help.lyxal.com/errors/..."
-- }
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE documentation
    ON TABLE error_definition
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Documentation technique et utilisateur associée";


-- ----------------------------------------------------------------------------
-- Métadonnées extensibles
--
-- Exemple :
-- {
--     icon: "triangle-alert",
--     ui_variant: "danger",
--     tags: ["email", "validation"]
-- }
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE metadata
    ON TABLE error_definition
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Métadonnées extensibles propres aux modules";


-- ----------------------------------------------------------------------------
-- Version du contrat d'erreur
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE version
    ON TABLE error_definition
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1
    COMMENT "Version de la définition du code d'erreur";


-- ----------------------------------------------------------------------------
-- Horodatages
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE created_at
    ON TABLE error_definition
    TYPE datetime
    VALUE $before OR time::now()
    COMMENT "Date de création immuable";


DEFINE FIELD OVERWRITE updated_at
    ON TABLE error_definition
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";


-- ----------------------------------------------------------------------------
-- Index
-- ----------------------------------------------------------------------------

DEFINE INDEX OVERWRITE error_definition_code_unique
    ON TABLE error_definition
    FIELDS code
    UNIQUE;


DEFINE INDEX OVERWRITE error_definition_module_index
    ON TABLE error_definition
    FIELDS module;


DEFINE INDEX OVERWRITE error_definition_module_domain_index
    ON TABLE error_definition
    FIELDS module, domain;


DEFINE INDEX OVERWRITE error_definition_category_index
    ON TABLE error_definition
    FIELDS category;


DEFINE INDEX OVERWRITE error_definition_enabled_index
    ON TABLE error_definition
    FIELDS enabled;