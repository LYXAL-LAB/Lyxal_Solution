-- ============================================================================
-- TABLE  : error_external_mapping
-- MODULE : lyxal_error
-- RÔLE   : Mapping des erreurs externes vers les erreurs canoniques Lyxal
-- ============================================================================

DEFINE TABLE IF NOT EXISTS error_external_mapping
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Correspondances entre erreurs externes et codes canoniques Lyxal";


-- ----------------------------------------------------------------------------
-- Fournisseur ou protocole
--
-- Exemples :
-- google
-- microsoft
-- caldav
-- smtp
-- stripe
-- bunny
-- surrealdb
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS provider
    ON TABLE error_external_mapping
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT
        string::len($value) >= 2
        AND string::len($value) <= 64
        AND $value ~ r"^[a-z][a-z0-9_-]+$"
    COMMENT "Nom normalisé du fournisseur ou du protocole externe";


-- ----------------------------------------------------------------------------
-- Service facultatif à l'intérieur du fournisseur
--
-- Exemples :
-- oauth
-- calendar
-- drive
-- smtp
-- api
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS service
    ON TABLE error_external_mapping
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
    COMMENT "Sous-service facultatif du fournisseur";


-- ----------------------------------------------------------------------------
-- Code ou motif externe
--
-- Exemples :
-- invalid_grant
-- 401
-- authentication_failed
-- connection_timeout
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS external_code
    ON TABLE error_external_mapping
    TYPE string
    VALUE string::trim($value)
    ASSERT
        string::len($value) > 0
        AND string::len($value) <= 500
    COMMENT "Code ou motif d'erreur retourné par le système externe";


-- ----------------------------------------------------------------------------
-- Mode de correspondance
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS matcher
    ON TABLE error_external_mapping
    TYPE string
    DEFAULT "exact"
    ASSERT $value IN [
        "exact",
        "prefix",
        "contains",
        "regex",
        "http_status"
    ]
    COMMENT "Méthode utilisée pour reconnaître l'erreur externe";


-- ----------------------------------------------------------------------------
-- Définition Lyxal cible
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS definition
    ON TABLE error_external_mapping
    TYPE record<error_definition>
    COMMENT "Erreur canonique Lyxal correspondant à l'erreur externe";


-- ----------------------------------------------------------------------------
-- Priorité
--
-- Les valeurs les plus basses doivent être évaluées en premier.
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS priority
    ON TABLE error_external_mapping
    TYPE int
    DEFAULT 100
    ASSERT $value >= 0
    COMMENT "Priorité d'évaluation de la règle";


-- ----------------------------------------------------------------------------
-- Statut HTTP externe facultatif
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS external_http_status
    ON TABLE error_external_mapping
    TYPE option<int>
    ASSERT
        $value = NONE
        OR ($value >= 100 AND $value <= 599)
    COMMENT "Statut HTTP externe éventuellement associé";


-- ----------------------------------------------------------------------------
-- Erreur temporaire
--
-- Peut compléter ou surcharger la valeur retryable de la définition.
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS retryable_override
    ON TABLE error_external_mapping
    TYPE option<bool>
    COMMENT "Surcharge facultative du caractère retentable";


-- ----------------------------------------------------------------------------
-- Activation
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS enabled
    ON TABLE error_external_mapping
    TYPE bool
    DEFAULT true
    COMMENT "Active ou désactive cette correspondance";


-- ----------------------------------------------------------------------------
-- Métadonnées propres au fournisseur
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS metadata
    ON TABLE error_external_mapping
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Métadonnées extensibles propres au mapping externe";


-- ----------------------------------------------------------------------------
-- Horodatages
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE error_external_mapping
    TYPE datetime
    VALUE $before OR time::now()
    COMMENT "Date de création immuable";


DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE error_external_mapping
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";


-- ----------------------------------------------------------------------------
-- Index
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS error_external_mapping_unique
    ON TABLE error_external_mapping
    FIELDS provider, service, external_code, matcher
    UNIQUE;


DEFINE INDEX IF NOT EXISTS error_external_mapping_provider_index
    ON TABLE error_external_mapping
    FIELDS provider;


DEFINE INDEX IF NOT EXISTS error_external_mapping_provider_service_index
    ON TABLE error_external_mapping
    FIELDS provider, service;


DEFINE INDEX IF NOT EXISTS error_external_mapping_definition_index
    ON TABLE error_external_mapping
    FIELDS definition;


DEFINE INDEX IF NOT EXISTS error_external_mapping_enabled_priority_index
    ON TABLE error_external_mapping
    FIELDS enabled, priority;