-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/execution_timeout.surql
-- Fonction     : fn::validation_execution_timeout
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un timeout d'exécution strictement positif.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être de type duration.
--   2. Le timeout doit être strictement supérieur à zéro.
--   3. Les bornes sont inclusives.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_timeout: duration
-- $max_timeout: duration
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TIMEOUT_NOT_POSITIVE
-- <FIELD>_TIMEOUT_TOO_SHORT
-- <FIELD>_TIMEOUT_TOO_LONG
-- VALIDATION_INVALID_TIMEOUT_RANGE
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- <FIELD>_BLANK_NOT_ALLOWED
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucun lancement de job ou workflow ;
--   - aucun accès réseau ;
--   - aucun effet secondaire.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_execution_timeout(
    $value: option<any>,
    $field: string,
    $min_timeout: duration,
    $max_timeout: duration
) -> duration {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_timeout <= 0s
        OR $max_timeout <= 0s
        OR $min_timeout > $max_timeout
    {
        THROW "VALIDATION_INVALID_TIMEOUT_RANGE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF type::of($value) != "duration" {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $value <= 0s {
        THROW string::concat(
            $clean_field,
            "_TIMEOUT_NOT_POSITIVE"
        );
    };

    IF $value < $min_timeout {
        THROW string::concat(
            $clean_field,
            "_TIMEOUT_TOO_SHORT"
        );
    };

    IF $value > $max_timeout {
        THROW string::concat(
            $clean_field,
            "_TIMEOUT_TOO_LONG"
        );
    };

    RETURN $value;
}
COMMENT "
Valide un timeout d'exécution strictement positif dans une plage inclusive.
"
PERMISSIONS FULL;
