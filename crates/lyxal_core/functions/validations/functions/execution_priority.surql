-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/execution_priority.surql
-- Fonction     : fn::validation_execution_priority
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une priorité entière de job ou de workflow.
--
-- Règles appliquées
-- -----------------
--   1. La valeur doit être strictement de type int.
--   2. La plage est inclusive.
--   3. Une valeur plus élevée peut représenter une priorité supérieure selon le moteur.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_priority: int
-- $max_priority: int
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_PRIORITY_TOO_LOW
-- <FIELD>_PRIORITY_TOO_HIGH
-- VALIDATION_INVALID_PRIORITY_RANGE
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

DEFINE FUNCTION OVERWRITE fn::validation_execution_priority(
    $value: option<any>,
    $field: string,
    $min_priority: int,
    $max_priority: int
) -> int {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_priority > $max_priority {
        THROW "VALIDATION_INVALID_PRIORITY_RANGE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_int($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $value < $min_priority {
        THROW string::concat(
            $clean_field,
            "_PRIORITY_TOO_LOW"
        );
    };

    IF $value > $max_priority {
        THROW string::concat(
            $clean_field,
            "_PRIORITY_TOO_HIGH"
        );
    };

    RETURN $value;
}
COMMENT "
Valide une priorité entière dans une plage inclusive.
"
PERMISSIONS FULL;
