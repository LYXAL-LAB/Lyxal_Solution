-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/workflow_delay.surql
-- Fonction     : fn::validation_workflow_delay
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une durée d'attente utilisée par un workflow ou un job différé.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être strictement de type duration.
--   2. Les bornes doivent être cohérentes et positives ou nulles.
--   3. Une durée nulle peut être autorisée ou interdite.
--   4. La plage est inclusive.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_delay: duration
-- $max_delay: duration
-- $allow_zero: bool
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_ZERO_DELAY_NOT_ALLOWED
-- <FIELD>_DELAY_TOO_SHORT
-- <FIELD>_DELAY_TOO_LONG
-- VALIDATION_INVALID_DELAY_RANGE
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

DEFINE FUNCTION OVERWRITE fn::validation_workflow_delay(
    $value: option<any>,
    $field: string,
    $min_delay: duration,
    $max_delay: duration,
    $allow_zero: bool
) -> duration {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_delay < 0s
        OR $max_delay < 0s
        OR $min_delay > $max_delay
    {
        THROW "VALIDATION_INVALID_DELAY_RANGE";
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

    IF !$allow_zero AND $value = 0s {
        THROW string::concat(
            $clean_field,
            "_ZERO_DELAY_NOT_ALLOWED"
        );
    };

    IF $value < $min_delay {
        THROW string::concat(
            $clean_field,
            "_DELAY_TOO_SHORT"
        );
    };

    IF $value > $max_delay {
        THROW string::concat(
            $clean_field,
            "_DELAY_TOO_LONG"
        );
    };

    RETURN $value;
}
COMMENT "
Valide une durée d'attente de workflow dans une plage inclusive.
"
PERMISSIONS FULL;
