-- ============================================================================
-- TABLE  : error_occurrence
-- MODULE : lyxal_error
-- RÔLE   : Journal append-only des erreurs réellement survenues
-- ============================================================================

DEFINE TABLE OVERWRITE error_occurrence
    TYPE NORMAL
    SCHEMAFULL

    PERMISSIONS
        FOR select NONE
        FOR create NONE
        FOR update NONE
        FOR delete NONE

    COMMENT "Journal technique append-only des occurrences d'erreurs Lyxal";


-- ----------------------------------------------------------------------------
-- Référence facultative vers le catalogue
--
-- Elle est facultative pour permettre de journaliser une erreur inconnue
-- ou non encore enregistrée dans error_definition.
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE definition
    ON TABLE error_occurrence
    TYPE option<record<error_definition>>
    COMMENT "Définition canonique associée lorsqu'elle existe";


-- ----------------------------------------------------------------------------
-- Copie du code
--
-- Le code est conservé directement dans l'occurrence afin que le journal
-- reste lisible même si une définition est ensuite modifiée ou désactivée.
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE code
    ON TABLE error_occurrence
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT
        string::len($value) >= 3
        AND string::len($value) <= 128
        AND $value ~ r"^[A-Z][A-Z0-9_]+$"
    COMMENT "Code d'erreur au moment de l'occurrence";


-- ----------------------------------------------------------------------------
-- Module source
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE source_module
    ON TABLE error_occurrence
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT
        string::len($value) >= 2
        AND string::len($value) <= 64
        AND $value ~ r"^[a-z][a-z0-9_-]+$"
    COMMENT "Module ayant produit l'erreur";


-- ----------------------------------------------------------------------------
-- Opération concernée
--
-- Exemples :
-- booking_generate_username
-- booking_create
-- caldav_sync
-- notification_send
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE operation
    ON TABLE error_occurrence
    TYPE option<string>
    VALUE {
        IF $value = NONE OR $value = "" {
            NONE
        } ELSE {
            string::trim($value)
        }
    }
    ASSERT
        $value = NONE
        OR (
            string::len($value) > 0
            AND string::len($value) <= 255
        )
    COMMENT "Fonction ou opération à l'origine de l'erreur";


-- ----------------------------------------------------------------------------
-- Record métier concerné
--
-- Exemples :
-- booking:abc
-- booking_caldav_source:google
-- notification_delivery:xyz
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE source
    ON TABLE error_occurrence
    TYPE option<record>
    COMMENT "Record métier concerné par l'erreur";


-- ----------------------------------------------------------------------------
-- Acteur
--
-- Peut ultérieurement pointer vers account, identity, service_account, etc.
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE actor
    ON TABLE error_occurrence
    TYPE option<record>
    COMMENT "Utilisateur, service ou identité ayant déclenché l'opération";


-- ----------------------------------------------------------------------------
-- Identifiants de corrélation
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE request_id
    ON TABLE error_occurrence
    TYPE option<string>
    ASSERT
        $value = NONE
        OR string::len($value) <= 255
    COMMENT "Identifiant de la requête applicative";


DEFINE FIELD OVERWRITE trace_id
    ON TABLE error_occurrence
    TYPE option<string>
    ASSERT
        $value = NONE
        OR string::len($value) <= 255
    COMMENT "Identifiant de trace distribuée";


DEFINE FIELD OVERWRITE correlation_id
    ON TABLE error_occurrence
    TYPE option<string>
    ASSERT
        $value = NONE
        OR string::len($value) <= 255
    COMMENT "Identifiant commun à plusieurs opérations liées";


-- ----------------------------------------------------------------------------
-- Message technique propre à cette occurrence
--
-- Il peut différer du message canonique de error_definition.
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE technical_message
    ON TABLE error_occurrence
    TYPE option<string>
    ASSERT
        $value = NONE
        OR string::len($value) <= 8000
    COMMENT "Message technique spécifique à cette occurrence";


-- ----------------------------------------------------------------------------
-- Contexte structuré
--
-- Ne jamais y placer :
-- - mot de passe ;
-- - token OAuth ;
-- - clé API ;
-- - cookie de session ;
-- - secret ;
-- - données personnelles non nécessaires.
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE context
    ON TABLE error_occurrence
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Contexte structuré et nettoyé de l'erreur";


-- ----------------------------------------------------------------------------
-- Empreinte pour regrouper les erreurs similaires
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE fingerprint
    ON TABLE error_occurrence
    TYPE option<string>
    ASSERT
        $value = NONE
        OR string::len($value) <= 255
    COMMENT "Empreinte utilisée pour regrouper les occurrences similaires";


-- ----------------------------------------------------------------------------
-- Environnement d'exécution
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE environment
    ON TABLE error_occurrence
    TYPE string
    DEFAULT "production"
    ASSERT $value IN [
        "development",
        "test",
        "staging",
        "production"
    ]
    COMMENT "Environnement dans lequel l'erreur est survenue";


-- ----------------------------------------------------------------------------
-- Niveau de gravité copié au moment de l'occurrence
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE severity
    ON TABLE error_occurrence
    TYPE string
    DEFAULT "error"
    ASSERT $value IN [
        "info",
        "warning",
        "error",
        "critical"
    ]
    COMMENT "Sévérité de cette occurrence";


-- ----------------------------------------------------------------------------
-- Nombre d'occurrences regroupées
--
-- Par défaut une ligne représente une occurrence.
-- Ce champ permet plus tard une stratégie d'agrégation éventuelle.
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE occurrence_count
    ON TABLE error_occurrence
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1
    COMMENT "Nombre d'erreurs représentées par cet enregistrement";


-- ----------------------------------------------------------------------------
-- Horodatage immuable
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE occurred_at
    ON TABLE error_occurrence
    TYPE datetime
    VALUE $before OR time::now()
    COMMENT "Date et heure de l'occurrence";


-- ----------------------------------------------------------------------------
-- Index
-- ----------------------------------------------------------------------------

DEFINE INDEX OVERWRITE error_occurrence_code_index
    ON TABLE error_occurrence
    FIELDS code;


DEFINE INDEX OVERWRITE error_occurrence_module_index
    ON TABLE error_occurrence
    FIELDS source_module;


DEFINE INDEX OVERWRITE error_occurrence_time_index
    ON TABLE error_occurrence
    FIELDS occurred_at;


DEFINE INDEX OVERWRITE error_occurrence_trace_index
    ON TABLE error_occurrence
    FIELDS trace_id;


DEFINE INDEX OVERWRITE error_occurrence_correlation_index
    ON TABLE error_occurrence
    FIELDS correlation_id;


DEFINE INDEX OVERWRITE error_occurrence_fingerprint_index
    ON TABLE error_occurrence
    FIELDS fingerprint;


DEFINE INDEX OVERWRITE error_occurrence_environment_index
    ON TABLE error_occurrence
    FIELDS environment;