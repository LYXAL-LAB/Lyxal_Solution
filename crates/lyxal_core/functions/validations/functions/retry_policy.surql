-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/retry_policy.surql
-- Fonction     : fn::validation_retry_policy
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une politique de retry pour Scheduler, Webhook Engine ou Workflow.
--
-- Règles appliquées
-- -----------------
--   1. L'objet doit contenir max_attempts, strategy et initial_delay.
--   2. strategy doit être fixed, linear ou exponential.
--   3. max_attempts doit être compris entre 1 et la limite configurée.
--   4. initial_delay et max_delay doivent être des durations positives ou nulles.
--   5. max_delay ne peut pas être inférieur à initial_delay.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $max_attempts_limit: int
-- $max_backoff: duration
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_MISSING_REQUIRED_KEY
-- <FIELD>_INVALID_MAX_ATTEMPTS
-- <FIELD>_INVALID_RETRY_STRATEGY
-- <FIELD>_INVALID_INITIAL_DELAY
-- <FIELD>_INVALID_MAX_DELAY
-- <FIELD>_INVALID_BACKOFF_ORDER
-- VALIDATION_INVALID_RETRY_LIMITS
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

DEFINE FUNCTION OVERWRITE fn::validation_retry_policy(
    $value: option<any>,
    $field: string,
    $max_attempts_limit: int,
    $max_backoff: duration
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $max_attempts_limit < 1 OR $max_backoff < 0s {
        THROW "VALIDATION_INVALID_RETRY_LIMITS";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_object($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $keys = object::keys($value);

    IF !array::all(
        ["max_attempts", "strategy", "initial_delay"],
        |$key| array::contains($keys, $key)
    ) {
        THROW string::concat(
            $clean_field,
            "_MISSING_REQUIRED_KEY"
        );
    };

    IF !type::is_int($value.max_attempts)
        OR $value.max_attempts < 1
        OR $value.max_attempts > $max_attempts_limit
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_MAX_ATTEMPTS"
        );
    };

    IF !type::is_string($value.strategy)
        OR !array::contains(
            ["fixed", "linear", "exponential"],
            string::lowercase(string::trim($value.strategy))
        )
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_RETRY_STRATEGY"
        );
    };

    IF type::of($value.initial_delay) != "duration"
        OR $value.initial_delay < 0s
        OR $value.initial_delay > $max_backoff
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_INITIAL_DELAY"
        );
    };

    LET $max_delay = IF array::contains($keys, "max_delay") {
        $value.max_delay
    } ELSE {
        $value.initial_delay
    };

    IF type::of($max_delay) != "duration"
        OR $max_delay < 0s
        OR $max_delay > $max_backoff
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_MAX_DELAY"
        );
    };

    IF $max_delay < $value.initial_delay {
        THROW string::concat(
            $clean_field,
            "_INVALID_BACKOFF_ORDER"
        );
    };

    RETURN {
        max_attempts: $value.max_attempts,
        strategy: string::lowercase(string::trim($value.strategy)),
        initial_delay: $value.initial_delay,
        max_delay: $max_delay
    };
}
COMMENT "
Valide et normalise une politique de retry pour les moteurs Lyxal.
"
PERMISSIONS FULL;
